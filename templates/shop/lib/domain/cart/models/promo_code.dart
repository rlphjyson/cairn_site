import 'package:equatable/equatable.dart';

/// A valid promo code and what it takes off the subtotal.
class PromoCode extends Equatable {
  /// Creates a code.
  const PromoCode({required this.code, required this.percentOff});

  /// The upper-case code, e.g. `CAIRN10`.
  final String code;

  /// Whole percent taken off the subtotal.
  final int percentOff;

  @override
  List<Object?> get props => <Object?>[code, percentOff];
}
