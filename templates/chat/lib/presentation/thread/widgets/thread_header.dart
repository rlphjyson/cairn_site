import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../core/presentation/widgets/chat_avatar.dart';
import '../../../core/presentation/widgets/chat_header.dart';
import '../../../core/presentation/widgets/icon_action.dart';
import '../../../domain/contacts/models/contact.dart';
import '../../../domain/contacts/models/presence.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/conversations/use_cases/format_relative_time.dart';
import '../../conversations/widgets/conversation_actions.dart';

/// The top of a thread: back (on phones), the avatar with presence, the name,
/// a live line (typing, presence, last seen or member count), and actions.
class ThreadHeader extends StatefulWidget {
  /// Creates the header.
  const ThreadHeader({
    super.key,
    required this.title,
    required this.conversation,
    required this.peer,
    required this.typingName,
    required this.now,
    required this.onBack,
    required this.onInfo,
  });

  /// The name to show before the conversation has loaded.
  final String title;

  /// The conversation, once loaded.
  final Conversation? conversation;

  /// The other person in a direct conversation.
  final Contact? peer;

  /// The name of someone typing, or `null`.
  final String? typingName;

  /// The current time, for "last seen".
  final DateTime now;

  /// Shows a back button when set.
  final VoidCallback? onBack;

  /// Opens the information screen.
  final VoidCallback onInfo;

  @override
  State<ThreadHeader> createState() => _ThreadHeaderState();
}

class _ThreadHeaderState extends State<ThreadHeader> {
  final CairnOverlayController _menu = CairnOverlayController();

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  String _status() {
    if (widget.typingName != null) {
      return widget.conversation?.isGroup ?? false
          ? '${widget.typingName} is typing...'
          : 'typing...';
    }
    final Conversation? c = widget.conversation;
    if (c == null) return '';
    if (c.isGroup) return '${c.memberIds.length} members';
    final Contact? peer = widget.peer;
    if (peer == null) return '';
    if (peer.presence != Presence.offline) return peer.presence.label;
    return peer.lastSeen == null
        ? 'Offline'
        : const FormatRelativeTime().lastSeen(peer.lastSeen!, widget.now);
  }

  @override
  Widget build(BuildContext context) {
    final Conversation? c = widget.conversation;
    final String status = _status();
    return ChatHeader(
      onBack: widget.onBack,
      backLabel: 'Back to chats',
      title: c?.title ?? widget.title,
      leading: c == null
          ? null
          : ChatAvatar(
              name: c.title,
              avatar: c.avatar,
              presence: widget.peer?.presence,
              group: c.isGroup,
            ),
      subtitle: status.isEmpty ? null : Text(status),
      actions: <Widget>[
        IconAction(
          icon: Icons.info_outline,
          label: c?.isGroup ?? false ? 'Group info' : 'Contact info',
          onPressed: c == null ? null : widget.onInfo,
        ),
        if (c != null)
          CairnDropdownMenu(
            controller: _menu,
            align: CairnAlign.end,
            items: conversationMenuItems(context, c),
            child: IconAction(
              icon: Icons.more_vert,
              label: 'More actions',
              onPressed: _menu.toggle,
            ),
          ),
      ],
    );
  }
}
