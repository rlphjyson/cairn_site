import 'package:equatable/equatable.dart';

import 'pricing_content.dart';

/// What kind of price a plan has.
enum PriceKind {
  /// Costs nothing.
  free,

  /// Has a list price.
  paid,

  /// Has no list price; the buyer talks to sales.
  custom,
}

/// A plan priced for one billing period.
class PriceQuote extends Equatable {
  /// Creates a quote.
  const PriceQuote({
    required this.kind,
    required this.period,
    required this.perMonth,
    required this.billedAmount,
    required this.yearlySavings,
  });

  /// What kind of price this is.
  final PriceKind kind;

  /// The period it was priced for.
  final BillingPeriod period;

  /// The effective price per unit per month.
  final double perMonth;

  /// What is charged each billing cycle: a month, or a year.
  final double billedAmount;

  /// How much a year of this plan saves against monthly billing; zero when
  /// billed monthly.
  final double yearlySavings;

  @override
  List<Object?> get props => <Object?>[
    kind,
    period,
    perMonth,
    billedAmount,
    yearlySavings,
  ];
}
