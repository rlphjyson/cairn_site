import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/settings_appearance.dart';
import '../../../core/presentation/settings_text.dart';
import '../../../core/presentation/widgets/focus_tap.dart';
import '../../../core/presentation/widgets/load_gate.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/setting_rows.dart';
import '../../../domain/settings/models/setting_definition.dart';
import '../../../domain/settings/models/settings_section.dart';
import '../../../domain/settings/models/settings_snapshot.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/registry/settings_registry.dart';
import '../../settings/bloc/settings_cubit.dart';
import '../../settings/bloc/settings_state.dart';
import '../../settings/widgets/section_blocks.dart';

/// Appearance: theme mode, text size with a live sample, accent colour and
/// reduce motion. Every change applies to the whole template at once.
class AppearanceView extends StatelessWidget {
  /// Creates the view.
  const AppearanceView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final SettingsState state = context.watch<SettingsCubit>().state;
    final SettingsCubit cubit = context.read<SettingsCubit>();
    final SettingsRegistry registry = context.read<SettingsRegistry>();
    return PageFrame(
      title: SettingsSection.appearance.title,
      onBack: onBack,
      children: <Widget>[
        LoadGate(
          status: state.status,
          onRetry: cubit.load,
          child: state.snapshot == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ...SectionBlocks.build(
                      context,
                      registry: registry,
                      section: SettingsSection.appearance,
                      snapshot: state.snapshot!,
                      onChanged: cubit.set,
                      custom: <String, SettingRowBuilder>{
                        SettingIds.textSize:
                            (BuildContext c, SettingDefinition d) =>
                                _TextSizeRow(
                                  definition: d as SliderSetting,
                                  snapshot: state.snapshot!,
                                  onChanged: (int v) =>
                                      cubit.set(SettingIds.textSize, v),
                                ),
                        SettingIds.accent:
                            (BuildContext c, SettingDefinition d) => _AccentRow(
                              definition: d as ChoiceSetting,
                              value: state.snapshot!.choice(SettingIds.accent),
                              onChanged: (String v) =>
                                  cubit.set(SettingIds.accent, v),
                            ),
                      },
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// The text size slider with a sample that is already drawn at the new size.
class _TextSizeRow extends StatelessWidget {
  const _TextSizeRow({
    required this.definition,
    required this.snapshot,
    required this.onChanged,
  });

  final SliderSetting definition;
  final SettingsSnapshot snapshot;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final int step = snapshot.step(definition.id).clamp(0, definition.max);
    final TextStyle small = settingsText(
      theme,
      CairnTypography.xs,
      color: theme.mutedForeground,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RowLabel(
            title: definition.title,
            subtitle: definition.description,
            trailing: definition.labels[step],
          ),
          Row(
            children: <Widget>[
              ExcludeSemantics(
                child: Text(
                  'A',
                  style: small,
                  textScaler: TextScaler.noScaling,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StepSlider(
                  value: step,
                  steps: definition.labels.length,
                  semanticLabel: definition.title,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              ExcludeSemantics(
                child: Text(
                  'A',
                  style: small.copyWith(fontSize: 20),
                  textScaler: TextScaler.noScaling,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Semantics(
            label: 'Sample text at the chosen size',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.muted,
                borderRadius: BorderRadius.circular(theme.radiusScale.md),
              ),
              child: Text(
                'The quick brown fox jumps over the lazy dog.',
                style: settingsText(theme, CairnTypography.base, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three accent swatches, drawn in the colours they would apply.
class _AccentRow extends StatelessWidget {
  const _AccentRow({
    required this.definition,
    required this.value,
    required this.onChanged,
  });

  final ChoiceSetting definition;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final CairnTheme baseline = theme.brightness == Brightness.dark
        ? CairnTheme.dark
        : CairnTheme.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RowLabel(title: definition.title, subtitle: definition.description),
          const SizedBox(height: 8),
          Semantics(
            container: true,
            label: definition.title,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final ChoiceOption o in definition.options)
                  FocusTap(
                    label: o.label,
                    selected: o.value == value,
                    onTap: () => onChanged(o.value),
                    builder: (BuildContext context, bool focused) {
                      final Color color =
                          SettingsAppearance.accentColor(
                            o.value,
                            theme.brightness,
                          ) ??
                          baseline.primary;
                      final bool on = o.value == value;
                      return Container(
                        constraints: const BoxConstraints(minWidth: 56),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                border: Border.all(
                                  color: on || focused
                                      ? theme.ring
                                      : theme.border,
                                  width: on || focused ? 3 : 1,
                                ),
                                boxShadow: focused ? theme.focusRing : null,
                              ),
                              child: on
                                  ? Icon(
                                      Icons.check,
                                      size: 20,
                                      color:
                                          SettingsAppearance.accentForeground(
                                            theme.brightness,
                                          ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              o.label,
                              textAlign: TextAlign.center,
                              style: settingsText(
                                theme,
                                CairnTypography.xs,
                                color: theme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
