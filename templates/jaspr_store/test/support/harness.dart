/// In-process test harness: a fake "browser" that talks to [StoreApp] with no
/// sockets. It keeps a cookie jar, can follow redirects and parses HTML, so
/// tests read like a visitor clicking through the real site.
library;

import 'dart:async';
import 'dart:convert';

import 'package:cairn_template_jaspr_store/app.dart';
import 'package:cairn_template_jaspr_store/backend/stores.dart';
import 'package:cairn_template_jaspr_store/core/config/store_config.dart';
import 'package:cairn_template_jaspr_store/core/errors/error_reporter.dart';
import 'package:cairn_template_jaspr_store/domain/catalog/models/product.dart';
import 'package:cairn_template_jaspr_store/di/service_locator.dart';
import 'package:cairn_template_jaspr_store/main.server.options.dart';
import 'package:get_it/get_it.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:jaspr/server.dart' show Component, Jaspr, renderComponent;
import 'package:shelf/shelf.dart';

bool _initialised = false;

/// Call once from `setUpAll`.
void initJaspr() {
  if (_initialised) return;
  Jaspr.initializeApp(options: defaultServerOptions);
  _initialised = true;
}

const StoreConfig kTestConfig = StoreConfig(
  environment: AppEnvironment.production,
  siteUrl: 'https://shop.example',
  cartSecret: 'test-secret-test-secret-test-secret-0123',
);

class TestResponse {
  TestResponse(this.status, this.headers, this.headersAll, this.body);

  final int status;
  final Map<String, String> headers;
  final Map<String, List<String>> headersAll;
  final String body;

  Document? _doc;
  Document get doc => _doc ??= html_parser.parse(body);

  String? header(String name) => headers[name.toLowerCase()];
  List<String> setCookies() => headersAll['set-cookie'] ?? const [];
  bool get isRedirect => status >= 300 && status < 400;
  String? get location => header('location');
  Object get json => jsonDecode(body) as Object;

  String get text => doc.body?.text ?? '';
  Element? q(String selector) => doc.querySelector(selector);
  List<Element> qa(String selector) => doc.querySelectorAll(selector);

  /// All `<script type="application/ld+json">` payloads, parsed.
  List<Map<String, dynamic>> jsonLd() => [
    for (final s in doc.querySelectorAll('script[type="application/ld+json"]'))
      jsonDecode(s.text) as Map<String, dynamic>,
  ];

  String? meta(String name) => doc.querySelector('meta[name="$name"]')?.attributes['content'];
  String? og(String property) => doc.querySelector('meta[property="$property"]')?.attributes['content'];
  String? get canonical => doc.querySelector('link[rel="canonical"]')?.attributes['href'];
  String get title => doc.querySelector('title')?.text ?? '';
}

class TestApp {
  TestApp._(this.app, this.locator, this.backend, this.config);

  final StoreApp app;
  final GetIt locator;
  final DemoBackend backend;
  final StoreConfig config;

  static Future<TestApp> create({StoreConfig? config, DemoBackend? backend, DateTime Function()? clock}) async {
    initJaspr();
    final cfg = config ?? kTestConfig;
    final store = backend ?? DemoBackend();
    final locator = GetIt.asNewInstance();
    configureDependencies(config: cfg, locator: locator, backend: store);
    final app = StoreApp(StoreDeps(locator, clock: clock ?? () => DateTime.utc(2026, 3, 15)));
    return TestApp._(app, locator, store, cfg);
  }

  /// An app whose catalogue throws, to exercise the 500 path.
  static Future<TestApp> createFailing(List<Object> errors) async {
    initJaspr();
    final locator = GetIt.asNewInstance();
    final store = DemoBackend(catalog: _BrokenCatalog());
    configureDependencies(config: kTestConfig, locator: locator, backend: store, errorReporter: _Collecting(errors));
    return TestApp._(StoreApp(StoreDeps(locator)), locator, store, kTestConfig);
  }

  Future<Response> _render(Component component) async {
    final r = await renderComponent(component);
    return Response(r.statusCode, body: r.body, headers: r.headers);
  }

  Future<TestResponse> send(
    String method,
    String path, {
    Map<String, String>? form,
    Map<String, String> headers = const {},
    String? cookie,
  }) async {
    final uri = Uri.parse('${config.origin}$path');
    final body = form == null
        ? ''
        : form.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&');
    final request = Request(
      method,
      uri,
      body: body,
      headers: {
        if (form != null) 'content-type': 'application/x-www-form-urlencoded',
        'cookie': ?cookie,
        ...headers,
      },
    );
    final response = await app.handle(request, _render);
    final text = await response.readAsString();
    return TestResponse(response.statusCode, response.headers, response.headersAll, text);
  }
}

/// A visitor with a cookie jar.
class Browser {
  Browser(this.app);
  final TestApp app;
  final Map<String, String> cookies = {};

  String? get cookieHeader => cookies.isEmpty ? null : cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  void _store(TestResponse r) {
    for (final raw in r.setCookies()) {
      final pair = raw.split(';').first;
      final i = pair.indexOf('=');
      final name = pair.substring(0, i);
      final value = pair.substring(i + 1);
      final maxAge0 = raw.toLowerCase().contains('max-age=0');
      if (maxAge0 || value.isEmpty) {
        cookies.remove(name);
      } else {
        cookies[name] = value;
      }
    }
  }

  Future<TestResponse> get(String path, {Map<String, String> headers = const {}, bool follow = false}) =>
      _go('GET', path, headers: headers, follow: follow);

  Future<TestResponse> post(
    String path,
    Map<String, String> form, {
    Map<String, String> headers = const {},
    bool follow = false,
  }) => _go('POST', path, form: form, headers: headers, follow: follow);

  Future<TestResponse> _go(
    String method,
    String path, {
    Map<String, String>? form,
    Map<String, String> headers = const {},
    bool follow = false,
  }) async {
    var r = await app.send(method, path, form: form, headers: headers, cookie: cookieHeader);
    _store(r);
    var hops = 0;
    while (follow && r.isRedirect && hops++ < 5) {
      final target = r.location!;
      r = await app.send('GET', target, headers: headers, cookie: cookieHeader);
      _store(r);
    }
    return r;
  }
}

class _BrokenCatalog extends CatalogStore {
  @override
  List<Product> get products => throw StateError('catalogue is down');
}

class _Collecting implements ErrorReporter {
  _Collecting(this.errors);
  final List<Object> errors;
  @override
  void report(Object error, StackTrace? stack, {String? context}) => errors.add(error);
}
