/// Compile-time and runtime configuration.
///
/// Everything read through `String.fromEnvironment` is baked in at build time
/// (`--dart-define`). Secrets must NOT be read that way; the one secret
/// (`CART_SECRET`) is read from the process environment at runtime in
/// `main.server.dart`, where `dart:io` is available.
library;

import 'package:meta/meta.dart';

enum AppEnvironment { development, production }

@immutable
class PromoCode {
  const PromoCode({required this.code, required this.percentOff, required this.label});

  final String code;
  final int percentOff;
  final String label;
}

@immutable
class ShippingPolicy {
  const ShippingPolicy({
    this.freeThresholdCents = 7500,
    this.standardCents = 600,
    this.expressCents = 1400,
  });

  /// Orders at or above this subtotal (after discounts) ship free (standard).
  final int freeThresholdCents;
  final int standardCents;
  final int expressCents;
}

const String kDevCartSecret = 'dev-only-cart-secret-change-me-please-32b';

@immutable
class StoreConfig {
  const StoreConfig({
    this.environment = AppEnvironment.development,
    this.siteUrl = 'http://localhost:8080',
    this.currency = 'USD',
    this.cartSecret = kDevCartSecret,
    this.shipping = const ShippingPolicy(),
    this.promoCodes = const [PromoCode(code: 'CAIRN10', percentOff: 10, label: '10% off your order')],
    this.cartTtl = const Duration(days: 14),
    this.analyticsEnabled = false,
  });

  /// Reads `--dart-define` values. The cart secret comes from [cartSecret]
  /// (a runtime value) rather than a define, because anything compiled in is
  /// readable by whoever can read the binary.
  factory StoreConfig.fromEnvironment({String? cartSecret, String? siteUrl}) {
    const env = String.fromEnvironment('APP_ENV', defaultValue: 'development');
    const site = String.fromEnvironment('SITE_URL', defaultValue: 'http://localhost:8080');
    const currency = String.fromEnvironment('CURRENCY', defaultValue: 'USD');
    const analytics = bool.fromEnvironment('ANALYTICS', defaultValue: false);
    return StoreConfig(
      environment: env == 'production' ? AppEnvironment.production : AppEnvironment.development,
      siteUrl: (siteUrl != null && siteUrl.isNotEmpty) ? siteUrl : site,
      currency: currency,
      cartSecret: cartSecret ?? kDevCartSecret,
      analyticsEnabled: analytics,
    );
  }

  final AppEnvironment environment;

  /// Absolute origin of the deployment, e.g. `https://shop.example`. Every
  /// canonical, Open Graph, sitemap and JSON-LD URL is derived from it.
  final String siteUrl;
  final String currency;
  final String cartSecret;
  final ShippingPolicy shipping;
  final List<PromoCode> promoCodes;
  final Duration cartTtl;
  final bool analyticsEnabled;

  bool get isProduction => environment == AppEnvironment.production;

  /// `siteUrl` without a trailing slash.
  String get origin => siteUrl.endsWith('/') ? siteUrl.substring(0, siteUrl.length - 1) : siteUrl;

  /// Cookies get the `Secure` flag and `__Host-` prefix when served over https.
  bool get secureCookies => siteUrl.startsWith('https://');

  /// Absolute URL for a site-relative [path] (which may include a query).
  String absoluteUrl(String path) => path == '/' ? '$origin/' : '$origin${path.startsWith('/') ? path : '/$path'}';

  PromoCode? findPromo(String code) {
    final normalised = code.trim().toUpperCase();
    for (final promo in promoCodes) {
      if (promo.code == normalised) return promo;
    }
    return null;
  }

  StoreConfig copyWith({String? siteUrl, AppEnvironment? environment, String? cartSecret, ShippingPolicy? shipping}) =>
      StoreConfig(
        environment: environment ?? this.environment,
        siteUrl: siteUrl ?? this.siteUrl,
        currency: currency,
        cartSecret: cartSecret ?? this.cartSecret,
        shipping: shipping ?? this.shipping,
        promoCodes: promoCodes,
        cartTtl: cartTtl,
        analyticsEnabled: analyticsEnabled,
      );
}
