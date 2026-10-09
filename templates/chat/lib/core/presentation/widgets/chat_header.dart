import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../chat_text.dart';
import 'icon_action.dart';

/// The bar at the top of a screen opened over the tabs: back button, an
/// optional avatar, a title with a line of detail under it, and actions.
class ChatHeader extends StatelessWidget {
  /// Creates a header.
  const ChatHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onBack,
    this.backLabel = 'Back',
    this.actions = const <Widget>[],
  });

  /// The main line.
  final String title;

  /// The line under the title; may be a live status such as "typing...".
  final Widget? subtitle;

  /// An avatar shown before the title.
  final Widget? leading;

  /// Shows a back button when set.
  final VoidCallback? onBack;

  /// The back button's accessible name.
  final String backLabel;

  /// Buttons at the end.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: EdgeInsets.fromLTRB(onBack == null ? 16 : 4, 6, 4, 6),
          child: Row(
            children: <Widget>[
              if (onBack != null)
                IconAction(
                  icon: Icons.arrow_back,
                  label: backLabel,
                  onPressed: onBack,
                ),
              if (leading != null) ...<Widget>[
                leading!,
                const SizedBox(width: 12),
              ] else if (onBack != null)
                const SizedBox(width: 4),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: chatText(
                          theme,
                          theme.textStyle(CairnTypography.base),
                          weight: CairnTypography.semibold,
                        ),
                      ),
                    ),
                    if (subtitle != null)
                      DefaultTextStyle(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: chatText(
                          theme,
                          theme.textStyle(CairnTypography.xs),
                          color: theme.mutedForeground,
                        ),
                        child: subtitle!,
                      ),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
