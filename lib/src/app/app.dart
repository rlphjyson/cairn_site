import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'routes.dart';
import 'site_theme.dart';

/// The site.
///
/// Two [ThemeData]s built from `CairnTheme.light` / `CairnTheme.dark` with
/// Geist applied, a [SiteThemeController] that defaults to dark, and a
/// [CairnToaster] installed above the Navigator so a toast fired from a code
/// block survives the route that fired it.
class CairnSiteApp extends StatefulWidget {
  /// Creates the app.
  const CairnSiteApp({super.key, this.initialLocation = Routes.home});

  /// Where to start. Overridden by widget tests to boot straight into a route.
  final String initialLocation;

  @override
  State<CairnSiteApp> createState() => _CairnSiteAppState();
}

class _CairnSiteAppState extends State<CairnSiteApp> {
  final SiteThemeController _theme = SiteThemeController();
  late final GoRouter _router = buildRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _theme.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _theme,
      builder: (BuildContext context, Widget? _) => MaterialApp.router(
        title: 'Cairn UI',
        debugShowCheckedModeBanner: false,
        theme: SiteTokens.themeData(Brightness.light),
        darkTheme: SiteTokens.themeData(Brightness.dark),
        // Dark by default. Not ThemeMode.system — a first-time visitor should
        // always land on the dark treatment regardless of their OS setting.
        themeMode: _theme.mode,
        routerConfig: _router,
        builder: (BuildContext context, Widget? child) => SiteTheme(
          controller: _theme,
          child: CairnToaster(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
