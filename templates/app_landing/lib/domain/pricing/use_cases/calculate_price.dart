import '../models/price_quote.dart';
import '../models/pricing_content.dart';

/// Prices a plan for a billing period.
///
/// Monthly billing charges the list price each month. Yearly billing takes
/// `discountPercent` off the monthly price and charges twelve months at once.
/// Amounts are rounded to the cent.
class CalculatePrice {
  /// Creates the use case.
  const CalculatePrice();

  /// Prices [plan] for [period] with [discountPercent] off yearly billing.
  PriceQuote call(Plan plan, BillingPeriod period, int discountPercent) {
    final double? list = plan.monthlyPrice;
    if (list == null) {
      return PriceQuote(
        kind: PriceKind.custom,
        period: period,
        perMonth: 0,
        billedAmount: 0,
        yearlySavings: 0,
      );
    }
    if (list == 0) {
      return PriceQuote(
        kind: PriceKind.free,
        period: period,
        perMonth: 0,
        billedAmount: 0,
        yearlySavings: 0,
      );
    }
    if (period == BillingPeriod.monthly) {
      return PriceQuote(
        kind: PriceKind.paid,
        period: period,
        perMonth: _cents(list),
        billedAmount: _cents(list),
        yearlySavings: 0,
      );
    }
    final double perMonth = _cents(list * (100 - discountPercent) / 100);
    final double billed = _cents(perMonth * 12);
    return PriceQuote(
      kind: PriceKind.paid,
      period: period,
      perMonth: perMonth,
      billedAmount: billed,
      yearlySavings: _cents(list * 12 - billed),
    );
  }

  static double _cents(double v) => (v * 100).round() / 100;
}
