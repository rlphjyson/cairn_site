/// Light/dark toggle: island #1.
///
/// The theme is stored in a script-readable (not httpOnly) cookie on purpose:
/// it is a display preference, not a credential, and the *server* reads it to
/// stamp `data-theme` onto `<html>` before first paint, which is what avoids the
/// dark-mode flash. With JavaScript off the OS preference
/// (`prefers-color-scheme`) still applies; the button simply is not hydrated.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../components/icons.dart';

/// Name of the theme preference cookie.
const String kThemeCookieName = 'theme';

@client
class ThemeToggle extends StatefulComponent {
  const ThemeToggle({this.initialTheme = 'system', super.key});

  /// `light`, `dark` or `system`, resolved on the server from the cookie so the
  /// button renders in the right state before hydration.
  final String initialTheme;

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> {
  late String _theme = component.initialTheme;

  bool get _isDark {
    if (_theme == 'dark') return true;
    if (_theme == 'light') return false;
    if (!kIsWeb) return false;
    return web.window.matchMedia('(prefers-color-scheme: dark)').matches;
  }

  void _toggle() {
    final next = _isDark ? 'light' : 'dark';
    setState(() => _theme = next);
    if (!kIsWeb) return;
    web.document.documentElement?.setAttribute('data-theme', next);
    web.document.cookie = '$kThemeCookieName=$next; Path=/; Max-Age=31536000; SameSite=Lax';
  }

  @override
  Component build(BuildContext context) {
    final dark = _isDark;
    return button(
      type: ButtonType.button,
      classes: 'icon-btn theme-toggle',
      attributes: {
        'aria-label': dark ? 'Switch to light theme' : 'Switch to dark theme',
        'title': dark ? 'Light theme' : 'Dark theme',
      },
      onClick: _toggle,
      [dark ? Icons.sun() : Icons.moon()],
    );
  }
}
