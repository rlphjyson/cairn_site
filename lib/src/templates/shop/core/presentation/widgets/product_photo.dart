import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// A rounded, cropped product photograph with a quiet fallback.
class ProductPhoto extends StatelessWidget {
  /// Creates a photo.
  const ProductPhoto(this.asset, {super.key, this.radius});

  /// Bundled asset path.
  final String asset;

  /// Corner radius; defaults to the theme's `lg`.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? theme.radiusScale.lg),
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
            ColoredBox(color: theme.muted),
      ),
    );
  }
}
