import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

/// A failed-load message with a retry button, centred in its parent.
class ErrorPanel extends StatelessWidget {
  /// Creates the panel.
  const ErrorPanel({super.key, required this.onRetry, this.message});

  /// Called when "Try again" is pressed.
  final VoidCallback onRetry;

  /// What went wrong, in a sentence.
  final String? message;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            CairnAlert(
              variant: CairnAlertVariant.destructive,
              icon: const Icon(Icons.error_outline, size: 16),
              title: const Text('Could not load this page'),
              description: Text(
                message ?? 'Check your connection and try again.',
              ),
            ),
            CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    ),
  );
}
