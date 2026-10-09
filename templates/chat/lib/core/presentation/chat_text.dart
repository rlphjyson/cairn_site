import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// A Cairn text style with the template's defaults applied.
///
/// Every colour resolves through [CairnTheme], so the template follows light
/// and dark with no extra code.
TextStyle chatText(
  CairnTheme theme,
  TextStyle base, {
  Color? color,
  FontWeight? weight,
  double? height,
}) => base.copyWith(
  color: color ?? theme.foreground,
  fontWeight: weight,
  height: height,
);
