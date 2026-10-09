import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../common/utils/money.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../domain/cart/models/cart_totals.dart';

/// How close the cart is to free standard shipping.
class FreeShippingProgress extends StatelessWidget {
  /// Creates the indicator.
  const FreeShippingProgress({super.key, required this.totals});

  /// The cart's money.
  final CartTotals totals;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool free = totals.amountToFreeShipping <= 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            Row(
              spacing: 8,
              children: <Widget>[
                Icon(
                  free
                      ? Icons.check_circle_outline
                      : Icons.local_shipping_outlined,
                  size: 16,
                  color: free
                      ? CairnToneColors.resolve(theme, CairnTone.success).fill
                      : theme.mutedForeground,
                ),
                Expanded(
                  child: Text(
                    free
                        ? 'You have free standard shipping.'
                        : 'Add ${formatMoney(totals.amountToFreeShipping)} '
                              'more for free shipping.',
                    style: shopText(theme, theme.textStyle(CairnTypography.sm)),
                  ),
                ),
              ],
            ),
            CairnProgress(
              value: totals.freeShippingProgress,
              semanticLabel: 'Progress to free shipping',
            ),
          ],
        ),
      ),
    );
  }
}
