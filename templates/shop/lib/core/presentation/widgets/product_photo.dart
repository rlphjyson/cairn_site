import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/shop_package.dart';

/// A rounded, cropped product photograph with a quiet fallback.
class ProductPhoto extends StatelessWidget {
  /// Creates a photo.
  const ProductPhoto(
    this.asset, {
    super.key,
    this.radius,
    this.alignment = Alignment.center,
  });

  /// Bundled asset path.
  final String asset;

  /// Corner radius; defaults to the theme's `lg`.
  final double? radius;

  /// Which part of the photograph stays in view when it is cropped.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? theme.radiusScale.lg),
      child: Image.asset(
        asset,
        package: ShopPackage.name,
        fit: BoxFit.cover,
        alignment: alignment,
        // Decorative: the product's name sits beside every photograph.
        excludeFromSemantics: true,
        errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
            ColoredBox(color: theme.muted),
      ),
    );
  }
}
