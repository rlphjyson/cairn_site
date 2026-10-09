import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/di/app_landing_injection.dart';
import 'core/presentation/view_model.dart';
import 'data/content/remote/app_content_data_source.dart';
import 'data/download/remote/download_link_service.dart';
import 'domain/site/models/site_info.dart';
import 'presentation/shell/app_landing_providers.dart';
import 'presentation/shell/app_landing_shell.dart';

/// A landing page for a mobile app, built only from `cairn_ui` and Cairn
/// tokens.
///
/// A sticky navbar whose links scroll to the sections (with the active one
/// highlighted and a menu sheet on phones), a hero with two live phone mockups
/// and store buttons, press and awards, a tabbed feature showcase, how it
/// works, a screenshots gallery, numbers, reviews with a rating breakdown,
/// pricing with a monthly/yearly toggle, an FAQ, a get-the-app section with a
/// send-me-the-link form and a QR card, and a footer.
///
/// It fills whatever space its parent gives it and adapts to that width, so it
/// works as a whole page or inside a frame. All copy lives in one in-memory
/// content document, `lib/data/content/remote/app_content_json.dart`.
///
/// Links in the content that start with `#` scroll to the section with that
/// id. Every other link (a pricing button, a footer link) goes to
/// [onCtaTap]; the two store buttons go to [onStoreTap]. The host decides what
/// to do with them: open a URL, push a route, start a purchase.
///
/// Organised as clean architecture, by layer and then by feature; see the
/// README next to this file.
class AppLandingApp extends StatefulWidget {
  /// Creates the page.
  const AppLandingApp({
    super.key,
    this.contentDataSource,
    this.linkService,
    this.onStoreTap,
    this.onCtaTap,
    this.initialSection,
    this.onSectionChanged,
    this.overrides,
  });

  /// Where the page's copy comes from. Defaults to the in-memory demo content;
  /// pass your own to serve the page from a CMS or an API.
  final AppContentDataSource? contentDataSource;

  /// Sends the download link to an email address or a phone number. Defaults to
  /// a stand-in that pretends to send; pass your own to go live.
  final DownloadLinkService? linkService;

  /// Called when a store button is pressed, with which store and its listing
  /// URL from the content.
  final void Function(StoreKind store, String href)? onStoreTap;

  /// Called with the `href` of any content link that is not a `#` anchor:
  /// pricing buttons, footer links, the navbar button when it points away.
  final ValueChanged<String>? onCtaTap;

  /// The id of a section to scroll to shortly after the page first builds, for
  /// deep links such as `/pricing`. See `SectionIds` for the ids.
  final String? initialSection;

  /// Called with the id of the section at the top of the viewport whenever it
  /// changes, for example to keep the URL in step with the scroll position.
  final ValueChanged<String>? onSectionChanged;

  /// Swaps any other dependency before the page builds: unregister it and
  /// register your own. Runs once, when the page is first mounted.
  ///
  /// ```dart
  /// AppLandingApp(
  ///   overrides: (GetIt locator) => locator
  ///     ..unregister<CalculatePrice>()
  ///     ..registerFactory<CalculatePrice>(MyCalculatePrice.new),
  /// )
  /// ```
  final void Function(GetIt locator)? overrides;

  @override
  State<AppLandingApp> createState() => _AppLandingAppState();
}

class _AppLandingAppState extends State<AppLandingApp> {
  late final GetIt _locator = createAppLandingLocator(
    contentDataSource: widget.contentDataSource,
    linkService: widget.linkService,
    overrides: widget.overrides,
  );

  @override
  void dispose() {
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppLandingScope(
    locator: _locator,
    child: AppLandingProviders(
      locator: _locator,
      child: AppLandingShell(
        onStoreTap: widget.onStoreTap,
        onCtaTap: widget.onCtaTap,
        initialSection: widget.initialSection,
        onSectionChanged: widget.onSectionChanged,
      ),
    ),
  );
}
