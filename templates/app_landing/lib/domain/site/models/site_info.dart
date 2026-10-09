import 'package:equatable/equatable.dart';

import '../../shared/models/link.dart';

/// The two app stores.
enum StoreKind {
  /// The iOS store.
  appStore,

  /// The Android store.
  googlePlay,
}

/// One store button: what it says and where it goes.
class StoreLink extends Equatable {
  /// Creates a store link.
  const StoreLink({
    required this.caption,
    required this.label,
    required this.icon,
    required this.href,
  });

  /// The small line above the name, such as `Download on the`.
  final String caption;

  /// The store name, such as `App Store`.
  final String label;

  /// The glyph name (see `AppLandingIcons`).
  final String icon;

  /// The listing URL.
  final String href;

  /// The full phrase a screen reader reads: `Download on the App Store`.
  String get spoken => '$caption $label';

  @override
  List<Object?> get props => <Object?>[caption, label, icon, href];
}

/// The brand, the navbar and the store listings.
///
/// This is the one place that names the app: the hero, the navbar, the
/// download section and the footer all read it.
class SiteInfo extends Equatable {
  /// Creates the site info.
  const SiteInfo({
    required this.brandName,
    required this.brandIcon,
    required this.tagline,
    required this.navLinks,
    required this.cta,
    required this.appStore,
    required this.googlePlay,
  });

  /// The app name.
  final String brandName;

  /// The icon name for the logo mark (see `AppLandingIcons`).
  final String brandIcon;

  /// A one-line description of the app.
  final String tagline;

  /// The navbar links; `#` hrefs scroll to a section.
  final List<Link> navLinks;

  /// The primary navbar button.
  final Link cta;

  /// The App Store button.
  final StoreLink appStore;

  /// The Google Play button.
  final StoreLink googlePlay;

  /// The link for [store].
  StoreLink storeFor(StoreKind store) => switch (store) {
    StoreKind.appStore => appStore,
    StoreKind.googlePlay => googlePlay,
  };

  @override
  List<Object?> get props => <Object?>[
    brandName,
    brandIcon,
    tagline,
    navLinks,
    cta,
    appStore,
    googlePlay,
  ];
}
