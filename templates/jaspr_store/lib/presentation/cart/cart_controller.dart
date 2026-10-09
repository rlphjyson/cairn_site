library;

import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../common/constants.dart';
import '../../core/result.dart';
import '../../core/seo/seo_data.dart';
import '../../di/service_locator.dart';
import '../../domain/cart/models/cart.dart';
import '../../http/reply.dart';
import '../../http/request_info.dart';
import 'cart_page.dart';

/// Cart pages and the form endpoints that change the cart.
///
/// Every mutation is a plain `<form method="post">` answered with a 303
/// redirect (Post/Redirect/Get), so it works with JavaScript off, and the
/// browser's back button never re-submits. The add-to-cart island sends the
/// same form with `Accept: application/json` and gets JSON instead.
class CartController {
  CartController(this.deps);
  final StoreDeps deps;

  String? _presentedId(RequestInfo r) => deps.cartCookie.idFromHeader(r.cookieHeader);

  /// A `Set-Cookie` only when the visitor does not already hold this cart.
  List<String> _cookiesFor(Cart cart, String? presentedId) =>
      cart.id == presentedId ? const [] : [deps.cartCookie.setCookie(cart.id)];

  Reply _json(int status, Map<String, Object?> body, {List<String> cookies = const []}) => RawReply(
    Response(status, body: jsonEncode(body), headers: {'content-type': 'application/json; charset=utf-8'}),
    cookies: cookies,
  );

  Future<Reply> view(RequestInfo r, {String? promoError, String promoValue = '', int status = 200}) async {
    final cart = await deps.loadCart.find(_presentedId(r));
    final priced = await deps.priceCart(cart ?? Cart(id: '', updatedAt: deps.clock()));
    return PageReply(
      status: status,
      cache: CachePolicy.noStore,
      seo: const SeoData(
        title: 'Your cart',
        description: 'Review the items in your cart, apply a promo code and check out.',
        path: '/cart',
        robots: RobotsPolicy.noIndexNoFollow,
      ),
      body: CartPage(
        config: deps.config,
        cart: priced,
        notice: r.query['notice'],
        promoError: promoError,
        promoValue: promoValue,
      ),
    );
  }

  /// `GET /cart/summary`: the item count the header island displays.
  Future<Reply> summary(RequestInfo r) async {
    final cart = await deps.loadCart.find(_presentedId(r));
    return _json(200, {'count': cart?.itemCount ?? 0});
  }

  Future<Reply> add(RequestInfo r) async {
    final presented = _presentedId(r);
    final productId = r.form['productId'] ?? '';
    final variantId = r.form['variantId'] ?? '';
    final quantity = (int.tryParse(r.form['quantity'] ?? '') ?? 1).clamp(1, kMaxLineQuantity);

    final cart = await deps.loadCart.findOrCreate(presented);
    final result = await deps.addToCart(cart, productId: productId, variantId: variantId, quantity: quantity);

    switch (result) {
      case Ok(:final value):
        deps.analytics.track(
          'add_to_cart',
          properties: {'productId': productId, 'variantId': variantId, 'quantity': quantity},
        );
        final cookies = _cookiesFor(value.cart, presented);
        if (r.wantsJson) {
          return _json(200, {
            'ok': true,
            'count': value.cart.itemCount,
            'adjusted': value.adjusted,
            'message': value.adjusted ? 'Added. We limited the quantity to what is in stock.' : 'Added to your cart.',
          }, cookies: cookies);
        }
        return RedirectReply('/cart?notice=${value.adjusted ? 'adjusted' : 'added'}', cookies: cookies);
      case Err(:final failure):
        if (r.wantsJson) return _json(422, {'ok': false, 'code': failure.code, 'message': failure.message});
        final product = await deps.catalog.productById(productId);
        final target = product == null ? '/products' : '/products/${product.slug}?error=${failure.code}';
        return RedirectReply(target);
    }
  }

  Future<Reply> update(RequestInfo r) async {
    final presented = _presentedId(r);
    final cart = await deps.loadCart.find(presented);
    if (cart == null) return const RedirectReply('/cart');
    final variantId = r.form['variantId'] ?? '';
    final quantity = int.tryParse(r.form['quantity'] ?? '') ?? 1;
    final result = await deps.updateQuantity(cart, variantId: variantId, quantity: quantity);
    return switch (result) {
      Ok(:final value) => RedirectReply(
        '/cart?notice=${quantity <= 0 ? 'removed' : (value.adjusted ? 'adjusted' : 'updated')}',
      ),
      Err() => const RedirectReply('/cart'),
    };
  }

  Future<Reply> remove(RequestInfo r) async {
    final cart = await deps.loadCart.find(_presentedId(r));
    if (cart == null) return const RedirectReply('/cart');
    await deps.removeFromCart(cart, r.form['variantId'] ?? '');
    return const RedirectReply('/cart?notice=removed');
  }

  Future<Reply> promo(RequestInfo r) async {
    final cart = await deps.loadCart.find(_presentedId(r));
    if (cart == null) return const RedirectReply('/cart');
    if (r.form['action'] == 'remove') {
      await deps.applyPromo.clear(cart);
      return const RedirectReply('/cart?notice=promo_removed');
    }
    final code = r.form['code'] ?? '';
    final result = await deps.applyPromo(cart, code);
    switch (result) {
      case Ok():
        return const RedirectReply('/cart?notice=promo_applied');
      case Err(:final failure):
        // Re-render in place (422) so the error sits next to the field and the
        // visitor's input is preserved; no redirect, no flash storage.
        return view(
          r,
          promoError: failure.message,
          promoValue: code.trim().length > 40 ? '' : code.trim(),
          status: 422,
        );
    }
  }
}
