/// Escaping helpers.
library;

import 'dart:convert';

/// Serialises [data] for embedding inside `<script type="application/ld+json">`.
///
/// `jsonEncode` alone is not safe there: a product name containing
/// `</script><script>alert(1)` would close the tag early. Escaping `<`, `>` and
/// `&` as unicode escapes keeps the JSON valid and the HTML parser blind to it.
const String _bs = '\\';

String safeJsonForScript(Object? data) {
  return jsonEncode(data)
      .replaceAll('<', '${_bs}u003c')
      .replaceAll('>', '${_bs}u003e')
      .replaceAll('&', '${_bs}u0026')
      .replaceAll(String.fromCharCode(0x2028), '${_bs}u2028')
      .replaceAll(String.fromCharCode(0x2029), '${_bs}u2029');
}

/// Minimal HTML attribute/text escape for the few places strings are built
/// by hand (sitemap XML). Jaspr escapes everything it renders itself.
String escapeXml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');
