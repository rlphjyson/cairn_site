import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/chat_text.dart';
import '../../../core/presentation/navigation/chat_navigation_cubit.dart';
import '../../../core/presentation/widgets/chat_empty.dart';
import '../../../core/presentation/widgets/chat_header.dart';
import '../../../core/presentation/widgets/icon_action.dart';
import '../../../core/presentation/widgets/screen_title.dart';
import '../../../core/presentation/widgets/search_field.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../bloc/conversations_cubit.dart';
import '../bloc/conversations_state.dart';
import '../widgets/conversation_skeleton.dart';
import '../widgets/conversation_tile.dart';

/// The Chats tab: search, pinned and recent conversations, and the archive.
class ConversationsView extends StatelessWidget {
  /// Creates the view.
  const ConversationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ConversationsCubit cubit = context.read<ConversationsCubit>();
    final ChatNavigationCubit nav = context.read<ChatNavigationCubit>();
    return BlocBuilder<ConversationsCubit, ConversationsState>(
      builder: (BuildContext context, ConversationsState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (state.showArchived)
            ChatHeader(
              title: 'Archived',
              backLabel: 'Back to chats',
              onBack: () => cubit.showArchive(show: false),
            )
          else
            ScreenTitle(
              'Chats',
              actions: <Widget>[
                IconAction(
                  icon: Icons.edit_outlined,
                  label: 'New chat',
                  onPressed: nav.openNewChat,
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchField(
              key: ValueKey<bool>(state.showArchived),
              placeholder: state.showArchived
                  ? 'Search archived chats'
                  : 'Search chats',
              text: state.query,
              onChanged: cubit.search,
            ),
          ),
          Expanded(child: _Body(state: state)),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final ConversationsState state;

  @override
  Widget build(BuildContext context) {
    final ConversationsCubit cubit = context.read<ConversationsCubit>();
    final ChatNavigationCubit nav = context.read<ChatNavigationCubit>();

    switch (state.status) {
      case ConversationsStatus.loading:
        return const SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: ConversationSkeleton(),
        );
      case ConversationsStatus.failed:
        return ChatEmpty(
          icon: Icons.cloud_off_outlined,
          title: 'Could not load your chats',
          description: 'Check your connection and try again.',
          actions: <Widget>[
            CairnButton(onPressed: cubit.retry, child: const Text('Try again')),
          ],
        );
      case ConversationsStatus.ready:
        break;
    }

    if (state.noResults) {
      return ChatEmpty(
        icon: Icons.search_off,
        title: 'No chats found',
        description:
            'Nothing matches "${state.query.trim()}". Try a name or a word '
            'from a message.',
        actions: <Widget>[
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: () => cubit.search(''),
            child: const Text('Clear search'),
          ),
        ],
      );
    }

    final bool showArchiveRow =
        !state.showArchived &&
        state.query.trim().isEmpty &&
        state.inbox.archived.isNotEmpty;

    if (state.isEmpty) {
      final Widget empty = state.showArchived
          ? const ChatEmpty(
              icon: Icons.archive_outlined,
              title: 'Nothing archived',
              description: 'Archived chats stay quiet and out of the way.',
            )
          : ChatEmpty(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              description: 'Start a chat with someone from your contacts.',
              actions: <Widget>[
                CairnButton(
                  onPressed: nav.openNewChat,
                  child: const Text('New chat'),
                ),
              ],
            );
      return Column(
        children: <Widget>[
          if (showArchiveRow) _ArchiveRow(count: state.inbox.archived.length),
          Expanded(child: empty),
        ],
      );
    }

    final String? openId = context.select(
      (ChatNavigationCubit n) => n.state.openThreadId,
    );
    Widget tile(Conversation c) => ConversationTile(
      key: ValueKey<String>(c.id),
      conversation: c,
      selected: c.id == openId,
      onOpen: () => nav.openThread(c.id),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: <Widget>[
        if (showArchiveRow) _ArchiveRow(count: state.inbox.archived.length),
        if (state.visiblePinned.isNotEmpty) ...<Widget>[
          const _SectionLabel('Pinned', icon: Icons.push_pin_outlined),
          CairnList(children: <Widget>[...state.visiblePinned.map(tile)]),
        ],
        if (state.visiblePinned.isNotEmpty &&
            state.visibleOthers.isNotEmpty) ...<Widget>[
          const _SectionLabel('All chats'),
        ],
        if (state.visibleOthers.isNotEmpty)
          CairnList(children: <Widget>[...state.visibleOthers.map(tile)]),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(
          spacing: 6,
          children: <Widget>[
            if (icon != null)
              Icon(icon, size: 14, color: theme.mutedForeground),
            Text(
              text,
              style: chatText(
                theme,
                theme.textStyle(CairnTypography.xs),
                color: theme.mutedForeground,
                weight: CairnTypography.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveRow extends StatelessWidget {
  const _ArchiveRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CairnListItem(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.muted,
            ),
            child: Icon(Icons.archive_outlined, color: theme.mutedForeground),
          ),
          title: const Text('Archived'),
          subtitle: Text(count == 1 ? '1 chat' : '$count chats'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              context.read<ConversationsCubit>().showArchive(show: true),
        ),
        const CairnSeparator(),
      ],
    );
  }
}
