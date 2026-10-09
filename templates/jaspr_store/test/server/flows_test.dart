/// The no-JavaScript purchase flow, as a visitor would click through it:
/// product -> add to cart -> cart -> promo -> checkout -> confirmation.
library;

import 'package:test/test.dart';

import '../support/harness.dart';

const validCheckout = {
  'email': 'ada@example.com',
  'fullName': 'Ada Lovelace',
  'phone': '+1 555 0100',
  'address1': '12 Analytical Way',
  'address2': '',
  'country': 'US',
  'city': 'Portland',
  'region': 'ME',
  'postalCode': '04101',
  'delivery': 'standard',
  'acceptTerms': 'on',
};

void main() {
  late TestApp app;
  late Browser visitor;
  setUp(() async {
    app = await TestApp.create();
    visitor = Browser(app);
  });

  Future<TestResponse> addBackpack({int qty = 1, Browser? who}) => (who ?? visitor).post('/cart/add', {
    'productId': 'p_day_backpack',
    'variantId': 'v_day_black',
    'quantity': '$qty',
  });

  group('add to cart (no JavaScript)', () {
    test('POST /cart/add redirects 303 to the cart and sets the cart cookie', () async {
      final r = await addBackpack();
      expect(r.status, 303);
      expect(r.location, '/cart?notice=added');
      expect(r.setCookies(), hasLength(1));
      expect(visitor.cookies.keys, contains('__Host-cart'));
    });

    test('the cart cookie is httpOnly, SameSite=Lax and carries no contents', () async {
      final r = await addBackpack();
      final cookie = r.setCookies().single;
      expect(cookie, contains('HttpOnly'));
      expect(cookie, contains('SameSite=Lax'));
      expect(cookie, contains('Path=/'));
      expect(cookie, contains('Secure')); // the test site is https
      expect(cookie, startsWith('__Host-cart='));
      expect(cookie.toLowerCase(), isNot(contains('backpack')));
      expect(cookie, isNot(contains('8500')));
    });

    test('following the redirect shows the item, price and totals', () async {
      await addBackpack(qty: 2);
      final r = await visitor.get('/cart?notice=added');
      expect(r.status, 200);
      expect(r.text, contains('Day Backpack'));
      expect(r.text, contains('Black'));
      expect(r.q('.cart-summary')!.text, contains(r'$170.00'));
      expect(r.q('.alert')!.text, contains('Added to your cart'));
      expect(r.text, contains('2 items'));
    });

    test('a second add reuses the cookie and merges quantities', () async {
      await addBackpack();
      final second = await addBackpack();
      expect(second.setCookies(), isEmpty);
      final cart = await visitor.get('/cart');
      expect(cart.q('.qty-input')!.attributes['value'], '2');
      expect(cart.qa('.cart-line'), hasLength(1));
    });

    test('two visitors have separate carts', () async {
      final other = Browser(app);
      await addBackpack();
      expect((await other.get('/cart')).text, contains('Your cart is empty'));
      expect((await visitor.get('/cart')).text, contains('Day Backpack'));
    });

    test('a forged or garbage cookie is ignored and does not create a cart on GET', () async {
      final r = await app.send('GET', '/cart', cookie: 'cart=aaaaaaaaaaaaaaaaaaaaaa.bbbbbbbbbbbbbbbbbbbbbb');
      expect(r.status, 200);
      expect(r.text, contains('Your cart is empty'));
      expect(app.backend.carts.length, 0);
    });

    test('browsing the catalogue never creates carts or cookies', () async {
      for (final path in ['/', '/products', '/products/day-backpack', '/cart', '/categories/bags']) {
        final r = await visitor.get(path);
        expect(r.setCookies(), isEmpty, reason: path);
      }
      expect(app.backend.carts.length, 0);
    });

    test('an unrecognised cart cookie gets a fresh cart on the next add', () async {
      final r = await app.send(
        'POST',
        '/cart/add',
        form: {'productId': 'p_day_backpack', 'variantId': 'v_day_black', 'quantity': '1'},
        cookie: 'cart=zzzzzzzzzzzzzzzzzzzzzz.yyyyyyyyyyyyyyyyyyyyyy',
      );
      expect(r.status, 303);
      expect(r.setCookies(), hasLength(1));
    });

    test('quantity is clamped; junk quantities become 1', () async {
      await visitor.post('/cart/add', {'productId': 'p_day_backpack', 'variantId': 'v_day_black', 'quantity': 'lots'});
      var cart = await visitor.get('/cart');
      expect(cart.q('.qty-input')!.attributes['value'], '1');
      await visitor.post('/cart/add', {'productId': 'p_day_backpack', 'variantId': 'v_day_black', 'quantity': '-5'});
      cart = await visitor.get('/cart');
      expect(cart.q('.qty-input')!.attributes['value'], '2');
      final big = await visitor.post('/cart/add', {
        'productId': 'p_day_backpack',
        'variantId': 'v_day_black',
        'quantity': '9999',
      });
      expect(big.location, '/cart?notice=adjusted');
      cart = await visitor.get('/cart');
      expect(cart.q('.qty-input')!.attributes['value'], '10');
    });

    test('adding a sold-out option goes back to the product with a message', () async {
      final r = await visitor.post('/cart/add', {
        'productId': 'p_stride_knit',
        'variantId': 'v_stride_44',
        'quantity': '1',
      });
      expect(r.status, 303);
      expect(r.location, '/products/stride-knit-sneaker?error=out_of_stock');
      expect(visitor.cookies, isEmpty);
      final page = await visitor.get(r.location!);
      expect(page.q('.alert')!.text, contains('sold out'));
    });

    test('missing or unknown ids are handled gracefully', () async {
      final r = await visitor.post('/cart/add', {'productId': 'p_stride_knit'});
      expect(r.location, '/products/stride-knit-sneaker?error=unknown_variant');
      final r2 = await visitor.post('/cart/add', {'productId': 'nope', 'variantId': 'x'});
      expect(r2.location, '/products');
      expect((await visitor.post('/cart/add', {})).status, 303);
    });
  });

  group('add to cart (JSON, used by the island)', () {
    test('returns the new count and sets the cookie', () async {
      final r = await visitor.post(
        '/cart/add',
        {'productId': 'p_day_backpack', 'variantId': 'v_day_black', 'quantity': '2'},
        headers: {'accept': 'application/json'},
      );
      expect(r.status, 200);
      expect(r.header('content-type'), contains('application/json'));
      expect(r.header('cache-control'), 'no-store');
      final data = r.json as Map<String, dynamic>;
      expect(data['ok'], isTrue);
      expect(data['count'], 2);
      expect(r.setCookies(), hasLength(1));
    });

    test('errors are JSON with 422', () async {
      final r = await visitor.post(
        '/cart/add',
        {'productId': 'p_stride_knit', 'variantId': 'v_stride_44'},
        headers: {'accept': 'application/json'},
      );
      expect(r.status, 422);
      final data = r.json as Map<String, dynamic>;
      expect(data['ok'], isFalse);
      expect(data['code'], 'out_of_stock');
      expect(data['message'], isNotEmpty);
    });

    test('GET /cart/summary reports the count', () async {
      expect(((await visitor.get('/cart/summary')).json as Map)['count'], 0);
      await addBackpack(qty: 3);
      final r = await visitor.get('/cart/summary');
      expect((r.json as Map)['count'], 3);
      expect(r.header('cache-control'), 'no-store');
    });
  });

  group('cart page', () {
    setUp(() async => await addBackpack());

    test('update quantity', () async {
      final r = await visitor.post('/cart/update', {'variantId': 'v_day_black', 'quantity': '4'});
      expect(r.status, 303);
      expect(r.location, '/cart?notice=updated');
      expect((await visitor.get('/cart')).q('.qty-input')!.attributes['value'], '4');
    });

    test('update to zero removes the line', () async {
      final r = await visitor.post('/cart/update', {'variantId': 'v_day_black', 'quantity': '0'});
      expect(r.location, '/cart?notice=removed');
      expect((await visitor.get('/cart')).text, contains('Your cart is empty'));
    });

    test('update beyond stock is clamped with a notice', () async {
      await visitor.post('/cart/add', {'productId': 'p_classic_38', 'variantId': 'v_classic_black', 'quantity': '1'});
      final r = await visitor.post('/cart/update', {'variantId': 'v_classic_black', 'quantity': '7'});
      expect(r.location, '/cart?notice=adjusted');
    });

    test('remove', () async {
      final r = await visitor.post('/cart/remove', {'variantId': 'v_day_black'});
      expect(r.location, '/cart?notice=removed');
      expect((await visitor.get('/cart')).qa('.cart-line'), isEmpty);
    });

    test('update/remove with no cart or unknown line just go back to the cart', () async {
      final fresh = Browser(app);
      expect((await fresh.post('/cart/update', {'variantId': 'x', 'quantity': '1'})).location, '/cart');
      expect((await fresh.post('/cart/remove', {'variantId': 'x'})).location, '/cart');
      expect((await visitor.post('/cart/update', {'variantId': 'nope', 'quantity': '1'})).location, '/cart');
    });

    test('every line has labelled quantity input, update and remove forms', () async {
      final r = await visitor.get('/cart');
      expect(r.q('.qty-form label.sr-only')!.text, contains('Quantity for Day Backpack'));
      expect(r.q('form[action="/cart/update"] button')!.attributes['aria-label'], contains('Update quantity'));
      expect(r.q('form[action="/cart/remove"] button')!.attributes['aria-label'], contains('Remove Day Backpack'));
    });

    test('free-shipping progress shows the remaining amount, then the unlock', () async {
      await visitor.post('/cart/remove', {'variantId': 'v_day_black'});
      await visitor.post('/cart/add', {'productId': 'p_stoneware_mug', 'variantId': 'v_mug_white', 'quantity': '1'});
      var r = await visitor.get('/cart');
      expect(r.q('.ship-progress')!.text, contains(r'$53.00 away'));
      expect(r.q('progress')!.attributes['value'], '29');
      await visitor.post('/cart/add', {'productId': 'p_day_backpack', 'variantId': 'v_day_black', 'quantity': '1'});
      r = await visitor.get('/cart');
      expect(r.q('.ship-progress')!.text, contains('free standard shipping'));
      expect(r.q('.totals')!.text, contains('Free'));
    });

    test('totals: subtotal, shipping and total', () async {
      await visitor.post('/cart/remove', {'variantId': 'v_day_black'});
      await visitor.post('/cart/add', {'productId': 'p_stoneware_mug', 'variantId': 'v_mug_white', 'quantity': '1'});
      final r = await visitor.get('/cart');
      final totals = r.q('.totals')!.text;
      expect(totals, contains(r'$22.00'));
      expect(totals, contains(r'$6.00'));
      expect(totals, contains(r'$28.00'));
    });

    test('unknown notice codes are ignored', () async {
      final r = await visitor.get('/cart?notice=<script>alert(1)</script>');
      expect(r.body, isNot(contains('<script>alert')));
      expect(r.q('.alert'), isNull);
    });
  });

  group('promo code', () {
    setUp(() async => await addBackpack());

    test('CAIRN10 applies 10% and shows a removable badge', () async {
      final r = await visitor.post('/cart/promo', {'action': 'apply', 'code': 'cairn10'});
      expect(r.status, 303);
      expect(r.location, '/cart?notice=promo_applied');
      final cart = await visitor.get(r.location!);
      final totals = cart.q('.totals')!.text;
      expect(totals, contains('Discount (CAIRN10)'));
      expect(totals, contains(r'-$8.50'));
      expect(totals, contains(r'$76.50'));
      expect(cart.q('.promo--applied')!.text, contains('CAIRN10'));
    });

    test('an invalid code re-renders with an inline, associated error (422) and keeps the input', () async {
      final r = await visitor.post('/cart/promo', {'action': 'apply', 'code': 'WRONG'});
      expect(r.status, 422);
      final input = r.q('#cart-code')!;
      expect(input.attributes['aria-invalid'], 'true');
      expect(input.attributes['aria-describedby'], contains('cart-code-error'));
      expect(input.attributes['value'], 'WRONG');
      expect(r.q('#cart-code-error')!.attributes['role'], 'alert');
      expect(r.q('#cart-code-error')!.text, contains("isn't valid"));
      expect(r.q('label[for="cart-code"]'), isNotNull);
    });

    test('an empty code asks for one', () async {
      final r = await visitor.post('/cart/promo', {'action': 'apply', 'code': ' '});
      expect(r.status, 422);
      expect(r.text, contains('Enter a promo code'));
    });

    test('a hostile code is not reflected as markup', () async {
      final r = await visitor.post('/cart/promo', {'action': 'apply', 'code': '"><script>alert(1)</script>'});
      expect(r.status, 422);
      expect(r.body, isNot(contains('<script>alert')));
    });

    test('remove', () async {
      await visitor.post('/cart/promo', {'action': 'apply', 'code': 'CAIRN10'});
      final r = await visitor.post('/cart/promo', {'action': 'remove'});
      expect(r.location, '/cart?notice=promo_removed');
      expect((await visitor.get('/cart')).q('.totals')!.text, isNot(contains('Discount')));
    });

    test('promo with no cart goes to the empty cart', () async {
      expect((await Browser(app).post('/cart/promo', {'action': 'apply', 'code': 'CAIRN10'})).location, '/cart');
    });
  });

  group('checkout', () {
    setUp(() async => await addBackpack());

    test('GET shows the form, the summary and the demo disclaimer', () async {
      final r = await visitor.get('/checkout');
      expect(r.status, 200);
      expect(r.header('cache-control'), 'no-store');
      expect(r.meta('robots'), 'noindex, nofollow');
      expect(r.qa('h1'), hasLength(1));
      expect(r.text, contains('never takes real payment'));
      expect(r.text, contains('will not ask for a card'));
      expect(r.q('form[action="/checkout"]')!.attributes['method'], 'post');
      expect(r.q('.checkout-summary')!.text, contains('Day Backpack'));
      expect(r.qa('input[type="radio"][name="delivery"]'), hasLength(2));
      expect(r.q('input[type="checkbox"][name="acceptTerms"]'), isNotNull);
    });

    test('every control is labelled and autocomplete tokens are set', () async {
      final r = await visitor.get('/checkout');
      for (final c in r.qa(
        'form.checkout-form input:not([type=hidden]):not([type=radio]):not([type=checkbox]), form.checkout-form select',
      )) {
        expect(r.q('label[for="${c.attributes['id']}"]'), isNotNull, reason: c.attributes['name']);
      }
      expect(r.q('#f-email')!.attributes['autocomplete'], 'email');
      expect(r.q('#f-postalCode')!.attributes['autocomplete'], 'postal-code');
      expect(r.q('#f-address1')!.attributes['autocomplete'], 'address-line1');
      expect(r.q('fieldset legend'), isNotNull);
    });

    test('an empty submission shows inline errors tied to fields, a summary and 422', () async {
      final r = await visitor.post('/checkout', {});
      expect(r.status, 422);
      final summary = r.q('#error-summary')!;
      expect(summary.attributes['role'], 'alert');
      expect(summary.querySelectorAll('a'), isNotEmpty);
      for (final field in ['email', 'fullName', 'address1', 'city', 'region', 'postalCode']) {
        final input = r.q('#f-$field')!;
        expect(input.attributes['aria-invalid'], 'true', reason: field);
        expect(input.attributes['aria-describedby'], contains('f-$field-error'), reason: field);
        expect(r.q('#f-$field-error')!.attributes['role'], 'alert', reason: field);
      }
      for (final a in summary.querySelectorAll('a')) {
        expect(r.doc.getElementById(a.attributes['href']!.substring(1)), isNotNull);
      }
      expect(r.q('#f-acceptTerms-error'), isNotNull);
    });

    test('invalid input is preserved when the form is re-rendered', () async {
      final r = await visitor.post('/checkout', {...validCheckout, 'email': 'not-an-email', 'postalCode': '123'});
      expect(r.status, 422);
      expect(r.q('#f-email')!.attributes['value'], 'not-an-email');
      expect(r.q('#f-fullName')!.attributes['value'], 'Ada Lovelace');
      expect(r.q('#f-email-error')!.text, contains('valid email'));
      expect(r.q('#f-postalCode-error')!.text, contains('zip code'));
      expect(r.q('#f-city-error'), isNull);
      expect(r.q('#f-country option[selected]')!.attributes['value'], 'US');
      expect(r.q('input[name="acceptTerms"]')!.attributes.containsKey('checked'), isTrue);
    });

    test('country changes the postal code rules and labels', () async {
      final r = await visitor.post('/checkout', {...validCheckout, 'country': 'CA', 'postalCode': '12345'});
      expect(r.status, 422);
      expect(r.q('label[for="f-postalCode"]')!.text, contains('Postal code'));
      expect(r.q('label[for="f-region"]')!.text, contains('Province'));
      final ok = await visitor.post('/checkout', {
        ...validCheckout,
        'country': 'CA',
        'postalCode': 'K1A 0B1',
        'region': 'ON',
      });
      expect(ok.status, 303);
    });

    test('hostile input is escaped when echoed back', () async {
      final r = await visitor.post('/checkout', {
        ...validCheckout,
        'fullName': '"><script>alert(1)</script>',
        'email': 'x',
      });
      expect(r.body, isNot(contains('<script>alert')));
      expect(r.status, 422);
    });

    test('a valid submission creates the order, clears the cart and redirects to the confirmation', () async {
      final r = await visitor.post('/checkout', validCheckout);
      expect(r.status, 303);
      expect(r.location, startsWith('/checkout/confirmation/ord_'));
      expect(r.setCookies().single, contains('Max-Age=0')); // cart cookie cleared
      expect(visitor.cookies, isEmpty);
      expect(app.backend.orders.length, 1);
      expect((await visitor.get('/cart')).text, contains('Your cart is empty'));
    });

    test('the confirmation page shows the order, is noindex and not cacheable', () async {
      final r = await visitor.post('/checkout', {...validCheckout, 'delivery': 'express'}, follow: true);
      expect(r.status, 200);
      expect(r.header('cache-control'), 'no-store');
      expect(r.meta('robots'), 'noindex, nofollow');
      expect(r.qa('h1'), hasLength(1));
      expect(r.q('h1')!.text, contains('Ada'));
      expect(r.text, contains('NG-100001'));
      expect(r.text, contains('Day Backpack'));
      expect(r.text, contains('Express delivery'));
      expect(r.text, contains('demo'));
      expect(r.text, contains('12 Analytical Way'));
      expect(r.q('.totals')!.text, contains(r'$14.00'));
    });

    test('promo discount carries through to the order', () async {
      await visitor.post('/cart/promo', {'action': 'apply', 'code': 'CAIRN10'});
      final r = await visitor.post('/checkout', validCheckout, follow: true);
      expect(r.q('.totals')!.text, contains('Discount (CAIRN10)'));
      expect(r.q('.totals')!.text, contains(r'$76.50'));
    });

    test('stock is reduced by the order', () async {
      int stock() =>
          app.backend.catalog.products.firstWhere((p) => p.id == 'p_day_backpack').variantById('v_day_black')!.stock;
      expect(stock(), 22);
      await visitor.post('/checkout', validCheckout);
      expect(stock(), 21);
    });

    test('placing the same cart twice is impossible (cart is gone)', () async {
      await visitor.post('/checkout', validCheckout);
      final again = await visitor.post('/checkout', validCheckout);
      expect(again.status, 303);
      expect(again.location, '/cart');
      expect(app.backend.orders.length, 1);
    });

    test('an item that sold out mid-checkout produces a 409 with an explanation', () async {
      final late = Browser(app);
      await late.post('/cart/add', {'productId': 'p_skeleton_sport', 'variantId': 'v_skeleton_42', 'quantity': '2'});
      app.backend.catalog.reserve({'v_skeleton_42': 2}); // someone else bought them
      final r = await late.post('/checkout', validCheckout);
      expect(r.status, 409);
      expect(r.q('#error-summary')!.text, contains('Skeleton Sport Watch'));
      expect(app.backend.orders.length, 0);
    });

    test('confirmation URLs are unguessable and unknown ids are 404', () async {
      await visitor.post('/checkout', validCheckout);
      expect((await visitor.get('/checkout/confirmation/ord_aaaaaaaaaaaaaaaa')).status, 404);
      expect((await visitor.get('/checkout/confirmation/NG-100001')).status, 404);
    });
  });

  group('newsletter (no JavaScript)', () {
    test('valid email: 303 then a thank-you page', () async {
      final r = await visitor.post('/newsletter', {'email': 'Ada@Example.com'});
      expect(r.status, 303);
      expect(r.location, '/newsletter?status=ok');
      final page = await visitor.get(r.location!);
      expect(page.q('h1')!.text, 'You are subscribed');
      expect(app.backend.newsletter.contains('ada@example.com'), isTrue);
    });

    test('a repeat is acknowledged', () async {
      await visitor.post('/newsletter', {'email': 'a@b.co'});
      final r = await visitor.post('/newsletter', {'email': 'a@b.co'});
      expect(r.location, '/newsletter?status=exists');
      expect((await visitor.get(r.location!)).q('h1')!.text, contains('already'));
    });

    test('invalid email: 422 with an inline error and the input preserved', () async {
      final r = await visitor.post('/newsletter', {'email': 'nope'});
      expect(r.status, 422);
      expect(r.q('#news-email')!.attributes['aria-invalid'], 'true');
      expect(r.q('#news-email-error')!.text, contains('valid email'));
      expect(r.q('#news-email')!.attributes['value'], 'nope');
      expect(app.backend.newsletter.length, 0);
    });
  });

  group('CSRF and origin checks', () {
    test('a cross-site POST is rejected with 403 and changes nothing', () async {
      final r = await visitor.post(
        '/cart/add',
        {'productId': 'p_day_backpack', 'variantId': 'v_day_black'},
        headers: {'origin': 'https://evil.example', 'host': 'shop.example'},
      );
      expect(r.status, 403);
      expect(visitor.cookies, isEmpty);
      expect(app.backend.carts.length, 0);
    });

    test('Sec-Fetch-Site: cross-site is rejected', () async {
      final r = await visitor.post('/newsletter', {'email': 'a@b.co'}, headers: {'sec-fetch-site': 'cross-site'});
      expect(r.status, 403);
      expect(app.backend.newsletter.length, 0);
    });

    test('a same-origin POST is accepted', () async {
      final r = await visitor.post(
        '/newsletter',
        {'email': 'a@b.co'},
        headers: {'origin': 'https://shop.example', 'sec-fetch-site': 'same-origin'},
      );
      expect(r.status, 303);
    });

    test('checkout and promo are protected too', () async {
      await addBackpack();
      final evil = {'origin': 'https://evil.example', 'host': 'shop.example'};
      expect((await visitor.post('/checkout', validCheckout, headers: evil)).status, 403);
      expect((await visitor.post('/cart/promo', {'action': 'apply', 'code': 'CAIRN10'}, headers: evil)).status, 403);
      expect((await visitor.post('/cart/remove', {'variantId': 'v_day_black'}, headers: evil)).status, 403);
      expect(app.backend.orders.length, 0);
    });
  });
}
