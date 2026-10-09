/// Behaviour that is not copy: sizes and limits.
abstract final class BlogConfig {
  /// Posts per page in the grid.
  static const int pageSize = 6;

  /// How many related posts the detail page shows.
  static const int relatedCount = 3;

  /// The widest the page content grows.
  static const double maxContentWidth = 1200;

  /// The width of the article text column.
  static const double articleWidth = 720;

  /// Words per minute used for the reading time.
  static const int wordsPerMinute = 200;
}
