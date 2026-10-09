import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../shop_text.dart';

/// An icon, a message and one action, for screens with nothing to show.
///
/// It scrolls when the screen is short, and may carry extra content (such as
/// suggested products) below the action.
class EmptyState extends StatelessWidget {
  /// Creates an empty state.
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.onAction,
    this.below,
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

  /// Extra content under the button, such as product suggestions.
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) =>
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: box.maxHeight.isFinite ? box.maxHeight - 48 : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.muted,
                      ),
                      child: Icon(icon, color: theme.mutedForeground),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
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
                  Center(
                    child: CairnButton(
                      size: CairnButtonSize.sm,
                      onPressed: onAction,
                      child: Text(action),
                    ),
                  ),
                  if (below != null) ...<Widget>[
                    const SizedBox(height: 28),
                    below!,
                  ],
                ],
              ),
            ),
          ),
    );
  }
}
