import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart'
    show Theme, ThemeData, ThemeExtension, ThemeMode;
import 'package:flutter/widgets.dart';

/// Turns the stored appearance choices into a theme.
///
/// The template wraps itself in a `Theme` built here, so a change on the
/// Appearance screen shows up at once without the host doing anything. A host
/// that also wants its own screens to follow reads `onThemeModeChanged`.
abstract final class SettingsAppearance {
  /// The accent ids, in the order the swatches are drawn.
  static const List<String> accents = <String>['ink', 'ocean', 'forest'];

  /// The mode for the stored `id`: `light`, `dark`, anything else is system.
  static ThemeMode modeOf(String id) => switch (id) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// The stored id for [mode].
  static String idOf(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  /// The colour of the [accent] swatch in [brightness], or `null` for `ink`,
  /// which keeps the theme's own primary.
  static Color? accentColor(String accent, Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    return switch (accent) {
      'ocean' =>
        dark ? Oklch.toColor(0.74, 0.12, 245) : Oklch.toColor(0.46, 0.17, 255),
      'forest' =>
        dark ? Oklch.toColor(0.76, 0.14, 155) : Oklch.toColor(0.46, 0.11, 160),
      _ => null,
    };
  }

  /// The text on top of an accent fill.
  static Color accentForeground(Brightness brightness) =>
      brightness == Brightness.dark
      ? CairnTheme.dark.primaryForeground
      : CairnTheme.light.primaryForeground;

  /// The [CairnTheme] for the stored choices, keeping the host's font and
  /// radius.
  static CairnTheme cairnTheme({
    required BuildContext context,
    required ThemeMode mode,
    required String accent,
  }) {
    final CairnTheme host = CairnTheme.of(context);
    // System follows the host's own Cairn theme when it registered one (so a
    // host that already resolved its mode is respected), and the device
    // otherwise.
    final Brightness systemBrightness =
        Theme.of(context).extension<CairnTheme>() != null
        ? host.brightness
        : MediaQuery.platformBrightnessOf(context);
    final Brightness brightness = switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => systemBrightness,
    };
    CairnTheme theme =
        (brightness == Brightness.dark ? CairnTheme.dark : CairnTheme.light)
            .copyWith(
              fontFamily: host.fontFamily,
              fontFamilyFallback: host.fontFamilyFallback,
              radius: host.radius,
            );
    final Color? color = accentColor(accent, brightness);
    if (color != null) {
      theme = theme.copyWith(
        primary: color,
        primaryForeground: accentForeground(brightness),
      );
    }
    return theme;
  }

  /// A [ThemeData] whose Cairn tokens use [primary] as the primary colour.
  /// Used to tint one widget, such as a segment of the storage meter.
  static ThemeData tinted(BuildContext context, Color primary) {
    final ThemeData data = Theme.of(context);
    return data.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        CairnTheme.of(context).copyWith(primary: primary),
      ],
    );
  }
}
