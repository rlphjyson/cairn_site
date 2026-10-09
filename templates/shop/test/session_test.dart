import 'package:cairn_template_shop/core/infrastructure/di/shop_injection.dart';
import 'package:cairn_template_shop/core/presentation/navigation/shop_navigation_cubit.dart';
import 'package:cairn_template_shop/domain/cart/models/cart_line.dart';
import 'package:cairn_template_shop/domain/cart/models/delivery_method.dart';
import 'package:cairn_template_shop/domain/cart/repositories/cart_repository.dart';
import 'package:cairn_template_shop/domain/cart/use_cases/calculate_cart_totals.dart';
import 'package:cairn_template_shop/domain/catalog/models/product.dart';
import 'package:cairn_template_shop/domain/catalog/models/product_sort.dart';
import 'package:cairn_template_shop/domain/catalog/repositories/product_repository.dart';
import 'package:cairn_template_shop/domain/catalog/use_cases/filter_products.dart';
import 'package:cairn_template_shop/domain/catalog/use_cases/get_products.dart';
import 'package:cairn_template_shop/domain/catalog/use_cases/sort_products.dart';
import 'package:cairn_template_shop/domain/checkout/models/payment_details.dart';
import 'package:cairn_template_shop/domain/checkout/use_cases/place_order.dart';
import 'package:cairn_template_shop/domain/checkout/use_cases/validate_payment_details.dart';
import 'package:cairn_template_shop/domain/checkout/use_cases/validate_shipping_details.dart';
import 'package:cairn_template_shop/domain/orders/models/order.dart';
import 'package:cairn_template_shop/domain/orders/models/order_status.dart';
import 'package:cairn_template_shop/domain/orders/models/shipping_details.dart';
import 'package:cairn_template_shop/domain/orders/repositories/order_repository.dart';
import 'package:cairn_template_shop/presentation/cart/bloc/cart_cubit.dart';
import 'package:cairn_template_shop/presentation/catalog/bloc/catalog_cubit.dart';
import 'package:cairn_template_shop/presentation/catalog/bloc/catalog_state.dart';
import 'package:cairn_template_shop/presentation/catalog/bloc/product_detail_cubit.dart';
import 'package:cairn_template_shop/presentation/catalog/view_models/product_detail_view_model.dart';
import 'package:cairn_template_shop/presentation/checkout/bloc/checkout_cubit.dart';
import 'package:cairn_template_shop/presentation/orders/bloc/orders_cubit.dart';
import 'package:cairn_template_shop/presentation/profile/bloc/profile_cubit.dart';
import 'package:cairn_template_shop/presentation/saved/bloc/saved_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// A catalogue that fails the first time it is asked.
class _FlakyProducts implements ProductRepository {
  bool _failed = false;

  @override
  Future<List<Product>> getProducts() async {
    if (!_failed) {
      _failed = true;
      throw StateError('offline');
    }
    return const <Product>[
      Product(
        id: 'a',
        name: 'A',
        category: 'Bags',
        price: 1,
        rating: 4,
        ratingCount: 1,
        imageAsset: 'x.jpg',
        description: '',
      ),
    ];
  }

  @override
  Future<Product?> getProduct(String id) async => null;
}

class _ThrowingOrders implements OrderRepository {
  @override
  Future<List<Order>> getOrders() async => const <Order>[];

  @override
  Future<Order> place(OrderDraft draft) async => throw StateError('offline');
}

const ShippingDetails _address = ShippingDetails(
  fullName: 'Grace Hopper',
  email: 'grace@example.com',
  phone: '555 010 9999',
  address: '1 Compiler Way',
  city: 'Arlington',
  postalCode: '22201',
);

const PaymentDetails _card = PaymentDetails(
  cardHolder: 'Grace Hopper',
  cardNumber: '4242 4242 4242 4242',
  expiry: '12/99',
  cvc: '123',
);

