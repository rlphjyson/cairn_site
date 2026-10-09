import 'package:equatable/equatable.dart';

/// Where an order goes and who to reach about it.
class ShippingDetails extends Equatable {
  /// Creates details.
  const ShippingDetails({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.postalCode = '',
  });

  /// Recipient's full name.
  final String fullName;

  /// Contact email.
  final String email;

  /// Contact phone number.
  final String phone;

  /// Street address.
  final String address;

  /// Town or city.
  final String city;

  /// Postal or ZIP code.
  final String postalCode;

  /// Whether every field is blank.
  bool get isBlank =>
      fullName.isEmpty &&
      email.isEmpty &&
      phone.isEmpty &&
      address.isEmpty &&
      city.isEmpty &&
      postalCode.isEmpty;

  /// `12 Analytical Row, London 10115`.
  String get oneLine => '$address, $city $postalCode';

  /// A copy with the given fields replaced.
  ShippingDetails copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
  }) => ShippingDetails(
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    city: city ?? this.city,
    postalCode: postalCode ?? this.postalCode,
  );

  @override
  List<Object?> get props => <Object?>[
    fullName,
    email,
    phone,
    address,
    city,
    postalCode,
  ];
}
