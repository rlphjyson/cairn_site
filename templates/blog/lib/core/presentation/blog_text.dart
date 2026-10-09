import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// A Cairn text style with the template's defaults applied.
///
/// Every colour resolves through [CairnTheme], so the template follows light
/// and dark with no extra code. Pass [muted] for secondary text and [tight]
/// for the slightly negative tracking Cairn uses on headings.
TextStyle blogText(
  CairnTheme theme,
  TextStyle base, {
  Color? color,
  FontWeight? weight,
  double? height,
  double? size,
  bool muted = false,
  bool tight = false,
}) {
  final double fontSize = size ?? base.fontSize ?? 14;
  return theme
      .textStyle(base)
      .copyWith(
        color: color ?? (muted ? theme.mutedForeground : theme.foreground),
        fontWeight: weight,
        height: height,
        fontSize: size,
        letterSpacing: tight ? CairnTypography.trackingTight(fontSize) : null,
      );
}
