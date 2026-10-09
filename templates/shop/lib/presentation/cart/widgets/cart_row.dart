import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/price_text.dart';
import '../../../core/presentation/widgets/product_photo.dart';
import '../../../core/presentation/widgets/quantity_stepper.dart';
import '../../../core/presentation/widgets/tap_target.dart';
import '../../../domain/cart/models/cart_line.dart';

/// One cart line: thumbnail, name, chosen variant, price, quantity stepper and
/// a remove button.
class CartRow extends StatelessWidget {
  /// Creates a row.
  const CartRow({
    super.key,
    required this.line,
    required this.onQuantity,
    required this.onRemove,
    required this.onOpen,
  });

  /// The line to show.
  final CartLine line;

  /// Called with the requested quantity.
  final ValueChanged<int> onQuantity;

  /// Called when the remove button is pressed.
  final VoidCallback onRemove;

  /// Called when the photograph or name is tapped.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          TapTarget(
            semanticLabel: 'Open ${line.product.name}',
            onTap: onOpen,
            child: SizedBox(
              width: 64,
              height: 64,
              child: ProductPhoto(
                line.product.imageAsset,
                radius: theme.radiusScale.md,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TapTarget(
                        onTap: onOpen,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            line.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: shopText(
                              theme,
                              theme.textStyle(CairnTypography.sm),
                              weight: CairnTypography.medium,
                            ),
                          ),
                        ),
                      ),
                    ),
                    CairnButton.icon(
                      variant: CairnButtonVariant.ghost,
                      size: CairnButtonSize.iconSm,
                      icon: const CairnIcon(CairnIconData.close, size: 14),
                      semanticLabel: 'Remove ${line.product.name} from cart',
                      onPressed: onRemove,
                    ),
                  ],
                ),
                if (line.variant.isNotEmpty)
                  Text(
                    line.variant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: shopText(
                      theme,
                      theme.textStyle(CairnTypography.xs),
                      color: theme.mutedForeground,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PriceText(
                        price: line.total,
                        compareAt: line.compareTotal > line.total
                            ? line.compareTotal
                            : null,
                      ),
                    ),
                    QuantityStepper(
                      value: line.quantity,
                      max: line.maxQuantity,
                      subject:
                          '${line.product.name}'
                          '${line.variant.isEmpty ? '' : ', ${line.variant}'}',
                      onChanged: onQuantity,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
