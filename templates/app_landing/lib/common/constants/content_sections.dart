/// The keys of the content document, one per feature.
///
/// `AppContentDataSource.fetchSection` is called with one of these. A backend
/// or CMS only has to answer to these names.
abstract final class ContentSections {
  /// Brand, navbar and store links.
  static const String site = 'site';

  /// The hero.
  static const String hero = 'hero';

  /// Press mentions and awards.
  static const String trust = 'trust';

  /// The feature showcase.
  static const String features = 'features';

  /// The three steps.
  static const String howItWorks = 'howItWorks';

  /// The screenshots gallery.
  static const String gallery = 'gallery';

  /// The numbers band.
  static const String stats = 'stats';

  /// Reviews and the rating distribution.
  static const String reviews = 'reviews';

  /// Plans and prices.
  static const String pricing = 'pricing';

  /// Questions and answers.
  static const String faq = 'faq';

  /// The send-me-the-link form and the QR card.
  static const String download = 'download';

  /// The footer.
  static const String footer = 'footer';
}
