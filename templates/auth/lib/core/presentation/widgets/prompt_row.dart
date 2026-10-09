import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../auth_text.dart';
import 'auth_link.dart';

/// A sentence with a link after it: "No account yet? Create one".
class PromptRow extends StatelessWidget {
  /// Creates a row.
  const PromptRow({
    super.key,
    required this.prompt,
    required this.linkLabel,
    required this.onPressed,
  });

  /// The words before the link.
  final String prompt;

  /// The link text.
  final String linkLabel;

  /// Called when the link is tapped.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: <Widget>[
        Text(
          prompt,
          style: authText(
            theme,
            CairnTypography.sm,
            color: theme.mutedForeground,
          ),
        ),
        AuthLink(label: linkLabel, onPressed: onPressed),
      ],
    );
  }
}
