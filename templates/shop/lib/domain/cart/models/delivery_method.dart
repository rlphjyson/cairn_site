import '../../../common/constants/shipping_policy.dart';

/// How an order travels.
enum DeliveryMethod {
  /// Free over the threshold, a flat rate below it.
  standard('Standard', ShippingPolicy.standardDays),

  /// A flat rate, always.
  express('Express', ShippingPolicy.expressDays);

  const DeliveryMethod(this.label, this.businessDays);

  /// Display name.
  final String label;

  /// Business days to arrive.
  final int businessDays;
}
