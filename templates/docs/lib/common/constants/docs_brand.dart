/// The product the documentation is about. Change these to rebrand the site.
abstract final class DocsBrand {
  /// Shown next to the logo mark in the top bar.
  static const String name = 'Acme SDK';

  /// One line under the product name where a tagline is needed (the 404 page,
  /// the drawer header).
  static const String tagline = 'Documentation';

  /// The first letter drawn inside the logo mark. Replace the mark in
  /// `core/presentation/widgets/brand_mark.dart` to use a real logo.
  static const String monogram = 'A';

  /// The version a visitor lands on. It must be the id of a version the data
  /// source returns; `domain_test.dart` checks that it is the latest one.
  static const String defaultVersionId = 'v2.0';

  /// The page a visitor lands on, and where "Go home" links point.
  static const String homeSlug = 'introduction';
}
