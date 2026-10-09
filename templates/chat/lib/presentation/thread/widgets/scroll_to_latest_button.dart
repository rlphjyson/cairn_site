import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../core/presentation/widgets/icon_action.dart';

/// A round button that jumps to the newest message, with a count of the
/// messages that arrived while you were reading older ones.
class ScrollToLatestButton extends StatelessWidget {
  /// Creates the button.
  const ScrollToLatestButton({
    super.key,
    required this.unseen,
    required this.onPressed,
  });

  /// How many new messages are waiting below.
  final int unseen;

  /// Called on tap.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => CairnIndicator(
    indicator: unseen > 0
        ? CairnBadge(label: Text(unseen > 99 ? '99+' : '$unseen'))
        : const SizedBox.shrink(),
    offset: const Offset(-4, 4),
    child: IconAction(
      icon: Icons.keyboard_arrow_down,
      label: unseen > 0
          ? 'Scroll to latest, $unseen new ${unseen == 1 ? 'message' : 'messages'}'
          : 'Scroll to latest message',
      variant: CairnButtonVariant.outline,
      onPressed: onPressed,
    ),
  );
}
