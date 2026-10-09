/// Add-to-cart progressive enhancement: island #2.
///
/// Server-rendered as a plain `<button type="submit">` inside a plain
/// `<form method="post" action="/cart/add">`, so adding to the cart works with
/// JavaScript off (the server answers with a 303 to `/cart`). When this island
/// hydrates it intercepts the click, posts the same form with `fetch`, asks for
/// JSON, and shows instant feedback ("Added") without a page load. If the
/// request fails for any reason it falls back to the normal form submit.
library;

import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../components/html.dart';
import '../components/icons.dart';

/// Window event other islands (the cart badge) listen to.
const String kCartChangedEvent = 'cart:changed';

@client
class AddToCartButton extends StatefulComponent {
  const AddToCartButton({this.label = 'Add to cart', this.disabled = false, super.key});

  final String label;
  final bool disabled;

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

enum _Phase { idle, busy, added, error }

class _AddToCartButtonState extends State<AddToCartButton> {
  _Phase _phase = _Phase.idle;
  String _message = '';

  Future<void> _onClick(web.Event event) async {
    if (!kIsWeb || component.disabled || _phase == _Phase.busy) return;
    final target = event.currentTarget;
    if (target == null) return;
    final form = (target as web.HTMLButtonElement).form;
    if (form == null) return;
    // From here on we own the submit; the no-JS path is the fallback.
    event.preventDefault();
    if (!form.reportValidity()) return;
    setState(() => _phase = _Phase.busy);
    try {
      final body = web.URLSearchParams(web.FormData(form) as JSAny);
      final headers = web.Headers()..append('Accept', 'application/json');
      final response = await web.window
          .fetch(
            form.action.toJS,
            web.RequestInit(method: 'POST', body: body, headers: headers, credentials: 'same-origin'),
          )
          .toDart;
      final text = (await response.text().toDart).toDart;
      final data = jsonDecode(text) as Map<String, dynamic>;
      if (data['ok'] == true) {
        final count = (data['count'] as num?)?.toInt() ?? 0;
        web.window.dispatchEvent(web.CustomEvent(kCartChangedEvent, web.CustomEventInit(detail: count.toJS)));
        setState(() {
          _phase = _Phase.added;
          _message = (data['message'] as String?) ?? 'Added to your cart.';
        });
      } else {
        setState(() {
          _phase = _Phase.error;
          _message = (data['message'] as String?) ?? 'Could not add that item.';
        });
      }
    } catch (_) {
      // Network error, bad JSON, blocked fetch: let the browser do a normal POST.
      form.submit();
    }
  }

  @override
  Component build(BuildContext context) {
    final label = switch (_phase) {
      _Phase.busy => 'Adding…',
      _Phase.added => 'Added to cart',
      _ => component.label,
    };
    return Component.fragment([
      el(
        'button',
        classes: cx(['btn btn--primary btn--lg btn--block', if (_phase == _Phase.busy) 'is-busy']),
        attrs: {
          'type': 'submit',
          if (component.disabled) 'disabled': '',
          if (_phase == _Phase.busy) 'aria-busy': 'true',
        },
        events: {'click': _onClick},
        children: [if (_phase == _Phase.added) Icons.check(), t(label)],
      ),
      // Polite live region: screen-reader users hear the result of the
      // JavaScript-driven add without focus moving.
      p(
        classes: cx(['add-status', if (_phase == _Phase.error) 'add-status--error']),
        attributes: const {'role': 'status', 'aria-live': 'polite'},
        [
          if (_phase == _Phase.added) ...[
            t('$_message '),
            a(href: '/cart', [t('View cart')]),
          ] else
            t(_phase == _Phase.error ? _message : ''),
        ],
      ),
    ]);
  }
}
