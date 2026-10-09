/// The application: routing, canonical-URL policy and rendering.
///
/// [StoreApp.handle] is a pure function of a shelf `Request` and a `render`
/// callback, which is why the same code runs unchanged behind `serveApp` in
/// production, behind `renderComponent` in tests and in `tool/seo_audit.dart`.
///
/// Request path:
///
/// ```text
/// Request
///   -> parse (RequestInfo)            query, cookies, form body
///   -> method + same-origin checks    405 / 403
///   -> path hygiene                   301 for // and trailing slash
///   -> route -> controller            domain use cases, no HTML yet
///   -> Reply (page | redirect | raw)
///   -> render: Document(head from SeoData, SiteShell(page))
///   -> Response: status, Cache-Control, ETag, Vary, Set-Cookie
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:jaspr/server.dart';

import 'core/config/brand.dart';
import 'di/service_locator.dart';
import 'http/middleware.dart';
import 'http/reply.dart';
import 'http/request_info.dart';
import 'http/seo_endpoints.dart';
import 'presentation/cart/cart_controller.dart';
import 'presentation/catalog/catalog_controller.dart';
import 'presentation/catalog/listing_page.dart';
import 'presentation/catalog/listing_params.dart';
import 'presentation/checkout/checkout_controller.dart';
import 'presentation/home/home_controller.dart';
import 'presentation/pages/pages_controller.dart';
import 'presentation/seo/seo_head.dart';
import 'presentation/shell/site_shell.dart';

/// What `serveApp` / `renderComponent` give us: component in, HTML response out.
typedef RenderFunction = FutureOr<Response> Function(Component component);

class StoreApp {
  StoreApp(this.deps)
    : _home = HomeController(deps),
      _catalog = CatalogController(deps),
      _cart = CartController(deps),
      _checkout = CheckoutController(deps),
      _pages = PagesController(deps);

  final StoreDeps deps;
  final HomeController _home;
  final CatalogController _catalog;
  final CartController _cart;
  final CheckoutController _checkout;
  final PagesController _pages;

  static const String catalogueCacheControl = 'public, max-age=60, s-maxage=300, stale-while-revalidate=86400';

  Future<Response> handle(Request request, RenderFunction render) async {
    RequestInfo info;
    try {
      info = await RequestInfo.from(request);
    } on PayloadTooLarge {
      return Response(413, body: 'Request body too large', headers: _plain);
    }

    try {
      if (info.method != 'GET' && info.method != 'HEAD' && info.method != 'POST') {
        return Response(405, body: 'Method not allowed', headers: {..._plain, 'allow': 'GET, HEAD, POST'});
      }
      if (info.isPost && !isSameOriginPost(info.headers, deps.config)) {
        return Response(403, body: 'Cross-site form submission blocked', headers: _plain);
      }

      // Path hygiene: one spelling per URL. `//a` and `/a/` redirect to `/a`.
      if (info.rawPath != info.path && info.isGet) {
        final query = request.requestedUri.hasQuery ? '?${request.requestedUri.query}' : '';
        return _respond(info, RedirectReply('${info.path}$query', status: 301), render);
      }

      final reply = await _route(info);
      return await _respond(info, reply, render);
    } on Object catch (error, stack) {
      deps.errors.report(error, stack, context: '${info.method} ${info.path}');
      return _respond(info, _pages.serverError(), render, swallowErrors: true);
    }
  }

  static const Map<String, String> _plain = {'content-type': 'text/plain; charset=utf-8', 'cache-control': 'no-store'};

  Future<Reply> _methods(RequestInfo r, Set<String> allowed, FutureOr<Reply> Function() run) async {
    if (!allowed.contains(r.method) && !(r.method == 'HEAD' && allowed.contains('GET'))) {
      return RawReply(Response(405, body: 'Method not allowed', headers: {..._plain, 'allow': allowed.join(', ')}));
    }
    return run();
  }

