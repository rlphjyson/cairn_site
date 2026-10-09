/// The cart cookie: one opaque id, signed.
///
/// **Design.** The cookie carries no cart contents and no prices, only an
/// opaque 128-bit server-issued id plus an HMAC tag: `<id>.<tag>`. The cart
/// lives on the server, keyed by that id.
///
/// *Why not put the cart in the cookie?* A client-held cart (even signed) is
/// capped at 4 KB, cannot be inspected or expired server-side, grows every
/// request, and encourages storing prices that then have to be trusted. With a
/// server-keyed cart the cookie is a handle, and every price is recomputed from
/// the catalogue on each read.
///
/// *Why sign an id the server already looks up?* The tag lets the server reject
/// forged or junk ids with no store lookup (cheap protection against cache
/// pollution and enumeration), and lets you rotate `CART_SECRET` to invalidate
/// every outstanding cart at once.
///
/// *Cookie flags.* `HttpOnly` (JavaScript, including a compromised dependency,
/// cannot read it), `SameSite=Lax` (cross-site POSTs do not carry it, which is
/// the CSRF defence for the demo forms; they also check `Origin`), `Path=/`
/// and, over https, `Secure` plus the `__Host-` prefix so a sibling subdomain
/// cannot overwrite it.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

class CartCookie {
  const CartCookie({required this.secret, required this.secure, this.maxAge = const Duration(days: 14)});

  final String secret;
  final bool secure;
  final Duration maxAge;

  String get name => secure ? '__Host-cart' : 'cart';

  String _tag(String id) {
    final mac = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode('cart:$id'));
    return base64Url.encode(mac.bytes.sublist(0, 16)).replaceAll('=', '');
  }

  String sign(String id) => '$id.${_tag(id)}';

  /// Returns the cart id if [value] is well-formed and correctly signed.
  String? verify(String? value) {
    if (value == null || value.length > 128) return null;
    final dot = value.lastIndexOf('.');
    if (dot <= 0) return null;
    final id = value.substring(0, dot);
    final tag = value.substring(dot + 1);
    if (!RegExp(r'^[A-Za-z0-9_-]{16,64}$').hasMatch(id)) return null;
    return _constantTimeEquals(tag, _tag(id)) ? id : null;
  }

  /// Extracts and verifies the cart id from a raw `Cookie:` request header.
  String? idFromHeader(String? cookieHeader) => verify(readCookie(cookieHeader, name));

  String setCookie(String id) =>
      '$name=${sign(id)}; Path=/; Max-Age=${maxAge.inSeconds}; HttpOnly; SameSite=Lax${secure ? '; Secure' : ''}';

  String clearCookie() => '$name=; Path=/; Max-Age=0; HttpOnly; SameSite=Lax${secure ? '; Secure' : ''}';
}

String? readCookie(String? header, String name) {
  if (header == null) return null;
  for (final pair in header.split(';')) {
    final index = pair.indexOf('=');
    if (index <= 0) continue;
    if (pair.substring(0, index).trim() == name) return pair.substring(index + 1).trim();
  }
  return null;
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}
