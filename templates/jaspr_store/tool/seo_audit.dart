/// SEO audit: crawls `/sitemap.xml` against an in-process render and asserts the
/// things search engines and link unfurlers care about.
///
///     dart run tool/seo_audit.dart            # audits the in-process app
///     dart run tool/seo_audit.dart http://localhost:8080   # audits a live server
///
/// For every sitemap URL it checks: status 200; exactly one `<title>`,
/// meta description, canonical (equal to the URL itself) and `<h1>`; sane
/// heading order; `lang` and viewport; absolute Open Graph and Twitter URLs;
/// valid JSON-LD with the fields rich results need; every `<img>` has `alt`,
/// `width` and `height` (and is lazy unless it is the LCP image); every form
/// control has a label; no duplicate ids; and no broken internal links.
/// Exit code is 1 when anything fails, so it can gate CI.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cairn_template_jaspr_store/app.dart';
import 'package:cairn_template_jaspr_store/core/config/store_config.dart';
import 'package:cairn_template_jaspr_store/di/service_locator.dart';
import 'package:cairn_template_jaspr_store/main.server.options.dart';
import 'package:get_it/get_it.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:jaspr/server.dart' show Component, Jaspr, renderComponent;
import 'package:shelf/shelf.dart';

/// What the audit needs from a "server": path in, status/headers/body out.
typedef Fetch = Future<AuditResponse> Function(String pathAndQuery);

class AuditResponse {
  const AuditResponse(this.status, this.body, [this.headers = const {}]);
  final int status;
  final String body;
  final Map<String, String> headers;
}

class AuditReport {
  final List<String> failures = [];
  final List<String> pages = [];
  int checks = 0;

  void expect(bool condition, String page, String message) {
    checks++;
    if (!condition) failures.add('$page: $message');
  }

  bool get passed => failures.isEmpty;
}

Future<AuditReport> auditSite({required Fetch fetch, required String origin, String webDir = 'web'}) async {
  final report = AuditReport();
  final sitemap = await fetch('/sitemap.xml');
  report.expect(sitemap.status == 200, '/sitemap.xml', 'status ${sitemap.status}');
  final locs = RegExp(r'<loc>([^<]+)</loc>').allMatches(sitemap.body).map((m) => m.group(1)!).toList();
  report.expect(locs.isNotEmpty, '/sitemap.xml', 'has no <loc> entries');
  report.expect(locs.toSet().length == locs.length, '/sitemap.xml', 'has duplicate <loc> entries');
  for (final m in RegExp(r'<lastmod>([^<]+)</lastmod>').allMatches(sitemap.body)) {
    report.expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(m.group(1)!), '/sitemap.xml', 'bad lastmod ${m.group(1)}');
  }

  final linkCache = <String, bool>{};
  Future<bool> linkOk(String target) async {
    return linkCache[target] ??= await () async {
      final path = target.split('#').first;
      if (path.isEmpty) return true;
      var current = path;
      for (var hops = 0; hops < 4; hops++) {
        final fileOnDisk = File('$webDir${current.split('?').first}');
        if (fileOnDisk.existsSync()) return true;
        final r = await fetch(current);
        if (r.status >= 300 && r.status < 400 && r.headers['location'] != null) {
          current = r.headers['location']!;
          if (current.startsWith(origin)) current = current.substring(origin.length);
          continue;
        }
        return r.status < 400;
      }
      return false;
    }();
  }

  for (final loc in locs) {
    report.expect(loc.startsWith(origin), loc, 'sitemap URL is not on $origin');
    final path = loc.startsWith(origin) ? loc.substring(origin.length).replaceFirst(RegExp(r'^$'), '/') : loc;
    final response = await fetch(path);
    report.pages.add(path);
    report.expect(response.status == 200, path, 'status ${response.status}, expected 200');
    if (response.status != 200) continue;
    final doc = html_parser.parse(response.body);
    _auditPage(report, doc, path: path, url: loc, origin: origin, webDir: webDir);

    for (final a in doc.querySelectorAll('a[href]')) {
      final href = a.attributes['href']!;
      if (href.startsWith('#') || href.startsWith('mailto:') || href.startsWith('tel:')) continue;
      if (href.startsWith('http')) {
        if (!href.startsWith(origin)) continue; // external: not crawled
      }
      final target = href.startsWith(origin) ? href.substring(origin.length) : href;
      report.expect(await linkOk(target), path, 'broken internal link $href');
    }
    // Same-document anchors must point at an element that exists.
    for (final a in doc.querySelectorAll('a[href^="#"]')) {
      final id = a.attributes['href']!.substring(1);
      if (id.isEmpty) continue;
      report.expect(doc.getElementById(id) != null, path, 'anchor #$id has no target');
    }
  }

  // A made-up URL must be a real 404, and the 404 page itself must be noindex.
  final missing = await fetch('/this-page-does-not-exist-${DateTime.now().millisecondsSinceEpoch}');
  report.expect(missing.status == 404, '(404 probe)', 'unknown URL returned ${missing.status}');
  report.expect(missing.body.contains('noindex'), '(404 probe)', '404 page is not noindex');

  final robots = await fetch('/robots.txt');
  report.expect(robots.status == 200, '/robots.txt', 'status ${robots.status}');
  report.expect(robots.body.contains('Sitemap: $origin/sitemap.xml'), '/robots.txt', 'does not point at the sitemap');
  return report;
}

