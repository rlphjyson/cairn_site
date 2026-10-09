import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/money.dart';
import '../../../domain/cart/models/cart_totals.dart';
import '../shop_text.dart';

/// Subtotal, discount, shipping and total, as a quiet list of rows.
///
/// Shared by the cart, the checkout review and the order pages, so a total is
/// always laid out the same way.
class TotalsSummary extends StatelessWidget {
  /// Creates a summary.
  const TotalsSummary({super.key, required this.totals, this.promoCode});

  /// The money to show.
  final CartTotals totals;

  /// The applied code, named on the discount row.
  final String? promoCode;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    Widget row(
      String label,
      String value, {
      bool strong = false,
      Color? valueColor,
    }) => Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: shopText(
              theme,
              theme.textStyle(
                strong ? CairnTypography.base : CairnTypography.sm,
              ),
              color: strong ? theme.foreground : theme.mutedForeground,
              weight: strong ? CairnTypography.semibold : null,
            ),
          ),
        ),
        Text(
          value,
          style: shopText(
            theme,
            theme.textStyle(strong ? CairnTypography.base : CairnTypography.sm),
            color: valueColor,
            weight: strong ? CairnTypography.semibold : CairnTypography.medium,
          ),
        ),
      ],
    );

    return Column(
      children: <Widget>[
        row('Subtotal', formatMoney(totals.subtotal)),
        if (totals.discount > 0) ...<Widget>[
          const SizedBox(height: 6),
          row(
            promoCode == null ? 'Discount' : 'Discount ($promoCode)',
            '-${formatMoney(totals.discount)}',
            valueColor: CairnToneColors.resolve(theme, CairnTone.success).fill,
          ),
        ],
        const SizedBox(height: 6),
        row(
          'Shipping (${totals.delivery.label.toLowerCase()})',
          totals.shipping == 0 ? 'Free' : formatMoney(totals.shipping),
        ),
        const SizedBox(height: 10),
        const CairnSeparator(),
        const SizedBox(height: 10),
        row('Total', formatMoney(totals.total), strong: true),
      ],
    );
  }
}
