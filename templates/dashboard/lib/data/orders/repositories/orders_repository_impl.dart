import '../../../domain/orders/mappers/order_mapper.dart';
import '../../../domain/orders/models/order.dart';
import '../../../domain/orders/repositories/orders_repository.dart';
import '../remote/orders_remote_data_source.dart';

/// [OrdersRepository] backed by an [OrdersRemoteDataSource].
class OrdersRepositoryImpl implements OrdersRepository {
  /// Creates the repository.
  OrdersRepositoryImpl(this._dataSource);

  final OrdersRemoteDataSource _dataSource;

  @override
  Future<List<Order>> getOrders() async =>
      (await _dataSource.fetchOrders()).map(OrderMapper.fromJson).toList();
}
