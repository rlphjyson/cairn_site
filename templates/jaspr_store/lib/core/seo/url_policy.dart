/// URL hygiene: one canonical spelling for every page.
///
/// Duplicate URLs split ranking signals and waste crawl budget. This file is
/// the single place the rules live; `app.dart` applies them as 301 redirects
/// and `SeoData.path` carries the canonical form into the `<link>` tag.
library;

import '../../common/constants.dart';

/// Collapses repeated slashes and drops a trailing slash (except for `/`).
String normalizePath(String path) {
  var p = path.isEmpty ? '/' : path;
  if (!p.startsWith('/')) p = '/$p';
  p = p.replaceAll(RegExp(r'/{2,}'), '/');
  if (p.length > 1 && p.endsWith('/')) p = p.substring(0, p.length - 1);
  return p;
}

/// Removes tracking parameters and empty values. Order is preserved.
Map<String, String> stripTracking(Map<String, String> query) => {
  for (final e in query.entries)
    if (!isTrackingParam(e.key) && e.value.isNotEmpty) e.key: e.value,
};

/// Builds `path?query` with deterministic parameter order, so the same state
/// always serialises to the same URL.
String buildUrl(String path, Map<String, String?> params, {List<String> order = const []}) {
  final entries = <MapEntry<String, String>>[
    for (final e in params.entries)
      if (e.value != null && e.value!.isNotEmpty) MapEntry(e.key, e.value!),
  ];
  entries.sort((a, b) {
    final ia = order.indexOf(a.key);
    final ib = order.indexOf(b.key);
    if (ia != ib) return (ia < 0 ? 999 : ia).compareTo(ib < 0 ? 999 : ib);
    return a.key.compareTo(b.key);
  });
  if (entries.isEmpty) return path;
  final query = entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&');
  return '$path?$query';
}
