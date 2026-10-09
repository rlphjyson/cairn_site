import '../../cart/mappers/cart_mapper.dart';
import '../../cart/models/cart_line.dart';
import '../../cart/models/cart_totals.dart';
import '../../cart/models/delivery_method.dart';
import '../../catalog/models/product.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/shipping_details.dart';

/// Converts orders to and from JSON.
abstract final class OrderMapper {
  /// The JSON for a new order. The backend adds `id` and `status`.
  static Map<String, Object?> draftToJson(OrderDraft draft) =>
      <String, Object?>{
        'placedAt': draft.placedAt.toIso8601String(),
        'estimatedDelivery': draft.estimatedDelivery.toIso8601String(),
        'cardLast4': draft.cardLast4,
        'promoCode': draft.promo?.code,
        'shipping': shippingToJson(draft.shipping),
        'totals': <String, Object?>{
          'itemCount': draft.totals.itemCount,
          'subtotal': draft.totals.subtotal,
          'discount': draft.totals.discount,
          'shipping': draft.totals.shipping,
          'delivery': draft.totals.delivery.name,
        },
        'lines': <Map<String, Object?>>[
          for (final CartLine l in draft.lines) CartMapper.lineToJson(l),
        ],
      };

  /// Maps [json] to an [Order], resolving its lines against [catalogue].
  ///
  /// Lines whose product no longer exists are dropped.
  static Order fromJson(Map<String, Object?> json, List<Product> catalogue) {
    final Map<String, Product> byId = <String, Product>{
      for (final Product p in catalogue) p.id: p,
    };
    final Map<String, Object?> totals = json['totals']! as Map<String, Object?>;
    return Order(
      id: json['id']! as String,
      status: OrderStatus.values.byName(json['status']! as String),
      placedAt: DateTime.parse(json['placedAt']! as String),
      estimatedDelivery: DateTime.parse(json['estimatedDelivery']! as String),
      cardLast4: json['cardLast4'] as String? ?? '',
      promo: CartMapper.promoFromCode(json['promoCode'] as String?),
      shipping: shippingFromJson(json['shipping']! as Map<String, Object?>),
      lines: <CartLine>[
        for (final Map<String, Object?> l
            in (json['lines']! as List<Object?>).cast<Map<String, Object?>>())
          if (byId[l['productId']] case final Product p)
            CartMapper.lineFromJson(l, p),
      ],
      totals: CartTotals(
        itemCount: (totals['itemCount']! as num).toInt(),
        subtotal: (totals['subtotal']! as num).toDouble(),
        discount: (totals['discount']! as num).toDouble(),
        shipping: (totals['shipping']! as num).toDouble(),
        amountToFreeShipping: 0,
        freeShippingProgress: 1,
        delivery: DeliveryMethod.values.byName(totals['delivery']! as String),
      ),
    );
  }

  /// The JSON for [details].
  static Map<String, Object?> shippingToJson(ShippingDetails details) =>
      <String, Object?>{
        'fullName': details.fullName,
        'email': details.email,
        'phone': details.phone,
        'address': details.address,
        'city': details.city,
        'postalCode': details.postalCode,
      };

  /// Maps [json] to [ShippingDetails].
  static ShippingDetails shippingFromJson(Map<String, Object?> json) =>
      ShippingDetails(
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        city: json['city'] as String? ?? '',
        postalCode: json['postalCode'] as String? ?? '',
      );
}
