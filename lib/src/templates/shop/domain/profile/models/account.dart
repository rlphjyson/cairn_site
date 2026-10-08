import 'package:equatable/equatable.dart';

/// The signed-in shopper.
class Account extends Equatable {
  /// Creates an account.
  const Account({
    required this.name,
    required this.email,
    required this.initials,
    required this.orderCount,
    required this.reviewCount,
  });

  /// Full name.
  final String name;

  /// Email address.
  final String email;

  /// Two letters for the avatar.
  final String initials;

  /// Orders placed to date.
  final int orderCount;

  /// Reviews written.
  final int reviewCount;

  @override
  List<Object?> get props => <Object?>[
    name,
    email,
    initials,
    orderCount,
    reviewCount,
  ];
}
