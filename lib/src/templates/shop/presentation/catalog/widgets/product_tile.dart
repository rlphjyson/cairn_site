import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../common/utils/money.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/product_photo.dart';
import '../../../core/presentation/widgets/tap_target.dart';
import '../../../domain/catalog/models/product.dart';
import '../../saved/widgets/save_button.dart';

/// One product in the grid: photo, save button, name, price and rating.
class ProductTile extends StatelessWidget {
  /// Creates a tile.
  const ProductTile({super.key, required this.product, required this.onOpen});

  /// What to show.
  final Product product;

  /// Called when the photo or text is tapped.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: <Widget>[
            TapTarget(
              semanticLabel: 'Open ${product.name}',
              onTap: onOpen,
              child: AspectRatio(
                aspectRatio: 1,
                child: ProductPhoto(product.imageAsset),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: SaveButton(productId: product.id),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TapTarget(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  weight: CairnTypography.medium,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: <Widget>[
                  Text(
                    formatMoney(product.price),
                    style: shopText(
                      theme,
                      theme.textStyle(CairnTypography.sm),
                      weight: CairnTypography.semibold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.star_rounded, size: 14, color: theme.foreground),
                  const SizedBox(width: 2),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: shopText(
                      theme,
                      theme.textStyle(CairnTypography.xs),
                      color: theme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
