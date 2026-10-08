import '../../../domain/cart/models/cart_line.dart';
import '../../../domain/cart/models/cart_totals.dart';
import '../../../domain/checkout/models/order.dart';
import '../../../domain/checkout/repositories/order_repository.dart';
import '../remote/order_remote_data_source.dart';

/// [OrderRepository] backed by an [OrderRemoteDataSource].
class OrderRepositoryImpl implements OrderRepository {
  /// Creates the repository.
  OrderRepositoryImpl(this._dataSource);

  final OrderRemoteDataSource _dataSource;

  @override
  Future<Order> place(List<CartLine> lines, CartTotals totals) async => Order(
    id: 'CR-${_dataSource.nextNumber()}',
    lines: lines,
    totals: totals,
    placedAt: DateTime.now(),
  );
}
