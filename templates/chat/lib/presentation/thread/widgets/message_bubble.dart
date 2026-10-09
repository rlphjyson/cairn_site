import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../common/utils/dates.dart';
import '../../../core/presentation/chat_text.dart';
import '../../../core/presentation/widgets/chat_avatar.dart';
import '../../../domain/contacts/models/contact.dart';
import '../../../domain/messages/models/message.dart';
import '../../../domain/messages/models/message_status.dart';
import '../../../domain/messages/models/reaction.dart';
import '../../../domain/messages/models/thread_item.dart';
import 'message_content.dart';

/// One message in a thread, built on [CairnChatBubble].
///
/// Messages in a run (same sender, within five minutes) sit close together;
/// the first shows the sender's name in groups, the last shows the avatar, the
/// time and the delivery tick. Long-press opens the message's actions.
class MessageBubble extends StatelessWidget {
  /// Creates a bubble.
  const MessageBubble({
    super.key,
    required this.item,
    required this.mine,
    required this.isGroup,
    required this.sender,
    required this.nameOf,
    required this.userId,
    required this.onActions,
    required this.onReact,
    required this.onLink,
  });

  /// The message and where it sits in its run.
  final ThreadMessage item;

  /// Whether you sent it.
  final bool mine;

  /// Whether the conversation is a group (names and avatars show).
  final bool isGroup;

  /// Who sent it, when it is not you.
  final Contact? sender;

  /// Resolves a user id to a name (for reply quotes).
  final String Function(String userId) nameOf;

  /// The signed-in user's id, to highlight your own reactions.
  final String userId;

  /// Opens the message's action sheet.
  final VoidCallback onActions;

  /// Toggles your reaction with an emoji.
  final void Function(String emoji) onReact;

  /// Called with the address of a tapped link.
  final ValueChanged<String> onLink;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Message message = item.message;
    final bool showAvatar = !mine && isGroup;
    final String senderName = sender?.name ?? 'Someone';
    final bool sending = message.status == MessageStatus.sending;

    final Widget? avatar = showAvatar
        ? (item.endsRun
              ? ChatAvatar(
                  name: senderName,
                  avatar: sender?.avatar,
                  size: CairnAvatarSize.sm,
                )
              : const SizedBox(width: 24))
        : null;

    final Widget? author = showAvatar && item.startsRun
        ? Text(
            senderName,
            style: chatText(
              theme,
              theme.textStyle(CairnTypography.xs),
              color: theme.mutedForeground,
              weight: CairnTypography.medium,
            ),
          )
        : null;

    final Widget bubble = CairnChatBubble(
      side: mine ? CairnChatSide.sent : CairnChatSide.received,
      avatar: avatar,
      author: author,
      footer: _footer(context, theme),
      child: MessageContent(
        message: message,
        mine: mine,
        replyAuthor: message.replyTo == null
            ? null
            : nameOf(message.replyTo!.senderId),
        onLink: onLink,
      ),
    );

    final String label = <String>[
      mine ? 'You' : senderName,
      if (message.replyTo != null)
        'replying to ${nameOf(message.replyTo!.senderId)}',
      message.preview,
      formatClock(message.sentAt),
      if (mine) _statusLabel(message.status),
      for (final Reaction r in message.reactions)
        '${r.count} ${r.emoji} reaction${r.count == 1 ? '' : 's'}',
    ].join(', ');

    return Padding(
      padding: EdgeInsets.only(top: item.startsRun ? 8 : 2),
      child: Semantics(
        container: true,
        label: label,
        excludeSemantics: true,
        onLongPress: sending ? null : onActions,
        customSemanticsActions: sending
            ? null
            : <CustomSemanticsAction, VoidCallback>{
                const CustomSemanticsAction(label: 'Message actions'):
                    onActions,
              },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: sending ? null : onActions,
          child: bubble,
        ),
      ),
    );
  }

  Widget? _footer(BuildContext context, CairnTheme theme) {
    final Message message = item.message;
    final bool failed = message.status == MessageStatus.failed;
    if (message.reactions.isEmpty && !item.endsRun && !failed) return null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: mine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      spacing: 2,
      children: <Widget>[
        if (message.reactions.isNotEmpty)
          Wrap(
            spacing: 4,
            children: <Widget>[
              for (final Reaction r in message.reactions)
                _ReactionChip(
                  reaction: r,
                  mine: r.includes(userId),
                  onTap: () => onReact(r.emoji),
                ),
            ],
          ),
        if (item.endsRun || failed)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: <Widget>[
              if (failed)
                Text('Not sent', style: TextStyle(color: theme.destructive))
              else
                Text(formatClock(message.sentAt)),
              if (mine && !failed) _Tick(message.status),
            ],
          ),
      ],
    );
  }

  static String _statusLabel(MessageStatus status) => switch (status) {
    MessageStatus.sending => 'sending',
    MessageStatus.sent => 'sent',
    MessageStatus.read => 'read',
    MessageStatus.failed => 'not sent',
  };
}

class _Tick extends StatelessWidget {
  const _Tick(this.status);

  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final (IconData icon, Color color) = switch (status) {
      MessageStatus.sending => (Icons.schedule, theme.mutedForeground),
      MessageStatus.sent => (Icons.check, theme.mutedForeground),
      MessageStatus.read => (
        Icons.done_all,
        CairnToneColors.resolve(theme, CairnTone.info).fill,
      ),
      MessageStatus.failed => (Icons.error_outline, theme.destructive),
    };
    return Icon(icon, size: 13, color: color);
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.reaction,
    required this.mine,
    required this.onTap,
  });

  final Reaction reaction;
  final bool mine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: mine ? theme.accent : theme.muted,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: mine ? theme.ring : theme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              reaction.count > 1
                  ? '${reaction.emoji} ${reaction.count}'
                  : reaction.emoji,
              style: chatText(theme, theme.textStyle(CairnTypography.xs)),
            ),
          ),
        ),
      ),
    );
  }
}
