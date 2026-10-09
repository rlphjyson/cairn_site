import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';

import '../../../common/constants/docs_layout.dart';

/// Placeholder bars shown while a version loads.
class PageSkeleton extends StatelessWidget {
  /// Creates the skeleton.
  const PageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading documentation',
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: DocsLayout.contentMaxWidth,
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 14,
              children: <Widget>[
                CairnSkeleton(width: 180, height: 14),
                SizedBox(height: 6),
                CairnSkeleton(width: 300, height: 36),
                CairnSkeleton(height: 18),
                CairnSkeleton(width: 420, height: 18),
                SizedBox(height: 24),
                CairnSkeleton(height: 14),
                CairnSkeleton(height: 14),
                CairnSkeleton(width: 360, height: 14),
                SizedBox(height: 12),
                CairnSkeleton(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A centred message with an icon and actions: the not-found and error states.
class PageMessage extends StatelessWidget {
  /// Creates a message.
  const PageMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actions = const <Widget>[],
  });

  /// The glyph.
  final IconData icon;

  /// The headline.
  final String title;

  /// The explanation.
  final String description;

  /// Buttons under the text.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: CairnEmpty(
            title: title,
            description: description,
            media: Icon(icon, size: 28, color: theme.mutedForeground),
            actions: actions,
          ),
        ),
      ),
    );
  }
}

/// The icon the not-found state uses.
const IconData notFoundIcon = Icons.find_in_page_outlined;

/// The icon the error state uses.
const IconData errorIcon = Icons.error_outline;
