import '../models/app_info.dart';
import '../models/setting_definition.dart';
import '../models/settings_snapshot.dart';
import '../registry/settings_registry.dart';

/// Turns decoded JSON into settings models and back. The only place that knows
/// the wire format of the settings.
///
/// The persisted shape:
///
/// ```json
/// {
///   "schema": 1,
///   "values": {
///     "appearance.themeMode": "dark",
///     "appearance.textSize": 2,
///     "notifications.messages": true
///   }
/// }
/// ```
///
/// Reading is forgiving. A missing key, a value of the wrong type and a choice
/// that is no longer offered all fall back to the definition's default, and
/// keys with no definition are dropped, so a stored blob from an older or newer
/// build never breaks the app.
class SettingsMapper {
  /// Creates a mapper that repairs values against [registry].
  const SettingsMapper(this.registry);

  /// The settings the values are checked against.
  final SettingsRegistry registry;

  /// The current schema version.
  static const int schema = 1;

  /// A snapshot of [json], repaired. A `null` or malformed [json] yields the
  /// defaults.
  SettingsSnapshot snapshotFromJson(Map<String, Object?>? json) {
    final Object? raw = json?['values'];
    final Map<String, Object?> stored = raw is Map<String, Object?>
        ? raw
        : const <String, Object?>{};
    final Map<String, Object?> values = <String, Object?>{};
    for (final SettingDefinition d in registry.definitions) {
      if (d.kind == SettingKind.action || d.kind == SettingKind.link) continue;
      final Object? v = stored[d.id];
      values[d.id] = d.accepts(v) ? v : d.defaultValue;
    }
    return SettingsSnapshot(values);
  }

  /// The JSON to persist for [snapshot].
  Map<String, Object?> snapshotToJson(SettingsSnapshot snapshot) =>
      <String, Object?>{'schema': schema, 'values': snapshot.values};

  /// App info from [json], with sensible blanks for anything missing.
  AppInfo appInfoFromJson(Map<String, Object?> json) {
    final Object? rawLicences = json['licences'];
    return AppInfo(
      name: json['name'] as String? ?? 'App',
      version: json['version'] as String? ?? '0.0.0',
      build: '${json['build'] ?? 0}',
      licences: <LicenceEntry>[
        if (rawLicences is List<Object?>)
          for (final Object? e in rawLicences)
            if (e is Map<String, Object?>)
              LicenceEntry(
                name: e['name'] as String? ?? '',
                licence: e['licence'] as String? ?? '',
                summary: e['summary'] as String? ?? '',
              ),
      ],
    );
  }
}
