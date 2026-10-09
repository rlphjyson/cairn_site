/// Where an order is in its journey.
enum OrderStatus {
  /// Received and being packed.
  processing('Processing'),

  /// On its way.
  shipped('Shipped'),

  /// Arrived.
  delivered('Delivered');

  const OrderStatus(this.label);

  /// The label shown on the status badge.
  final String label;
}
