import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/repositories/product_repository.dart';
import '../../../domain/orders/mappers/order_mapper.dart';
import '../../../domain/orders/models/order.dart';
import '../../../domain/orders/repositories/order_repository.dart';
import '../remote/order_remote_data_source.dart';

/// [OrderRepository] backed by an [OrderRemoteDataSource]; lines are resolved
/// against the catalogue.
class OrderRepositoryImpl implements OrderRepository {
  /// Creates the repository.
  OrderRepositoryImpl(this._dataSource, this._products);

  final OrderRemoteDataSource _dataSource;
  final ProductRepository _products;

  @override
  Future<List<Order>> getOrders() async {
    final List<Product> catalogue = await _products.getProducts();
    final List<Map<String, Object?>> json = await _dataSource.fetchOrders();
    return <Order>[
      for (final Map<String, Object?> o in json)
        OrderMapper.fromJson(o, catalogue),
    ];
  }

  @override
  Future<Order> place(OrderDraft draft) async {
    final List<Product> catalogue = await _products.getProducts();
    final Map<String, Object?> stored = await _dataSource.createOrder(
      OrderMapper.draftToJson(draft),
    );
    return OrderMapper.fromJson(stored, catalogue);
  }
}
