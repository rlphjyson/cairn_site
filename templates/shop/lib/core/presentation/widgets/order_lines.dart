import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/money.dart';
import '../../../domain/cart/models/cart_line.dart';
import '../shop_text.dart';
import 'product_photo.dart';

/// A compact, read-only list of cart lines: photo, name, variant and quantity,
/// and the line price. Used by the checkout review and the order pages.
class OrderLines extends StatelessWidget {
  /// Creates the list.
  const OrderLines({super.key, required this.lines});

  /// The lines to show.
  final List<CartLine> lines;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      spacing: 12,
      children: <Widget>[
        for (final CartLine l in lines)
          Row(
            spacing: 12,
            children: <Widget>[
              SizedBox(
                width: 48,
                height: 48,
                child: ProductPhoto(
                  l.product.imageAsset,
                  radius: theme.radiusScale.md,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: shopText(
                        theme,
                        theme.textStyle(CairnTypography.sm),
                        weight: CairnTypography.medium,
                      ),
                    ),
                    Text(
                      l.variant.isEmpty
                          ? 'Qty ${l.quantity}'
                          : '${l.variant} · Qty ${l.quantity}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: shopText(
                        theme,
                        theme.textStyle(CairnTypography.xs),
                        color: theme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatMoney(l.total),
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  weight: CairnTypography.medium,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
