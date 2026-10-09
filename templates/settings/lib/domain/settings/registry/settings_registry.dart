import '../models/setting_definition.dart';
import '../models/settings_section.dart';

/// Every setting the app has, in the order its screen shows them.
///
/// The registry is the single source of truth: the search reads it to build its
/// index, each category screen reads it to draw its rows, the mapper reads it to
/// repair stored values and `UpdateSetting` reads it to validate changes.
/// Remove a definition and the setting disappears from all four. See
/// `defaultSettingsRegistry` for the built-in list.
class SettingsRegistry {
  /// Creates a registry. Ids must be unique.
  SettingsRegistry(Iterable<SettingDefinition> definitions)
    : definitions = List<SettingDefinition>.unmodifiable(definitions) {
    final Set<String> seen = <String>{};
    for (final SettingDefinition d in this.definitions) {
      if (!seen.add(d.id)) {
        throw ArgumentError('Duplicate setting id "${d.id}".');
      }
    }
  }

  /// All definitions, in order.
  final List<SettingDefinition> definitions;

  /// The definition with [id], or `null`.
  SettingDefinition? byId(String id) {
    for (final SettingDefinition d in definitions) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Whether a definition with [id] exists.
  bool contains(String id) => byId(id) != null;

  /// The definition with [id] as a [T], or `null` when it is missing or of
  /// another kind.
  T? maybe<T extends SettingDefinition>(String id) {
    final SettingDefinition? d = byId(id);
    return d is T ? d : null;
  }

  /// The definitions in [section], in order.
  List<SettingDefinition> inSection(SettingsSection section) =>
      <SettingDefinition>[
        for (final SettingDefinition d in definitions)
          if (d.section == section) d,
      ];

  /// The sections that have at least one definition, in declaration order.
  List<SettingsSection> get sections => <SettingsSection>[
    for (final SettingsSection s in SettingsSection.values)
      if (definitions.any((SettingDefinition d) => d.section == s)) s,
  ];

  /// The value each setting starts with, keyed by id. Actions and links have
  /// none, so they are left out.
  Map<String, Object?> get defaults => <String, Object?>{
    for (final SettingDefinition d in definitions)
      if (d.kind != SettingKind.action && d.kind != SettingKind.link)
        d.id: d.defaultValue,
  };
}
