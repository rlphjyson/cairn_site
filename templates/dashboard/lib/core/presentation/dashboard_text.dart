import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// A Cairn text style with the template's defaults applied. Every colour comes
/// from [CairnTheme], so light and dark need no extra code.
TextStyle dashText(
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
