import 'package:equatable/equatable.dart';

import 'attachment.dart';
import 'message_status.dart';
import 'reaction.dart';
import 'reply_preview.dart';

/// One message in a conversation.
class Message extends Equatable {
  /// Creates a message.
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sentAt,
    this.text = '',
    this.status = MessageStatus.sent,
    this.replyTo,
    this.attachment,
    this.reactions = const <Reaction>[],
  });

  /// A stable identifier.
  final String id;

  /// The conversation this message belongs to.
  final String conversationId;

  /// Who wrote it.
  final String senderId;

  /// When it was sent.
  final DateTime sentAt;

  /// The body, or the caption of an [attachment].
  final String text;

  /// Delivery state; only meaningful for your own messages.
  final MessageStatus status;

  /// The message this one answers.
  final ReplyPreview? replyTo;

  /// A photo, file or location.
  final Attachment? attachment;

  /// Emoji reactions, in the order they first appeared.
  final List<Reaction> reactions;

  /// A one-line summary for lists and reply quotes.
  String get preview {
    final String body = text.trim();
    if (body.isNotEmpty) return body.replaceAll(RegExp(r'\s+'), ' ');
    final Attachment? a = attachment;
    if (a == null) return '';
    return switch (a.kind) {
      AttachmentKind.image => 'Photo',
      AttachmentKind.file => a.name ?? 'File',
      AttachmentKind.location => 'Location',
    };
  }

  /// A copy with some fields replaced.
  Message copyWith({
    String? id,
    MessageStatus? status,
    List<Reaction>? reactions,
    DateTime? sentAt,
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId,
    senderId: senderId,
    sentAt: sentAt ?? this.sentAt,
    text: text,
    status: status ?? this.status,
    replyTo: replyTo,
    attachment: attachment,
    reactions: reactions ?? this.reactions,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    conversationId,
    senderId,
    sentAt,
    text,
    status,
    replyTo,
    attachment,
    reactions,
  ];
}
