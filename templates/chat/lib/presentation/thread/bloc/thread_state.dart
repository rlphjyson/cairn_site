import 'package:equatable/equatable.dart';

import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/messages/models/message.dart';
import '../../../domain/messages/models/thread_item.dart';

/// Where loading a thread stands.
enum ThreadStatus {
  /// Loading the first page.
  loading,

  /// Loaded.
  ready,

  /// The first page failed to load.
  failed,
}

/// State of one open conversation.
class ThreadState extends Equatable {
  /// Creates a state.
  const ThreadState({
    this.status = ThreadStatus.loading,
    this.conversation,
    this.messages = const <Message>[],
    this.items = const <ThreadItem>[],
    this.hasMore = false,
    this.loadingOlder = false,
    this.replyingTo,
    this.typingUserIds = const <String>[],
    this.unseen = 0,
    this.scrollTick = 0,
    this.lastIncoming,
  });

  /// Loading, ready or failed.
  final ThreadStatus status;

  /// The conversation, for the header.
  final Conversation? conversation;

  /// Every loaded message, oldest first (including ones still sending).
  final List<Message> messages;

  /// [messages] grouped into runs with date separators.
  final List<ThreadItem> items;

  /// Whether older history can still be loaded.
  final bool hasMore;

  /// Whether an older page is loading right now.
  final bool loadingOlder;

  /// The message being answered, shown above the composer.
  final Message? replyingTo;

  /// Who is typing right now (never you).
  final List<String> typingUserIds;

  /// Messages that arrived while the thread was scrolled away from the bottom.
  final int unseen;

  /// Increases whenever the view should scroll to the newest message.
  final int scrollTick;

  /// The latest message from someone else, announced to screen readers.
  final Message? lastIncoming;

  /// A copy with some fields replaced.
  ThreadState copyWith({
    ThreadStatus? status,
    Conversation? conversation,
    List<Message>? messages,
    List<ThreadItem>? items,
    bool? hasMore,
    bool? loadingOlder,
    Message? replyingTo,
    bool clearReply = false,
    List<String>? typingUserIds,
    int? unseen,
    int? scrollTick,
    Message? lastIncoming,
  }) => ThreadState(
    status: status ?? this.status,
    conversation: conversation ?? this.conversation,
    messages: messages ?? this.messages,
    items: items ?? this.items,
    hasMore: hasMore ?? this.hasMore,
    loadingOlder: loadingOlder ?? this.loadingOlder,
    replyingTo: clearReply ? null : (replyingTo ?? this.replyingTo),
    typingUserIds: typingUserIds ?? this.typingUserIds,
    unseen: unseen ?? this.unseen,
    scrollTick: scrollTick ?? this.scrollTick,
    lastIncoming: lastIncoming ?? this.lastIncoming,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    conversation,
    messages,
    items,
    hasMore,
    loadingOlder,
    replyingTo,
    typingUserIds,
    unseen,
    scrollTick,
    lastIncoming,
  ];
}
