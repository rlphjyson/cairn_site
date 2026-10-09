/// Responsive images.
///
/// Every image the store renders goes through [ResponsiveImage], so the rules
/// that protect Core Web Vitals live in one place:
///  * explicit `width`/`height` (the browser reserves the box: no layout shift),
///  * `<picture>` with a WebP `srcset` and a JPEG fallback,
///  * `loading="lazy"` + `decoding="async"` by default; the LCP image opts in
///    to `priority` and gets `fetchpriority="high"` and no lazy loading,
///  * descriptive `alt` text (decorative images pass an empty alt on purpose).
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/catalog/models/product.dart';
import '../theme/tokens.dart';
import 'html.dart';

class ResponsiveImage extends StatelessComponent {
  const ResponsiveImage({
    required this.image,
    required this.sizes,
    this.priority = false,
    this.classes,
    this.altOverride,
    super.key,
  });

  final ProductImage image;

  /// The `sizes` attribute: how wide the image renders at each breakpoint.
  final String sizes;

  /// True for the single above-the-fold (LCP) image on a page.
  final bool priority;
  final String? classes;

  /// Pass `''` to mark an image decorative.
  final String? altOverride;

  @override
  Component build(BuildContext context) {
    return el(
      'picture',
      classes: classes,
      children: [
        el('source', attrs: {'type': 'image/webp', 'srcset': image.srcset, 'sizes': sizes}),
        el(
          'img',
          attrs: {
            'src': image.fallbackUrl,
            'alt': altOverride ?? image.alt,
            'width': '${image.width}',
            'height': '${image.height}',
            'decoding': 'async',
            if (priority) 'fetchpriority': 'high' else 'loading': 'lazy',
          },
        ),
      ],
    );
  }
}

/// A wide image (the home hero) with several widths.
class HeroImage extends StatelessComponent {
  const HeroImage({super.key});

  static const List<int> widths = [640, 960, 1280, 1600];
  static const int width = 1600;
  static const int height = 1069;
  static const String alt = 'A tidy desk with a notebook, a mug and a plant in soft daylight';
  static String get srcset => widths.map((w) => '/images/hero/hero-$w.webp ${w}w').join(', ');
  static const String sizes = '(min-width: 64rem) 50vw, 100vw';

  @override
  Component build(BuildContext context) {
    return el(
      'picture',
      classes: 'hero__picture',
      children: [
        el('source', attrs: {'type': 'image/webp', 'srcset': srcset, 'sizes': sizes}),
        el(
          'img',
          attrs: {
            'src': '/images/hero/hero.jpg',
            'alt': alt,
            'width': '$width',
            'height': '$height',
            'decoding': 'async',
            'fetchpriority': 'high',
          },
        ),
      ],
    );
  }
}

@css
List<StyleRule> get mediaStyles => [
  rule('.media', {
    'position': 'relative',
    'overflow': 'hidden',
    'aspect-ratio': '1 / 1',
    'background': Tok.muted,
    'border-radius': Tok.radiusLg,
  }),
  rule('.media picture, .media img', {'width': '100%', 'height': '100%'}),
  rule('.media img', {'object-fit': 'cover'}),
  rule('.hero__picture, .hero__picture img', {'width': '100%', 'height': '100%'}),
  rule('.hero__picture img', {'object-fit': 'cover'}),
];
