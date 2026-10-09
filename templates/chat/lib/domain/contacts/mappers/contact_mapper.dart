import '../models/contact.dart';
import '../models/presence.dart';

/// Decoded JSON <-> [Contact].
///
/// ```json
/// {
///   "id": "u_mina", "name": "Mina Park", "about": "Hiking this weekend",
///   "avatar": "assets/images/avatar-mina.jpg", "presence": "online",
///   "lastSeen": "2026-10-09T09:12:00.000", "blocked": false
/// }
/// ```
abstract final class ContactMapper {
  /// Reads a contact.
  static Contact fromJson(Map<String, Object?> json) => Contact(
    id: json['id']! as String,
    name: json['name']! as String,
    about: (json['about'] as String?) ?? '',
    avatar: json['avatar'] as String?,
    presence: Presence.fromWire(json['presence']),
    lastSeen: _date(json['lastSeen']),
    blocked: (json['blocked'] as bool?) ?? false,
  );

  /// Writes a contact.
  static Map<String, Object?> toJson(Contact contact) => <String, Object?>{
    'id': contact.id,
    'name': contact.name,
    'about': contact.about,
    'avatar': contact.avatar,
    'presence': contact.presence.wire,
    'lastSeen': contact.lastSeen?.toIso8601String(),
    'blocked': contact.blocked,
  };

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
