/// `/sitemap.xml`, `/robots.txt` and `/manifest.webmanifest`.
///
/// All three are generated per request from the catalogue and the configured
/// `SITE_URL`, so they can never drift from the real pages or point at the
/// wrong origin in a deployment.
library;

import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../common/utils/escape.dart';
import '../core/config/brand.dart';
import '../core/config/store_config.dart';
import '../domain/catalog/catalog_repository.dart';
import '../domain/catalog/models/product.dart';

String _date(DateTime d) =>
    '${d.toUtc().year.toString().padLeft(4, '0')}-${d.toUtc().month.toString().padLeft(2, '0')}-${d.toUtc().day.toString().padLeft(2, '0')}';

/// One `<url>` entry. Exposed so tests and the SEO audit can reason about the
/// same data the XML is generated from.
class SitemapEntry {
  const SitemapEntry(this.path, this.lastModified, {this.changeFrequency, this.priority, this.images = const []});
  final String path;
  final DateTime lastModified;
  final String? changeFrequency;
  final double? priority;
  final List<({String path, String title})> images;
}

Future<List<SitemapEntry>> sitemapEntries(CatalogRepository catalog) async {
  final products = await catalog.allProducts();
  final categories = await catalog.categories();
  DateTime newest(Iterable<Product> ps) =>
      ps.fold(DateTime.utc(2000), (a, p) => p.updatedAt.isAfter(a) ? p.updatedAt : a);
  final site = newest(products);
  return [
    SitemapEntry('/', site, changeFrequency: 'daily', priority: 1.0),
    SitemapEntry('/products', site, changeFrequency: 'daily', priority: 0.9),
    for (final c in categories)
      SitemapEntry(
        '/categories/${c.slug}',
        newest(products.where((p) => p.categorySlug == c.slug)),
        changeFrequency: 'weekly',
        priority: 0.8,
      ),
    for (final p in products)
      SitemapEntry(
        '/products/${p.slug}',
        p.updatedAt,
        changeFrequency: 'weekly',
        priority: 0.7,
        images: [for (final i in p.images) (path: i.fallbackUrl, title: i.alt)],
      ),
    SitemapEntry('/about', DateTime.utc(2026, 3, 1), changeFrequency: 'yearly', priority: 0.4),
  ];
}

Future<Response> sitemapResponse(StoreConfig config, CatalogRepository catalog) async {
  final entries = await sitemapEntries(catalog);
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" '
      'xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">',
    );
  for (final e in entries) {
    b.writeln('  <url>');
    b.writeln('    <loc>${escapeXml(config.absoluteUrl(e.path))}</loc>');
    b.writeln('    <lastmod>${_date(e.lastModified)}</lastmod>');
    if (e.changeFrequency != null) b.writeln('    <changefreq>${e.changeFrequency}</changefreq>');
    if (e.priority != null) b.writeln('    <priority>${e.priority!.toStringAsFixed(1)}</priority>');
    for (final i in e.images) {
      b.writeln(
        '    <image:image><image:loc>${escapeXml(config.absoluteUrl(i.path))}</image:loc>'
        '<image:title>${escapeXml(i.title)}</image:title></image:image>',
      );
    }
    b.writeln('  </url>');
  }
  b.writeln('</urlset>');
  return Response.ok(
    b.toString(),
    headers: {
      'content-type': 'application/xml; charset=utf-8',
      'cache-control': 'public, max-age=3600',
    },
  );
}

String robotsTxt(StoreConfig config) => [
  'User-agent: *',
  'Allow: /',
  // Transactional and personal pages.
  'Disallow: /cart',
  'Disallow: /checkout',
  'Disallow: /newsletter',
  // Internal search and faceted URLs: an unbounded space of near-duplicates.
  'Disallow: /search',
  'Disallow: /*?q=',
  'Disallow: /*&q=',
  'Disallow: /*?sort=',
  'Disallow: /*&sort=',
  'Disallow: /*?theme=',
  '',
  'Sitemap: ${config.absoluteUrl('/sitemap.xml')}',
  '',
].join('\n');

Response robotsResponse(StoreConfig config) => Response.ok(
  robotsTxt(config),
  headers: {'content-type': 'text/plain; charset=utf-8', 'cache-control': 'public, max-age=3600'},
);

Response manifestResponse(StoreConfig config) => Response.ok(
  jsonEncode({
    'name': Brand.name,
    'short_name': Brand.shortName,
    'description': Brand.description,
    'start_url': '/',
    'scope': '/',
    'display': 'standalone',
    'lang': Brand.language,
    'background_color': Brand.themeColorLight,
    'theme_color': Brand.themeColorLight,
    'icons': [
      {'src': '/icons/icon-192.png', 'sizes': '192x192', 'type': 'image/png', 'purpose': 'any'},
      {'src': '/icons/icon-512.png', 'sizes': '512x512', 'type': 'image/png', 'purpose': 'any'},
      {'src': '/favicon.svg', 'sizes': 'any', 'type': 'image/svg+xml'},
    ],
  }),
  headers: {'content-type': 'application/manifest+json; charset=utf-8', 'cache-control': 'public, max-age=86400'},
);
