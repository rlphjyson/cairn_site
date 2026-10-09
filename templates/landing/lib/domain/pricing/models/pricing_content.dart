import 'package:equatable/equatable.dart';

import '../../shared/models/link.dart';

/// How often a plan is billed.
enum BillingPeriod {
  /// Month to month.
  monthly,

  /// Once a year, at a discount.
  yearly,
}

/// The pricing section.
class PricingContent extends Equatable {
  /// Creates the content.
  const PricingContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.currency,
    required this.yearlyDiscountPercent,
    required this.monthlyLabel,
    required this.yearlyLabel,
    required this.plans,
    required this.compareNote,
    required this.compare,
  });

  /// The label above the title.
  final String eyebrow;

  /// The section title.
  final String title;

  /// The copy under the title.
  final String subtitle;

  /// The currency symbol placed before prices.
  final String currency;

  /// The yearly discount, as a whole percent (20 means 20% off).
  final int yearlyDiscountPercent;

  /// The toggle label for monthly billing.
  final String monthlyLabel;

  /// The toggle label for yearly billing.
  final String yearlyLabel;

  /// The plans, left to right.
  final List<Plan> plans;

  /// The sentence under the plans.
  final String compareNote;

  /// The link after the note.
  final Link compare;

  @override
  List<Object?> get props => <Object?>[
    eyebrow,
    title,
    subtitle,
    currency,
    yearlyDiscountPercent,
    monthlyLabel,
    yearlyLabel,
    plans,
    compareNote,
    compare,
  ];
}

/// One plan.
class Plan extends Equatable {
  /// Creates a plan.
  const Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.priceLabel,
    required this.unit,
    required this.highlighted,
    required this.badge,
    required this.cta,
    required this.featuresHeading,
    required this.features,
  });

  /// A stable id.
  final String id;

  /// The plan name.
  final String name;

  /// Who it is for.
  final String description;

  /// The price per unit per month when billed monthly, or `null` when the plan
  /// has no list price (then [priceLabel] is shown instead).
  final double? monthlyPrice;

  /// The text shown instead of a price when [monthlyPrice] is `null`.
  final String priceLabel;

  /// What the price is per, such as `per seat / month`.
  final String unit;

  /// Whether this is the recommended plan.
  final bool highlighted;

  /// An optional badge such as "Most popular".
  final String? badge;

  /// The button under the price. Any `{period}` in the href becomes `monthly`
  /// or `yearly`, so one link can carry the billing choice to checkout.
  final Link cta;

  /// The heading above the checklist.
  final String featuresHeading;

  /// The checklist.
  final List<String> features;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    description,
    monthlyPrice,
    priceLabel,
    unit,
    highlighted,
    badge,
    cta,
    featuresHeading,
    features,
  ];
}
