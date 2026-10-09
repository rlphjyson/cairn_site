import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/price_format.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../domain/pricing/models/price_quote.dart';
import '../../../domain/pricing/models/pricing_content.dart';

/// One plan: name, price for the selected period, call to action and the
/// checklist. The recommended plan gets a ring and a badge.
class PlanCard extends StatelessWidget {
  /// Creates the card.
  const PlanCard({
    super.key,
    required this.plan,
    required this.quote,
    required this.currency,
    required this.onSelected,
  });

  /// The plan.
  final Plan plan;

  /// The plan priced for the selected period, or `null` while pricing.
  final PriceQuote? quote;

  /// The currency symbol.
  final String currency;

  /// Called with the call to action's href.
  final ValueChanged<String> onSelected;

  String get _price {
    final PriceQuote? q = quote;
    if (q == null) return '';
    return switch (q.kind) {
      PriceKind.free => 'Free',
      PriceKind.custom => plan.priceLabel,
      PriceKind.paid => formatPrice(q.perMonth, currency: currency),
    };
  }

  String get _note {
    final PriceQuote? q = quote;
    if (q == null || q.kind != PriceKind.paid) return '';
    if (q.period == BillingPeriod.monthly) return 'Billed monthly';
    return 'Billed ${formatPrice(q.billedAmount, currency: currency)} yearly, '
        'save ${formatPrice(q.yearlySavings, currency: currency)}';
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    final Widget card = CairnCard(
      gap: CairnSpacing.s5,
      children: <Widget>[
        CairnCardHeader(
          title: Semantics(
            header: true,
            child: Text(
              plan.name,
              style: landingText(
                theme,
                CairnTypography.xl,
                weight: CairnTypography.semibold,
                tight: true,
              ),
            ),
          ),
          description: Text(plan.description),
          action: plan.badge == null
              ? null
              : CairnBadge(label: Text(plan.badge!)),
        ),
        CairnCardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: CairnSpacing.s2,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: CairnMotion.d200,
                    child: Text(
                      _price,
                      key: ValueKey<String>('${plan.id}:$_price'),
                      style: landingText(
                        theme,
                        CairnTypography.xl4,
                        size: 44,
                        height: 1.1,
                        weight: CairnTypography.semibold,
                        tight: true,
                      ),
                    ),
                  ),
                  if (plan.unit.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: CairnSpacing.s1p5),
                      child: Text(
                        plan.unit,
                        style: landingText(
                          theme,
                          CairnTypography.sm,
                          color: theme.mutedForeground,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: CairnSpacing.s1p5),
              SizedBox(
                height: 20,
                child: Text(
                  _note,
                  style: landingText(
                    theme,
                    CairnTypography.xs,
                    color: theme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
        CairnCardContent(
          child: CairnButton(
            size: CairnButtonSize.lg,
            expand: true,
            variant: plan.highlighted
                ? CairnButtonVariant.primary
                : CairnButtonVariant.outline,
            onPressed: () => onSelected(plan.cta.href),
            child: Text(plan.cta.label),
          ),
        ),
        const CairnSeparator(),
        CairnCardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: CairnSpacing.s3,
            children: <Widget>[
              Text(
                plan.featuresHeading,
                style: landingText(
                  theme,
                  CairnTypography.sm,
                  weight: CairnTypography.medium,
                ),
              ),
              for (final String feature in plan.features)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: CairnSpacing.s3,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: CairnIcon(
                        CairnIconData.circleCheck,
                        size: 16,
                        color: theme.foreground,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feature,
                        style: landingText(
                          theme,
                          CairnTypography.sm,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );

    if (!plan.highlighted) return card;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        boxShadow: <BoxShadow>[
          BoxShadow(color: theme.primary, spreadRadius: 2),
          ...CairnShadows.lg,
        ],
      ),
      child: card,
    );
  }
}
