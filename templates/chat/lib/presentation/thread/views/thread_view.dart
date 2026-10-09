import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/chat_limits.dart';
import '../../../common/utils/dates.dart';
import '../../../core/infrastructure/chat_session.dart';
import '../../../core/presentation/chat_text.dart';
import '../../../core/presentation/navigation/chat_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/chat_avatar.dart';
import '../../../core/presentation/widgets/chat_empty.dart';
import '../../../domain/contacts/models/contact.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/messages/models/message.dart';
import '../../../domain/messages/models/thread_item.dart';
import '../../contacts/bloc/contacts_cubit.dart';
import '../../conversations/bloc/conversations_cubit.dart';
import '../bloc/thread_cubit.dart';
import '../bloc/thread_state.dart';
import '../view_models/thread_view_model.dart';
import '../widgets/attach_sheet.dart';
import '../widgets/message_actions_sheet.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_composer.dart';
import '../widgets/scroll_to_latest_button.dart';
import '../widgets/thread_header.dart';
import '../widgets/thread_skeleton.dart';
import '../widgets/typing_indicator.dart';

/// One open conversation: header, messages, composer.
///
/// The screen owns a [ThreadCubit] through its view model, so the cubit lives
/// exactly as long as the thread is on screen.
class ThreadView extends StatelessWidget {
  /// Creates the view for [conversationId].
  ///
  /// [showBack] adds a back button to the header (phones); in the two-pane
  /// layout the list is already on screen and there is nothing to go back to.
  const ThreadView({
    super.key,
    required this.conversationId,
    required this.showBack,
  });

  /// The conversation to show.
  final String conversationId;

  /// Whether to show the back button.
  final bool showBack;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<ThreadViewModel>(
    onCreate: (BuildContext context, ThreadViewModel vm) =>
        vm.cubit.load(conversationId),
    builder: (BuildContext context, ThreadViewModel vm) =>
        BlocProvider<ThreadCubit>.value(
          value: vm.cubit,
          child: _ThreadScaffold(
            conversationId: conversationId,
            showBack: showBack,
          ),
        ),
  );
}

class _ThreadScaffold extends StatefulWidget {
  const _ThreadScaffold({required this.conversationId, required this.showBack});

  final String conversationId;
  final bool showBack;

  @override
  State<_ThreadScaffold> createState() => _ThreadScaffoldState();
}

