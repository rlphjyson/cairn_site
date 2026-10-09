import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../shop_text.dart';

/// A section's title with an optional trailing widget (a count, a control).
class SectionHeader extends StatelessWidget {
  /// Creates a header.
  const SectionHeader(this.title, {super.key, this.trailing});

  /// The title.
  final String title;

  /// Shown at the end of the row.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: shopText(
                theme,
                theme.textStyle(CairnTypography.base),
                weight: CairnTypography.semibold,
              ),
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
