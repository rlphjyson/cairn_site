/// A parsed, framework-free view of one HTTP request.
///
/// Controllers receive a [RequestInfo] rather than a shelf `Request`, so they
/// stay easy to unit test and never touch streams, headers or cookies directly.
library;

import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../backend/cart_cookie.dart';
import '../core/seo/url_policy.dart';
import '../presentation/islands/theme_toggle.dart' show kThemeCookieName;

/// Upper bound for a form body. Every form here is a few hundred bytes.
const int kMaxFormBytes = 16 * 1024;

class RequestInfo {
  RequestInfo({
    required this.method,
    required this.rawPath,
    required this.query,
    required this.cookieHeader,
    required this.headers,
    this.form = const {},
  });

  final String method;

  /// Path exactly as received (used to detect non-canonical spellings).
  final String rawPath;

  /// Decoded query parameters (last value wins for repeated keys).
  final Map<String, String> query;
  final String? cookieHeader;
  final Map<String, String> headers;

  /// Decoded `application/x-www-form-urlencoded` body (POST only).
  final Map<String, String> form;

  String get path => normalizePath(rawPath);
  bool get isGet => method == 'GET' || method == 'HEAD';
  bool get isPost => method == 'POST';

  /// The add-to-cart island asks for JSON; plain form posts ask for HTML.
  bool get wantsJson => (headers['accept'] ?? '').contains('application/json');

  /// `light` / `dark` / `system`. `?theme=` wins over the cookie so a design
  /// review (or a screenshot) can force a theme without touching cookies.
  String get theme {
    final q = query['theme'];
    if (q == 'light' || q == 'dark') return q!;
    final c = readCookie(cookieHeader, kThemeCookieName);
    return c == 'light' || c == 'dark' ? c! : 'system';
  }

  static Future<RequestInfo> from(Request request) async {
    final form = <String, String>{};
    if (request.method == 'POST') {
      final type = request.headers['content-type'] ?? '';
      if (type.startsWith('application/x-www-form-urlencoded')) {
        final bytes = <int>[];
        await for (final chunk in request.read()) {
          bytes.addAll(chunk);
          if (bytes.length > kMaxFormBytes) throw const PayloadTooLarge();
        }
        try {
          form.addAll(Uri.splitQueryString(utf8.decode(bytes)));
        } on Object {
          // Malformed encoding: treat as an empty form; validation reports it.
        }
      }
    }
    return RequestInfo(
      method: request.method,
      rawPath: request.requestedUri.path,
      query: request.requestedUri.queryParameters,
      cookieHeader: request.headers['cookie'],
      headers: {for (final e in request.headers.entries) e.key.toLowerCase(): e.value},
      form: form,
    );
  }
}

class PayloadTooLarge implements Exception {
  const PayloadTooLarge();
}
