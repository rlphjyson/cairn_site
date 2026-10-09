import '../models/attachment.dart';
import '../models/message.dart';
import '../models/message_page.dart';
import '../models/message_status.dart';
import '../models/outgoing_message.dart';
import '../models/reaction.dart';
import '../models/reply_preview.dart';

/// Decoded JSON <-> [Message].
///
/// ```json
/// {
///   "id": "m_1042", "conversationId": "c_mina", "senderId": "u_mina",
///   "text": "See you at 8?", "sentAt": "2026-10-09T18:02:00.000",
///   "status": "read",
///   "replyTo": { "messageId": "m_1040", "senderId": "me", "text": "Dinner?" },
///   "attachment": {
///     "type": "image", "asset": "assets/images/photo-lake.jpg",
///     "url": null, "name": null, "size": null, "aspectRatio": 1.33
///   },
///   "reactions": [ { "emoji": "\u{1F44D}", "userIds": ["me"] } ]
/// }
/// ```
///
/// A page of history is `{ "messages": [ ...oldest first... ], "hasMore": true }`.
abstract final class MessageMapper {
  /// Reads a message.
  static Message fromJson(Map<String, Object?> json) {
    final Map<String, Object?>? reply = _map(json['replyTo']);
    final Map<String, Object?>? attachment = _map(json['attachment']);
    final List<Object?> reactions =
        (json['reactions'] as List<Object?>?) ?? const <Object?>[];
    return Message(
      id: json['id']! as String,
      conversationId: json['conversationId']! as String,
      senderId: json['senderId']! as String,
      sentAt: DateTime.parse(json['sentAt']! as String),
      text: (json['text'] as String?) ?? '',
      status: MessageStatus.fromWire(json['status']),
      replyTo: reply == null
          ? null
          : ReplyPreview(
              messageId: reply['messageId']! as String,
              senderId: reply['senderId']! as String,
              text: (reply['text'] as String?) ?? '',
            ),
      attachment: attachment == null ? null : _attachment(attachment),
      reactions: <Reaction>[
        for (final Object? r in reactions)
          if (r is Map<String, Object?>)
            Reaction(r['emoji']! as String, <String>[
              for (final Object? id in (r['userIds'] as List<Object?>? ?? []))
                id! as String,
            ]),
      ],
    );
  }

  /// Writes a message.
  static Map<String, Object?> toJson(Message message) => <String, Object?>{
    'id': message.id,
    'conversationId': message.conversationId,
    'senderId': message.senderId,
    'text': message.text,
    'sentAt': message.sentAt.toIso8601String(),
    'status': message.status.wire,
    'replyTo': message.replyTo == null
        ? null
        : <String, Object?>{
            'messageId': message.replyTo!.messageId,
            'senderId': message.replyTo!.senderId,
            'text': message.replyTo!.text,
          },
    'attachment': message.attachment == null
        ? null
        : attachmentToJson(message.attachment!),
    'reactions': <Object?>[
      for (final Reaction r in message.reactions)
        <String, Object?>{'emoji': r.emoji, 'userIds': r.userIds},
    ],
  };

  /// The request body for sending a message.
  static Map<String, Object?> outgoingToJson(OutgoingMessage message) =>
      <String, Object?>{
        'conversationId': message.conversationId,
        'text': message.text,
        'replyTo': message.replyTo == null
            ? null
            : <String, Object?>{
                'messageId': message.replyTo!.messageId,
                'senderId': message.replyTo!.senderId,
                'text': message.replyTo!.text,
              },
        'attachment': message.attachment == null
            ? null
            : attachmentToJson(message.attachment!),
      };

  /// Writes an attachment.
  static Map<String, Object?> attachmentToJson(Attachment attachment) =>
      <String, Object?>{
        'type': attachment.kind.wire,
        'asset': attachment.asset,
        'url': attachment.url,
        'name': attachment.name,
        'size': attachment.sizeBytes,
        'aspectRatio': attachment.aspectRatio,
      };

  /// Reads a page of history.
  static MessagePage pageFromJson(Map<String, Object?> json) => MessagePage(
    messages: <Message>[
      for (final Object? m in (json['messages'] as List<Object?>? ?? []))
        fromJson(m! as Map<String, Object?>),
    ],
    hasMore: (json['hasMore'] as bool?) ?? false,
  );

  static Attachment _attachment(Map<String, Object?> json) => Attachment(
    kind: AttachmentKind.fromWire(json['type']),
    asset: json['asset'] as String?,
    url: json['url'] as String?,
    name: json['name'] as String?,
    sizeBytes: (json['size'] as num?)?.toInt(),
    aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 4 / 3,
  );

  static Map<String, Object?>? _map(Object? value) =>
      value is Map<String, Object?> ? value : null;
}
