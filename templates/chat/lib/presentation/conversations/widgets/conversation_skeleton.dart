import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// Placeholder rows shown while the conversation list loads.
class ConversationSkeleton extends StatelessWidget {
  /// Creates the skeleton.
  const ConversationSkeleton({super.key, this.rows = 7});

  /// How many rows to draw.
  final int rows;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading conversations',
    child: ExcludeSemantics(
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                spacing: 12,
                children: <Widget>[
                  const CairnSkeleton.circle(size: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: <Widget>[
                        CairnSkeleton(width: 100.0 + (i % 3) * 24, height: 14),
                        CairnSkeleton(width: 160.0 + (i % 2) * 40, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
