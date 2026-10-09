import 'package:equatable/equatable.dart';

/// Where an order is in its life.
enum OrderStatus {
  /// Paid in full.
  paid('Paid'),

  /// Awaiting payment.
  pending('Pending'),

  /// The payment failed.
  failed('Failed'),

  /// Money returned.
  refunded('Refunded');

  const OrderStatus(this.label);

  /// Shown in badges and filters.
  final String label;
}

/// One customer order.
class Order extends Equatable {
  /// Creates an order.
  const Order({
    required this.id,
    required this.customer,
    required this.email,
    required this.status,
    required this.amount,
    required this.date,
  });

  /// Reference, e.g. `#3201`.
  final String id;

  /// Customer name.
  final String customer;

  /// Customer email.
  final String email;

  /// Current status.
  final OrderStatus status;

  /// Order total in dollars.
  final double amount;

  /// When it was placed.
  final DateTime date;

  @override
  List<Object?> get props => <Object?>[
    id,
    customer,
    email,
    status,
    amount,
    date,
  ];
}
