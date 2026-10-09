import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/price_text.dart';
import '../../../core/presentation/widgets/product_photo.dart';
import '../../../core/presentation/widgets/tap_target.dart';
import '../../../domain/catalog/models/product.dart';
import '../../saved/widgets/save_button.dart';
import 'product_badges.dart';

/// One product in a grid or a row: photo with badges and a save button, then
/// name, rating with review count, and price (struck-through when on sale).
class ProductTile extends StatelessWidget {
  /// Creates a tile.
  const ProductTile({
    super.key,
    required this.product,
    required this.onOpen,
    this.aspectRatio = 1,
  });

  /// What to show.
  final Product product;

  /// Called when the photo or text is tapped.
  final VoidCallback onOpen;

  /// Width over height of the photograph. Featured tiles are taller.
  final double aspectRatio;

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
                aspectRatio: aspectRatio,
                child: ProductPhoto(product.imageAsset),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IgnorePointer(child: ProductBadges(product)),
            ),
            Positioned(
              top: 6,
              right: 6,
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
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: CairnToneColors.resolve(
                      theme,
                      CairnTone.warning,
                    ).fill,
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      '${product.rating.toStringAsFixed(1)} '
                      '(${product.ratingCount})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: shopText(
                        theme,
                        theme.textStyle(CairnTypography.xs),
                        color: theme.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              PriceText(
                price: product.price,
                compareAt: product.compareAtPrice,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
