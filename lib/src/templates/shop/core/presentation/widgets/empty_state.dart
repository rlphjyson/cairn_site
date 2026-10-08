import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../shop_text.dart';

/// An icon, a message and one action, for screens with nothing to show.
class EmptyState extends StatelessWidget {
  /// Creates an empty state.
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.onAction,
  });

  /// The glyph in the circle.
  final IconData icon;

  /// The headline.
  final String title;

  /// The explanation.
  final String body;

  /// The button label.
  final String action;

  /// Called when the button is pressed.
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.muted,
              ),
              child: Icon(icon, color: theme.mutedForeground),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: shopText(
                theme,
                theme.textStyle(CairnTypography.base),
                weight: CairnTypography.semibold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              textAlign: TextAlign.center,
              style: shopText(
                theme,
                theme.textStyle(CairnTypography.sm),
                color: theme.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            CairnButton(
              size: CairnButtonSize.sm,
              onPressed: onAction,
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
