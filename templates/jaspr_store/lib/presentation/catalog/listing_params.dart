library;

import '../../domain/catalog/models/product_query.dart';

/// The query-string state of a listing page, normalised.
///
/// [needsRedirect] is true when the *spelling* of the URL is not canonical
/// (`?page=1`, `?sort=featured`, `?q=`, `?page=abc`, padded search text). The
/// controller answers those with a 301 to the canonical spelling, so each state
/// of the listing has exactly one URL.
class ListingParams {
  const ListingParams({required this.q, required this.sort, required this.page, required this.needsRedirect});

  final String q;
  final ProductSort sort;
  final int page;
  final bool needsRedirect;

  bool get hasSearch => q.isNotEmpty;
  bool get isDefault => !hasSearch && sort == ProductSort.defaultSort;

  static const int maxSearchLength = 80;

  factory ListingParams.parse(Map<String, String> query) {
    final rawQ = query['q'];
    var q = (rawQ ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (q.length > maxSearchLength) q = q.substring(0, maxSearchLength).trim();

    final rawSort = query['sort'];
    final parsedSort = ProductSort.parse(rawSort);
    final sort = parsedSort ?? ProductSort.defaultSort;

    final rawPage = query['page'];
    var page = int.tryParse(rawPage ?? '') ?? 1;
    if (page < 1) page = 1;

    final redirect =
        (rawQ != null && (rawQ != q || q.isEmpty)) ||
        (rawSort != null && (parsedSort == null || sort == ProductSort.defaultSort)) ||
        (rawPage != null && (rawPage != '$page' || page == 1));

    return ListingParams(q: q, sort: sort, page: page, needsRedirect: redirect);
  }
}
