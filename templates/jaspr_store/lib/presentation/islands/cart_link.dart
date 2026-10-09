/// Header cart link with a live item count: island #3.
///
/// Catalogue pages are identical for every visitor so they can be cached by a
/// CDN; a personalised count in the server HTML would make that impossible.
/// So the server renders a plain `<a href="/cart">Cart</a>` and this island
/// fills in the number after hydration from `GET /cart/summary` (a tiny,
/// uncacheable JSON endpoint), then keeps it current by listening for the
/// `cart:changed` event the add-to-cart island dispatches.
library;

import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../components/html.dart';
import '../components/icons.dart';
import 'add_to_cart_button.dart' show kCartChangedEvent;

@client
class CartLink extends StatefulComponent {
  const CartLink({super.key});

  @override
  State<CartLink> createState() => _CartLinkState();
}

class _CartLinkState extends State<CartLink> {
  int _count = 0;
  JSFunction? _listener;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;
    _listener = ((web.Event e) {
      final detail = (e as web.CustomEvent).detail;
      final n = (detail as JSNumber?)?.toDartInt;
      if (n != null) setState(() => _count = n);
    }).toJS;
    web.window.addEventListener(kCartChangedEvent, _listener);
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final response = await web.window.fetch('/cart/summary'.toJS, web.RequestInit(credentials: 'same-origin')).toDart;
      if (!response.ok) return;
      final text = (await response.text().toDart).toDart;
      final data = jsonDecode(text) as Map<String, dynamic>;
      final n = (data['count'] as num?)?.toInt() ?? 0;
      if (mounted) setState(() => _count = n);
    } catch (_) {
      // Offline or blocked: the plain link still works.
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _listener != null) web.window.removeEventListener(kCartChangedEvent, _listener);
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final label = _count == 0 ? 'Cart' : 'Cart, $_count ${_count == 1 ? 'item' : 'items'}';
    return a(
      href: '/cart',
      classes: 'cart-link',
      attributes: {'aria-label': label},
      [
        Icons.cart(),
        span(classes: 'cart-link__text', [t('Cart')]),
        if (_count > 0) span(classes: 'cart-link__count', attributes: const {'aria-hidden': 'true'}, [t('$_count')]),
      ],
    );
  }
}
