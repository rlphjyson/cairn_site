import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/avatar_presets.dart';
import '../../../core/presentation/settings_text.dart';

/// A round avatar: the person's initials on a flat or gradient fill built from
/// Cairn colours.
///
/// The initials ignore the text scale, so the circle never grows with it; the
/// avatar is decorative and the name is always shown beside it.
class ProfileAvatar extends StatelessWidget {
  /// Creates an avatar.
  const ProfileAvatar({
    super.key,
    required this.initials,
    required this.presetId,
    this.size = 48,
  });

  /// The letters to draw.
  final String initials;

  /// One of [AvatarPresets].
  final String presetId;

  /// The diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final (Color from, Color to, Color text) = _palette(theme, presetId);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[from, to],
          ),
        ),
        child: Text(
          initials,
          textScaler: TextScaler.noScaling,
          style: settingsText(
            theme,
            CairnTypography.base,
            color: text,
            weight: CairnTypography.semibold,
            height: 1,
          ).copyWith(fontSize: size * 0.36),
        ),
      ),
    );
  }

  /// The fill and text colours for [id].
  static (Color, Color, Color) _palette(CairnTheme theme, String id) =>
      switch (id) {
        'ink' => (
          theme.primary,
          theme.mutedForeground,
          theme.primaryForeground,
        ),
        'dusk' => (
          Oklch.toColor(0.55, 0.17, 295),
          Oklch.toColor(0.4, 0.14, 262),
          CairnColors.white,
        ),
        'ember' => (
          Oklch.toColor(0.58, 0.19, 40),
          Oklch.toColor(0.5, 0.2, 15),
          CairnColors.white,
        ),
        'moss' => (
          Oklch.toColor(0.55, 0.12, 150),
          Oklch.toColor(0.42, 0.09, 180),
          CairnColors.white,
        ),
        _ => (theme.muted, theme.muted, theme.foreground),
      };
}
