/// Turns a [SeoData] into `<head>` elements.
///
/// This is the part of the template that only exists because of SSR. In a
/// client-rendered app these tags are written by JavaScript after the document
/// has been delivered, so every non-Google crawler, link unfurler (Slack,
/// iMessage, LinkedIn) and "view source" sees an empty shell. Here they are in
/// the first byte of HTML.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../common/utils/escape.dart';
import '../../common/utils/text.dart';
import '../../core/config/brand.dart';
import '../../core/config/store_config.dart';
import '../../core/seo/seo_data.dart';
import '../components/html.dart';

/// `<title>` text: page title plus site suffix, cut on a word boundary so the
/// whole thing stays within ~60 characters.
String documentTitle(SeoData seo) {
  if (seo.fullTitle) return title60(seo.title);
  final suffix = ' | ${Brand.name}';
  return '${truncate(seo.title, kMaxTitleLength - suffix.length)}$suffix';
}

Component _meta({String? name, String? property, required String content, String? media}) => el(
  'meta',
  attrs: {
    'name': ?name,
    'property': ?property,
    'content': content,
    'media': ?media,
  },
);

/// All head elements except `<title>` and the viewport (Document provides those).
List<Component> buildHead(SeoData seo, StoreConfig config) {
  final canonical = config.absoluteUrl(seo.path);
  final description = description158(seo.description);
  final image = config.absoluteUrl(seo.imagePath ?? Brand.ogImagePath);
  final imageAlt = seo.imageAlt ?? Brand.ogImageAlt;
  final imageW = seo.imageWidth ?? (seo.imagePath == null ? Brand.ogImageWidth : null);
  final imageH = seo.imageHeight ?? (seo.imagePath == null ? Brand.ogImageHeight : null);
  final ogTitle = seo.fullTitle ? seo.title : seo.title;

  return [
    _meta(name: 'description', content: description),
    _meta(
      name: 'robots',
      content: seo.robots.isIndexable ? 'index, follow, max-image-preview:large' : seo.robots.content,
    ),
    _meta(name: 'theme-color', content: Brand.themeColorLight, media: '(prefers-color-scheme: light)'),
    _meta(name: 'theme-color', content: Brand.themeColorDark, media: '(prefers-color-scheme: dark)'),
    el('link', attrs: {'rel': 'canonical', 'href': canonical}),
    if (seo.prevPath != null) el('link', attrs: {'rel': 'prev', 'href': config.absoluteUrl(seo.prevPath!)}),
    if (seo.nextPath != null) el('link', attrs: {'rel': 'next', 'href': config.absoluteUrl(seo.nextPath!)}),
    // hreflang: a single-language store points at itself. Add entries to
    // `SeoData.hreflangPaths` when localised URLs exist.
    if (seo.hreflangPaths.isEmpty) ...[
      el('link', attrs: {'rel': 'alternate', 'hreflang': Brand.language, 'href': canonical}),
      el('link', attrs: {'rel': 'alternate', 'hreflang': 'x-default', 'href': canonical}),
    ] else ...[
      for (final e in seo.hreflangPaths.entries)
        el('link', attrs: {'rel': 'alternate', 'hreflang': e.key, 'href': config.absoluteUrl(e.value)}),
      el('link', attrs: {'rel': 'alternate', 'hreflang': 'x-default', 'href': canonical}),
    ],
    el('link', attrs: {'rel': 'icon', 'href': '/favicon.svg', 'type': 'image/svg+xml'}),
    el('link', attrs: {'rel': 'icon', 'href': '/favicon.ico', 'sizes': '48x48'}),
    el('link', attrs: {'rel': 'apple-touch-icon', 'href': '/icons/apple-touch-icon.png'}),
    el('link', attrs: {'rel': 'manifest', 'href': '/manifest.webmanifest'}),
    if (seo.preloadImage != null)
      el(
        'link',
        attrs: {
          'rel': 'preload',
          'as': 'image',
          'type': 'image/webp',
          'imagesrcset': seo.preloadImage!.srcset,
          'imagesizes': seo.preloadImage!.sizes,
          'fetchpriority': 'high',
        },
      ),
    // Open Graph
    _meta(property: 'og:type', content: seo.ogType),
    _meta(property: 'og:site_name', content: Brand.name),
    _meta(property: 'og:locale', content: Brand.locale),
    _meta(property: 'og:title', content: ogTitle),
    _meta(property: 'og:description', content: description),
    _meta(property: 'og:url', content: canonical),
    _meta(property: 'og:image', content: image),
    _meta(property: 'og:image:alt', content: imageAlt),
    if (imageW != null) _meta(property: 'og:image:width', content: '$imageW'),
    if (imageH != null) _meta(property: 'og:image:height', content: '$imageH'),
    for (final e in seo.openGraph.entries) _meta(property: e.key, content: e.value),
    // Twitter / X
    _meta(name: 'twitter:card', content: 'summary_large_image'),
    _meta(name: 'twitter:site', content: Brand.twitterHandle),
    _meta(name: 'twitter:title', content: ogTitle),
    _meta(name: 'twitter:description', content: description),
    _meta(name: 'twitter:image', content: image),
    _meta(name: 'twitter:image:alt', content: imageAlt),
    // JSON-LD. `safeJsonForScript` escapes `<` so a product name cannot close the tag.
    for (final ld in seo.jsonLd)
      el('script', attrs: const {'type': 'application/ld+json'}, children: [RawText(safeJsonForScript(ld))]),
  ];
}
