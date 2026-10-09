import 'package:cairn_template_jaspr_store/backend/cart_cookie.dart';
import 'package:cairn_template_jaspr_store/backend/stores.dart';
import 'package:cairn_template_jaspr_store/domain/cart/models/cart.dart';
import 'package:test/test.dart';

void main() {
  const cookie = CartCookie(secret: 'a-test-secret-that-is-long-enough-123', secure: false);
  const secureCookie = CartCookie(secret: 'a-test-secret-that-is-long-enough-123', secure: true);

  group('CartCookie', () {
    test('round-trips a signed id', () {
      final id = randomToken(16);
      expect(cookie.verify(cookie.sign(id)), id);
    });

    test('rejects a tampered id', () {
      final id = randomToken(16);
      final signed = cookie.sign(id);
      final tampered = '${randomToken(16)}.${signed.split('.').last}';
      expect(cookie.verify(tampered), isNull);
    });

    test('rejects a tampered tag, a missing tag and garbage', () {
      final signed = cookie.sign(randomToken(16));
      expect(cookie.verify('${signed.substring(0, signed.length - 2)}xx'), isNull);
      expect(cookie.verify(signed.split('.').first), isNull);
      expect(cookie.verify(''), isNull);
      expect(cookie.verify(null), isNull);
      expect(cookie.verify('.'), isNull);
      expect(cookie.verify('a.b.c'), isNull);
      expect(cookie.verify('x' * 500), isNull);
      expect(cookie.verify("'; DROP TABLE carts;--.abc"), isNull);
    });

    test('a different secret invalidates every cookie', () {
      final id = randomToken(16);
      const other = CartCookie(secret: 'another-secret-another-secret-12345', secure: false);
      expect(other.verify(cookie.sign(id)), isNull);
    });

    test('the Set-Cookie value is HttpOnly, SameSite=Lax, Path=/ with a lifetime', () {
      final header = cookie.setCookie('abcdefghijklmnop');
      expect(header, startsWith('cart='));
      expect(header, contains('HttpOnly'));
      expect(header, contains('SameSite=Lax'));
      expect(header, contains('Path=/'));
      expect(header, contains('Max-Age=1209600'));
      expect(header, isNot(contains('Secure')));
      expect(header, isNot(contains('Domain')));
    });

    test('over https it is Secure and uses the __Host- prefix', () {
      final header = secureCookie.setCookie('abcdefghijklmnop');
      expect(header, startsWith('__Host-cart='));
      expect(header, contains('; Secure'));
      expect(header, isNot(contains('Domain')));
    });

    test('clearCookie expires it immediately', () {
      expect(cookie.clearCookie(), contains('Max-Age=0'));
      expect(cookie.clearCookie(), contains('HttpOnly'));
    });

    test('the cookie value contains no cart contents or prices', () {
      final value = cookie.sign(randomToken(16));
      expect(value, matches(RegExp(r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$')));
      expect(value.length, lessThan(80));
    });

    test('idFromHeader finds the cookie among others', () {
      final id = randomToken(16);
      final header = 'theme=dark; cart=${cookie.sign(id)}; other=1';
      expect(cookie.idFromHeader(header), id);
      expect(cookie.idFromHeader('theme=dark'), isNull);
      expect(cookie.idFromHeader(null), isNull);
    });

    test('readCookie handles spacing and missing values', () {
      expect(readCookie('a=1;b=2; c = 3', 'b'), '2');
      expect(readCookie('a=1', 'z'), isNull);
      expect(readCookie('=x; a', 'a'), isNull);
    });
  });

  group('randomToken', () {
    test('is url-safe, unpadded and unique', () {
      final tokens = {for (var i = 0; i < 200; i++) randomToken(16)};
      expect(tokens, hasLength(200));
      for (final t in tokens) {
        expect(t, matches(RegExp(r'^[A-Za-z0-9_-]{22}$')));
      }
    });
  });

  group('CartStore', () {
    test('creates, finds, saves and deletes', () {
      final store = CartStore();
      final cart = store.create();
      expect(store.find(cart.id)!.id, cart.id);
      store.save(
        cart.copyWith(
          lines: const [CartLine(productId: 'p', variantId: 'v', quantity: 2)],
        ),
      );
      expect(store.find(cart.id)!.itemCount, 2);
      store.delete(cart.id);
      expect(store.find(cart.id), isNull);
    });

    test('is keyed by a hash, not by the id', () {
      final store = CartStore();
      final cart = store.create();
      expect(store.find(cart.id.toUpperCase()), isNull);
    });

    test('carts expire after the TTL', () {
      var now = DateTime.utc(2026, 1, 1);
      final store = CartStore(ttl: const Duration(days: 14), clock: () => now);
      final cart = store.create();
      now = now.add(const Duration(days: 13));
      expect(store.find(cart.id), isNotNull);
      now = now.add(const Duration(days: 2));
      expect(store.find(cart.id), isNull);
      expect(store.length, 0);
    });

    test('is bounded: the least recently updated cart is evicted', () {
      final store = CartStore(maxCarts: 3);
      final a = store.create();
      final b = store.create();
      final c = store.create();
      store.save(a.copyWith(updatedAt: DateTime.now())); // a becomes most recent
      final d = store.create();
      expect(store.length, 3);
      expect(store.find(b.id), isNull);
      expect(store.find(a.id), isNotNull);
      expect(store.find(c.id), isNotNull);
      expect(store.find(d.id), isNotNull);
    });
  });

  group('CatalogStore.reserve', () {
    test('decrements stock atomically', () {
      final store = CatalogStore();
      expect(store.reserve({'v_mug_white': 5, 'v_notebook_dot': 5}), isTrue);
      final mug = store.products.firstWhere((p) => p.id == 'p_stoneware_mug');
      expect(mug.variantById('v_mug_white')!.stock, 35);
    });

    test('changes nothing when any line fails', () {
      final store = CatalogStore();
      expect(store.reserve({'v_mug_white': 5, 'v_skeleton_42': 99}), isFalse);
      final mug = store.products.firstWhere((p) => p.id == 'p_stoneware_mug');
      expect(mug.variantById('v_mug_white')!.stock, 40);
    });
  });

  group('OrderStore and NewsletterStore', () {
    test('order identities are unique and sequential', () {
      final store = OrderStore();
      final a = store.nextIdentity();
      final b = store.nextIdentity();
      expect(a.id, isNot(b.id));
      expect(a.number, 'NG-100001');
      expect(b.number, 'NG-100002');
      expect(store.byId('missing'), isNull);
    });

    test('newsletter set semantics', () {
      final store = NewsletterStore();
      expect(store.add('a@b.co'), isTrue);
      expect(store.add('a@b.co'), isFalse);
    });
  });
}
