import 'package:cairn_template_jaspr_store/backend/stores.dart';
import 'package:cairn_template_jaspr_store/core/config/store_config.dart';
import 'package:cairn_template_jaspr_store/data/cart/cart_repository_impl.dart';
import 'package:cairn_template_jaspr_store/data/catalog/catalog_repository_impl.dart';
import 'package:cairn_template_jaspr_store/data/checkout/order_repository_impl.dart';
import 'package:cairn_template_jaspr_store/data/newsletter/newsletter_repository_impl.dart';
import 'package:cairn_template_jaspr_store/domain/cart/models/cart.dart';
import 'package:cairn_template_jaspr_store/domain/cart/use_cases/cart_mutations.dart';
import 'package:cairn_template_jaspr_store/domain/cart/use_cases/price_cart.dart';
import 'package:cairn_template_jaspr_store/domain/checkout/models/checkout.dart';
import 'package:cairn_template_jaspr_store/domain/checkout/use_cases/place_order.dart';
import 'package:cairn_template_jaspr_store/domain/checkout/use_cases/validate_checkout.dart';
import 'package:cairn_template_jaspr_store/domain/newsletter/newsletter.dart';
import 'package:test/test.dart';

const validForm = CheckoutForm(
  email: 'ada@example.com',
  fullName: 'Ada Lovelace',
  address1: '12 Analytical Way',
  city: 'Portland',
  region: 'ME',
  postalCode: '04101',
  country: 'US',
  acceptTerms: true,
);

CheckoutForm form({
  String? email,
  String? fullName,
  String? phone,
  String? address1,
  String? address2,
  String? city,
  String? region,
  String? postalCode,
  String? country,
  String? delivery,
  bool? acceptTerms,
}) => CheckoutForm(
  email: email ?? validForm.email,
  fullName: fullName ?? validForm.fullName,
  phone: phone ?? validForm.phone,
  address1: address1 ?? validForm.address1,
  address2: address2 ?? validForm.address2,
  city: city ?? validForm.city,
  region: region ?? validForm.region,
  postalCode: postalCode ?? validForm.postalCode,
  country: country ?? validForm.country,
  delivery: delivery ?? validForm.delivery,
  acceptTerms: acceptTerms ?? validForm.acceptTerms,
);

