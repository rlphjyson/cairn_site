import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/infrastructure/chat_session.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/conversations/use_cases/get_conversation.dart';
import '../../../domain/messages/models/attachment.dart';
import '../../../domain/messages/models/chat_event.dart';
import '../../../domain/messages/models/message.dart';
import '../../../domain/messages/models/message_page.dart';
import '../../../domain/messages/models/message_status.dart';
import '../../../domain/messages/models/reply_preview.dart';
import '../../../domain/messages/use_cases/delete_message.dart';
import '../../../domain/messages/use_cases/get_messages.dart';
import '../../../domain/messages/use_cases/group_messages.dart';
import '../../../domain/messages/use_cases/mark_read.dart';
import '../../../domain/messages/use_cases/react_to_message.dart';
import '../../../domain/messages/use_cases/send_message.dart';
import '../../../domain/messages/use_cases/watch_conversation.dart';
import 'thread_state.dart';

/// State for one open conversation.
///
/// A screen cubit, created and closed by `ThreadViewModel`: it loads the
/// newest page, follows the conversation's live events (new messages, read
/// receipts, typing), pages in older history, and handles sending, replying,
/// reacting and deleting, applying each change at once and confirming it with
/// the backend.
class ThreadCubit extends Cubit<ThreadState> {
  /// Creates the cubit.
  ThreadCubit(
    this._session,
    this._getConversation,
    this._getMessages,
    this._send,
    this._markRead,
    this._group,
    this._react,
    this._delete,
    this._watch,
  ) : super(const ThreadState());

  final ChatSession _session;
  final GetConversation _getConversation;
  final GetMessages _getMessages;
  final SendMessage _send;
  final MarkRead _markRead;
  final GroupMessages _group;
  final ReactToMessage _react;
  final DeleteMessage _delete;
  final WatchConversation _watch;

  String _conversationId = '';
  StreamSubscription<ChatEvent>? _subscription;
  final List<ChatEvent> _early = <ChatEvent>[];
  int _localCount = 0;
  bool _atBottom = true;

  /// Opens [conversationId]: loads the newest page and starts following live
  /// events.
  Future<void> load(String conversationId) async {
    _conversationId = conversationId;
    _atBottom = true;
    emit(const ThreadState());
    // Subscribe before loading so nothing that happens meanwhile is lost.
    _subscription = _watch(conversationId).listen(_onEvent);
    try {
      final Conversation? conversation = await _getConversation(conversationId);
      final MessagePage page = await _getMessages(conversationId);
      if (isClosed) return;
      emit(
        _withMessages(
          state.copyWith(
            status: ThreadStatus.ready,
            conversation: conversation,
            hasMore: page.hasMore,
          ),
          page.messages,
        ),
      );
      final List<ChatEvent> early = List<ChatEvent>.of(_early);
      _early.clear();
      early.forEach(_onEvent);
      unawaited(_markConversationRead());
    } on Object {
      if (isClosed) return;
      emit(state.copyWith(status: ThreadStatus.failed));
    }
  }

  /// Loads the page of history before the oldest message shown.
  Future<void> loadOlder() async {
    if (state.status != ThreadStatus.ready ||
        !state.hasMore ||
        state.loadingOlder) {
      return;
    }
    final Iterable<Message> real = state.messages.where(
      (Message m) => !_isLocal(m),
    );
    if (real.isEmpty) return;
    emit(state.copyWith(loadingOlder: true));
    try {
      final MessagePage page = await _getMessages(
        _conversationId,
        beforeId: real.first.id,
      );
      if (isClosed) return;
      final Set<String> known = state.messages.map((Message m) => m.id).toSet();
      emit(
        _withMessages(
          state.copyWith(hasMore: page.hasMore, loadingOlder: false),
          <Message>[
            ...page.messages.where((Message m) => !known.contains(m.id)),
            ...state.messages,
          ],
        ),
      );
    } on Object {
      if (!isClosed) emit(state.copyWith(loadingOlder: false));
    }
  }

  /// Sends [text] (and optionally an [attachment]) to the conversation.
  ///
  /// The message appears at once with the "sending" tick and is replaced by the
  /// stored one when the backend answers.
  Future<void> send(String text, {Attachment? attachment}) async {
    if (state.status != ThreadStatus.ready ||
        !SendMessage.canSend(text, attachment: attachment)) {
      return;
    }
    final Message? quoted = state.replyingTo;
    final ReplyPreview? reply = quoted == null
        ? null
        : ReplyPreview(
            messageId: quoted.id,
            senderId: quoted.senderId,
            text: quoted.preview,
          );
    final String localId = 'local-${_localCount++}';
    final Message local = Message(
      id: localId,
      conversationId: _conversationId,
      senderId: _session.userId,
      sentAt: _session.now(),
      text: text.trim(),
      status: MessageStatus.sending,
      replyTo: reply,
      attachment: attachment,
    );
    _atBottom = true;
    emit(
      _withMessages(
        state.copyWith(
          clearReply: true,
          unseen: 0,
          scrollTick: state.scrollTick + 1,
        ),
        <Message>[...state.messages, local],
      ),
    );
    try {
      final Message sent = await _send(
        _conversationId,
        text: text,
        replyTo: reply,
        attachment: attachment,
      );
      if (isClosed) return;
      emit(_withMessages(state, _swapLocal(localId, sent)));
    } on Object {
      if (isClosed) return;
      emit(
        _withMessages(state, <Message>[
          for (final Message m in state.messages)
            m.id == localId ? m.copyWith(status: MessageStatus.failed) : m,
        ]),
      );
    }
  }