class _ThreadScaffoldState extends State<_ThreadScaffold> {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<bool> _showLatest = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _showLatest.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final ScrollPosition position = _scroll.position;
    // The list is reversed: pixels is the distance from the newest message and
    // extentAfter is how much older history is above the viewport.
    context.read<ThreadCubit>().setAtBottom(value: position.pixels <= 24);
    _showLatest.value = position.pixels > ChatLimits.scrollButtonDistance;
    if (position.extentAfter < 400) {
      context.read<ThreadCubit>().loadOlder();
    }
  }

  /// Asks for older history when the loaded messages do not fill the screen.
  void _fillViewport() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      if (_scroll.position.extentAfter < 400) {
        context.read<ThreadCubit>().loadOlder();
      }
    });
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        0,
        duration: CairnMotion.d200,
        curve: CairnMotion.easeOut,
      );
    });
  }

  String _nameOf(String userId, ChatSession session, ContactsState contacts) {
    if (userId == session.userId) return 'You';
    return contacts.byId(userId)?.name ?? 'Someone';
  }

  Future<void> _openActions(Message message, ChatSession session) async {
    final ThreadCubit cubit = context.read<ThreadCubit>();
    final String author = _nameOf(
      message.senderId,
      session,
      context.read<ContactsCubit>().state,
    );
    final MessageChoice? choice = await showMessageActions(
      context,
      message: message,
      userId: session.userId,
    );
    if (choice == null || !mounted) return;
    final String? emoji = choice.emoji;
    if (emoji != null) {
      await cubit.react(message, emoji);
      return;
    }
    switch (choice.action!) {
      case MessageAction.reply:
        cubit.startReply(message);
      case MessageAction.copy:
        await Clipboard.setData(ClipboardData(text: message.text));
        if (!mounted) return;
        CairnToast.show(
          context,
          const CairnToast(
            title: 'Copied',
            description: 'The message text is on your clipboard.',
            variant: CairnToastVariant.success,
          ),
        );
      case MessageAction.delete:
        await cubit.deleteForMe(message);
        if (!mounted) return;
        CairnToast.show(
          context,
          CairnToast(
            title: 'Message deleted',
            description: 'Removed for you. $author still has it.',
          ),
        );
    }
  }

  Future<void> _attach() async {
    final AttachOption? option = await showAttachSheet(context);
    if (option == null || !mounted) return;
    CairnToast.show(
      context,
      CairnToast(
        title: '${option.label} is a demo',
        description:
            'Connect your own picker to send this. See the docs, "Attachments '
            'upload".',
        variant: CairnToastVariant.info,
      ),
    );
  }

  void _openLink(String url) => CairnToast.show(
    context,
    CairnToast(title: 'Link tapped', description: url),
  );

  @override
  Widget build(BuildContext context) {
    final ChatSession session = ChatSessionScope.of(context);
    final ChatNavigationCubit nav = context.read<ChatNavigationCubit>();
    final ContactsState contacts = context.watch<ContactsCubit>().state;
    final Conversation? listed = context.select(
      (ConversationsCubit c) => c.state.find(widget.conversationId),
    );

    return BlocConsumer<ThreadCubit, ThreadState>(
      listenWhen: (ThreadState a, ThreadState b) =>
          a.scrollTick != b.scrollTick || a.items.length != b.items.length,
      listener: (BuildContext context, ThreadState state) => _fillViewport(),
      builder: (BuildContext context, ThreadState state) {
        final Conversation? conversation = listed ?? state.conversation;
        final Contact? peer = conversation?.peerId == null
            ? null
            : contacts.byId(conversation!.peerId!);
        final String? typingName = state.typingUserIds.isEmpty
            ? null
            : contacts.byId(state.typingUserIds.first)?.name.split(' ').first ??
                  'Someone';
        final Message? replyTo = state.replyingTo;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ThreadHeader(
              title: 'Chat',
              conversation: conversation,
              peer: peer,
              typingName: typingName,
              now: session.now(),
              onBack: widget.showBack ? nav.back : null,
              onInfo: () => nav.openInfo(widget.conversationId),
            ),
            Expanded(
              child: switch (state.status) {
                ThreadStatus.loading => const ThreadSkeleton(),
                ThreadStatus.failed => ChatEmpty(
                  icon: Icons.cloud_off_outlined,
                  title: 'Could not open this chat',
                  description: 'Check your connection and try again.',
                  actions: <Widget>[
                    CairnButton(
                      onPressed: () => context.read<ThreadCubit>().load(
                        widget.conversationId,
                      ),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
                ThreadStatus.ready =>
                  state.items.isEmpty
                      ? const ChatEmpty(
                          icon: Icons.waving_hand_outlined,
                          title: 'Say hello',
                          description:
                              'No messages yet. Send the first one below.',
                        )
                      : _MessageList(
                          state: state,
                          controller: _scroll,
                          showLatest: _showLatest,
                          session: session,
                          contacts: contacts,
                          isGroup: conversation?.isGroup ?? false,
                          nameOf: (String id) => _nameOf(id, session, contacts),
                          onActions: (Message m) => _openActions(m, session),
                          onLink: _openLink,
                          onScrollToLatest: () {
                            context.read<ThreadCubit>().requestScrollToLatest();
                            _scrollToLatest();
                          },
                        ),
              },
            ),
            if (state.status == ThreadStatus.ready)
              MessageComposer(
                replyTo: replyTo,
                replyAuthor: replyTo == null
                    ? null
                    : _nameOf(replyTo.senderId, session, contacts),
                onCancelReply: context.read<ThreadCubit>().cancelReply,
                onAttach: _attach,
                onSend: (String text) {
                  context.read<ThreadCubit>().send(text);
                  _scrollToLatest();
                },
              ),
          ],
        );
      },
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.state,
    required this.controller,
    required this.showLatest,
    required this.session,
    required this.contacts,
    required this.isGroup,
    required this.nameOf,
    required this.onActions,
    required this.onLink,
    required this.onScrollToLatest,
  });

  final ThreadState state;
  final ScrollController controller;
  final ValueNotifier<bool> showLatest;
  final ChatSession session;
  final ContactsState contacts;
  final bool isGroup;
  final String Function(String userId) nameOf;
  final void Function(Message message) onActions;
  final ValueChanged<String> onLink;
  final VoidCallback onScrollToLatest;

  @override
  Widget build(BuildContext context) {
    final List<ThreadItem> items = state.items;
    final bool typing = state.typingUserIds.isNotEmpty;
    final int lead = typing ? 1 : 0;
    final Message? incoming = state.lastIncoming;

    // Keys let the list keep its place when older pages are prepended.
    final Map<String, int> indexOfKey = <String, int>{
      for (int j = 0; j < items.length; j++)
        items[items.length - 1 - j].key: j + lead,
    };

    return Stack(
      children: <Widget>[
        // Announces each new incoming message to screen readers.
        if (incoming != null)
          Semantics(
            liveRegion: true,
            label:
                'New message from ${nameOf(incoming.senderId)}: ${incoming.preview}',
            child: const SizedBox(width: 1, height: 1),
          ),
        ListView.builder(
          controller: controller,
          reverse: true,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          itemCount: items.length + lead + 1,
          findChildIndexCallback: (Key key) =>
              key is ValueKey<String> ? indexOfKey[key.value] : null,
          itemBuilder: (BuildContext context, int index) {
            if (typing && index == 0) {
              final Contact? who = contacts.byId(state.typingUserIds.first);
              return TypingIndicator(
                name: who?.name ?? 'Someone',
                avatar: isGroup
                    ? ChatAvatar(
                        name: who?.name ?? 'Someone',
                        avatar: who?.avatar,
                        size: CairnAvatarSize.sm,
                      )
                    : null,
              );
            }
            final int j = index - lead;
            if (j == items.length) {
              return _HistoryEdge(
                loading: state.loadingOlder,
                hasMore: state.hasMore,
              );
            }
            final ThreadItem item = items[items.length - 1 - j];
            switch (item) {
              case DateSeparator(:final DateTime day):
                return Padding(
                  key: ValueKey<String>(item.key),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Semantics(
                      header: true,
                      child: CairnBadge(
                        variant: CairnBadgeVariant.secondary,
                        label: Text(formatDayLabel(day, session.now())),
                      ),
                    ),
                  ),
                );
              case ThreadMessage(:final Message message):
                final bool mine = message.senderId == session.userId;
                return MessageBubble(
                  key: ValueKey<String>(item.key),
                  item: item,
                  mine: mine,
                  isGroup: isGroup,
                  sender: mine ? null : contacts.byId(message.senderId),
                  userId: session.userId,
                  nameOf: nameOf,
                  onActions: () => onActions(message),
                  onReact: (String emoji) =>
                      context.read<ThreadCubit>().react(message, emoji),
                  onLink: onLink,
                );
            }
          },
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: ValueListenableBuilder<bool>(
            valueListenable: showLatest,
            builder: (BuildContext context, bool visible, Widget? child) =>
                visible || state.unseen > 0 ? child! : const SizedBox.shrink(),
            child: ScrollToLatestButton(
              unseen: state.unseen,
              onPressed: onScrollToLatest,
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryEdge extends StatelessWidget {
  const _HistoryEdge({required this.loading, required this.hasMore});

  final bool loading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: CairnSpinner(semanticLabel: 'Loading older messages'),
        ),
      );
    }
    if (hasMore) return const SizedBox(height: 24);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          'Start of the conversation',
          style: chatText(
            theme,
            theme.textStyle(CairnTypography.xs),
            color: theme.mutedForeground,
          ),
        ),
      ),
    );
  }
}
