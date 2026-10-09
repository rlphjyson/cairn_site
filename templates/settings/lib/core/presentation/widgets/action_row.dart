import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import 'control_scale.dart';

/// A list row with a leading mark, two lines of text and a button.
///
/// The button sits at the end of the row. When text is scaled up there is not
/// enough width for both, so the button moves under the text instead, and the
/// text keeps the whole row.
class ActionRow extends StatelessWidget {
  /// Creates a row.
  const ActionRow({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.action,
    this.badge,
  });

  /// The leading avatar or icon.
  final Widget leading;

  /// The primary line.
  final Widget title;

  /// The secondary line.
  final Widget subtitle;

  /// The button. `null` shows none.
  final Widget? action;

  /// A badge after the title.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool stacked = isLargeText(context);
    final Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DefaultTextStyle(
          style: theme
              .textStyle(CairnTypography.sm)
              .copyWith(
                fontWeight: CairnTypography.medium,
                color: theme.foreground,
              ),
          child: badge == null
              ? title
              : Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[title, badge!],
                ),
        ),
        DefaultTextStyle(
          style: theme
              .textStyle(CairnTypography.xs)
              .copyWith(color: theme.mutedForeground),
          child: subtitle,
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    leading,
                    const SizedBox(width: 12),
                    Expanded(child: text),
                  ],
                ),
                if (action != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 44),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ControlScale(child: action!),
                    ),
                  ),
              ],
            )
          : Row(
              children: <Widget>[
                leading,
                const SizedBox(width: 12),
                Expanded(child: text),
                if (action != null) ...<Widget>[
                  const SizedBox(width: 12),
                  action!,
                ],
              ],
            ),
    );
  }
}
