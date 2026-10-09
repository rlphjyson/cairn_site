import '../models/order.dart';
import '../models/shipping_details.dart';

/// The distinct addresses the shopper has shipped to, most recent first.
///
/// Pure: it reads the orders it is given, so "saved addresses" need no store of
/// their own.
class GetSavedAddresses {
  /// Creates the use case.
  const GetSavedAddresses();

  /// Runs it. [orders] must be newest first.
  List<ShippingDetails> call(List<Order> orders) {
    final Set<String> seen = <String>{};
    final List<ShippingDetails> result = <ShippingDetails>[];
    for (final Order o in orders) {
      final ShippingDetails s = o.shipping;
      if (s.address.isEmpty) continue;
      final String key = '${s.address}|${s.city}|${s.postalCode}'.toLowerCase();
      if (seen.add(key)) result.add(s);
    }
    return result;
  }
}
