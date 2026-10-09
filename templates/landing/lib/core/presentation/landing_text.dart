import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// A Cairn text style with the template's defaults applied. Every colour comes
/// from [CairnTheme], so light and dark need no extra code.
///
/// [tight] applies Cairn's `tracking-tight`, used on headings.
TextStyle landingText(
  CairnTheme theme,
  TextStyle base, {
  Color? color,
  FontWeight? weight,
  double? height,
  double? size,
  bool tight = false,
}) => theme
    .textStyle(base)
    .copyWith(
      color: color ?? theme.foreground,
      fontWeight: weight,
      height: height,
      fontSize: size,
      letterSpacing: tight
          ? CairnTypography.trackingTight(size ?? base.fontSize ?? 16)
          : null,
    );
