import '../../../domain/cart/models/cart_line.dart';
import '../../../domain/cart/repositories/cart_repository.dart';
import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/repositories/product_repository.dart';
import '../remote/cart_remote_data_source.dart';

/// [CartRepository] that stores quantities and hydrates them with products.
class CartRepositoryImpl implements CartRepository {
  /// Creates the repository.
  CartRepositoryImpl(this._dataSource, this._products);

  final CartRemoteDataSource _dataSource;
  final ProductRepository _products;

  @override
  Future<List<CartLine>> getLines() async {
    final List<CartLine> lines = <CartLine>[];
    for (final MapEntry<String, int> e in _dataSource.read().entries) {
      final Product? product = await _products.getProduct(e.key);
      if (product != null) {
        lines.add(CartLine(product: product, quantity: e.value));
      }
    }
    return lines;
  }

  @override
  Future<void> add(String productId) async {
    final Map<String, int> q = _dataSource.read();
    q[productId] = (q[productId] ?? 0) + 1;
    _dataSource.write(q);
  }

  @override
  Future<void> setQuantity(String productId, int quantity) async {
    final Map<String, int> q = _dataSource.read();
    if (quantity <= 0) {
      q.remove(productId);
    } else {
      q[productId] = quantity;
    }
    _dataSource.write(q);
  }

  @override
  Future<void> clear() async => _dataSource.write(<String, int>{});
}