void main() {
  group('validateCheckout', () {
    test('a complete form is valid', () => expect(validateCheckout(validForm), isEmpty));

    test('an empty form reports every required field', () {
      final e = validateCheckout(const CheckoutForm());
      expect(e.keys, containsAll(['email', 'fullName', 'address1', 'city', 'region', 'postalCode', 'acceptTerms']));
      expect(e.containsKey('phone'), isFalse);
      expect(e.containsKey('address2'), isFalse);
    });

    group('email', () {
      for (final good in ['a@b.co', 'first.last+tag@sub.example.com', "o'neil@example.org", 'x_y@example-site.io']) {
        test('accepts $good', () => expect(validateCheckout(form(email: good)).containsKey('email'), isFalse));
      }
      for (final bad in ['plain', 'a@', '@b.com', 'a b@c.com', 'a@b', 'a@@b.com', 'a@b..com', '<x>@b.com']) {
        test('rejects $bad', () => expect(validateCheckout(form(email: bad)).containsKey('email'), isTrue));
      }
      test('rejects overlong addresses', () {
        expect(isValidEmail('${'a' * 250}@b.com'), isFalse);
      });
    });

    group('postal codes', () {
      final cases = <String, (List<String>, List<String>)>{
        'US': (['04101', '94105-1234'], ['4101', 'ABCDE', '94105-12']),
        'CA': (['K1A 0B1', 'k1a0b1', 'K1A-0B1'], ['12345', 'K1A 0B']),
        'GB': (['SW1A 1AA', 'M1 1AE', 'EC1A1BB'], ['12345', 'SW1A']),
        'DE': (['10115'], ['1011', '101155', 'D1011']),
        'AU': (['2000'], ['200', '20000']),
      };
      for (final entry in cases.entries) {
        for (final ok in entry.value.$1) {
          test('${entry.key} accepts $ok', () => expect(isValidPostalCode(entry.key, ok), isTrue));
        }
        for (final bad in entry.value.$2) {
          test('${entry.key} rejects $bad', () => expect(isValidPostalCode(entry.key, bad), isFalse));
        }
      }
      test('an unsupported country has no valid postal code', () => expect(isValidPostalCode('ZZ', '12345'), isFalse));
      test('the error mentions the country-specific label', () {
        final e = validateCheckout(form(postalCode: 'x'));
        expect(e['postalCode'], contains('zip code'));
      });
    });

    test('phone is optional but validated when present', () {
      expect(validateCheckout(form(phone: '+1 (555) 014-2000')).containsKey('phone'), isFalse);
      expect(validateCheckout(form(phone: 'call me')).containsKey('phone'), isTrue);
      expect(validateCheckout(form(phone: '123')).containsKey('phone'), isTrue);
    });

    test('names and address lengths are bounded', () {
      expect(validateCheckout(form(fullName: 'A')).containsKey('fullName'), isTrue);
      expect(validateCheckout(form(fullName: 'A' * 81)).containsKey('fullName'), isTrue);
      expect(validateCheckout(form(address1: 'x' * 101)).containsKey('address1'), isTrue);
      expect(validateCheckout(form(address2: 'x' * 101)).containsKey('address2'), isTrue);
      expect(validateCheckout(form(city: 'x' * 61)).containsKey('city'), isTrue);
    });

    test('country and delivery must be known values', () {
      expect(validateCheckout(form(country: 'ZZ')).containsKey('country'), isTrue);
      expect(validateCheckout(form(delivery: 'drone')).containsKey('delivery'), isTrue);
    });

    test('the demo confirmation must be ticked', () {
      expect(validateCheckout(form(acceptTerms: false))['acceptTerms'], contains('demo'));
    });

    test('messages never echo user input', () {
      final e = validateCheckout(form(email: '<script>x</script>', fullName: '<b>', city: '<i>'));
      for (final msg in e.values) {
        expect(msg, isNot(contains('<')));
      }
    });

    test('fromMap trims and reads checkboxes', () {
      final f = CheckoutForm.fromMap({'email': '  a@b.co ', 'acceptTerms': 'on', 'delivery': 'express'});
      expect(f.email, 'a@b.co');
      expect(f.acceptTerms, isTrue);
      expect(f.deliveryMethod, DeliveryMethod.express);
      expect(CheckoutForm.fromMap({}).acceptTerms, isFalse);
      expect(CheckoutForm.fromMap({'delivery': 'bogus'}).deliveryMethod, DeliveryMethod.standard);
    });

    test('ShippingAddress upper-cases the postal code', () {
      expect(ShippingAddress.fromForm(form(country: 'CA', postalCode: 'k1a 0b1')).postalCode, 'K1A 0B1');
    });
  });

  group('PlaceOrder', () {
    late DemoBackend backend;
    late CatalogRepositoryImpl catalog;
    late AddToCart add;
    late PlaceOrder place;
    late OrderRepositoryImpl orders;
    late Cart cart;

    setUp(() async {
      backend = DemoBackend();
      catalog = CatalogRepositoryImpl(backend.catalog, backend.reviews);
      final carts = CartRepositoryImpl(backend.carts);
      add = AddToCart(catalog, carts);
      orders = OrderRepositoryImpl(backend.orders);
      place = PlaceOrder(priceCart: PriceCart(catalog, const StoreConfig()), catalog: catalog, orders: orders);
      cart = (await add(
        await carts.create(),
        productId: 'p_day_backpack',
        variantId: 'v_day_black',
        quantity: 2,
      )).valueOrNull!.cart;
    });

    test('places an order with a snapshot of lines and totals', () async {
      final r = await place(cart, validForm);
      final order = r.valueOrNull!;
      expect(order.number, startsWith('NG-'));
      expect(order.id, startsWith('ord_'));
      expect(order.lines.single.quantity, 2);
      expect(order.lines.single.unitCents, 8500);
      expect(order.subtotalCents, 17000);
      expect(order.shippingCents, 0);
      expect(order.totalCents, 17000);
      expect(order.email, 'ada@example.com');
      expect(await orders.byId(order.id), isNotNull);
    });

    test('express delivery is charged', () async {
      final order = (await place(cart, form(delivery: 'express'))).valueOrNull!;
      expect(order.shippingCents, 1400);
      expect(order.delivery, DeliveryMethod.express);
    });

    test('reserves stock', () async {
      await place(cart, validForm);
      final p = (await catalog.productById('p_day_backpack'))!;
      expect(p.variantById('v_day_black')!.stock, 20);
    });

    test('an invalid form returns field errors and reserves nothing', () async {
      final r = await place(cart, form(email: 'nope'));
      expect(r.failureOrNull!.code, 'invalid_form');
      expect(r.failureOrNull!.fieldErrors.keys, ['email']);
      expect((await catalog.productById('p_day_backpack'))!.variantById('v_day_black')!.stock, 22);
      expect(backend.orders.length, 0);
    });

    test('an empty cart is rejected', () async {
      final empty = cart.copyWith(lines: const []);
      expect((await place(empty, validForm)).failureOrNull!.code, 'empty_cart');
    });

    test('lines for removed products make the cart stale', () async {
      final stale = cart.copyWith(
        lines: [
          ...cart.lines,
          const CartLine(productId: 'gone', variantId: 'v', quantity: 1),
        ],
      );
      expect((await place(stale, validForm)).failureOrNull!.code, 'stale_cart');
    });

    test('cannot oversell: the second order for the last items fails', () async {
      final carts = CartRepositoryImpl(backend.carts);
      Future<Cart> take() async => (await add(
        await carts.create(),
        productId: 'p_skeleton_sport',
        variantId: 'v_skeleton_42',
        quantity: 2,
      )).valueOrNull!.cart;
      final first = await take();
      final second = await take(); // both carts were built while stock was 2
      expect((await place(first, validForm)).isOk, isTrue);
      final r = await place(second, validForm);
      expect(r.failureOrNull!.code, 'out_of_stock');
      expect(backend.orders.length, 1);
    });

    test('order numbers are sequential and ids are unguessable and unique', () async {
      final a = (await place(cart, validForm)).valueOrNull!;
      final carts = CartRepositoryImpl(backend.carts);
      final cart2 = (await add(
        await carts.create(),
        productId: 'p_stoneware_mug',
        variantId: 'v_mug_white',
      )).valueOrNull!.cart;
      final b = (await place(cart2, validForm)).valueOrNull!;
      expect(int.parse(b.number.substring(3)), int.parse(a.number.substring(3)) + 1);
      expect(a.id, isNot(b.id));
      expect(a.id.length, greaterThanOrEqualTo(20));
    });

    test('the promo code is recorded on the order', () async {
      final promoted = (await ApplyPromo(const StoreConfig(), CartRepositoryImpl(backend.carts))(
        cart,
        'cairn10',
      )).valueOrNull!;
      final order = (await place(promoted, validForm)).valueOrNull!;
      expect(order.promoCode, 'CAIRN10');
      expect(order.discountCents, 1700);
      expect(order.totalCents, 15300);
    });
  });

  group('newsletter', () {
    late NewsletterStore store;
    late SubscribeToNewsletter subscribe;
    setUp(() {
      store = NewsletterStore();
      subscribe = SubscribeToNewsletter(NewsletterRepositoryImpl(store));
    });

    test('subscribes a valid address (normalised)', () async {
      expect((await subscribe('  Ada@Example.COM ')).valueOrNull, isTrue);
      expect(store.contains('ada@example.com'), isTrue);
    });

    test('a repeat subscription is reported, not duplicated', () async {
      await subscribe('a@b.co');
      expect((await subscribe('A@B.co')).valueOrNull, isFalse);
      expect(store.length, 1);
    });

    test('rejects empty and malformed addresses with a field error', () async {
      expect((await subscribe('')).failureOrNull!.fieldErrors['email'], isNotNull);
      final bad = await subscribe('nope');
      expect(bad.failureOrNull!.code, 'invalid_email');
      expect(store.length, 0);
    });
  });
}
