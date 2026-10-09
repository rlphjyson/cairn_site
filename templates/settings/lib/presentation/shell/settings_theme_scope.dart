import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart' show Material, MaterialType, Theme;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/constants/text_size_steps.dart';
import '../../core/presentation/settings_appearance.dart';
import '../../domain/settings/models/settings_snapshot.dart';
import '../../domain/settings/registry/default_settings_registry.dart';
import '../settings/bloc/settings_cubit.dart';
import '../settings/bloc/settings_state.dart';

/// Wraps the template in the theme, text scale and motion the person chose.
///
/// This is what makes the Appearance screen a live preview: the choice is read
/// from [SettingsCubit], so changing it rebuilds everything below at once.
class SettingsThemeScope extends StatelessWidget {
  /// Creates the scope.
  const SettingsThemeScope({super.key, required this.child});

  /// The settings screens.
  final Widget child;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<SettingsCubit, SettingsState>(
    buildWhen: (SettingsState a, SettingsState b) =>
        !listEquals(_look(a.snapshot), _look(b.snapshot)),
    builder: (BuildContext context, SettingsState state) {
      final SettingsSnapshot? s = state.snapshot;
      final CairnTheme cairn = SettingsAppearance.cairnTheme(
        context: context,
        mode: SettingsAppearance.modeOf(s?.choice(SettingIds.themeMode) ?? ''),
        accent: s?.choice(SettingIds.accent) ?? 'ink',
      );
      final MediaQueryData host = MediaQuery.of(context);
      final double factor = TextSizeSteps.factorOf(
        s?.step(SettingIds.textSize) ?? TextSizeSteps.defaultStep,
      );
      final bool reduce = s?.flag(SettingIds.reduceMotion) ?? false;
      return Theme(
        data: CairnTheme.materialTheme(cairn),
        child: MediaQuery(
          data: host.copyWith(
            textScaler: TextScaler.linear(host.textScaler.scale(1) * factor),
            disableAnimations: host.disableAnimations || reduce,
          ),
          child: Material(
            type: MaterialType.canvas,
            color: cairn.background,
            child: DefaultTextStyle(
              style: cairn.defaultTextStyle,
              child: IconTheme(
                data: IconThemeData(color: cairn.foreground, size: 16),
                child: child,
              ),
            ),
          ),
        ),
      );
    },
  );

  /// The four values the look depends on.
  List<Object?> _look(SettingsSnapshot? s) => <Object?>[
    s?.choice(SettingIds.themeMode),
    s?.choice(SettingIds.accent),
    s?.step(SettingIds.textSize),
    s?.flag(SettingIds.reduceMotion),
  ];
}
