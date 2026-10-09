import 'package:equatable/equatable.dart';

/// Card details typed into the demo payment step.
///
/// These never leave the device and are never stored: an order keeps only the
/// last four digits.
class PaymentDetails extends Equatable {
  /// Creates details.
  const PaymentDetails({
    this.cardHolder = '',
    this.cardNumber = '',
    this.expiry = '',
    this.cvc = '',
  });

  /// Name on the card.
  final String cardHolder;

  /// The card number, grouped or not.
  final String cardNumber;

  /// `MM/YY`.
  final String expiry;

  /// The security code.
  final String cvc;

  /// The card number without spaces.
  String get digits => cardNumber.replaceAll(RegExp(r'\D'), '');

  /// The last four digits, or fewer when the number is short.
  String get last4 {
    final String d = digits;
    return d.length <= 4 ? d : d.substring(d.length - 4);
  }

  /// A copy with the given fields replaced.
  PaymentDetails copyWith({
    String? cardHolder,
    String? cardNumber,
    String? expiry,
    String? cvc,
  }) => PaymentDetails(
    cardHolder: cardHolder ?? this.cardHolder,
    cardNumber: cardNumber ?? this.cardNumber,
    expiry: expiry ?? this.expiry,
    cvc: cvc ?? this.cvc,
  );

  @override
  List<Object?> get props => <Object?>[cardHolder, cardNumber, expiry, cvc];
}
