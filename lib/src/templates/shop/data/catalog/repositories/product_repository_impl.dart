import '../../../domain/catalog/mappers/product_mapper.dart';
import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/repositories/product_repository.dart';
import '../remote/product_remote_data_source.dart';

/// [ProductRepository] backed by a [ProductRemoteDataSource].
class ProductRepositoryImpl implements ProductRepository {
  /// Creates the repository.
  ProductRepositoryImpl(this._dataSource);

  final ProductRemoteDataSource _dataSource;
  List<Product>? _cache;

  @override
  Future<List<Product>> getProducts() async {
    final List<Map<String, Object?>> json = await _dataSource.fetchProducts();
    return _cache ??= json.map(ProductMapper.fromJson).toList();
  }

  @override
  Future<Product?> getProduct(String id) async {
    final List<Product> all = await getProducts();
    for (final Product p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
