/// The **server** entrypoint: builds the dependency graph and the shelf pipeline.
///
/// ```text
/// logRequests
///   -> gzip                    (HTML, JSON, XML, JS)
///     -> securityHeaders       (CSP, HSTS, frame/referrer/content-type policy)
///       -> staticCaching       (Cache-Control for files from web/)
///         -> serveApp          static files from web/, then StoreApp.handle -> SSR
/// ```
library;

import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_gzip/shelf_gzip.dart';

import 'app.dart';
import 'backend/stores.dart';
import 'core/config/store_config.dart';
import 'di/service_locator.dart';
import 'http/middleware.dart';
import 'main.server.options.dart';

void main() async {
  // Jaspr only routes requests whose last path segment has no extension (or one
  // of these suffixes) to the app; anything else is answered 404 before our
  // handler runs. /robots.txt and /manifest.webmanifest are dynamic, so their
  // suffixes must be allow-listed (without this they 404 in production).
  Jaspr.initializeApp(
    options: defaultServerOptions,
    allowedPathSuffixes: const ['html', 'htm', 'xml', 'txt', 'webmanifest'],
  );

  final env = Platform.environment;
  var config = StoreConfig.fromEnvironment(cartSecret: env['CART_SECRET'], siteUrl: env['SITE_URL']);
  if (config.isProduction && config.cartSecret == kDevCartSecret) {
    // Never run production on the published development secret. A random one
    // is safe (carts live in memory anyway) but invalidates carts on restart,
    // so set CART_SECRET to a stable 32+ character value.
    config = config.copyWith(cartSecret: randomToken(32));
    stderr.writeln('[warn] CART_SECRET is not set; using a random per-process secret.');
  }

  configureDependencies(config: config);
  final app = StoreApp(StoreDeps(services));

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(gzipMiddleware)
      .addMiddleware(securityHeaders(config))
      .addMiddleware(staticCaching())
      .addHandler(serveApp((request, render) => app.handle(request, render)));

  final lock = activeReloadLock = Object();
  // `Platform.environment`, not `int.fromEnvironment`: the latter is a
  // compile-time constant, so a binary built with it ignores the PORT the host
  // assigns at runtime (Cloud Run, Fly, Render all inject it).
  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    int.tryParse(env['PORT'] ?? '') ?? 8080,
    shared: true,
  );

  if (lock != activeReloadLock) {
    server.close();
    return;
  }
  activeServer?.close();
  activeServer = server;
  // ignore: avoid_print
  print('Serving ${config.siteUrl} (${config.environment.name}) on port ${server.port}');
}

/// Tracks the running server across `jaspr serve` hot reloads.
HttpServer? activeServer;
Object? activeReloadLock;
