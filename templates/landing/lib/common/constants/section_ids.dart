/// The anchor id of every section on the page.
///
/// Navigation links in the content point at these ids with a `#` prefix (for
/// example `#pricing`). Add an id here, give the section a key in
/// `presentation/shell/landing_page.dart`, and it can be linked to.
abstract final class SectionIds {
  /// The hero.
  static const String hero = 'hero';

  /// The trusted-by logo cloud.
  static const String logos = 'logos';

  /// Features and spotlights.
  static const String features = 'features';

  /// The three-step explainer.
  static const String howItWorks = 'how-it-works';

  /// The numbers band.
  static const String stats = 'stats';

  /// Customer quotes.
  static const String testimonials = 'testimonials';

  /// Plans and prices.
  static const String pricing = 'pricing';

  /// Frequently asked questions.
  static const String faq = 'faq';

  /// The waitlist call to action.
  static const String waitlist = 'waitlist';

  /// The footer.
  static const String footer = 'footer';

  /// Every section, top to bottom.
  static const List<String> all = <String>[
    hero,
    logos,
    features,
    howItWorks,
    stats,
    testimonials,
    pricing,
    faq,
    waitlist,
    footer,
  ];
}