  Future<Reply> _route(RequestInfo r) async {
    final segs = r.path.split('/').where((s) => s.isNotEmpty).toList();
    final first = segs.isEmpty ? '' : segs.first;
    return switch ((first, segs.length)) {
      ('', _) => _methods(r, {'GET'}, () => _home.home(r)),
      ('products', 1) => _methods(r, {'GET'}, () => _catalog.products(r)),
      ('products', 2) => _methods(r, {'GET'}, () => _catalog.product(r, segs[1])),
      ('categories', 2) => _methods(r, {'GET'}, () => _catalog.category(r, segs[1])),
      ('search', 1) => _methods(r, {'GET'}, () {
        // /search is an alias of the listing; one canonical URL for results.
        final p = ListingParams.parse(r.query);
        return RedirectReply(listingUrl('/products', q: p.q, sort: p.sort, page: p.page), status: 301);
      }),
      ('healthz', 1) => _methods(r, {'GET'}, () => RawReply(Response.ok('ok', headers: _plain))),
      ('about', 1) => _methods(r, {'GET'}, () => _pages.about(r)),
      ('newsletter', 1) => _methods(r, {
        'GET',
        'POST',
      }, () => r.isPost ? _pages.newsletterSubmit(r) : _pages.newsletterForm(r)),
      ('cart', 1) => _methods(r, {'GET'}, () => _cart.view(r)),
      ('cart', 2) => _cartAction(r, segs[1]),
      ('checkout', 1) => _methods(r, {'GET', 'POST'}, () => r.isPost ? _checkout.submit(r) : _checkout.view(r)),
      ('checkout', 3) when segs[1] == 'confirmation' => _methods(r, {'GET'}, () => _checkout.confirmation(r, segs[2])),
      ('sitemap.xml', 1) => _methods(r, {
        'GET',
      }, () async => RawReply(await sitemapResponse(deps.config, deps.catalog))),
      ('robots.txt', 1) => _methods(r, {'GET'}, () => RawReply(robotsResponse(deps.config))),
      ('manifest.webmanifest', 1) => _methods(r, {'GET'}, () => RawReply(manifestResponse(deps.config))),
      _ => Future.value(const NotFoundReply()),
    };
  }

  Future<Reply> _cartAction(RequestInfo r, String action) => switch (action) {
    'summary' => _methods(r, {'GET'}, () => _cart.summary(r)),
    'add' => _methods(r, {'POST'}, () => _cart.add(r)),
    'update' => _methods(r, {'POST'}, () => _cart.update(r)),
    'remove' => _methods(r, {'POST'}, () => _cart.remove(r)),
    'promo' => _methods(r, {'POST'}, () => _cart.promo(r)),
    _ => Future.value(const NotFoundReply()),
  };

  // ---------------------------------------------------------------------------
  // Reply -> Response
  // ---------------------------------------------------------------------------

  Future<Response> _respond(RequestInfo info, Reply reply, RenderFunction render, {bool swallowErrors = false}) async {
    final cookies = reply.cookies;
    switch (reply) {
      case RedirectReply():
        return Response(
          reply.status,
          headers: {
            'location': reply.location,
            // A permanent move is cacheable; a post-redirect never is.
            'cache-control': reply.status == 301 ? 'public, max-age=3600' : 'no-store',
            if (cookies.isNotEmpty) 'set-cookie': cookies,
          },
        );
      case RawReply():
        final response = reply.response;
        return response.change(
          headers: {
            if (!response.headers.containsKey('cache-control')) 'cache-control': 'no-store',
            if (cookies.isNotEmpty) 'set-cookie': cookies,
          },
        );
      case NotFoundReply():
        return _respond(info, _pages.notFound(info), render);
      case PageReply():
        return _page(info, reply, render);
    }
  }

  Future<Response> _page(RequestInfo info, PageReply page, RenderFunction render) async {
    final config = deps.config;
    final categories = await deps.getCategories();
    final theme = info.theme;
    final document = Document(
      lang: Brand.language,
      title: documentTitle(page.seo),
      // No <base>: with `<base href="/">` a bare `#main` skip link would resolve
      // against the base and navigate away from the current page.
      base: null,
      head: buildHead(page.seo, config),
      body: Component.fragment([
        if (theme == 'light' || theme == 'dark') Document.html(attributes: {'data-theme': theme}),
        SiteShell(config: config, categories: categories, currentPath: info.path, theme: theme, child: page.body),
      ]),
    );
    final rendered = await render(document);
    final html = await rendered.readAsString();

    final cacheable = page.cache == CachePolicy.catalogue && page.status == 200 && info.isGet;
    final etag = 'W/"${md5.convert(utf8.encode(html)).toString().substring(0, 20)}"';
    final headers = <String, Object>{
      'content-type': 'text/html; charset=utf-8',
      'content-language': Brand.language,
      'cache-control': switch (page.cache) {
        CachePolicy.noStore => 'no-store',
        CachePolicy.catalogue when page.status == 200 => catalogueCacheControl,
        CachePolicy.catalogue => 'public, max-age=60',
      },
      // The server stamps data-theme from a cookie, so the HTML varies by it.
      if (page.cache == CachePolicy.catalogue) 'vary': 'Cookie, Accept-Encoding',
      if (cacheable) 'etag': etag,
      if (!page.seo.robots.isIndexable) 'x-robots-tag': page.seo.robots.content,
      if (page.cookies.isNotEmpty) 'set-cookie': page.cookies,
    };

    if (cacheable && _etagMatches(info.headers['if-none-match'], etag)) {
      return Response(304, headers: {...headers}..remove('content-type'));
    }
    return Response(page.status, body: html, headers: headers);
  }

  bool _etagMatches(String? header, String etag) {
    if (header == null) return false;
    final opaque = etag.replaceFirst('W/', '');
    return header.split(',').map((e) => e.trim().replaceFirst('W/', '')).any((e) => e == opaque || e == '*');
  }
}
