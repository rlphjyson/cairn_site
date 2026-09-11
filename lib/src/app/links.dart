import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

/// Every off-site URL the site links to.
abstract final class SiteLinks {
  /// The library this site documents.
  static const String libraryRepo = 'https://github.com/rlphjyson/cairn_ui';

  /// This site's own source.
  static const String siteRepo = 'https://github.com/rlphjyson/cairn_site';

  /// The exact commit the site's `pubspec.yaml` pins.
  static const String pinnedCommit =
      'https://github.com/rlphjyson/cairn_ui/commit/'
      '7abb0cc70dea5daaeefda0a93ae94e0c0d2bf737';

  /// The short form of [pinnedCommit], for display.
  static const String pinnedCommitShort = '7abb0cc';

  /// The project Cairn measures itself against.
  static const String shadcn = 'https://ui.shadcn.com';

  /// The accessibility behaviour shadcn/ui is built on.
  static const String radix = 'https://www.radix-ui.com';

  /// The bundled typeface.
  static const String geist = 'https://vercel.com/font';

  /// The icon geometry Cairn redraws.
  static const String lucide = 'https://lucide.dev';

  /// Flutter's charting package, restyled on this site's Charts page.
  static const String flChart = 'https://pub.dev/packages/fl_chart';

  /// The library's MIT licence.
  static const String licence =
      'https://github.com/rlphjyson/cairn_ui/blob/main/LICENSE';

  /// The library's third-party attribution file.
  static const String notice =
      'https://github.com/rlphjyson/cairn_ui/blob/main/NOTICE.md';
}

/// Opens [url] in a new browser tab.
void openExternal(String url) {
  unawaited(
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).then<void>((bool _) {}, onError: (Object _) {}),
  );
}
