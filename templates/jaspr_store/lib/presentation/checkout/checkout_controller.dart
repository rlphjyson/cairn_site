library;

import '../../core/result.dart';
import '../../core/seo/seo_data.dart';
import '../../di/service_locator.dart';
import '../../domain/cart/models/cart.dart';
import '../../domain/checkout/models/checkout.dart';
import '../../domain/catalog/models/product.dart';
import '../../http/reply.dart';
import '../../http/request_info.dart';
import 'checkout_page.dart';
import 'confirmation_page.dart';

/// Demo checkout. It validates, reserves stock and records an order; it never
/// takes, simulates or stores payment details.
class CheckoutController {
  CheckoutController(this.deps);
  final StoreDeps deps;

  static const SeoData _seo = SeoData(
    title: 'Checkout',
    description: 'Demo checkout: enter delivery details to place a demo order. No payment is taken.',
    path: '/checkout',
    robots: RobotsPolicy.noIndexNoFollow,
  );

  Future<Cart?> _cart(RequestInfo r) => deps.loadCart.find(deps.cartCookie.idFromHeader(r.cookieHeader));

  Future<Reply> view(RequestInfo r) async {
    final cart = await _cart(r);
    if (cart == null || cart.isEmpty) return const RedirectReply('/cart');
    final priced = await deps.priceCart(cart);
    if (priced.isEmpty) return const RedirectReply('/cart');
    return PageReply(
      seo: _seo,
      cache: CachePolicy.noStore,
      body: CheckoutPage(config: deps.config, cart: priced, values: const CheckoutForm()),
    );
  }

  Future<Reply> submit(RequestInfo r) async {
    final cart = await _cart(r);
    if (cart == null || cart.isEmpty) return const RedirectReply('/cart');
    final form = CheckoutForm.fromMap(r.form);
    final result = await deps.placeOrder(cart, form);

    switch (result) {
      case Ok(:final value):
        deps.analytics.track(
          'purchase',
          properties: {'orderId': value.id, 'totalCents': value.totalCents, 'demo': true},
        );
        await deps.clearCart(cart);
        return RedirectReply('/checkout/confirmation/${value.id}', cookies: [deps.cartCookie.clearCookie()]);
      case Err(:final failure):
        if (failure.code == 'empty_cart') return const RedirectReply('/cart');
        final priced = await deps.priceCart(cart, delivery: form.deliveryMethod);
        final invalid = failure.code == 'invalid_form';
        return PageReply(
          // 422 for fixable input, 409 when the cart itself changed under the visitor.
          status: invalid ? 422 : 409,
          seo: _seo,
          cache: CachePolicy.noStore,
          body: CheckoutPage(
            config: deps.config,
            cart: priced,
            values: form,
            errors: failure.fieldErrors,
            formError: invalid ? null : failure.message,
          ),
        );
    }
  }

  Future<Reply> confirmation(RequestInfo r, String id) async {
    final order = await deps.orders.byId(id);
    if (order == null) return const NotFoundReply();
    final products = await deps.catalog.allProducts();
    final images = <String, ProductImage>{for (final p in products) p.id: p.primaryImage};
    return PageReply(
      cache: CachePolicy.noStore,
      seo: SeoData(
        title: 'Order ${order.number}',
        description: 'Your demo order confirmation.',
        path: '/checkout/confirmation/${order.id}',
        robots: RobotsPolicy.noIndexNoFollow,
      ),
      body: ConfirmationPage(config: deps.config, order: order, imageByProductId: images),
    );
  }
}
