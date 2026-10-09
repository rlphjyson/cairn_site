import '../../../common/constants/promo_codes.dart';
import '../../catalog/models/product.dart';
import '../models/cart_line.dart';
import '../models/promo_code.dart';

/// Converts cart lines and promo codes to and from stored JSON.
///
/// A stored line holds only `productId`, `variant` and `quantity`; the product
/// itself is looked up in the catalogue when the cart is read.
abstract final class CartMapper {
  /// The JSON for [line].
  static Map<String, Object?> lineToJson(CartLine line) => <String, Object?>{
    'productId': line.product.id,
    'variant': line.variant,
    'quantity': line.quantity,
  };

  /// Rebuilds a line from [json] and its [product].
  static CartLine lineFromJson(Map<String, Object?> json, Product product) =>
      CartLine(
        product: product,
        variant: json['variant'] as String? ?? '',
        quantity: (json['quantity']! as num).toInt(),
      );

  /// Looks up [code] in the accepted codes; `null` when it is unknown.
  static PromoCode? promoFromCode(String? code) {
    if (code == null) return null;
    final String normal = code.trim().toUpperCase();
    final int? percent = PromoCodes.percentOff[normal];
    return percent == null
        ? null
        : PromoCode(code: normal, percentOff: percent);
  }
}
