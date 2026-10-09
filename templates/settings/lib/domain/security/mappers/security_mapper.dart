import '../models/device_session.dart';

/// Turns the security data source's JSON into models.
///
/// Sessions:
///
/// ```json
/// { "sessions": [
///   { "id": "s1", "device": "Pixel 9", "location": "Lisbon, PT",
///     "lastActive": "2026-10-09T08:30:00Z", "current": true }
/// ] }
/// ```
abstract final class SecurityMapper {
  /// The sessions in [json], current device first.
  static List<DeviceSession> sessionsFromJson(Map<String, Object?> json) {
    final Object? raw = json['sessions'];
    final List<DeviceSession> sessions = <DeviceSession>[
      if (raw is List<Object?>)
        for (final Object? e in raw)
          if (e is Map<String, Object?>)
            DeviceSession(
              id: e['id'] as String? ?? '',
              device: e['device'] as String? ?? 'Unknown device',
              location: e['location'] as String? ?? 'Unknown location',
              lastActive:
                  DateTime.tryParse(e['lastActive'] as String? ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
              isCurrent: e['current'] == true,
            ),
    ];
    sessions.sort((DeviceSession a, DeviceSession b) {
      if (a.isCurrent != b.isCurrent) return a.isCurrent ? -1 : 1;
      return b.lastActive.compareTo(a.lastActive);
    });
    return sessions;
  }

  /// The blocked users in [json].
  static List<BlockedUser> blockedFromJson(Map<String, Object?> json) {
    final Object? raw = json['blocked'];
    return <BlockedUser>[
      if (raw is List<Object?>)
        for (final Object? e in raw)
          if (e is Map<String, Object?>)
            BlockedUser(
              id: e['id'] as String? ?? '',
              name: e['name'] as String? ?? '',
              username: e['username'] as String? ?? '',
            ),
    ];
  }

  /// The two-factor setup in [json]: `{ "secret": "JBSWY3DPEHPK3PXP" }`.
  static TwoFactorSetup twoFactorFromJson(Map<String, Object?> json) {
    final String raw = (json['secret'] as String? ?? '').replaceAll(' ', '');
    final StringBuffer grouped = StringBuffer();
    for (int i = 0; i < raw.length; i += 4) {
      if (i > 0) grouped.write(' ');
      grouped.write(raw.substring(i, i + 4 > raw.length ? raw.length : i + 4));
    }
    return TwoFactorSetup(secret: grouped.toString());
  }

  /// The export request in [json].
  static DataExportRequest exportFromJson(Map<String, Object?> json) =>
      DataExportRequest(
        id: json['id'] as String? ?? '',
        requestedAt:
            DateTime.tryParse(json['requestedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}
