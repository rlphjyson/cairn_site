import 'package:flutter/widgets.dart';

import '../../../core/presentation/widgets/setting_rows.dart';
import '../../../domain/settings/models/setting_definition.dart';
import '../../../domain/settings/models/settings_section.dart';
import '../../../domain/settings/models/settings_snapshot.dart';
import '../../../domain/settings/registry/settings_registry.dart';

/// Builds the row for one setting, replacing the default for its kind.
typedef SettingRowBuilder =
    Widget Function(BuildContext context, SettingDefinition definition);

/// Draws the registry's definitions for one section.
///
/// This is what makes the registry the single source of truth for the screens:
/// every toggle, choice, slider, action and link in the section appears here
/// in the order it is declared, grouped under its `group` heading, with no
/// per-setting code. A screen only adds code for what is special: [custom]
/// replaces the row for an id, [actions] says what an action or link does, and
/// [enabled] greys settings out.
class SectionBlocks {
  const SectionBlocks._();

  /// The groups for [section], as widgets.
  static List<Widget> build(
    BuildContext context, {
    required SettingsRegistry registry,
    required SettingsSection section,
    required SettingsSnapshot snapshot,
    required void Function(String id, Object? value) onChanged,
    Map<String, SettingRowBuilder> custom = const <String, SettingRowBuilder>{},
    Map<String, VoidCallback> actions = const <String, VoidCallback>{},
    bool Function(SettingDefinition definition)? enabled,
    Map<String, String> subtitles = const <String, String>{},
  }) {
    final List<Widget> blocks = <Widget>[];
    String? group;
    final List<Widget> rows = <Widget>[];

    void flush() {
      if (rows.isEmpty) return;
      blocks.add(SettingsGroup(title: group, children: List<Widget>.of(rows)));
      rows.clear();
    }

    for (final SettingDefinition d in registry.inSection(section)) {
      if (d.group != group) {
        flush();
        group = d.group;
      }
      final bool on = enabled?.call(d) ?? true;
      final SettingRowBuilder? override = custom[d.id];
      rows.add(
        override != null
            ? override(context, d)
            : _row(
                d,
                snapshot: snapshot,
                on: on,
                onChanged: onChanged,
                action: actions[d.id],
                subtitle: subtitles[d.id] ?? d.description,
              ),
      );
    }
    flush();
    return blocks;
  }

  static Widget _row(
    SettingDefinition d, {
    required SettingsSnapshot snapshot,
    required bool on,
    required void Function(String id, Object? value) onChanged,
    required VoidCallback? action,
    required String? subtitle,
  }) => switch (d) {
    ToggleSetting() => ToggleRow(
      title: d.title,
      subtitle: subtitle,
      value: snapshot.flag(d.id),
      onChanged: on ? (bool v) => onChanged(d.id, v) : null,
    ),
    ChoiceSetting(style: ChoiceStyle.radio) => RadioRow(
      title: d.title,
      subtitle: subtitle,
      options: d.options,
      value: snapshot.choice(d.id),
      onChanged: on ? (String v) => onChanged(d.id, v) : null,
    ),
    ChoiceSetting() => SelectRow(
      title: d.title,
      subtitle: subtitle,
      options: d.options,
      value: snapshot.choice(d.id),
      inline: subtitle == null,
      onChanged: on ? (String v) => onChanged(d.id, v) : null,
    ),
    SliderSetting() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RowLabel(
            title: d.title,
            subtitle: subtitle,
            trailing: d.labels[snapshot.step(d.id).clamp(0, d.max)],
            enabled: on,
          ),
          StepSlider(
            value: snapshot.step(d.id),
            steps: d.labels.length,
            semanticLabel: d.title,
            onChanged: on ? (int v) => onChanged(d.id, v) : null,
          ),
        ],
      ),
    ),
    ActionSetting() => NavRow(
      title: d.title,
      subtitle: subtitle,
      destructive: d.destructive,
      onTap: on ? action : null,
    ),
    LinkSetting() => NavRow(
      title: d.title,
      subtitle: subtitle,
      external: true,
      onTap: on ? action : null,
    ),
  };
}
