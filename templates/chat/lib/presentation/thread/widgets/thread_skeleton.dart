import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// Placeholder bubbles shown while a thread loads.
class ThreadSkeleton extends StatelessWidget {
  /// Creates the skeleton.
  const ThreadSkeleton({super.key});

  static const List<(bool, double, double)> _rows = <(bool, double, double)>[
    (false, 180, 40),
    (false, 120, 40),
    (true, 150, 40),
    (false, 210, 56),
    (true, 100, 40),
    (true, 190, 40),
  ];

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading messages',
    child: ExcludeSemantics(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 12,
          children: <Widget>[
            for (final (bool mine, double width, double height) in _rows)
              Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: CairnSkeleton(
                  width: width,
                  height: height,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
