/// Shelf middleware: security headers, asset caching, same-origin guard.
library;

import 'package:shelf/shelf.dart';

import '../core/config/store_config.dart';

/// Content-Security-Policy. `script-src 'self'` is the important line: the only
/// JavaScript that can run is the compiled islands served from this origin.
/// `'unsafe-inline'` is allowed for styles only, because the stylesheet is
/// inlined into every page (see the README for the nonce-based alternative).
String contentSecurityPolicy() => [
  "default-src 'self'",
  "script-src 'self'",
  "style-src 'self' 'unsafe-inline'",
  "img-src 'self' data:",
  "font-src 'self'",
  "connect-src 'self'",
  "object-src 'none'",
  "frame-ancestors 'none'",
  "base-uri 'self'",
  "form-action 'self'",
].join('; ');

Middleware securityHeaders(StoreConfig config) =>
    (inner) => (request) async {
      final response = await inner(request);
      return response.change(
        headers: {
          'content-security-policy': contentSecurityPolicy(),
          'x-content-type-options': 'nosniff',
          'x-frame-options': 'DENY',
          'referrer-policy': 'strict-origin-when-cross-origin',
          'permissions-policy': 'camera=(), microphone=(), geolocation=(), payment=()',
          'cross-origin-opener-policy': 'same-origin',
          if (config.secureCookies) 'strict-transport-security': 'max-age=31536000; includeSubDomains',
        },
      );
    };

final RegExp _hashed = RegExp(r'[.\-][0-9a-f]{8,}\.(?:js|css|webp|png|jpe?g|svg|woff2?)$');

/// `Cache-Control` for static files (anything the app itself did not already
/// label). Content-hashed filenames are immutable for a year; images and icons
/// are cached for a week with background revalidation (rename a file when you
/// change it); scripts revalidate on every load so a deploy is picked up at once.
String? staticCacheControl(String path) {
  if (_hashed.hasMatch(path)) return 'public, max-age=31536000, immutable';
  if (path.startsWith('/images/')) return 'public, max-age=604800, stale-while-revalidate=86400';
  if (path.startsWith('/icons/') || path == '/favicon.ico' || path == '/favicon.svg') {
    return 'public, max-age=86400';
  }
  if (path.endsWith('.js') || path.endsWith('.css') || path.endsWith('.map')) {
    return 'public, max-age=0, must-revalidate';
  }
  return null;
}

Middleware staticCaching() =>
    (inner) => (request) async {
      final response = await inner(request);
      if (response.headers.containsKey('cache-control') || response.statusCode != 200) return response;
      final value = staticCacheControl(request.requestedUri.path);
      return value == null ? response : response.change(headers: {'cache-control': value});
    };

/// Rejects cross-site form posts. `SameSite=Lax` cookies already stop a
/// cross-site POST from carrying the cart; this check adds a second,
/// independent layer by validating `Origin` (and `Sec-Fetch-Site`) on POSTs.
/// Requests with neither header (curl, server-to-server) are allowed: they
/// cannot be forged from a victim's browser.
bool isSameOriginPost(Map<String, String> headers, StoreConfig config) {
  final site = headers['sec-fetch-site'];
  if (site != null && site != 'same-origin' && site != 'none') return false;
  final origin = headers['origin'];
  if (origin == null) return true;
  if (origin == config.origin) return true;
  final host = headers['x-forwarded-host'] ?? headers['host'];
  final parsed = Uri.tryParse(origin);
  return parsed != null && host != null && parsed.authority == host;
}
