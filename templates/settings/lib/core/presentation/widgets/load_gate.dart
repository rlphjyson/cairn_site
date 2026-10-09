import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../load_status.dart';
import 'themed_overlays.dart';

/// Shows [child] once [status] is ready; skeleton rows while loading, and an
/// error with a retry button when it failed.
class LoadGate extends StatelessWidget {
  /// Creates a gate.
  const LoadGate({
    super.key,
    required this.status,
    required this.onRetry,
    required this.child,
    this.rows = 3,
  });

  /// Where loading is.
  final LoadStatus status;

  /// Called by the retry button.
  final VoidCallback onRetry;

  /// How many skeleton rows to draw while loading.
  final int rows;

  /// The loaded content.
  final Widget child;

  @override
  Widget build(BuildContext context) => switch (status) {
    LoadStatus.ready => child,
    LoadStatus.loading => Semantics(
      label: 'Loading',
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < rows; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 12),
            const CairnSkeleton(height: 56),
          ],
        ],
      ),
    ),
    LoadStatus.failure => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const CairnAlert(
          variant: CairnAlertVariant.destructive,
          icon: CairnIcon(CairnIconData.alert),
          title: Text('Could not load'),
          description: Text('Check your connection and try again.'),
        ),
        const SizedBox(height: 12),
        DialogButton(
          label: 'Try again',
          variant: CairnButtonVariant.outline,
          onPressed: onRetry,
        ),
      ],
    ),
  };
}
