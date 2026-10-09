import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/widgets/themed_overlays.dart';

/// Asks for a star rating. Pops with the number of stars (1 to 5) on Send, or
/// `null` when dismissed.
class RateDialog extends StatefulWidget {
  /// Creates the dialog.
  const RateDialog({super.key});

  @override
  State<RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<RateDialog> {
  double _stars = 0;

  @override
  Widget build(BuildContext context) => CairnDialog(
    title: const Text('Rate the app'),
    description: const Text('Tap a star to tell us how we are doing.'),
    content: Center(
      child: CairnRating(
        value: _stars,
        size: 36,
        semanticLabel: 'Rating, 1 to 5 stars',
        onChanged: (double v) => setState(() => _stars = v),
      ),
    ),
    actions: <Widget>[
      DialogButton(
        label: 'Not now',
        variant: CairnButtonVariant.outline,
        onPressed: () => Navigator.of(context).pop(),
      ),
      DialogButton(
        label: 'Send',
        onPressed: _stars < 1
            ? null
            : () => Navigator.of(context).pop(_stars.round()),
      ),
    ],
  );
}
