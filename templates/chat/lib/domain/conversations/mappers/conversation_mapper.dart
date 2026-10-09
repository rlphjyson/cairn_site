import '../../messages/mappers/message_mapper.dart';
import '../models/conversation.dart';

/// Decoded JSON <-> [Conversation].
///
/// ```json
/// {
///   "id": "c_mina", "type": "direct", "title": "Mina Park",
///   "avatar": "assets/images/avatar-mina.jpg", "peerId": "u_mina",
///   "memberIds": ["me", "u_mina"], "pinned": true, "muted": false,
///   "archived": false, "markedUnread": false, "unread": 2,
///   "updatedAt": "2026-10-09T18:02:00.000",
///   "lastMessage": { ...message... }
/// }
/// ```
///
/// For a group, `type` is `"group"`, `title` is the group's name and `peerId`
/// is `null`.
abstract final class ConversationMapper {
  /// Reads a conversation.
  static Conversation fromJson(Map<String, Object?> json) {
    final Object? last = json['lastMessage'];
    return Conversation(
      id: json['id']! as String,
      kind: ConversationKind.fromWire(json['type']),
      title: json['title']! as String,
      avatar: json['avatar'] as String?,
      peerId: json['peerId'] as String?,
      memberIds: <String>[
        for (final Object? id in (json['memberIds'] as List<Object?>? ?? []))
          id! as String,
      ],
      updatedAt: DateTime.parse(json['updatedAt']! as String),
      pinned: (json['pinned'] as bool?) ?? false,
      muted: (json['muted'] as bool?) ?? false,
      archived: (json['archived'] as bool?) ?? false,
      markedUnread: (json['markedUnread'] as bool?) ?? false,
      unread: (json['unread'] as num?)?.toInt() ?? 0,
      lastMessage: last is Map<String, Object?>
          ? MessageMapper.fromJson(last)
          : null,
    );
  }
}
