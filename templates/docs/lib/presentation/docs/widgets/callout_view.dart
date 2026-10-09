import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';

import '../../../core/presentation/docs_text.dart';
import '../../../domain/docs/models/doc_block.dart';
import 'rich_inline.dart';

/// A note, tip or warning, drawn with a [CairnAlert].
///
/// Cairn's alert has a normal and a destructive variant, so the three kinds are
/// told apart by icon and title, and a warning uses the destructive variant.
class CalloutView extends StatelessWidget {
  /// Creates a callout.
  const CalloutView({super.key, required this.block});

  /// The callout to show.
  final CalloutBlock block;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool warning = block.kind == CalloutKind.warning;
    final Color color = theme.mutedForeground;
    final Widget icon = switch (block.kind) {
      CalloutKind.info => const CairnIcon(CairnIconData.info),
      CalloutKind.tip => const Icon(Icons.lightbulb_outline, size: 16),
      CalloutKind.warning => const CairnIcon(CairnIconData.alert),
    };
    return CairnAlert(
      variant: warning
          ? CairnAlertVariant.destructive
          : CairnAlertVariant.normal,
      icon: IconTheme(
        data: IconThemeData(
          color: warning ? theme.destructive : theme.foreground,
        ),
        child: icon,
      ),
      title: Text(block.title ?? block.kind.defaultTitle),
      description: RichInline(
        block.text,
        style: docsText(
          theme,
          theme.textStyle(CairnTypography.sm),
          color: color,
          height: 1.6,
        ),
      ),
    );
  }
}
