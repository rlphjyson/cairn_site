library;

import 'models/checkout.dart';

abstract interface class OrderRepository {
  /// Issues an unguessable id (used in the confirmation URL) and a human order
  /// number. Separate from [save] so the id exists before the order is built.
  Future<({String id, String number})> nextIdentity();
  Future<void> save(Order order);
  Future<Order?> byId(String id);
}
