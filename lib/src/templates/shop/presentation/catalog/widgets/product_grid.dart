import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../../../domain/catalog/models/product.dart';
import 'product_tile.dart';

/// A two-column grid of [ProductTile]s that opens a product on tap.
///
/// Shared by the storefront and the saved list.
class ProductGrid extends StatelessWidget {
  /// Creates a grid.
  const ProductGrid({super.key, required this.products});

  /// What to show.
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        const double gap = 12;
        final double width = (box.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: <Widget>[
            for (final Product p in products)
              SizedBox(
                width: width,
                child: ProductTile(
                  product: p,
                  onOpen: () =>
                      context.read<ShopNavigationCubit>().openProduct(p.id),
                ),
              ),
          ],
        );
      },
    );
  }
}
