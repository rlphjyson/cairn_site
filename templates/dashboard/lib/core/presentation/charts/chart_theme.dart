import 'package:cairn_ui/cairn_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Cairn tokens, translated into the shapes fl_chart expects.
///
/// ## Why fl_chart rather than new Cairn components
///
/// Charting is a genuinely large problem — axes, ticks, curve interpolation,
/// hit-testing, tooltips, animation — and Flutter already has a mature package
/// that solves it. The useful thing a design system adds on top is not another
/// implementation of that; it is a consistent skin. So this adapter takes an
/// established charting package and dresses it in Cairn's tokens.
///
/// The alternative, adding chart widgets to `package:cairn_ui`, was rejected on
/// two counts. The library's stated contract is "no runtime dependencies beyond
/// Flutter itself", so a chart family would have to be hand-painted from
/// scratch — and every component in that package is pinned by a golden test
/// generated on Linux CI, so it would also mean maintaining golden sheets for
/// a surface far larger and far more data-dependent than any control in the
/// catalogue.
///
/// What Cairn *does* already ship is the palette: `CairnColors.chart1` through
/// `chart5`, defined as `--chart-N` OKLCH values alongside the other tokens. In
/// the Neutral base those are achromatic — `#D4D4D4` down to `#262626` — which
/// is why these charts are monochrome by default rather than reaching for
/// colours the design system does not define.
abstract final class ChartTheme {
  /// The five-step series ramp, straight from the library's tokens.
  ///
  /// Ordered brightest-first for dark themes and darkest-first for light ones,
  /// so the primary series always has the most contrast against the surface.
  static List<Color> series(CairnTheme theme) =>
      theme.brightness == Brightness.dark
      ? const <Color>[
          CairnColors.chart1,
          CairnColors.chart2,
          CairnColors.chart3,
          CairnColors.chart4,
          CairnColors.chart5,
        ]
      : const <Color>[
          CairnColors.chart5,
          CairnColors.chart4,
          CairnColors.chart3,
          CairnColors.chart2,
          CairnColors.chart1,
        ];

  /// The nth series colour, wrapping.
  static Color seriesColor(CairnTheme theme, int index) {
    final List<Color> ramp = series(theme);
    return ramp[index % ramp.length];
  }

  /// Horizontal grid lines only, at `--border`, hairline width.
  ///
  /// Horizontal rules help a reader carry a point across to the value axis;
  /// vertical ones mostly add noise, since the category is already labelled.
  static FlGridData grid(CairnTheme theme, {double? interval}) => FlGridData(
    drawVerticalLine: false,
    horizontalInterval: interval,
    getDrawingHorizontalLine: (double value) => FlLine(
      color: theme.brightness == Brightness.dark
          ? theme.border.withValues(alpha: 0.7)
          : theme.border,
      strokeWidth: 1,
    ),
  );

  /// The axis label style: `text-xs` in `--muted-foreground`.
  static TextStyle axisLabel(CairnTheme theme) => theme
      .textStyle(CairnTypography.xs)
      .copyWith(color: theme.mutedForeground);

  /// A bottom axis that renders [labels] under each integer x position.
  static AxisTitles categoryAxis(CairnTheme theme, List<String> labels) =>
      AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (double value, TitleMeta meta) {
            final int index = value.round();
            if (index < 0 || index >= labels.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: CairnSpacing.s2),
              child: Text(labels[index], style: axisLabel(theme)),
            );
          },
        ),
      );

  /// A left axis formatted by [format].
  static AxisTitles valueAxis(
    CairnTheme theme, {
    required String Function(double) format,
    double? interval,
    double reservedSize = 44,
  }) => AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: reservedSize,
      interval: interval,
      getTitlesWidget: (double value, TitleMeta meta) => Padding(
        padding: const EdgeInsets.only(right: CairnSpacing.s2),
        child: Text(
          format(value),
          textAlign: TextAlign.right,
          style: axisLabel(theme),
        ),
      ),
    ),
  );

  /// Axes turned off on the sides Cairn charts do not use.
  static const AxisTitles hidden = AxisTitles();

  /// No chart border — the card around it already draws one.
  static FlBorderData get border => FlBorderData(show: false);

  /// A tooltip painted on `--popover` with the popover radius.
  static LineTouchTooltipData lineTooltip(
    CairnTheme theme, {
    required String Function(LineBarSpot) label,
  }) => LineTouchTooltipData(
    getTooltipColor: (LineBarSpot _) => theme.popover,
    tooltipBorder: BorderSide(color: theme.border),
    tooltipBorderRadius: BorderRadius.circular(theme.radiusScale.md),
    tooltipPadding: const EdgeInsets.symmetric(
      horizontal: CairnSpacing.s3,
      vertical: CairnSpacing.s2,
    ),
    getTooltipItems: (List<LineBarSpot> spots) => spots
        .map(
          (LineBarSpot spot) => LineTooltipItem(
            label(spot),
            theme
                .textStyle(CairnTypography.xs)
                .copyWith(color: theme.popoverForeground),
          ),
        )
        .toList(),
  );

  /// The bar-chart equivalent of [lineTooltip].
  static BarTouchTooltipData barTooltip(
    CairnTheme theme, {
    required String Function(BarChartGroupData, BarChartRodData) label,
  }) => BarTouchTooltipData(
    getTooltipColor: (BarChartGroupData _) => theme.popover,
    tooltipBorder: BorderSide(color: theme.border),
    tooltipBorderRadius: BorderRadius.circular(theme.radiusScale.md),
    tooltipPadding: const EdgeInsets.symmetric(
      horizontal: CairnSpacing.s3,
      vertical: CairnSpacing.s2,
    ),
    getTooltipItem:
        (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
        ) => BarTooltipItem(
          label(group, rod),
          theme
              .textStyle(CairnTypography.xs)
              .copyWith(color: theme.popoverForeground),
        ),
  );

  /// The dot painter used on a highlighted line series.
  static FlDotData dots(CairnTheme theme, Color color, {bool show = false}) =>
      FlDotData(
        show: show,
        getDotPainter:
            (FlSpot spot, double percent, LineChartBarData bar, int index) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: theme.background,
                  strokeColor: color,
                  strokeWidth: 2,
                ),
      );
}
