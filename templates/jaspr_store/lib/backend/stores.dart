/// DEMO STAND-IN. In-memory stores for everything that would live in a database.
///
/// Delete this directory when you connect a real backend and implement the
/// repository interfaces in `lib/domain/` instead.
///
/// Concurrency note: Dart runs each isolate's code on one thread, and none of
/// these methods `await` between a read and its write, so each is atomic with
/// respect to other requests in the same isolate. A real database needs real
/// transactions (see `CatalogRepository.reserveStock`).
library;

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../domain/cart/models/cart.dart';
import '../domain/catalog/models/product.dart';
import '../domain/checkout/models/checkout.dart';
import '../domain/reviews/models/review.dart';
import 'seed_catalog.dart';
import 'seed_reviews.dart';

final Random _secure = Random.secure();

/// A URL-safe random token with [bytes] bytes of entropy.
String randomToken([int bytes = 16]) =>
    base64Url.encode(List<int>.generate(bytes, (_) => _secure.nextInt(256))).replaceAll('=', '');

class CatalogStore {
  CatalogStore({List<Product>? products, List<Category>? categories})
    : _products = [...(products ?? seedProducts())],
      categories = categories ?? seedCategories();

  final List<Product> _products;
  final List<Category> categories;

  List<Product> get products => List.unmodifiable(_products);

  /// Takes stock for every variant or none of them.
  bool reserve(Map<String, int> quantityByVariant) {
    // Validate first...
    for (final entry in quantityByVariant.entries) {
      final variant = _variant(entry.key);
      if (variant == null || variant.stock < entry.value) return false;
    }
    // ...then apply.
    for (final entry in quantityByVariant.entries) {
      for (var i = 0; i < _products.length; i++) {
        final p = _products[i];
        if (p.variantById(entry.key) == null) continue;
        _products[i] = p.copyWith(
          variants: [for (final v in p.variants) v.id == entry.key ? v.withStock(v.stock - entry.value) : v],
        );
      }
    }
    return true;
  }

  ProductVariant? _variant(String id) {
    for (final p in _products) {
      final v = p.variantById(id);
      if (v != null) return v;
    }
    return null;
  }
}

class ReviewStore {
  ReviewStore({List<Review>? reviews}) : reviews = reviews ?? seedReviews();
  final List<Review> reviews;
}

/// Carts keyed by SHA-256 of their id, so a leaked dump of the store does not
/// reveal usable ids. Bounded: when full, the least recently updated cart goes.
class CartStore {
  CartStore({this.ttl = const Duration(days: 14), this.maxCarts = 10000, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final Duration ttl;
  final int maxCarts;
  final DateTime Function() _clock;
  final Map<String, Cart> _carts = {};

  static String _key(String id) => sha256.convert(utf8.encode(id)).toString();

  Cart create() {
    final cart = Cart(id: randomToken(16), updatedAt: _clock().toUtc());
    _put(cart);
    return cart;
  }

  Cart? find(String id) {
    final cart = _carts[_key(id)];
    if (cart == null) return null;
    if (_clock().toUtc().difference(cart.updatedAt) > ttl) {
      _carts.remove(_key(id));
      return null;
    }
    return cart;
  }

  void save(Cart cart) => _put(cart);

  void delete(String id) => _carts.remove(_key(id));

  int get length => _carts.length;

  void _put(Cart cart) {
    _carts.remove(_key(cart.id)); // re-insert so iteration order tracks recency
    _carts[_key(cart.id)] = cart;
    while (_carts.length > maxCarts) {
      _carts.remove(_carts.keys.first);
    }
  }
}

class OrderStore {
  final Map<String, Order> _orders = {};
  int _sequence = 100000;

  ({String id, String number}) nextIdentity() {
    _sequence++;
    return (id: 'ord_${randomToken(12)}', number: 'NG-$_sequence');
  }

  void save(Order order) => _orders[order.id] = order;
  Order? byId(String id) => _orders[id];
  int get length => _orders.length;
}

class NewsletterStore {
  final Set<String> _emails = {};
  bool add(String email) => _emails.add(email);
  int get length => _emails.length;
  bool contains(String email) => _emails.contains(email);
}

/// Bundles every store so the composition root can hand them out together.
class DemoBackend {
  DemoBackend({
    CatalogStore? catalog,
    ReviewStore? reviews,
    CartStore? carts,
    OrderStore? orders,
    NewsletterStore? newsletter,
  }) : catalog = catalog ?? CatalogStore(),
       reviews = reviews ?? ReviewStore(),
       carts = carts ?? CartStore(),
       orders = orders ?? OrderStore(),
       newsletter = newsletter ?? NewsletterStore();

  final CatalogStore catalog;
  final ReviewStore reviews;
  final CartStore carts;
  final OrderStore orders;
  final NewsletterStore newsletter;
}