  /// Toggles your [emoji] reaction on [message].
  Future<void> react(Message message, String emoji) async {
    if (_isLocal(message)) return;
    final Message optimistic = ReactToMessage.apply(
      message,
      emoji,
      _session.userId,
    );
    emit(_withMessages(state, _replace(optimistic)));
    try {
      final Message stored = await _react(_conversationId, message.id, emoji);
      if (!isClosed) emit(_withMessages(state, _replace(stored)));
    } on Object {
      if (!isClosed) emit(_withMessages(state, _replace(message)));
    }
  }

  /// Removes [message] from your view.
  Future<void> deleteForMe(Message message) async {
    final List<Message> before = state.messages;
    final bool replying = state.replyingTo?.id == message.id;
    emit(
      _withMessages(
        replying ? state.copyWith(clearReply: true) : state,
        before.where((Message m) => m.id != message.id).toList(),
      ),
    );
    if (_isLocal(message)) return;
    try {
      await _delete(_conversationId, message.id);
    } on Object {
      if (!isClosed) emit(_withMessages(state, before));
    }
  }

  /// Starts answering [message].
  void startReply(Message message) => emit(state.copyWith(replyingTo: message));

  /// Stops answering.
  void cancelReply() => emit(state.copyWith(clearReply: true));

  /// The view reports whether the newest message is on screen.
  void setAtBottom({required bool value}) {
    if (value == _atBottom) return;
    _atBottom = value;
    if (value && state.unseen > 0) {
      emit(state.copyWith(unseen: 0));
      unawaited(_markConversationRead());
    }
  }

  /// Asks the view to scroll to the newest message.
  void requestScrollToLatest() {
    _atBottom = true;
    emit(state.copyWith(unseen: 0, scrollTick: state.scrollTick + 1));
    unawaited(_markConversationRead());
  }

  // Live events -------------------------------------------------------------

  void _onEvent(ChatEvent event) {
    if (state.status != ThreadStatus.ready) {
      _early.add(event);
      return;
    }
    switch (event) {
      case MessageArrived(:final Message message):
        _onArrived(message);
      case MessageUpdated(:final Message message):
        emit(_withMessages(state, _replace(message)));
      case MessageRemoved(:final String messageId):
        emit(
          _withMessages(
            state,
            state.messages.where((Message m) => m.id != messageId).toList(),
          ),
        );
      case TypingChanged(:final String userId, :final bool typing):
        if (userId == _session.userId) return;
        final List<String> others = state.typingUserIds
            .where((String id) => id != userId)
            .toList();
        emit(
          state.copyWith(
            typingUserIds: typing ? <String>[...others, userId] : others,
          ),
        );
      case PresenceChanged() || ConversationChanged():
        break;
    }
  }

  void _onArrived(Message message) {
    final bool known = state.messages.any((Message m) => m.id == message.id);
    if (known) {
      emit(_withMessages(state, _replace(message)));
      return;
    }
    final bool mine = message.senderId == _session.userId;
    // Your own message echoed back while it is still being sent: the send
    // call will swap it in.
    if (mine && state.messages.any(_isLocal)) return;
    final List<String> typing = state.typingUserIds
        .where((String id) => id != message.senderId)
        .toList();
    emit(
      _withMessages(
        state.copyWith(
          typingUserIds: typing,
          lastIncoming: mine ? null : message,
          unseen: mine || _atBottom ? state.unseen : state.unseen + 1,
        ),
        <Message>[...state.messages, message],
      ),
    );
    if (!mine && _atBottom) unawaited(_markConversationRead());
  }

  // Helpers -----------------------------------------------------------------

  bool _isLocal(Message m) => m.id.startsWith('local-');

  ThreadState _withMessages(ThreadState base, List<Message> messages) =>
      base.copyWith(messages: messages, items: _group(messages));

  List<Message> _replace(Message updated) => <Message>[
    for (final Message m in state.messages) m.id == updated.id ? updated : m,
  ];

  List<Message> _swapLocal(String localId, Message sent) {
    final bool echoed = state.messages.any((Message m) => m.id == sent.id);
    return <Message>[
      for (final Message m in state.messages)
        if (m.id != localId) m else if (!echoed) sent,
    ];
  }

  Future<void> _markConversationRead() async {
    try {
      await _markRead(_conversationId);
    } on Object {
      // A missed read receipt is not worth interrupting the thread for.
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
