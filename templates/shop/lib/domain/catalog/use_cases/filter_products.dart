import '../../../common/constants/product_categories.dart';
import '../models/product.dart';

/// Narrows a product list by category and a free-text query.
///
/// Pure and synchronous, so it is trivial to test and cheap to re-run on every
/// keystroke. The query matches the name and the category.
class FilterProducts {
  /// Creates the use case.
  const FilterProducts();

  /// Runs it.
  List<Product> call(
    List<Product> products, {
    String category = ProductCategories.all,
    String query = '',
  }) {
    final String q = query.trim().toLowerCase();
    return products.where((Product p) {
      if (category != ProductCategories.all && p.category != category) {
        return false;
      }
      return q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }
}
