import '../../../common/utils/json.dart';
import '../../shared/mappers/link_mapper.dart';
import '../models/pricing_content.dart';

/// Maps the pricing JSON. A plan without `monthlyPrice` has no list price and
/// shows its `priceLabel` instead.
PricingContent mapPricing(JsonMap json) => PricingContent(
  eyebrow: json.string('eyebrow'),
  title: json.string('title'),
  subtitle: json.string('subtitle'),
  currency: json.string('currency'),
  yearlyDiscountPercent: json.number('yearlyDiscountPercent').round(),
  monthlyLabel: json.string('monthlyLabel'),
  yearlyLabel: json.string('yearlyLabel'),
  plans: <Plan>[
    for (final JsonMap e in json.objects('plans'))
      Plan(
        id: e.string('id'),
        name: e.string('name'),
        description: e.string('description'),
        monthlyPrice: e.maybeNumber('monthlyPrice'),
        priceLabel: e.maybeString('priceLabel') ?? '',
        unit: e.maybeString('unit') ?? '',
        highlighted: e.flag('highlighted'),
        badge: e.maybeString('badge'),
        cta: mapLink(e.object('cta')),
        featuresHeading: e.string('featuresHeading'),
        features: e.strings('features'),
      ),
  ],
  compareNote: json.string('compareNote'),
  compare: mapLink(json.object('compare')),
);
