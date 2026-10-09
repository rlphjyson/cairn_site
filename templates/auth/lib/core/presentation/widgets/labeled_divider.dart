import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../auth_text.dart';

/// A hairline with a word in the middle ("or").
class LabeledDivider extends StatelessWidget {
  /// Creates a divider.
  const LabeledDivider(this.label, {super.key});

  /// The word between the lines.
  final String label;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      spacing: 12,
      children: <Widget>[
        const Expanded(child: CairnSeparator()),
        Text(
          label,
          style: authText(
            theme,
            CairnTypography.xs,
            color: theme.mutedForeground,
          ),
        ),
        const Expanded(child: CairnSeparator()),
      ],
    );
  }
}