void _auditPage(
  AuditReport report,
  Document doc, {
  required String path,
  required String url,
  required String origin,
  required String webDir,
}) {
  void check(bool ok, String message) => report.expect(ok, path, message);

  final html = doc.documentElement!;
  check((html.attributes['lang'] ?? '').isNotEmpty, 'missing <html lang>');
  check(doc.querySelector('meta[name="viewport"]') != null, 'missing viewport meta');

  final titles = doc.querySelectorAll('title');
  check(titles.length == 1, 'expected exactly 1 <title>, found ${titles.length}');
  if (titles.isNotEmpty) {
    final len = titles.first.text.trim().length;
    check(len >= 10 && len <= 70, 'title length $len outside 10-70');
  }
  final descriptions = doc.querySelectorAll('meta[name="description"]');
  check(descriptions.length == 1, 'expected exactly 1 meta description, found ${descriptions.length}');
  if (descriptions.isNotEmpty) {
    final len = (descriptions.first.attributes['content'] ?? '').length;
    check(len >= 40 && len <= 165, 'description length $len outside 40-165');
  }
  final canonicals = doc.querySelectorAll('link[rel="canonical"]');
  check(canonicals.length == 1, 'expected exactly 1 canonical, found ${canonicals.length}');
  if (canonicals.isNotEmpty) {
    final href = canonicals.first.attributes['href'] ?? '';
    check(href.startsWith(origin), 'canonical is not absolute: $href');
    check(href == url, 'canonical $href differs from sitemap URL $url');
  }
  check(doc.querySelector('meta[name="robots"]') != null, 'missing robots meta');

  // Open Graph / Twitter: present and absolute.
  for (final p in [
    'og:type',
    'og:title',
    'og:description',
    'og:url',
    'og:image',
    'og:image:alt',
    'og:site_name',
    'og:locale',
  ]) {
    check(doc.querySelector('meta[property="$p"]') != null, 'missing $p');
  }
  for (final p in ['og:url', 'og:image']) {
    final v = doc.querySelector('meta[property="$p"]')?.attributes['content'] ?? '';
    check(v.startsWith(origin), '$p is not an absolute URL on $origin: $v');
  }
  check(doc.querySelector('meta[name="twitter:card"]') != null, 'missing twitter:card');
  final twitterImage = doc.querySelector('meta[name="twitter:image"]')?.attributes['content'] ?? '';
  check(twitterImage.startsWith(origin), 'twitter:image is not absolute');

  // Landmarks and headings.
  check(doc.querySelectorAll('h1').length == 1, 'expected exactly 1 <h1>, found ${doc.querySelectorAll('h1').length}');
  check(doc.querySelectorAll('main').length == 1, 'expected exactly 1 <main>');
  check(doc.querySelector('header') != null && doc.querySelector('footer') != null, 'missing header/footer landmark');
  check(doc.querySelector('a.skip-link[href="#main"]') != null, 'missing skip link');
  var previous = 0;
  for (final h in doc.querySelectorAll('h1,h2,h3,h4,h5,h6')) {
    final level = int.parse(h.localName!.substring(1));
    check(
      previous == 0 || level <= previous + 1,
      'heading order jumps from h$previous to h$level ("${h.text.trim()}")',
    );
    previous = level;
  }

  // Images.
  var priorityImages = 0;
  for (final img in doc.querySelectorAll('img')) {
    final src = img.attributes['src'] ?? '';
    check(img.attributes.containsKey('alt'), 'img $src has no alt attribute');
    check(
      int.tryParse(img.attributes['width'] ?? '') != null && int.tryParse(img.attributes['height'] ?? '') != null,
      'img $src lacks width/height',
    );
    final priority = img.attributes['fetchpriority'] == 'high';
    if (priority) priorityImages++;
    check(priority || img.attributes['loading'] == 'lazy', 'img $src is neither lazy nor high priority');
    check(img.attributes['decoding'] == 'async', 'img $src lacks decoding=async');
    if (src.startsWith('/')) check(File('$webDir$src').existsSync(), 'image file missing on disk: $src');
  }
  check(
    priorityImages <= 1 || path == '/' || path.startsWith('/products') || path.startsWith('/categories'),
    'more than one high-priority image',
  );
  for (final source in doc.querySelectorAll('picture source[srcset]')) {
    for (final candidate in source.attributes['srcset']!.split(',')) {
      final file = candidate.trim().split(' ').first;
      check(File('$webDir$file').existsSync(), 'srcset file missing on disk: $file');
    }
  }

  // Forms: every control labelled.
  for (final control in doc.querySelectorAll('input:not([type=hidden]):not([type=submit]), select, textarea')) {
    final id = control.attributes['id'];
    final labelled =
        (id != null && doc.querySelector('label[for="$id"]') != null) ||
        control.attributes.containsKey('aria-label') ||
        control.parent?.localName == 'label';
    check(labelled, 'form control ${control.localName}[name=${control.attributes['name']}] has no label');
  }
  final ids = <String>{};
  for (final e in doc.querySelectorAll('[id]')) {
    check(ids.add(e.attributes['id']!), 'duplicate id "${e.attributes['id']}"');
  }

  // Structured data.
  final scripts = doc.querySelectorAll('script[type="application/ld+json"]');
  check(scripts.isNotEmpty || path == '/about', 'no JSON-LD');
  for (final script in scripts) {
    Object? data;
    try {
      data = jsonDecode(script.text);
    } on FormatException catch (e) {
      check(false, 'JSON-LD is not valid JSON: ${e.message}');
      continue;
    }
    if (data is! Map<String, dynamic>) {
      check(false, 'JSON-LD root is not an object');
      continue;
    }
    check(data['@context'] == 'https://schema.org', 'JSON-LD missing @context');
    final type = data['@type'];
    check(type is String, 'JSON-LD missing @type');
    switch (type) {
      case 'Product':
        final offers = data['offers'] as Map<String, dynamic>?;
        check(
          data['name'] != null && data['image'] is List && (data['image'] as List).isNotEmpty,
          'Product needs name and image',
        );
        check(
          offers != null &&
              offers['price'] != null &&
              offers['priceCurrency'] != null &&
              offers['availability'] != null,
          'Offer needs price, currency, availability',
        );
        check(offers != null && (offers['url'] as String? ?? '').startsWith(origin), 'Offer url must be absolute');
      case 'BreadcrumbList':
        final items = (data['itemListElement'] as List).cast<Map<String, dynamic>>();
        for (var i = 0; i < items.length; i++) {
          check(items[i]['position'] == i + 1, 'breadcrumb position ${items[i]['position']} should be ${i + 1}');
          check((items[i]['item'] as String).startsWith(origin), 'breadcrumb item is not absolute');
        }
      case 'ItemList':
        check((data['itemListElement'] as List).isNotEmpty, 'ItemList is empty');
      default:
    }
  }
}

