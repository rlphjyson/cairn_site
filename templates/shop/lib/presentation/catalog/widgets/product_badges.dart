import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/catalog/models/product.dart';

/// The Sale and New badges a product earns, stacked, or nothing at all.
class ProductBadges extends StatelessWidget {
  /// Creates the badges for [product].
  const ProductBadges(this.product, {super.key});

  /// The product.
  final Product product;

  @override
  Widget build(BuildContext context) {
    if (!product.isOnSale && !product.isNew) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: <Widget>[
        if (product.isOnSale)
          const _Backed(
            child: CairnBadge(
              variant: CairnBadgeVariant.destructive,
              label: Text('Sale'),
            ),
          ),
        if (product.isNew) const _Backed(child: CairnBadge(label: Text('New'))),
      ],
    );
  }
}

/// Gives a badge the page colour behind it, so the dark theme's translucent
/// fills read the same over any photograph.
class _Backed extends StatelessWidget {
  const _Backed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: CairnTheme.of(context).background,
      borderRadius: BorderRadius.circular(CairnRadius.full),
    ),
    child: child,
  );
}
