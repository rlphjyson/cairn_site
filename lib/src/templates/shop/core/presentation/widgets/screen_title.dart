import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../shop_text.dart';

/// A screen's large heading with an optional trailing widget.
class ScreenTitle extends StatelessWidget {
  /// Creates a title.
  const ScreenTitle(this.text, {super.key, this.trailing});

  /// The heading.
  final String text;

  /// Shown at the end of the row.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            text,
            style: shopText(
              theme,
              theme.textStyle(CairnTypography.xl2),
              weight: CairnTypography.semibold,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
