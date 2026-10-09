import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/money.dart';
import '../shop_text.dart';

/// A price, with the pre-markdown price struck through beside it when given.
class PriceText extends StatelessWidget {
  /// Creates a price.
  const PriceText({
    super.key,
    required this.price,
    this.compareAt,
    this.style = CairnTypography.sm,
    this.compareStyle = CairnTypography.xs,
  });

  /// The price to pay.
  final double price;

  /// The price before the markdown, or `null`.
  final double? compareAt;

  /// The size of the price.
  final TextStyle style;

  /// The size of the struck-through price.
  final TextStyle compareStyle;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool onSale = compareAt != null && compareAt! > price;
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: formatMoney(price),
            style: shopText(
              theme,
              theme.textStyle(style),
              weight: CairnTypography.semibold,
            ),
          ),
          if (onSale) ...<InlineSpan>[
            const TextSpan(text: '  '),
            TextSpan(
              text: formatMoney(compareAt!),
              semanticsLabel: 'was ${formatMoney(compareAt!)}',
              style: shopText(
                theme,
                theme.textStyle(compareStyle),
                color: theme.mutedForeground,
              ).copyWith(decoration: TextDecoration.lineThrough),
            ),
          ],
        ],
      ),
    );
  }
}
