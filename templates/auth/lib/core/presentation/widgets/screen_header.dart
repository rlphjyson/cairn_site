import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../auth_text.dart';

/// A screen's heading and the sentence under it.
class ScreenHeader extends StatelessWidget {
  /// Creates a header.
  const ScreenHeader({super.key, required this.title, this.subtitle});

  /// The heading.
  final String title;

  /// A sentence of context.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            title,
            style: authText(
              theme,
              CairnTypography.xl2,
              weight: CairnTypography.semibold,
              letterSpacing: CairnTypography.trackingTight(24),
            ),
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: authText(
              theme,
              CairnTypography.sm,
              color: theme.mutedForeground,
              height: 1.5,
            ),
          ),
      ],
    );
  }
}
