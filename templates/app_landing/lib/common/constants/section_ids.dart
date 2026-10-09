/// The anchor id of every section on the page.
///
/// Links in the content point at these ids with a `#` prefix (for example
/// `#pricing`). Add an id here, give the section a key in
/// `presentation/shell/app_landing_page.dart`, and it can be linked to.
abstract final class SectionIds {
  /// The hero.
  static const String hero = 'hero';

  /// The press and awards strip.
  static const String trust = 'trust';

  /// The feature showcase.
  static const String features = 'features';

  /// The three-step explainer.
  static const String howItWorks = 'how-it-works';

  /// The screenshots gallery.
  static const String gallery = 'gallery';

  /// The numbers band.
  static const String stats = 'stats';

  /// Ratings and reviews.
  static const String reviews = 'reviews';

  /// Free and Premium.
  static const String pricing = 'pricing';

  /// Frequently asked questions.
  static const String faq = 'faq';

  /// Send me the link, the QR card and the store buttons.
  static const String download = 'download';

  /// The footer.
  static const String footer = 'footer';

  /// Every section, top to bottom.
  static const List<String> all = <String>[
    hero,
    trust,
    features,
    howItWorks,
    gallery,
    stats,
    reviews,
    pricing,
    faq,
    download,
    footer,
  ];
}
