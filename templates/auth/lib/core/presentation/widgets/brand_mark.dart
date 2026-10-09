import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// Cairn's stacked-stones mark, drawn from theme tokens.
///
/// Three rounded bars on a rounded square. Replace this widget with your own
/// logo (an `Image.asset` or an SVG widget) to rebrand every screen at once.
class BrandMark extends StatelessWidget {
  /// Creates the mark, [size] logical pixels square.
  const BrandMark({super.key, this.size = 56});

  /// The side length.
  final double size;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final double u = size / 24;
    Widget stone(double width) => Container(
      width: width * u,
      height: 5 * u,
      decoration: BoxDecoration(
        color: theme.primaryForeground,
        borderRadius: BorderRadius.circular(2.5 * u),
      ),
    );
    return Semantics(
      image: true,
      label: 'Logo',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.primary,
          borderRadius: BorderRadius.circular(5.3 * u),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 1.5 * u,
          children: <Widget>[stone(7), stone(13), stone(18)],
        ),
      ),
    );
  }
}
