import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// Families the browser falls back to inside code.
const List<String> monoFallback = <String>[
  'ui-monospace',
  'SFMono-Regular',
  'Menlo',
  'Consolas',
  'Liberation Mono',
  'monospace',
];

/// A Cairn text style with the template's defaults applied. Every colour comes
/// from [CairnTheme], so light and dark need no extra code.
TextStyle docsText(
  CairnTheme theme,
  TextStyle base, {
  Color? color,
  FontWeight? weight,
  double? height,
  double? letterSpacing,
}) => base.copyWith(
  color: color ?? theme.foreground,
  fontWeight: weight,
  height: height,
  letterSpacing: letterSpacing,
);

/// A monospace style for code, sized relative to [base].
TextStyle docsMono(
  CairnTheme theme,
  TextStyle base, {
  Color? color,
  double? height,
}) => base.copyWith(
  fontFamily: 'monospace',
  fontFamilyFallback: monoFallback,
  color: color ?? theme.foreground,
  height: height,
);
