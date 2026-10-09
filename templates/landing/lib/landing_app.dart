import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/di/landing_injection.dart';
import 'core/presentation/view_model.dart';
import 'presentation/shell/landing_providers.dart';
import 'presentation/shell/landing_shell.dart';

/// A SaaS landing page, built only from `cairn_ui` and Cairn tokens.
///
/// A sticky navbar whose links scroll to the sections (with the active one
/// highlighted and a menu sheet on phones), a hero with a product mockup, a
/// logo cloud, features with image spotlights, how it works, numbers,
/// testimonials, pricing with a monthly/yearly toggle, an FAQ, a waitlist form
/// and a footer.
///
/// It fills whatever space its parent gives it and adapts to that width, so it
/// works as a whole page or inside a frame. All copy lives in the in-memory
/// data sources under `lib/data/*/remote/`.
///
/// Links in the content that start with `#` scroll to the section with that
/// id. Every other link is passed to [onLink], where the host decides what to
/// do with it (open a URL, push a route, start a checkout).
///
/// Organised as clean architecture, by layer and then by feature; see the
/// README next to this file.
class LandingApp extends StatefulWidget {
  /// Creates the page.
  const LandingApp({
    super.key,
    this.onLink,
    this.initialSection,
    this.onSectionChanged,
    this.overrides,
  });

  /// Called with the `href` of any content link that is not a `#` anchor.
  final ValueChanged<String>? onLink;

  /// The id of a section to scroll to shortly after the page first builds, for
  /// deep links such as `/pricing`. See `SectionIds` for the ids.
  final String? initialSection;

  /// Called with the id of the section at the top of the viewport whenever it
  /// changes, for example to keep the URL in step with the scroll position.
  final ValueChanged<String>? onSectionChanged;

  /// Swaps dependencies before the page builds: unregister a data source and
  /// register your own. Runs once, when the page is first mounted.
  ///
  /// ```dart
  /// LandingApp(
  ///   overrides: (GetIt locator) => locator
  ///     ..unregister<WaitlistRemoteDataSource>()
  ///     ..registerLazySingleton<WaitlistRemoteDataSource>(MyWaitlist.new),
  /// )
  /// ```
  final void Function(GetIt locator)? overrides;

  @override
  State<LandingApp> createState() => _LandingAppState();
}

class _LandingAppState extends State<LandingApp> {
  late final GetIt _locator = createLandingLocator(overrides: widget.overrides);

  @override
  void dispose() {
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LandingScope(
    locator: _locator,
    child: LandingProviders(
      locator: _locator,
      child: LandingShell(
        onLink: widget.onLink,
        initialSection: widget.initialSection,
        onSectionChanged: widget.onSectionChanged,
      ),
    ),
  );
}
