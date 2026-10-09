import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/infrastructure/chat_session.dart';
import '../../../core/presentation/chat_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/chat_avatar.dart';
import '../../../core/presentation/widgets/icon_action.dart';
import '../../../domain/contacts/models/presence.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/conversations/use_cases/format_relative_time.dart';
import '../../../domain/messages/models/message.dart';
import '../../contacts/bloc/contacts_cubit.dart';
import 'conversation_actions.dart';

/// One row of the conversation list: avatar with presence, name, a preview of
/// the last message, the time, an unread badge and a muted icon.
///
/// Long-press opens a menu at the finger; the overflow button opens the same
/// menu for people who do not long-press. Screen readers get the same actions
/// from the row's custom actions.
class ConversationTile extends StatefulWidget {
  /// Creates a row.
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onOpen,
    this.selected = false,
  });

  /// The conversation to show.
  final Conversation conversation;

  /// Called when the row is tapped.
  final VoidCallback onOpen;

  /// Whether this conversation is the open one (two-pane layout).
  final bool selected;

  @override
  State<ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile> {
  final CairnOverlayController _menu = CairnOverlayController();

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  String _preview(Conversation c, ChatSession session, ContactsState contacts) {
    final Message? last = c.lastMessage;
    if (last == null) return 'No messages yet';
    if (last.senderId == session.userId) return 'You: ${last.preview}';
    if (c.isGroup) {
      final String name =
          contacts.byId(last.senderId)?.name.split(' ').first ?? 'Someone';
      return '$name: ${last.preview}';
    }
    return last.preview;
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Conversation c = widget.conversation;
    final ChatSession session = ChatSessionScope.of(context);
    final ContactsState contacts = context.watch<ContactsCubit>().state;
    final Presence? presence = c.peerId == null
        ? null
        : contacts.byId(c.peerId!)?.presence;
    final String time = c.lastMessage == null
        ? ''
        : const FormatRelativeTime()(c.lastMessage!.sentAt, session.now());
    final String preview = _preview(c, session, contacts);
    final List<Widget> items = conversationMenuItems(context, c);

    final String summary = <String>[
      c.title,
      if (c.unread > 0)
        '${c.unread} unread'
      else if (c.markedUnread)
        'marked unread',
      if (c.pinned) 'pinned',
      if (c.muted) 'muted',
      preview,
      if (time.isNotEmpty) time,
    ].join(', ');

    return CairnContextMenu(
      items: items,
      child: ColoredBox(
        // The highlight spans the overflow button too.
        color: widget.selected ? theme.accent : const Color(0x00000000),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Semantics(
                container: true,
                button: true,
                label: summary,
                onTap: widget.onOpen,
                excludeSemantics: true,
                customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
                  const CustomSemanticsAction(label: 'More actions'):
                      _menu.open,
                },
                child: CairnListItem(
                  onTap: widget.onOpen,
                  leading: ChatAvatar(
                    name: c.title,
                    avatar: c.avatar,
                    presence: presence,
                    group: c.isGroup,
                  ),
                  title: Text(
                    c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: c.hasUnread
                        ? const TextStyle(fontWeight: CairnTypography.semibold)
                        : null,
                  ),
                  subtitle: DefaultTextStyle.merge(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: c.hasUnread
                        ? TextStyle(color: theme.foreground)
                        : null,
                    child: Text(preview),
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 4,
                    children: <Widget>[
                      Text(
                        time,
                        style: chatText(
                          theme,
                          theme.textStyle(CairnTypography.xs),
                          color: c.hasUnread
                              ? theme.foreground
                              : theme.mutedForeground,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: <Widget>[
                          if (c.muted)
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 14,
                              color: theme.mutedForeground,
                            ),
                          if (c.unread > 0)
                            CairnBadge(
                              variant: c.muted
                                  ? CairnBadgeVariant.secondary
                                  : CairnBadgeVariant.primary,
                              label: Text(
                                c.unread > 99 ? '99+' : '${c.unread}',
                              ),
                            )
                          else if (c.markedUnread)
                            const CairnStatus(
                              tone: CairnTone.primary,
                              semanticLabel: 'Marked unread',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            CairnDropdownMenu(
              controller: _menu,
              align: CairnAlign.end,
              items: items,
              child: IconAction(
                icon: Icons.more_vert,
                label: 'More actions for ${c.title}',
                onPressed: _menu.toggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
