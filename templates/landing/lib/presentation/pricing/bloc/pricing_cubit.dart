import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/content_cubit.dart';
import '../../../domain/pricing/models/price_quote.dart';
import '../../../domain/pricing/models/pricing_content.dart';
import '../../../domain/pricing/use_cases/calculate_price.dart';
import '../../../domain/pricing/use_cases/get_pricing.dart';

/// The pricing section: its content, the billing period and every plan priced
/// for that period.
class PricingState extends Equatable {
  /// Creates a state.
  const PricingState({
    this.status = ContentStatus.initial,
    this.content,
    this.period = BillingPeriod.monthly,
    this.quotes = const <String, PriceQuote>{},
  });

  /// Whether the content has loaded.
  final ContentStatus status;

  /// The content, once loaded.
  final PricingContent? content;

  /// The selected billing period.
  final BillingPeriod period;

  /// The price of each plan, by plan id, for [period].
  final Map<String, PriceQuote> quotes;

  /// The quote for [plan], or `null` before the content loads.
  PriceQuote? quoteFor(Plan plan) => quotes[plan.id];

  /// A copy with the given fields replaced.
  PricingState copyWith({
    ContentStatus? status,
    PricingContent? content,
    BillingPeriod? period,
    Map<String, PriceQuote>? quotes,
  }) => PricingState(
    status: status ?? this.status,
    content: content ?? this.content,
    period: period ?? this.period,
    quotes: quotes ?? this.quotes,
  );

  @override
  List<Object?> get props => <Object?>[status, content, period, quotes];
}

/// Loads the plans and re-prices them when the billing period changes.
class PricingCubit extends Cubit<PricingState> {
  /// Creates the cubit.
  PricingCubit(this._getPricing, this._calculatePrice)
    : super(const PricingState());

  final GetPricing _getPricing;
  final CalculatePrice _calculatePrice;

  /// Loads the plans; does nothing once loaded.
  Future<void> load() async {
    if (state.status == ContentStatus.loading ||
        state.status == ContentStatus.loaded) {
      return;
    }
    emit(state.copyWith(status: ContentStatus.loading));
    try {
      final PricingContent content = await _getPricing();
      emit(
        state.copyWith(
          status: ContentStatus.loaded,
          content: content,
          quotes: _price(content, state.period),
        ),
      );
    } on Object {
      emit(state.copyWith(status: ContentStatus.failure));
    }
  }

  /// Switches the billing period and re-prices every plan.
  void setPeriod(BillingPeriod period) {
    final PricingContent? content = state.content;
    if (content == null || period == state.period) return;
    emit(state.copyWith(period: period, quotes: _price(content, period)));
  }

  Map<String, PriceQuote> _price(
    PricingContent content,
    BillingPeriod period,
  ) => <String, PriceQuote>{
    for (final Plan plan in content.plans)
      plan.id: _calculatePrice(plan, period, content.yearlyDiscountPercent),
  };
}
