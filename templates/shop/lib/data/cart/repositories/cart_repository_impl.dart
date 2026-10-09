import '../../../domain/cart/mappers/cart_mapper.dart';
import '../../../domain/cart/models/cart.dart';
import '../../../domain/cart/models/cart_line.dart';
import '../../../domain/cart/models/promo_code.dart';
import '../../../domain/cart/repositories/cart_repository.dart';
import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/repositories/product_repository.dart';
import '../remote/cart_remote_data_source.dart';

/// [CartRepository] that stores lines by product and variant and hydrates them
/// with products from the catalogue.
class CartRepositoryImpl implements CartRepository {
  /// Creates the repository.
  CartRepositoryImpl(this._dataSource, this._products);

  final CartRemoteDataSource _dataSource;
  final ProductRepository _products;

  List<Map<String, Object?>> _lines(Map<String, Object?> stored) =>
      (stored['lines']! as List<Object?>).cast<Map<String, Object?>>();

  String _key(Map<String, Object?> line) => CartLine.lineKey(
    line['productId']! as String,
    line['variant'] as String? ?? '',
  );

  @override
  Future<Cart> getCart() async {
    final Map<String, Object?> stored = _dataSource.read();
    final List<CartLine> lines = <CartLine>[];
    for (final Map<String, Object?> json in _lines(stored)) {
      final Product? product = await _products.getProduct(
        json['productId']! as String,
      );
      if (product != null) lines.add(CartMapper.lineFromJson(json, product));
    }
    return Cart(
      lines: lines,
      promo: CartMapper.promoFromCode(stored['promoCode'] as String?),
    );
  }

  @override
  Future<void> add(String productId, String variant, int quantity) async {
    final Map<String, Object?> stored = _dataSource.read();
    final List<Map<String, Object?>> lines = _lines(stored);
    final String key = CartLine.lineKey(productId, variant);
    final int index = lines.indexWhere(
      (Map<String, Object?> l) => _key(l) == key,
    );
    if (index >= 0) {
      final int current = (lines[index]['quantity']! as num).toInt();
      lines[index]['quantity'] = current + quantity;
    } else {
      lines.add(<String, Object?>{
        'productId': productId,
        'variant': variant,
        'quantity': quantity,
      });
    }
    _dataSource.write(stored);
  }

  @override
  Future<void> setQuantity(String lineKey, int quantity) async {
    final Map<String, Object?> stored = _dataSource.read();
    final List<Map<String, Object?>> lines = _lines(stored);
    if (quantity <= 0) {
      lines.removeWhere((Map<String, Object?> l) => _key(l) == lineKey);
    } else {
      for (final Map<String, Object?> l in lines) {
        if (_key(l) == lineKey) l['quantity'] = quantity;
      }
    }
    _dataSource.write(stored);
  }

  @override
  Future<void> setPromo(PromoCode? promo) async {
    final Map<String, Object?> stored = _dataSource.read();
    stored['promoCode'] = promo?.code;
    _dataSource.write(stored);
  }

  @override
  Future<void> clear() async => _dataSource.write(<String, Object?>{
    'lines': <Map<String, Object?>>[],
    'promoCode': null,
  });
}
