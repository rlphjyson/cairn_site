import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/settings_layout.dart';
import '../settings_text.dart';
import 'touch_target.dart';

/// The frame every page shares: a header with an optional back control, and a
/// scrolling body kept to a readable width.
///
/// The body scrolls rather than overflowing, so large text and short screens
/// still work.
class PageFrame extends StatelessWidget {
  /// Creates a frame.
  const PageFrame({
    super.key,
    required this.title,
    this.onBack,
    required this.children,
    this.bottom,
  });

  /// The heading. It is announced as a header.
  final String title;

  /// Called by the back control. `null` hides the control.
  final VoidCallback? onBack;

  /// The page's content, one block per child, spaced evenly.
  final List<Widget> children;

  /// A widget pinned under the scrolling area.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, SettingsLayout.gutter, 0),
            child: Row(
              children: <Widget>[
                if (onBack != null)
                  TouchTarget(
                    onTap: onBack,
                    child: CairnButton.icon(
                      variant: CairnButtonVariant.ghost,
                      size: CairnButtonSize.iconLg,
                      semanticLabel: 'Back',
                      icon: const CairnIcon(CairnIconData.chevronLeft),
                      onPressed: onBack,
                    ),
                  )
                else
                  const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: settingsText(
                          theme,
                          CairnTypography.xl,
                          weight: CairnTypography.semibold,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                SettingsLayout.gutter,
                8,
                SettingsLayout.gutter,
                24,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: SettingsLayout.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (int i = 0; i < children.length; i++) ...<Widget>[
                        if (i > 0) const SizedBox(height: 20),
                        children[i],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          ?bottom,
        ],
      ),
    );
  }
}
