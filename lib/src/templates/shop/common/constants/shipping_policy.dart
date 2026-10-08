/// What shipping costs.
abstract final class ShippingPolicy {
  /// Orders at or above this subtotal ship free.
  static const double freeShippingThreshold = 150;

  /// The flat rate below the threshold.
  static const double flatRate = 8;
}
