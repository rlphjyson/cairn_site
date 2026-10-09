import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/docs_brand.dart';
import '../docs_text.dart';

/// The logo mark and product name shown at the left of the top bar.
///
/// The mark is a rounded square with the brand monogram. To use a real logo,
/// replace the [DecoratedBox] below with an `Image.asset` (see
/// `DocsPackage.name` for the asset package).
class BrandMark extends StatelessWidget {
  /// Creates the mark.
  const BrandMark({super.key, this.showName = true});

  /// Whether to show the product name beside the mark.
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Semantics(
      label: DocsBrand.name,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(theme.radiusScale.md),
            ),
            child: SizedBox.square(
              dimension: 28,
              child: Center(
                child: Text(
                  DocsBrand.monogram,
                  style: docsText(
                    theme,
                    theme.textStyle(CairnTypography.sm),
                    color: theme.primaryForeground,
                    weight: CairnTypography.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          if (showName)
            Text(
              DocsBrand.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: docsText(
                theme,
                theme.textStyle(CairnTypography.base),
                weight: CairnTypography.semibold,
                letterSpacing: -0.2,
              ),
            ),
        ],
      ),
    );
  }
}
