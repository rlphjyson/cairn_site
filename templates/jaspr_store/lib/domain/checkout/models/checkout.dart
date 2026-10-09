library;

import 'package:meta/meta.dart';

import '../../cart/models/cart.dart';

/// Countries the demo ships to. `code` is ISO 3166-1 alpha-2.
class Country {
  const Country(this.code, this.name, {this.regionLabel = 'State / region', this.postalLabel = 'Postal code'});
  final String code;
  final String name;
  final String regionLabel;
  final String postalLabel;
}

const List<Country> kCountries = [
  Country('US', 'United States', regionLabel: 'State', postalLabel: 'ZIP code'),
  Country('CA', 'Canada', regionLabel: 'Province'),
  Country('GB', 'United Kingdom', regionLabel: 'County'),
  Country('DE', 'Germany', regionLabel: 'State'),
  Country('AU', 'Australia', regionLabel: 'State', postalLabel: 'Postcode'),
];

Country? countryByCode(String? code) {
  for (final c in kCountries) {
    if (c.code == code) return c;
  }
  return null;
}

/// Raw, untrusted form input. Everything is a string until validated.
@immutable
class CheckoutForm {
  const CheckoutForm({
    this.email = '',
    this.fullName = '',
    this.phone = '',
    this.address1 = '',
    this.address2 = '',
    this.city = '',
    this.region = '',
    this.postalCode = '',
    this.country = 'US',
    this.delivery = 'standard',
    this.acceptTerms = false,
  });

  factory CheckoutForm.fromMap(Map<String, String> map) => CheckoutForm(
    email: (map['email'] ?? '').trim(),
    fullName: (map['fullName'] ?? '').trim(),
    phone: (map['phone'] ?? '').trim(),
    address1: (map['address1'] ?? '').trim(),
    address2: (map['address2'] ?? '').trim(),
    city: (map['city'] ?? '').trim(),
    region: (map['region'] ?? '').trim(),
    postalCode: (map['postalCode'] ?? '').trim(),
    country: (map['country'] ?? 'US').trim(),
    delivery: (map['delivery'] ?? 'standard').trim(),
    acceptTerms: map['acceptTerms'] == 'on' || map['acceptTerms'] == 'true',
  );

  final String email;
  final String fullName;
  final String phone;
  final String address1;
  final String address2;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final String delivery;
  final bool acceptTerms;

  DeliveryMethod get deliveryMethod => DeliveryMethod.parse(delivery) ?? DeliveryMethod.standard;
}

@immutable
class ShippingAddress {
  const ShippingAddress({
    required this.fullName,
    required this.address1,
    required this.address2,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.country,
    required this.phone,
  });

  factory ShippingAddress.fromForm(CheckoutForm f) => ShippingAddress(
    fullName: f.fullName,
    address1: f.address1,
    address2: f.address2,
    city: f.city,
    region: f.region,
    postalCode: f.postalCode.toUpperCase(),
    country: f.country,
    phone: f.phone,
  );

  final String fullName;
  final String address1;
  final String address2;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final String phone;
}

@immutable
class OrderLine {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.variantLabel,
    required this.sku,
    required this.quantity,
    required this.unitCents,
    required this.imageBase,
  });

  final String productId;
  final String name;
  final String variantLabel;
  final String sku;
  final int quantity;
  final int unitCents;
  final String imageBase;

  int get totalCents => unitCents * quantity;
}

@immutable
class Order {
  const Order({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.email,
    required this.address,
    required this.delivery,
    required this.lines,
    required this.subtotalCents,
    required this.discountCents,
    required this.shippingCents,
    this.promoCode,
  });

  final String id;
  final String number;
  final DateTime createdAt;
  final String email;
  final ShippingAddress address;
  final DeliveryMethod delivery;
  final List<OrderLine> lines;
  final int subtotalCents;
  final int discountCents;
  final int shippingCents;
  final String? promoCode;

  int get totalCents => subtotalCents - discountCents + shippingCents;
  int get itemCount => lines.fold(0, (s, l) => s + l.quantity);
}
