import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/money.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/product_photo.dart';
import '../../../domain/cart/models/cart_line.dart';

/// One cart line: thumbnail, name, line price and a quantity stepper.
class CartRow extends StatelessWidget {
  /// Creates a row.
  const CartRow({super.key, required this.line, required this.onQuantity});

  /// The line to show.
  final CartLine line;

  /// Called with the requested quantity; zero removes the line.
  final ValueChanged<int> onQuantity;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnListItem(
      leading: SizedBox(
        width: 48,
        height: 48,
        child: ProductPhoto(
          line.product.imageAsset,
          radius: theme.radiusScale.md,
        ),
      ),
      title: Text(
        line.product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(formatMoney(line.total)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: <Widget>[
          CairnButton.icon(
            size: CairnButtonSize.iconXs,
            variant: CairnButtonVariant.outline,
            icon: const CairnIcon(CairnIconData.minus, size: 12),
            semanticLabel: 'Remove one ${line.product.name}',
            onPressed: () => onQuantity(line.quantity - 1),
          ),
          SizedBox(
            width: 20,
            child: Text(
              '${line.quantity}',
              textAlign: TextAlign.center,
              style: shopText(theme, theme.textStyle(CairnTypography.sm)),
            ),
          ),
          CairnButton.icon(
            size: CairnButtonSize.iconXs,
            variant: CairnButtonVariant.outline,
            icon: const CairnIcon(CairnIconData.plus, size: 12),
            semanticLabel: 'Add one ${line.product.name}',
            onPressed: () => onQuantity(line.quantity + 1),
          ),
        ],
      ),
    );
  }
}
