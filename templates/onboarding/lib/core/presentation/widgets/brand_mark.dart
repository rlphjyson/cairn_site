import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// The product's mark: three stacked stones, drawn from Cairn tokens so it
/// follows light and dark. Replace it with your own logo (an `Image.asset`
/// works) in `presentation/splash/views/splash_view.dart`.
class BrandMark extends StatelessWidget {
  /// Creates the mark.
  const BrandMark({super.key, this.size = 88});

  /// The width of the base stone.
  final double size;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final double h = size * 0.26;
    Widget stone(double width, Color color) => Container(
      width: width,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(h / 2),
      ),
    );
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: size * 0.06,
        children: <Widget>[
          stone(size * 0.46, theme.primary),
          stone(size * 0.72, theme.primary.withValues(alpha: 0.7)),
          stone(size, theme.primary.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}
