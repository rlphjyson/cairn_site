import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../app/links.dart';
import '../app/site_theme.dart';
import '../charts/chart_samples.dart';
import '../widgets/code_block.dart';
import '../widgets/preview_pane.dart';
import '../widgets/site_icons.dart';
import '../widgets/surfaces.dart';

/// The charts showcase.
///
/// Cairn has no chart widgets — deliberately, and this page says so at the top
/// rather than quietly implying otherwise.
class ChartsPage extends StatelessWidget {
  /// Creates the page.
  const ChartsPage({super.key});

  static const List<_ChartSpec> _charts = <_ChartSpec>[
    _ChartSpec(
      name: 'Area',
      description:
          'A single curved series with a gradient fill, from the series colour '
          'at 35% down to 2%.',
      builder: ChartSamples.area,
      code: '''
LineChart(
  LineChartData(
    gridData: ChartTheme.grid(theme, interval: 120),
    borderData: ChartTheme.border,
    titlesData: FlTitlesData(
      topTitles: ChartTheme.hidden,
      rightTitles: ChartTheme.hidden,
      bottomTitles: ChartTheme.categoryAxis(theme, months),
      leftTitles: ChartTheme.valueAxis(theme, format: _thousands),
    ),
    lineTouchData: LineTouchData(
      touchTooltipData: ChartTheme.lineTooltip(theme, label: _label),
    ),
    lineBarsData: <LineChartBarData>[
      LineChartBarData(
        isCurved: true,
        color: ChartTheme.seriesColor(theme, 0),
        barWidth: 2,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              color.withValues(alpha: 0.35),
              color.withValues(alpha: 0.02),
            ],
          ),
        ),
        spots: spots,
      ),
    ],
  ),
)''',
    ),
    _ChartSpec(
      name: 'Bar',
      description:
          'Two grouped series. The rod corners use theme.radiusScale.sm, so a '
          'themed app with a tighter --radius gets tighter bars too.',
      builder: ChartSamples.bar,
      code: '''
BarChartRodData(
  toY: visitors[i],
  color: ChartTheme.seriesColor(theme, 0),
  width: 12,
  // Not a literal 6 — re-derived from whatever --radius is active.
  borderRadius: BorderRadius.vertical(
    top: Radius.circular(theme.radiusScale.sm),
  ),
)''',
    ),
    _ChartSpec(
      name: 'Line',
      description:
          'Two series, one emphasised with dots painted as a ring: the page '
          'background filled, the series colour stroked.',
      builder: ChartSamples.line,
      code: '''
FlDotData(
  show: true,
  getDotPainter: (FlSpot spot, double percent, LineChartBarData bar, int i) =>
      FlDotCirclePainter(
        radius: 3,
        color: theme.background,   // punches through the line
        strokeColor: seriesColor,
        strokeWidth: 2,
      ),
)''',
    ),
    _ChartSpec(
      name: 'Pie',
      description:
          'A donut with a centre readout and a legend built from Cairn type '
          'tokens rather than the charting library\'s own labels.',
      builder: ChartSamples.pie,
      code: '''
PieChart(
  PieChartData(
    centerSpaceRadius: 56,
    sectionsSpace: 2,
    startDegreeOffset: -90,
    sections: <PieChartSectionData>[
      for (int i = 0; i < slices.length; i++)
        PieChartSectionData(
          value: slices[i].share,
          color: ChartTheme.seriesColor(theme, i),
          radius: 46,
          showTitle: false, // the legend does this job, in text-sm
        ),
    ],
  ),
)''',
    ),
    _ChartSpec(
      name: 'Radial',
      description:
          'A gauge built from the same donut primitive. The unfilled arc is '
          'primary at 20% alpha — the exact track colour CairnProgress paints.',
      builder: ChartSamples.radial,
      code: '''
PieChartData(
  centerSpaceRadius: 68,
  sectionsSpace: 0,
  startDegreeOffset: -90,
  sections: <PieChartSectionData>[
    PieChartSectionData(
      value: progress * 100,
      color: ChartTheme.seriesColor(theme, 0),
      radius: 18,
      showTitle: false,
    ),
    PieChartSectionData(
      value: (1 - progress) * 100,
      // Same token CairnProgress uses for its track.
      color: theme.primary.withValues(alpha: 0.2),
      radius: 18,
      showTitle: false,
    ),
  ],
)''',
    ),
    _ChartSpec(
      name: 'Radar',
      description:
          'Two overlaid profiles on a polygon grid. The built-in tick labels '
          'are suppressed because they cannot be styled independently.',
      builder: ChartSamples.radar,
      code: '''
RadarChartData(
  radarShape: RadarShape.polygon,
  radarBorderData: BorderSide(color: theme.hairline),
  gridBorderData: BorderSide(color: theme.hairline),
  tickBorderData: const BorderSide(color: Color(0x00000000)),
  titleTextStyle: ChartTheme.axisLabel(theme),
  getTitle: (int index, double angle) => RadarChartTitle(text: axes[index]),
  dataSets: <RadarDataSet>[
    RadarDataSet(
      fillColor: primary.withValues(alpha: 0.22),
      borderColor: primary,
      borderWidth: 2,
      dataEntries: entries,
    ),
  ],
)''',
    ),
    _ChartSpec(
      name: 'Tooltip',
      description:
          'Hover or tap a bar. The tooltip is painted on --popover with the '
          'popover border and the derived md radius, so it is the same surface '
          'a CairnPopover would draw.',
      builder: ChartSamples.tooltip,
      code: '''
BarTouchTooltipData(
  getTooltipColor: (BarChartGroupData _) => theme.popover,
  tooltipBorder: BorderSide(color: theme.border),
  tooltipBorderRadius: BorderRadius.circular(theme.radiusScale.md),
  tooltipPadding: const EdgeInsets.symmetric(
    horizontal: CairnSpacing.s3,
    vertical: CairnSpacing.s2,
  ),
  getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
    label(group, rod),
    theme.textStyle(CairnTypography.xs).copyWith(
      color: theme.popoverForeground,
    ),
  ),
)''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageHeading(
            eyebrow: 'Data visualisation',
            title: 'Charts',
            lead:
                'Seven chart shapes, every one of them wearing Cairn\'s tokens '
                '— the series ramp, the border hairline, the popover surface, '
                'the derived radius scale and the text-xs axis style.',
          ),
          const SizedBox(height: CairnSpacing.s8),
          const _DecisionPanel(),
          for (final _ChartSpec spec in _charts) ...<Widget>[
            const SizedBox(height: CairnSpacing.s12),
            SectionHeading(spec.name, subtitle: spec.description),
            const SizedBox(height: CairnSpacing.s5),
            PreviewPane(
              preview: spec.builder,
              code: spec.code,
              // Charts fill their pane instead of sizing themselves, so they
              // need bounded width rather than the default overflow scroller.
              fillWidth: true,
              minHeight: 300,
              padding: const EdgeInsets.fromLTRB(
                CairnSpacing.s6,
                CairnSpacing.s8,
                CairnSpacing.s6,
                CairnSpacing.s6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChartSpec {
  const _ChartSpec({
    required this.name,
    required this.description,
    required this.builder,
    required this.code,
  });

  final String name;
  final String description;
  final WidgetBuilder builder;
  final String code;
}

/// The honest explanation of what is and is not part of the library.
class _DecisionPanel extends StatelessWidget {
  const _DecisionPanel();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= 900;

    final Widget copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SiteIcon(SiteIconData.barChart, size: 18, color: theme.foreground),
            const SizedBox(width: CairnSpacing.s3),
            Expanded(
              child: Text(
                'Cairn does not ship a chart component',
                style: theme
                    .textStyle(CairnTypography.base)
                    .copyWith(
                      color: theme.foreground,
                      fontWeight: CairnTypography.semibold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: CairnSpacing.s4),
        Text(
          'Charting is a large problem in its own right — axes, ticks, curve '
          'interpolation, hit-testing, tooltips, animation — and Flutter '
          'already has a mature package that solves it. What a design system '
          'usefully adds on top is not a second implementation of all that; it '
          'is a consistent skin. So these charts are fl_chart, dressed in '
          'Cairn\'s tokens by a small adapter in this site\'s own source.',
          style: theme
              .textStyle(CairnTypography.sm)
              .copyWith(
                color: theme.mutedForeground,
                height: CairnTypography.leadingRelaxed,
              ),
        ),
        const SizedBox(height: CairnSpacing.s4),
        Text(
          'Adding chart widgets to the package itself was considered and '
          'rejected. cairn_ui\'s contract is "no runtime dependencies beyond '
          'Flutter", so a chart family would have to be hand-painted from '
          'scratch. Every component there is also pinned by a golden sheet '
          'generated on Linux CI, and charts are far larger and far more '
          'data-dependent than any control in the catalogue — a maintenance '
          'cost the library would carry forever, for something an existing '
          'package already does well.',
          style: theme
              .textStyle(CairnTypography.sm)
              .copyWith(
                color: theme.mutedForeground,
                height: CairnTypography.leadingRelaxed,
              ),
        ),
        const SizedBox(height: CairnSpacing.s4),
        Text(
          'What the library does already ship is the palette. CairnColors.chart1 '
          'through chart5 are defined as --chart-N OKLCH values alongside the '
          'other tokens, and in the Neutral base they are achromatic — #D4D4D4 '
          'down to #262626. That is why these charts are monochrome rather '
          'than reaching for colours the design system does not define.',
          style: theme
              .textStyle(CairnTypography.sm)
              .copyWith(
                color: theme.mutedForeground,
                height: CairnTypography.leadingRelaxed,
              ),
        ),
        const SizedBox(height: CairnSpacing.s5),
        Wrap(
          spacing: CairnSpacing.s2,
          runSpacing: CairnSpacing.s2,
          children: <Widget>[
            CairnButton(
              variant: CairnButtonVariant.outline,
              size: CairnButtonSize.sm,
              onPressed: () => openExternal(SiteLinks.flChart),
              trailing: const SiteIcon(SiteIconData.externalLink, size: 13),
              child: const Text('fl_chart on pub.dev'),
            ),
            const CairnBadge(
              variant: CairnBadgeVariant.secondary,
              label: Text('site-only dependency'),
            ),
          ],
        ),
      ],
    );

    const Widget snippet = CodeBlock(
      '''
// lib/src/charts/chart_theme.dart — the whole adapter, in essence.
abstract final class ChartTheme {
  static List<Color> series(CairnTheme theme) =>
      theme.brightness == Brightness.dark
          ? const <Color>[
              CairnColors.chart1, CairnColors.chart2, CairnColors.chart3,
              CairnColors.chart4, CairnColors.chart5,
            ]
          : const <Color>[
              CairnColors.chart5, CairnColors.chart4, CairnColors.chart3,
              CairnColors.chart2, CairnColors.chart1,
            ];

  static FlGridData grid(CairnTheme theme, {double? interval}) => FlGridData(
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (double v) =>
            FlLine(color: theme.hairline, strokeWidth: 1),
      );

  static TextStyle axisLabel(CairnTheme theme) => theme
      .textStyle(CairnTypography.xs)
      .copyWith(color: theme.mutedForeground);
}''',
      filename: 'chart_theme.dart',
      maxHeight: 380,
    );

    return Container(
      padding: const EdgeInsets.all(CairnSpacing.s6),
      decoration: BoxDecoration(
        color: theme.subtleSurface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 5, child: copy),
                const SizedBox(width: CairnSpacing.s8),
                const Expanded(flex: 4, child: snippet),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                copy,
                const SizedBox(height: CairnSpacing.s6),
                snippet,
              ],
            ),
    );
  }
}
