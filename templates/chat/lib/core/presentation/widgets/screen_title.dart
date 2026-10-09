import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../chat_text.dart';

/// A tab's large heading with optional actions at the end.
class ScreenTitle extends StatelessWidget {
  /// Creates a title.
  const ScreenTitle(this.text, {super.key, this.actions = const <Widget>[]});

  /// The heading.
  final String text;

  /// Buttons at the end.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                text,
                style: chatText(
                  theme,
                  theme.textStyle(CairnTypography.xl2),
                  weight: CairnTypography.semibold,
                ),
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
