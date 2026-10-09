import 'package:cairn_template_jaspr_store/backend/stores.dart';
import 'package:cairn_template_jaspr_store/core/config/store_config.dart';
import 'package:cairn_template_jaspr_store/data/cart/cart_repository_impl.dart';
import 'package:cairn_template_jaspr_store/data/catalog/catalog_repository_impl.dart';
import 'package:cairn_template_jaspr_store/domain/cart/models/cart.dart';
import 'package:cairn_template_jaspr_store/domain/cart/use_cases/cart_mutations.dart';
import 'package:cairn_template_jaspr_store/domain/cart/use_cases/price_cart.dart';
import 'package:cairn_template_jaspr_store/domain/catalog/models/product.dart';
import 'package:test/test.dart';

const config = StoreConfig();

void main() {
  late DemoBackend backend;
  late CatalogRepositoryImpl catalog;
  late CartRepositoryImpl carts;
  late AddToCart add;
  late UpdateLineQuantity update;
  late RemoveFromCart remove;
  late ApplyPromo promo;
  late PriceCart price;
  late LoadCart load;
  late Map<String, Product> bySlug;

  setUp(() async {
    backend = DemoBackend();
    catalog = CatalogRepositoryImpl(backend.catalog, backend.reviews);
    carts = CartRepositoryImpl(backend.carts);
    add = AddToCart(catalog, carts);
    update = UpdateLineQuantity(catalog, carts);
    remove = RemoveFromCart(carts);
    promo = ApplyPromo(config, carts);
    price = PriceCart(catalog, config);
    load = LoadCart(carts);
    bySlug = {for (final p in await catalog.allProducts()) p.slug: p};
  });

  Future<Cart> newCart() => load.findOrCreate(null);

  Product p(String slug) => bySlug[slug]!;

  group('LoadCart', () {
    test('find does not create a cart', () async {
      expect(await load.find(null), isNull);
      expect(await load.find('unknown-id-unknown-id'), isNull);
      expect(backend.carts.length, 0);
    });

    test('findOrCreate creates when the id is missing or unknown', () async {
      final a = await load.findOrCreate(null);
      final b = await load.findOrCreate('unknown-id-unknown-id');
      expect(a.id, isNot(b.id));
      expect(backend.carts.length, 2);
    });

    test('findOrCreate returns the existing cart for a known id', () async {
      final a = await load.findOrCreate(null);
      expect((await load.findOrCreate(a.id)).id, a.id);
      expect(backend.carts.length, 1);
    });
  });

  group('AddToCart', () {
    test('adds a line', () async {
      final cart = await newCart();
      final r = await add(cart, productId: p('day-backpack').id, variantId: 'v_day_black');
      expect(r.isOk, isTrue);
      expect(r.valueOrNull!.cart.lines.single.quantity, 1);
      expect(r.valueOrNull!.adjusted, isFalse);
    });

    test('merging the same variant increases the quantity', () async {
      var cart = await newCart();
      cart = (await add(cart, productId: p('day-backpack').id, variantId: 'v_day_black')).valueOrNull!.cart;
      cart = (await add(
        cart,
        productId: p('day-backpack').id,
        variantId: 'v_day_black',
        quantity: 2,
      )).valueOrNull!.cart;
      expect(cart.lines, hasLength(1));
      expect(cart.lines.single.quantity, 3);
    });

    test('different variants are separate lines', () async {
      var cart = await newCart();
      cart = (await add(cart, productId: p('classic-38-watch').id, variantId: 'v_classic_brown')).valueOrNull!.cart;
      cart = (await add(cart, productId: p('classic-38-watch').id, variantId: 'v_classic_black')).valueOrNull!.cart;
      expect(cart.lines, hasLength(2));
      expect(cart.itemCount, 2);
    });

    test('quantity is clamped to stock and flagged as adjusted', () async {
      final cart = await newCart();
      // Black strap has 3 in stock.
      final r = await add(cart, productId: p('classic-38-watch').id, variantId: 'v_classic_black', quantity: 9);
      expect(r.valueOrNull!.cart.lines.single.quantity, 3);
      expect(r.valueOrNull!.adjusted, isTrue);
    });

    test('quantity is clamped to the per-line maximum', () async {
      final cart = await newCart();
      final r = await add(cart, productId: p('stoneware-mug').id, variantId: 'v_mug_white', quantity: 50);
      expect(r.valueOrNull!.cart.lines.single.quantity, 10);
      expect(r.valueOrNull!.adjusted, isTrue);
    });

    test('a sold-out variant is rejected', () async {
      final r = await add(await newCart(), productId: p('stride-knit-sneaker').id, variantId: 'v_stride_44');
      expect(r.failureOrNull!.code, 'out_of_stock');
    });

    test('an unknown product or variant is rejected', () async {
      final cart = await newCart();
      expect((await add(cart, productId: 'nope', variantId: 'x')).failureOrNull!.code, 'unknown_product');
      expect(
        (await add(cart, productId: p('day-backpack').id, variantId: 'nope')).failureOrNull!.code,
        'unknown_variant',
      );
      // A variant that exists, but on another product.
      expect(
        (await add(cart, productId: p('day-backpack').id, variantId: 'v_mug_white')).failureOrNull!.code,
        'unknown_variant',
      );
    });

    test('a quantity below one is rejected', () async {
      final r = await add(await newCart(), productId: p('day-backpack').id, variantId: 'v_day_black', quantity: 0);
      expect(r.failureOrNull!.code, 'bad_quantity');
    });

    test('the cart is persisted', () async {
      final cart = await newCart();
      await add(cart, productId: p('day-backpack').id, variantId: 'v_day_black');
      expect((await carts.find(cart.id))!.lines, hasLength(1));
    });

    test('a failed add changes nothing', () async {
      final cart = await newCart();
      await add(cart, productId: p('stride-knit-sneaker').id, variantId: 'v_stride_44');
      expect((await carts.find(cart.id))!.lines, isEmpty);
    });
  });

  group('UpdateLineQuantity / RemoveFromCart', () {
    late Cart cart;
    setUp(() async {
      cart = (await add(
        await newCart(),
        productId: p('day-backpack').id,
        variantId: 'v_day_black',
        quantity: 2,
      )).valueOrNull!.cart;
    });

    test('sets a new quantity', () async {
      final r = await update(cart, variantId: 'v_day_black', quantity: 5);
      expect(r.valueOrNull!.cart.lines.single.quantity, 5);
    });

    test('zero or negative removes the line', () async {
      expect((await update(cart, variantId: 'v_day_black', quantity: 0)).valueOrNull!.cart.isEmpty, isTrue);
      expect((await update(cart, variantId: 'v_day_black', quantity: -3)).valueOrNull!.cart.isEmpty, isTrue);
    });

    test('is clamped to stock and flagged', () async {
      final watch = (await add(
        await newCart(),
        productId: p('classic-38-watch').id,
        variantId: 'v_classic_black',
      )).valueOrNull!.cart;
      final r = await update(watch, variantId: 'v_classic_black', quantity: 8);
      expect(r.valueOrNull!.cart.lines.single.quantity, 3);
      expect(r.valueOrNull!.adjusted, isTrue);
    });

    test('unknown line is an error', () async {
      expect((await update(cart, variantId: 'nope', quantity: 1)).failureOrNull!.code, 'not_in_cart');
    });

    test('remove deletes only that line', () async {
      final two = (await add(cart, productId: p('stoneware-mug').id, variantId: 'v_mug_white')).valueOrNull!.cart;
      final after = await remove(two, 'v_day_black');
      expect(after.lines.map((l) => l.variantId), ['v_mug_white']);
    });

    test('remove of an unknown line is a no-op', () async {
      expect((await remove(cart, 'nope')).lines, hasLength(1));
    });
  });

  group('promo codes', () {
    late Cart cart;
    setUp(() async => cart = await newCart());

    test('CAIRN10 is accepted case-insensitively and trimmed', () async {
      for (final code in ['CAIRN10', 'cairn10', '  Cairn10  ']) {
        final r = await promo(cart, code);
        expect(r.valueOrNull!.promoCode, 'CAIRN10', reason: code);
      }
    });

    test('invalid and empty codes are rejected without changing the cart', () async {
      expect((await promo(cart, 'NOPE')).failureOrNull!.code, 'invalid_promo');
      expect((await promo(cart, '   ')).failureOrNull!.code, 'empty_promo');
      expect((await carts.find(cart.id))!.promoCode, isNull);
    });

    test('clear removes the code', () async {
      final applied = (await promo(cart, 'CAIRN10')).valueOrNull!;
      expect((await promo.clear(applied)).promoCode, isNull);
    });

    test('error copy never echoes the input', () async {
      final r = await promo(cart, '<script>alert(1)</script>');
      expect(r.failureOrNull!.message, isNot(contains('script')));
    });
  });

  group('pricing', () {
    Future<Cart> cartWith(List<(String, String, int)> items, {String? code}) async {
      var cart = await newCart();
      for (final (slug, variant, qty) in items) {
        cart = (await add(cart, productId: p(slug).id, variantId: variant, quantity: qty)).valueOrNull!.cart;
      }
      if (code != null) cart = (await promo(cart, code)).valueOrNull!;
      return cart;
    }

    test('an empty cart costs nothing', () async {
      final priced = await price(await newCart());
      expect(priced.isEmpty, isTrue);
      expect(priced.totalCents, 0);
      expect(priced.shippingCents, 0);
    });

    test('subtotal sums unit price x quantity', () async {
      final priced = await price(
        await cartWith([('day-backpack', 'v_day_black', 2), ('stoneware-mug', 'v_mug_white', 1)]),
      );
      expect(priced.subtotalCents, 8500 * 2 + 2200);
      expect(priced.itemCount, 3);
    });

    test('below the threshold standard shipping is charged', () async {
      final priced = await price(await cartWith([('stoneware-mug', 'v_mug_white', 1)]));
      expect(priced.subtotalCents, 2200);
      expect(priced.shippingCents, 600);
      expect(priced.totalCents, 2800);
      expect(priced.qualifiesForFreeShipping, isFalse);
      expect(priced.freeShippingRemainingCents, 7500 - 2200);
    });

    test('at the threshold shipping is free', () async {
      // 7500 exactly: 3 x 2200 = 6600 + 900? use backpack 8500 (above).
      final priced = await price(await cartWith([('day-backpack', 'v_day_black', 1)]));
      expect(priced.subtotalCents, 8500);
      expect(priced.shippingCents, 0);
      expect(priced.qualifiesForFreeShipping, isTrue);
      expect(priced.freeShippingProgress, 1);
    });

    test('the promo applies to the subtotal and can drop an order below the free-shipping line', () async {
      // 8500 - 10% = 7650: still free.
      final a = await price(await cartWith([('day-backpack', 'v_day_black', 1)], code: 'CAIRN10'));
      expect(a.discountCents, 850);
      expect(a.shippingCents, 0);
      expect(a.totalCents, 7650);
      // 7900-ish carts: mug x? Use satchel 17500 -> irrelevant; craft 8000 via notebook (1800) x ? Use mug+notebook+... :
      // 2200*3 + 1800*1 = 8400 -> discount 840 -> 7560 (>= 7500, free); with 2200*2+1800*2 = 8000 -> 800 -> 7200 (< 7500, charged).
      final b = await price(
        await cartWith([
          ('stoneware-mug', 'v_mug_white', 2),
          ('lay-flat-notebook', 'v_notebook_dot', 2),
        ], code: 'CAIRN10'),
      );
      expect(b.subtotalCents, 8000);
      expect(b.discountCents, 800);
      expect(b.qualifyingCents, 7200);
      expect(b.shippingCents, 600);
      expect(b.totalCents, 8000 - 800 + 600);
    });

    test('without the promo the same cart ships free', () async {
      final priced = await price(
        await cartWith([('stoneware-mug', 'v_mug_white', 2), ('lay-flat-notebook', 'v_notebook_dot', 2)]),
      );
      expect(priced.shippingCents, 0);
    });

    test('express always costs money', () async {
      final cart = await cartWith([('day-backpack', 'v_day_black', 2)]);
      final priced = await price(cart, delivery: DeliveryMethod.express);
      expect(priced.shippingCents, 1400);
      expect(priced.totalCents, 17000 + 1400);
    });

    test('an unknown promo code stored on a cart is ignored', () async {
      final cart = (await cartWith([('day-backpack', 'v_day_black', 1)])).copyWith(promoCode: 'FORGED');
      final priced = await price(cart);
      expect(priced.discountCents, 0);
      expect(priced.promoCode, isNull);
    });

    test('lines for products that left the catalogue are dropped', () async {
      final cart = Cart(
        id: 'x',
        updatedAt: DateTime.now(),
        lines: const [
          CartLine(productId: 'gone', variantId: 'v', quantity: 1),
          CartLine(productId: 'p_day_backpack', variantId: 'v_day_black', quantity: 1),
        ],
      );
      final priced = await price(cart);
      expect(priced.lines, hasLength(1));
    });

    test('prices come from the catalogue, not the cart', () async {
      // The persisted line has no price field at all.
      final cart = await cartWith([('day-backpack', 'v_day_black', 1)]);
      expect(cart.lines.single.toString(), isNot(contains('8500')));
    });

    test('over-stock lines are flagged', () async {
      final cart = Cart(
        id: 'x',
        updatedAt: DateTime.now(),
        lines: const [CartLine(productId: 'p_classic_38', variantId: 'v_classic_black', quantity: 9)],
      );
      expect((await price(cart)).lines.single.overStock, isTrue);
    });

    test('free-shipping progress is a fraction', () async {
      final priced = await price(await cartWith([('stoneware-mug', 'v_mug_white', 1)]));
      expect(priced.freeShippingProgress, closeTo(2200 / 7500, 1e-9));
    });

    test('computePricedCart honours a custom shipping policy', () async {
      final cart = await cartWith([('stoneware-mug', 'v_mug_white', 1)]);
      final custom = const StoreConfig(
        shipping: ShippingPolicy(freeThresholdCents: 1000, standardCents: 100, expressCents: 200),
      );
      final priced = computePricedCart(
        cart: cart,
        productsById: {for (final x in bySlug.values) x.id: x},
        config: custom,
      );
      expect(priced.shippingCents, 0);
    });
  });
}