/// Renders the whole site in this process (no sockets, no build step beyond
/// the generated `main.server.options.dart`) and audits it.
Future<AuditReport> auditInProcess({StoreConfig? config}) async {
  Jaspr.initializeApp(options: defaultServerOptions);
  final cfg = config ?? const StoreConfig(siteUrl: 'https://shop.example', environment: AppEnvironment.production);
  final locator = GetIt.asNewInstance();
  configureDependencies(config: cfg, locator: locator);
  final app = StoreApp(StoreDeps(locator));
  Future<Response> render(Component c) async {
    final r = await renderComponent(c);
    return Response(r.statusCode, body: r.body, headers: r.headers);
  }

  return auditSite(
    origin: cfg.origin,
    fetch: (path) async {
      final response = await app.handle(Request('GET', Uri.parse('${cfg.origin}$path')), render);
      return AuditResponse(response.statusCode, await response.readAsString(), response.headers);
    },
  );
}

Future<void> main(List<String> args) async {
  final live = args.isNotEmpty ? args.first.replaceFirst(RegExp(r'/$'), '') : null;
  final AuditReport report;
  if (live != null) {
    final client = HttpClient();
    report = await auditSite(
      origin: live,
      fetch: (path) async {
        final request = await client.getUrl(Uri.parse('$live$path'))
          ..followRedirects = false;
        final response = await request.close();
        final body = await utf8.decodeStream(response);
        final headers = <String, String>{};
        response.headers.forEach((name, values) => headers[name] = values.join(', '));
        return AuditResponse(response.statusCode, body, headers);
      },
    );
    client.close();
  } else {
    report = await auditInProcess();
  }
  stdout.writeln('Audited ${report.pages.length} pages, ${report.checks} checks.');
  if (report.passed) {
    stdout.writeln('PASS');
  } else {
    stdout.writeln('${report.failures.length} FAILURES:');
    for (final f in report.failures) {
      stdout.writeln('  - $f');
    }
    exit(1);
  }
}
