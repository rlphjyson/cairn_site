import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

/// Holds the site's light/dark preference.
///
/// The default is deliberately [ThemeMode.dark] rather than [ThemeMode.system]:
/// a first-time visitor should always land on the dark treatment, regardless of
/// what their OS reports. The toggle then flips between the two explicit modes,
/// never back to "system", so the control is never a no-op on a machine whose
/// system preference already matches.
class SiteThemeController extends ChangeNotifier {
  /// Creates a controller, dark by default.
  SiteThemeController({ThemeMode? initial}) : _mode = initial ?? fromUrl();

  /// Reads an optional `?theme=light` override from the URL.
  ///
  /// Dark remains the default for anyone who just opens the site; this exists
  /// so a light-mode screenshot can be captured head-lessly and so a link can
  /// point at a specific treatment. Anything other than `light` — including no
  /// query at all, and every non-web platform, where `Uri.base` is a file
  /// path — resolves to dark.
  static ThemeMode fromUrl() => Uri.base.queryParameters['theme'] == 'light'
      ? ThemeMode.light
      : ThemeMode.dark;

  ThemeMode _mode;

  /// The active mode.
  ThemeMode get mode => _mode;

  /// Whether the dark theme is showing.
  bool get isDark => _mode == ThemeMode.dark;

  /// Flips between dark and light.
  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Sets an explicit mode.
  void set(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }
}

/// Exposes the [SiteThemeController] to the widget tree.
class SiteTheme extends InheritedNotifier<SiteThemeController> {
  /// Wraps [child] with access to [controller].
  const SiteTheme({
    super.key,
    required SiteThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The nearest controller. Throws if the site shell is missing.
  static SiteThemeController of(BuildContext context) {
    final SiteTheme? scope = context
        .dependOnInheritedWidgetOfExactType<SiteTheme>();
    assert(scope != null, 'No SiteTheme found in the widget tree.');
    return scope!.notifier!;
  }
}

/// The typography and colour tokens the site layers on top of [CairnTheme].
///
/// Everything here is *derived* from the library's own tokens rather than
/// invented: the display sizes continue Tailwind's type scale past the `text-4xl`
/// step Cairn stops at, and the surfaces are Cairn's own colours composited at
/// documented alphas. Nothing on this site picks a colour that is not either a
/// Cairn token or a blend of two of them.
abstract final class SiteTokens {
  /// The bundled Geist family. Cairn's tokens leave `fontFamily` null, so this
  /// is applied once via `CairnTheme.copyWith(fontFamily: ...)`.
  static const String fontFamily = 'Geist';

  /// Families the browser falls back to inside code blocks.
  static const List<String> monoFallback = <String>[
    'ui-monospace',
    'SFMono-Regular',
    'Menlo',
    'Consolas',
    'Liberation Mono',
    'monospace',
  ];

  /// `text-5xl` — 3rem / 1. Tailwind's next step above Cairn's `xl4`.
  static const TextStyle display1 = TextStyle(fontSize: 48.0, height: 1.0);

  /// `text-6xl` — 3.75rem / 1.
  static const TextStyle display2 = TextStyle(fontSize: 60.0, height: 1.0);

  /// `text-7xl` — 4.5rem / 1.
  static const TextStyle display3 = TextStyle(fontSize: 72.0, height: 1.0);

  /// The widest the reading column ever gets.
  static const double contentMaxWidth = 1280.0;

  /// The width of the docs sidebar on wide layouts.
  static const double sidebarWidth = 248.0;

  /// The width of the docs "On this page" rail.
  static const double tocWidth = 216.0;

  /// The sticky header's height — `h-14` on the spacing scale.
  static const double headerHeight = 56.0;

  /// The breakpoint above which the desktop nav and sidebars appear.
  static const double desktopBreakpoint = 1024.0;

  /// The breakpoint above which two-column marketing layouts split.
  static const double tabletBreakpoint = 768.0;

  /// Builds the [ThemeData] for a brightness, with Geist applied.
  static ThemeData themeData(Brightness brightness) {
    final CairnTheme base = brightness == Brightness.dark
        ? CairnTheme.dark
        : CairnTheme.light;
    return CairnTheme.materialTheme(base.copyWith(fontFamily: fontFamily));
  }
}

/// Site-level colour helpers derived from the ambient [CairnTheme].
extension SiteColors on CairnTheme {
  /// A surface that sits a half-step above [background] but below [card].
  ///
  /// The dark theme's `--card` (`#171717`) is a real step up from `--background`
  /// (`#0A0A0A`); in the light theme the two tokens are both pure white, so a
  /// card only reads as raised because of its border. This blend gives the site
  /// a subtle panel fill that behaves sensibly in both.
  Color get subtleSurface => brightness == Brightness.dark
      ? Color.alphaBlend(card.withValues(alpha: 0.6), background)
      : muted;

  /// The hairline used for large decorative rules (grid lines, the bento
  /// dividers). Softer than [border] so a full-width grid does not dominate.
  Color get hairline =>
      brightness == Brightness.dark ? border.withOpacityModifier(0.7) : border;

  /// The tint painted behind a hovered interactive surface.
  Color get hoverTint => brightness == Brightness.dark
      ? foreground.withValues(alpha: 0.04)
      : foreground.withValues(alpha: 0.03);
}