/// The session cubits wired through the real container, with no widgets: the
/// point of the layering is that all of this runs without a UI.
void main() {
  late GetIt locator;

  setUp(() => locator = createShopLocator());
  tearDown(() => locator.reset());

  test('each container is independent', () {
    final GetIt other = createShopLocator();
    expect(identical(locator<CartCubit>(), other<CartCubit>()), isFalse);
    other.reset();
  });

  test('session cubits are singletons; screen view models are not', () {
    expect(identical(locator<CartCubit>(), locator<CartCubit>()), isTrue);
    expect(identical(locator<CatalogCubit>(), locator<CatalogCubit>()), isTrue);
  });

  group('catalogue', () {
    test('a failed load shows as failed and can be retried', () async {
      final _FlakyProducts flaky = _FlakyProducts();
      final CatalogCubit catalog = CatalogCubit(
        GetProducts(flaky),
        const FilterProducts(),
        const SortProducts(),
      );
      await catalog.load();
      expect(catalog.state.status, CatalogStatus.failed);
      expect(catalog.state.visible, isEmpty);

      await catalog.load();
      expect(catalog.state.status, CatalogStatus.ready);
      expect(catalog.state.products, hasLength(1));
      await catalog.close();
    });

    test('loads, then filters and sorts', () async {
      final CatalogCubit catalog = locator<CatalogCubit>();
      expect(catalog.state.status, CatalogStatus.loading);
      await catalog.load();
      expect(catalog.state.status, CatalogStatus.ready);
      expect(catalog.state.products, hasLength(12));
      expect(catalog.state.visible, hasLength(12));
      expect(catalog.state.featured, hasLength(CatalogCubit.featuredCount));
      expect(catalog.state.newArrivals, isNotEmpty);
      expect(catalog.state.newArrivals.every((p) => p.isNew), isTrue);
      expect(catalog.state.isFiltering, isFalse);

      catalog.selectCategory('Shoes');
      expect(catalog.state.isFiltering, isTrue);
      expect(catalog.state.visible.every((p) => p.category == 'Shoes'), isTrue);

      catalog.sortBy(ProductSort.priceLowHigh);
      final List<double> prices = catalog.state.visible
          .map((p) => p.price)
          .toList();
      expect(prices, <double>[...prices]..sort());

      catalog.sortBy(ProductSort.priceHighLow);
      final List<double> desc = catalog.state.visible
          .map((p) => p.price)
          .toList();
      expect(desc, (<double>[...desc]..sort()).reversed.toList());

      catalog.search('classic');
      expect(catalog.state.visible.single.id, 'classic-white');
      catalog.search('zzz');
      expect(catalog.state.visible, isEmpty);

      catalog.clearFilters();
      expect(catalog.state.isFiltering, isFalse);
      expect(catalog.state.visible, hasLength(12));
      expect(catalog.state.sort, ProductSort.priceHighLow);
    });

    test(
      'the product page picks defaults, variants and a capped quantity',
      () async {
        final ProductDetailCubit detail =
            locator<ProductDetailViewModel>().cubit;
        await detail.load('street-low');
        expect(detail.state.product?.name, 'Street Low Sneaker');
        expect(detail.state.selection, <String, String>{'Size': '40'});
        expect(detail.state.related, isNotEmpty);
        expect(detail.state.related.any((p) => p.id == 'street-low'), isFalse);

        detail.selectVariant('Size', '43');
        expect(detail.state.variant, '43');
        // Three are in stock.
        detail.setQuantity(9);
        expect(detail.state.quantity, 3);
        detail.setQuantity(0);
        expect(detail.state.quantity, 1);
        await detail.close();
      },
    );

    test('an unknown product loads as not found', () async {
      final ProductDetailCubit detail = locator<ProductDetailViewModel>().cubit;
      await detail.load('nope');
      expect(detail.state.loaded, isTrue);
      expect(detail.state.product, isNull);
      await detail.close();
    });
  });

  test('saved starts with one item and toggles', () async {
    final SavedCubit saved = locator<SavedCubit>();
    await saved.load();
    expect(saved.state.ids, <String>{'classic-white'});
    expect(saved.state.products.single.id, 'classic-white');

    await saved.toggle('court-low');
    expect(saved.state.isSaved('court-low'), isTrue);
    await saved.toggle('court-low');
    expect(saved.state.isSaved('court-low'), isFalse);
  });

  group('cart', () {
    test('lines remember their variant and merge only when equal', () async {
      final CartCubit cart = locator<CartCubit>();
      await cart.load();
      expect(cart.state.isEmpty, isTrue);

      await cart.add('court-low', variant: '42 / Red');
      await cart.add('court-low', variant: '42 / Red', quantity: 2);
      await cart.add('court-low', variant: '41 / Cream');
      expect(cart.state.lines, hasLength(2));
      expect(cart.state.quantityOf('court-low'), 4);
      expect(
        cart.state.quantityOfLine(CartLine.lineKey('court-low', '42 / Red')),
        3,
      );
      expect(cart.state.itemCount, 4);
      expect(cart.state.totals.subtotal, 89 * 4);

      await cart.remove(CartLine.lineKey('court-low', '42 / Red'));
      expect(cart.state.lines.single.variant, '41 / Cream');
    });

    test('promo codes apply, report errors and can be removed', () async {
      final CartCubit cart = locator<CartCubit>();
      await cart.add('monitor-pro');
      expect(cart.state.totals.discount, 0);

      expect(await cart.applyPromo('WRONG'), isFalse);
      expect(cart.state.promoError, 'That code is not valid.');
      expect(await cart.applyPromo('  '), isFalse);
      expect(cart.state.promoError, 'Enter a promo code.');

      expect(await cart.applyPromo('cairn10'), isTrue);
      expect(cart.state.promo?.code, 'CAIRN10');
      expect(cart.state.promoError, isNull);
      expect(cart.state.totals.discount, closeTo(24.9, 1e-9));
      expect(cart.state.totals.total, closeTo(224.1, 1e-9));

      await cart.removePromo();
      expect(cart.state.promo, isNull);
      expect(cart.state.totals.discount, 0);
    });

    test('totals can be priced for another delivery method', () async {
      final CartCubit cart = locator<CartCubit>();
      await cart.add('court-low');
      expect(cart.state.totals.shipping, 8);
      expect(cart.totalsFor(DeliveryMethod.express).shipping, 12);
      expect(cart.totalsFor(DeliveryMethod.express).total, 101);
    });
  });

  group('checkout', () {
    Future<void> fillCart(GetIt g) async {
      await g<CartCubit>().add('monitor-pro', variant: 'Coiled');
      await g<CartCubit>().add('round-frames', variant: 'Rose', quantity: 2);
    }

    test('moves through the steps and keeps what was typed', () async {
      await fillCart(locator);
      final CheckoutCubit checkout = locator<CheckoutCubit>();
      expect(checkout.state.isActive, isFalse);

      checkout.begin(
        prefill: const ShippingDetails(fullName: 'Ada', email: 'a@b.co'),
      );
      expect(checkout.state.status, CheckoutStatus.editing);
      expect(checkout.state.step, CheckoutStep.shipping);
      expect(checkout.state.shipping.fullName, 'Ada');

      // Invalid: errors appear and the step does not change.
      checkout.next();
      expect(checkout.state.step, CheckoutStep.shipping);
      expect(checkout.state.shippingErrors, isNotEmpty);

      // Errors update live once shown.
      checkout.updateShipping(_address);
      expect(checkout.state.shippingErrors, isEmpty);

      checkout.setDelivery(DeliveryMethod.express);
      checkout.next();
      expect(checkout.state.step, CheckoutStep.payment);

      checkout.next();
      expect(checkout.state.step, CheckoutStep.payment);
      expect(checkout.state.paymentErrors, isNotEmpty);

      checkout.updatePayment(_card);
      checkout.next();
      expect(checkout.state.step, CheckoutStep.review);

      // Going back loses nothing.
      checkout.back();
      checkout.back();
      expect(checkout.state.step, CheckoutStep.shipping);
      expect(checkout.state.shipping, _address);
      expect(checkout.state.payment, _card);
      expect(checkout.state.delivery, DeliveryMethod.express);

      // Back from the first step leaves checkout but keeps the form.
      checkout.back();
      expect(checkout.state.status, CheckoutStatus.idle);
      checkout.begin(prefill: const ShippingDetails(fullName: 'Someone'));
      expect(checkout.state.shipping, _address);
    });

    test(
      'placing an order records it, clears the cart and forgets the card',
      () async {
        await fillCart(locator);
        final CartCubit cart = locator<CartCubit>();
        await cart.applyPromo('CAIRN10');
        final CheckoutCubit checkout = locator<CheckoutCubit>();
        final OrdersCubit orders = locator<OrdersCubit>();
        await orders.load();
        expect(orders.state.orders, hasLength(2));

        checkout
          ..begin()
          ..updateShipping(_address)
          ..next()
          ..updatePayment(_card)
          ..next();
        await checkout.placeOrder();

        expect(checkout.state.status, CheckoutStatus.placed);
        final Order order = checkout.state.order!;
        expect(order.id, 'CR-2048');
        expect(order.status, OrderStatus.processing);
        expect(order.cardLast4, '4242');
        expect(order.promo?.code, 'CAIRN10');
        expect(order.lines.map((l) => l.variant), <String>['Coiled', 'Rose']);
        expect(order.totals.subtotal, 249 + 158);
        expect(order.totals.discount, closeTo(40.7, 1e-9));
        expect(order.totals.shipping, 0);
        expect(order.shipping, _address);
        expect(checkout.state.payment, const PaymentDetails());

        await cart.load();
        expect(cart.state.isEmpty, isTrue);
        expect(cart.state.promo, isNull);

        await orders.load();
        expect(orders.state.orders, hasLength(3));
        expect(orders.state.orders.first.id, 'CR-2048');
        expect(orders.state.addresses.first, _address);
        expect(orders.state.byId('CR-2048'), order);

        checkout.reset();
        expect(checkout.state.status, CheckoutStatus.idle);
        expect(checkout.state.order, isNull);
      },
    );

    test('express is charged even over the threshold', () async {
      await locator<CartCubit>().add('monitor-pro');
      final CheckoutCubit checkout = locator<CheckoutCubit>()
        ..begin()
        ..updateShipping(_address)
        ..setDelivery(DeliveryMethod.express)
        ..next()
        ..updatePayment(_card)
        ..next();
      await checkout.placeOrder();
      expect(checkout.state.order?.totals.shipping, 12);
      expect(checkout.state.order?.totals.total, 261);
    });

    test('a failing backend leaves the form intact with a message', () async {
      await locator<CartCubit>().add('court-low');
      final CheckoutCubit checkout = CheckoutCubit(
        PlaceOrder(
          locator<CartRepository>(),
          _ThrowingOrders(),
          const CalculateCartTotals(),
        ),
        const ValidateShippingDetails(),
        const ValidatePaymentDetails(),
      )..updateShipping(_address);
      checkout.begin();
      await checkout.placeOrder();
      expect(checkout.state.status, CheckoutStatus.editing);
      expect(checkout.state.failure, contains('could not place'));
      expect(checkout.state.shipping, _address);
      await checkout.close();
    });

    test('checking out an empty cart places nothing', () async {
      final CheckoutCubit checkout = locator<CheckoutCubit>()..begin();
      await checkout.placeOrder();
      expect(checkout.state.status, CheckoutStatus.editing);
      expect(checkout.state.order, isNull);
      expect(checkout.state.failure, isNotNull);
    });
  });

  test('seeded orders resolve against the catalogue', () async {
    final OrdersCubit orders = locator<OrdersCubit>();
    await orders.load();
    expect(orders.state.orders.map((o) => o.status), <OrderStatus>[
      OrderStatus.shipped,
      OrderStatus.delivered,
    ]);
    final Order delivered = orders.state.orders.last;
    expect(delivered.lines, hasLength(2));
    expect(delivered.promo?.percentOff, 10);
    expect(orders.state.addresses, hasLength(1));
  });

  group('profile', () {
    test('preferences persist across a toggle', () async {
      final ProfileCubit profile = locator<ProfileCubit>();
      await profile.load();
      expect(profile.state.account?.name, 'Ada Lovelace');
      expect(profile.state.account?.initials, 'AL');
      expect(profile.state.preferences.offers, isFalse);

      await profile.setOffers(true);
      expect(profile.state.preferences.offers, isTrue);
      expect(profile.state.preferences.orderUpdates, isTrue);
    });

    test('signing out and in', () async {
      final ProfileCubit profile = locator<ProfileCubit>();
      await profile.load();
      await profile.setOffers(true);
      await profile.signOut();
      expect(profile.state.signedIn, isFalse);
      expect(profile.state.loaded, isTrue);
      expect(profile.state.preferences.offers, isTrue);

      await profile.signIn();
      expect(profile.state.signedIn, isTrue);
    });
  });

  test('navigation opens products and orders and returns to the tab', () {
    final ShopNavigationCubit nav = locator<ShopNavigationCubit>();
    nav.selectTab(ShopTab.saved);
    nav.openProduct('court-low');
    expect(nav.state.productId, 'court-low');
    nav.back();
    expect(nav.state.tab, ShopTab.saved);
    expect(nav.state.productId, isNull);

    nav.openOrder('CR-2041');
    expect(nav.state.tab, ShopTab.profile);
    expect(nav.state.orderId, 'CR-2041');
    nav.selectTab(ShopTab.shop);
    expect(nav.state.orderId, isNull);
  });
}
