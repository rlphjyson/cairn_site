import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/constants/chat_limits.dart';
import '../../core/presentation/navigation/chat_navigation_cubit.dart';
import '../../core/presentation/widgets/chat_empty.dart';
import '../contacts/views/contacts_view.dart';
import '../conversations/bloc/conversations_cubit.dart';
import '../conversations/views/conversations_view.dart';
import '../info/views/info_view.dart';
import '../new_chat/views/new_chat_view.dart';
import '../profile/views/profile_view.dart';
import '../thread/views/thread_view.dart';

/// The chat's frame: tabs above a bottom dock on phones; from 700 px wide, the
/// tabs and the conversation list on the left with the open thread (or info,
/// or new chat screen) on the right.
class ChatShell extends StatelessWidget {
  /// Creates the shell.
  const ChatShell({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints box) =>
        box.maxWidth >= ChatLimits.twoPaneBreakpoint
        ? const _TwoPane()
        : const _Phone(),
  );
}

class _Phone extends StatelessWidget {
  const _Phone();

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      // Clears the phone's notch.
      const SizedBox(height: 22),
      Expanded(
        child: BlocBuilder<ChatNavigationCubit, ChatNavigationState>(
          builder: (BuildContext context, ChatNavigationState nav) {
            final ChatRoute? top = nav.top;
            return Column(
              children: <Widget>[
                Expanded(
                  child: AnimatedSwitcher(
                    duration: CairnMotion.d150,
                    child: KeyedSubtree(
                      key: ValueKey<Object>(top ?? nav.tab),
                      child: top != null
                          ? _RouteView(route: top, showBack: true)
                          : _TabView(tab: nav.tab),
                    ),
                  ),
                ),
                if (top == null) const _ChatDock(),
              ],
            );
          },
        ),
      ),
    ],
  );
}

class _TwoPane extends StatelessWidget {
  const _TwoPane();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return BlocBuilder<ChatNavigationCubit, ChatNavigationState>(
      builder: (BuildContext context, ChatNavigationState nav) {
        final ChatRoute? top = nav.top;
        return Row(
          children: <Widget>[
            SizedBox(
              width: ChatLimits.listPaneWidth,
              child: Column(
                children: <Widget>[
                  Expanded(child: _TabView(tab: nav.tab)),
                  const _ChatDock(),
                ],
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: theme.border),
            Expanded(
              child: top == null
                  ? const ChatEmpty(
                      icon: Icons.forum_outlined,
                      title: 'Select a conversation',
                      description:
                          'Choose a chat on the left, or start a new one.',
                    )
                  : KeyedSubtree(
                      key: ValueKey<Object>(top),
                      child: _RouteView(route: top, showBack: false),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TabView extends StatelessWidget {
  const _TabView({required this.tab});

  final ChatTab tab;

  @override
  Widget build(BuildContext context) => switch (tab) {
    ChatTab.chats => const ConversationsView(),
    ChatTab.contacts => const ContactsView(),
    ChatTab.profile => const ProfileView(),
  };
}

class _RouteView extends StatelessWidget {
  const _RouteView({required this.route, required this.showBack});

  final ChatRoute route;

  /// Whether a thread shows its back button (phones only).
  final bool showBack;

  @override
  Widget build(BuildContext context) => switch (route) {
    ThreadRoute(:final String conversationId) => ThreadView(
      conversationId: conversationId,
      showBack: showBack,
    ),
    InfoRoute(:final String conversationId) => InfoView(
      conversationId: conversationId,
    ),
    NewChatRoute(:final bool group) => NewChatView(group: group),
  };
}

class _ChatDock extends StatelessWidget {
  const _ChatDock();

  @override
  Widget build(BuildContext context) {
    final int unread = context.select(
      (ConversationsCubit c) => c.state.inbox.unreadTotal,
    );
    return BlocBuilder<ChatNavigationCubit, ChatNavigationState>(
      builder: (BuildContext context, ChatNavigationState nav) => CairnDock(
        index: nav.tab.index,
        onChanged: (int i) =>
            context.read<ChatNavigationCubit>().selectTab(ChatTab.values[i]),
        items: <CairnDockItem>[
          CairnDockItem(
            icon: const Icon(Icons.chat_bubble_outline, size: 20),
            label: 'Chats',
            badge: unread == 0
                ? null
                : Semantics(
                    label: '$unread unread',
                    // Nudged off the icon so the glyph stays readable.
                    child: Transform.translate(
                      offset: const Offset(14, -4),
                      child: CairnBadge(
                        variant: CairnBadgeVariant.destructive,
                        label: Text(unread > 99 ? '99+' : '$unread'),
                      ),
                    ),
                  ),
          ),
          const CairnDockItem(
            icon: Icon(Icons.people_outline, size: 20),
            label: 'Contacts',
          ),
          const CairnDockItem(
            icon: Icon(Icons.person_outline, size: 20),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
