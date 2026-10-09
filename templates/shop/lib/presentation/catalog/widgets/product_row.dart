import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../../../domain/catalog/models/product.dart';
import 'product_tile.dart';

/// A horizontally scrolling row of [ProductTile]s, edge to edge.
///
/// [tileWidth] sets how many tiles are visible at once; a row with a larger
/// [aspectRatio] denominator makes taller (featured) cards.
class ProductRow extends StatelessWidget {
  /// Creates a row.
  const ProductRow({
    super.key,
    required this.products,
    this.tileWidth = 140,
    this.aspectRatio = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  /// What to show.
  final List<Product> products;

  /// The width of each tile.
  final double tileWidth;

  /// Width over height of each photograph.
  final double aspectRatio;

  /// Space around the scrolling content; the default insets it from the screen
  /// edge while still scrolling edge to edge.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: padding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        for (final Product p in products)
          SizedBox(
            width: tileWidth,
            child: ProductTile(
              product: p,
              aspectRatio: aspectRatio,
              onOpen: () =>
                  context.read<ShopNavigationCubit>().openProduct(p.id),
            ),
          ),
      ],
    ),
  );
}
