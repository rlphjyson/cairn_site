import '../models/order.dart';

/// Turns decoded JSON into an [Order].
abstract final class OrderMapper {
  /// Maps one order.
  static Order fromJson(Map<String, Object?> json) => Order(
    id: json['id']! as String,
    customer: json['customer']! as String,
    email: json['email']! as String,
    status: OrderStatus.values.byName(json['status']! as String),
    amount: (json['amount']! as num).toDouble(),
    date: DateTime.parse(json['date']! as String),
  );
}
