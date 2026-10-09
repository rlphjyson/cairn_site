import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../common/utils/emoji.dart';
import '../../../core/presentation/chat_images.dart';
import '../../../core/presentation/chat_text.dart';
import '../../../domain/messages/models/attachment.dart';
import '../../../domain/messages/models/message.dart';
import '../../../domain/messages/models/reply_preview.dart';
import 'linkified_text.dart';

/// What goes inside a bubble: the quoted message, the attachment, and the text
/// (with tappable links, or large when it is only emoji).
class MessageContent extends StatelessWidget {
  /// Creates the content.
  const MessageContent({
    super.key,
    required this.message,
    required this.mine,
    required this.replyAuthor,
    required this.onLink,
  });

  /// The message.
  final Message message;

  /// Whether the bubble is a sent one (primary colours) or received.
  final bool mine;

  /// The name shown on the quote, when the message is a reply.
  final String? replyAuthor;

  /// Called with the address of a tapped link.
  final ValueChanged<String> onLink;

  @override
  Widget build(BuildContext context) {
    final String text = message.text;
    final ReplyPreview? reply = message.replyTo;
    final Attachment? attachment = message.attachment;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: <Widget>[
        if (reply != null)
          ReplyQuote(reply: reply, author: replyAuthor ?? '', mine: mine),
        if (attachment != null) _AttachmentView(attachment, mine: mine),
        if (text.isNotEmpty)
          isEmojiOnly(text)
              ? Text(text, style: const TextStyle(fontSize: 34, height: 1.25))
              : LinkifiedText(text, onLink: onLink),
      ],
    );
  }
}

/// The quoted part of a reply, drawn at the top of the bubble.
class ReplyQuote extends StatelessWidget {
  /// Creates a quote.
  const ReplyQuote({
    super.key,
    required this.reply,
    required this.author,
    required this.mine,
  });

  /// What is quoted.
  final ReplyPreview reply;

  /// Who wrote it.
  final String author;

  /// Whether it sits in a sent bubble.
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color ink = mine
        ? theme.primaryForeground
        : theme.secondaryForeground;
    return Semantics(
      label: 'Replying to $author: ${reply.text}',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: ink.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(theme.radiusScale.sm),
          border: Border(
            left: BorderSide(color: ink.withValues(alpha: 0.7), width: 3),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: chatText(
                theme,
                theme.textStyle(CairnTypography.xs),
                color: ink,
                weight: CairnTypography.semibold,
              ),
            ),
            Text(
              reply.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: chatText(
                theme,
                theme.textStyle(CairnTypography.xs),
                color: ink.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentView extends StatelessWidget {
  const _AttachmentView(this.attachment, {required this.mine});

  final Attachment attachment;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color ink = mine
        ? theme.primaryForeground
        : theme.secondaryForeground;
    switch (attachment.kind) {
      case AttachmentKind.image:
        final String? source = attachment.asset ?? attachment.url;
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
            child: AspectRatio(
              aspectRatio: attachment.aspectRatio,
              child: source == null
                  ? ColoredBox(color: ink.withValues(alpha: 0.12))
                  : Image(
                      image: chatImage(source),
                      fit: BoxFit.cover,
                      semanticLabel: 'Photo',
                      frameBuilder:
                          (
                            BuildContext context,
                            Widget child,
                            int? frame,
                            bool sync,
                          ) => sync || frame != null
                          ? child
                          : ColoredBox(color: ink.withValues(alpha: 0.12)),
                      errorBuilder:
                          (BuildContext context, Object error, StackTrace? s) =>
                              ColoredBox(
                                color: ink.withValues(alpha: 0.12),
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: ink,
                                ),
                              ),
                    ),
            ),
          ),
        );
      case AttachmentKind.file:
        return _InfoRow(
          icon: Icons.insert_drive_file_outlined,
          title: attachment.name ?? 'File',
          detail: attachment.sizeBytes == null
              ? null
              : _size(attachment.sizeBytes!),
          ink: ink,
        );
      case AttachmentKind.location:
        return _InfoRow(
          icon: Icons.place_outlined,
          title: attachment.name ?? 'Location',
          detail: 'Shared location',
          ink: ink,
        );
    }
  }

  static String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.ink,
    this.detail,
  });

  final IconData icon;
  final String title;
  final String? detail;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ink.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
          ),
          child: Icon(icon, size: 20, color: ink),
        ),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: chatText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  color: ink,
                  weight: CairnTypography.medium,
                ),
              ),
              if (detail != null)
                Text(
                  detail!,
                  style: chatText(
                    theme,
                    theme.textStyle(CairnTypography.xs),
                    color: ink.withValues(alpha: 0.75),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
