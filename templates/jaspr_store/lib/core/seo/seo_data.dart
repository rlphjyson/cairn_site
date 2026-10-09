/// Everything a page tells crawlers and link unfurlers, as plain data.
///
/// Controllers build a [SeoData]; `presentation/seo/seo_head.dart` turns it
/// into `<head>` elements. Keeping it as data (not components) means the SEO
/// rules are unit-testable without rendering anything.
library;

import 'package:meta/meta.dart';

enum RobotsPolicy {
  indexed('index, follow'),

  /// Keep out of the index but let crawlers follow links (faceted/search pages).
  noIndexFollow('noindex, follow'),

  /// Private or transactional pages (cart, checkout, confirmation).
  noIndexNoFollow('noindex, nofollow');

  const RobotsPolicy(this.content);
  final String content;

  bool get isIndexable => this == RobotsPolicy.indexed;
}

@immutable
class SeoData {
  const SeoData({
    required this.title,
    required this.description,
    required this.path,
    this.robots = RobotsPolicy.indexed,
    this.ogType = 'website',
    this.imagePath,
    this.imageAlt,
    this.imageWidth,
    this.imageHeight,
    this.fullTitle = false,
    this.openGraph = const {},
    this.jsonLd = const [],
    this.prevPath,
    this.nextPath,
    this.preloadImage,
    this.hreflangPaths = const {},
  });

  /// Page title without the site suffix (the suffix is appended unless [fullTitle]).
  final String title;
  final String description;

  /// Site-relative canonical URL, path plus the (already-cleaned) query.
  final String path;
  final RobotsPolicy robots;
  final String ogType;

  /// Site-relative image path; falls back to the brand OG image.
  final String? imagePath;
  final String? imageAlt;
  final int? imageWidth;
  final int? imageHeight;

  /// When true, [title] is used as-is (home page: "Brand: tagline").
  final bool fullTitle;

  /// Extra Open Graph properties, e.g. `product:price:amount`.
  final Map<String, String> openGraph;

  /// JSON-LD objects; each becomes its own `<script type="application/ld+json">`.
  final List<Map<String, Object?>> jsonLd;
  final String? prevPath;
  final String? nextPath;

  /// A responsive image to `<link rel=preload>` (the LCP candidate).
  final PreloadImage? preloadImage;

  /// language -> site-relative path. Empty for a single-language store; the
  /// hook exists so adding `/fr/...` URLs later is a data change, not a rewrite.
  final Map<String, String> hreflangPaths;
}

@immutable
class PreloadImage {
  const PreloadImage({required this.srcset, required this.sizes, required this.fallbackUrl});
  final String srcset;
  final String sizes;
  final String fallbackUrl;
}
