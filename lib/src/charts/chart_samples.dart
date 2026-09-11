import 'package:cairn_ui/cairn_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app/site_theme.dart';
import 'chart_theme.dart';

/// The charts shown on the Charts page.
///
/// Every colour, radius, grid line, tooltip surface and text style in here is
/// resolved from [CairnTheme] through [ChartTheme]. fl_chart supplies geometry,
/// hit-testing and animation; Cairn supplies the design.
abstract final class ChartSamples {
  /// Month labels shared by the time-series charts.
  static const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
  ];

  static const List<double> _visitors = <double>[186, 305, 237, 273, 209, 264];
  static const List<double> _returning = <double>[80, 200, 120, 190, 130, 140];

  /// A filled single-series trend.
  static Widget area(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color color = ChartTheme.seriesColor(theme, 0);
    return _Frame(
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 360,
          gridData: ChartTheme.grid(theme, interval: 120),
          borderData: ChartTheme.border,
          titlesData: FlTitlesData(
            topTitles: ChartTheme.hidden,
            rightTitles: ChartTheme.hidden,
            bottomTitles: ChartTheme.categoryAxis(theme, months),
            leftTitles: ChartTheme.valueAxis(
              theme,
              interval: 120,
              format: (double v) => v.toInt().toString(),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: ChartTheme.lineTooltip(
              theme,
              label: (LineBarSpot spot) =>
                  '${months[spot.x.toInt()]}  ${spot.y.toInt()} visitors',
            ),
          ),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              isCurved: true,
              curveSmoothness: 0.28,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: ChartTheme.dots(theme, color),
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
              spots: <FlSpot>[
                for (int i = 0; i < _visitors.length; i++)
                  FlSpot(i.toDouble(), _visitors[i]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Two grouped series with rounded caps.
  static Widget bar(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color primary = ChartTheme.seriesColor(theme, 0);
    final Color secondary = ChartTheme.seriesColor(theme, 2);

    return _Frame(
      child: BarChart(
        BarChartData(
          maxY: 360,
          alignment: BarChartAlignment.spaceAround,
          gridData: ChartTheme.grid(theme, interval: 120),
          borderData: ChartTheme.border,
          titlesData: FlTitlesData(
            topTitles: ChartTheme.hidden,
            rightTitles: ChartTheme.hidden,
            bottomTitles: ChartTheme.categoryAxis(theme, months),
            leftTitles: ChartTheme.valueAxis(
              theme,
              interval: 120,
              format: (double v) => v.toInt().toString(),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: ChartTheme.barTooltip(
              theme,
              label: (BarChartGroupData group, BarChartRodData rod) =>
                  '${months[group.x]}  ${rod.toY.toInt()}',
            ),
          ),
          barGroups: <BarChartGroupData>[
            for (int i = 0; i < months.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: <BarChartRodData>[
                  BarChartRodData(
                    toY: _visitors[i],
                    color: primary,
                    width: 12,
                    // rounded-sm, re-derived from the active --radius.
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(theme.radiusScale.sm),
                    ),
                  ),
                  BarChartRodData(
                    toY: _returning[i],
                    color: secondary,
                    width: 12,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(theme.radiusScale.sm),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Two series, one emphasised with dots.
  static Widget line(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color primary = ChartTheme.seriesColor(theme, 0);
    final Color secondary = ChartTheme.seriesColor(theme, 2);

    return _Frame(
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 360,
          gridData: ChartTheme.grid(theme, interval: 120),
          borderData: ChartTheme.border,
          titlesData: FlTitlesData(
            topTitles: ChartTheme.hidden,
            rightTitles: ChartTheme.hidden,
            bottomTitles: ChartTheme.categoryAxis(theme, months),
            leftTitles: ChartTheme.valueAxis(
              theme,
              interval: 120,
              format: (double v) => v.toInt().toString(),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: ChartTheme.lineTooltip(
              theme,
              label: (LineBarSpot spot) => '${spot.y.toInt()}',
            ),
          ),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              isCurved: true,
              color: primary,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: ChartTheme.dots(theme, primary, show: true),
              spots: <FlSpot>[
                for (int i = 0; i < _visitors.length; i++)
                  FlSpot(i.toDouble(), _visitors[i]),
              ],
            ),
            LineChartBarData(
              isCurved: true,
              color: secondary,
              barWidth: 2,
              dashArray: const <int>[6, 4],
              dotData: ChartTheme.dots(theme, secondary),
              spots: <FlSpot>[
                for (int i = 0; i < _returning.length; i++)
                  FlSpot(i.toDouble(), _returning[i]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A donut with a centre readout.
  static Widget pie(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    const List<(String, double)> slices = <(String, double)>[
      ('Flutter', 42),
      ('Web', 26),
      ('iOS', 17),
      ('Android', 9),
      ('Other', 6),
    ];

    return _Frame(
      height: 260,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 56,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    sections: <PieChartSectionData>[
                      for (int i = 0; i < slices.length; i++)
                        PieChartSectionData(
                          value: slices[i].$2,
                          color: ChartTheme.seriesColor(theme, i),
                          radius: 46,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '12,480',
                      style: theme
                          .textStyle(CairnTypography.xl2)
                          .copyWith(
                            color: theme.foreground,
                            fontWeight: CairnTypography.semibold,
                          ),
                    ),
                    Text(
                      'sessions',
                      style: theme
                          .textStyle(CairnTypography.xs)
                          .copyWith(color: theme.mutedForeground),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: CairnSpacing.s6),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s3,
            children: <Widget>[
              for (int i = 0; i < slices.length; i++)
                _LegendRow(
                  color: ChartTheme.seriesColor(theme, i),
                  label: slices[i].$1,
                  value: '${slices[i].$2.toInt()}%',
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// A radial gauge, built from the same donut primitive.
  static Widget radial(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    const double progress = 0.735;

    return _Frame(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          PieChart(
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
                  // The unfilled arc uses the same `primary at 20%` the
                  // Progress component paints its track with.
                  color: theme.primary.withValues(alpha: 0.2),
                  radius: 18,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${(progress * 100).round()}%',
                style: theme
                    .textStyle(CairnTypography.xl3)
                    .copyWith(
                      color: theme.foreground,
                      fontWeight: CairnTypography.semibold,
                      letterSpacing: CairnTypography.trackingTight(30),
                    ),
              ),
              Text(
                'of quarterly target',
                style: theme
                    .textStyle(CairnTypography.xs)
                    .copyWith(color: theme.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Two overlaid profiles on a polygon grid.
  static Widget radar(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color primary = ChartTheme.seriesColor(theme, 0);
    final Color secondary = ChartTheme.seriesColor(theme, 2);
    const List<String> axes = <String>[
      'Speed',
      'A11y',
      'Fidelity',
      'API',
      'Docs',
      'Tests',
    ];

    return _Frame(
      height: 300,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBackgroundColor: const Color(0x00000000),
          radarBorderData: BorderSide(color: theme.hairline),
          gridBorderData: BorderSide(color: theme.hairline),
          tickBorderData: const BorderSide(color: Color(0x00000000)),
          tickCount: 4,
          ticksTextStyle: const TextStyle(
            color: Color(0x00000000),
            fontSize: 1,
          ),
          titleTextStyle: ChartTheme.axisLabel(theme),
          getTitle: (int index, double angle) =>
              RadarChartTitle(text: axes[index]),
          dataSets: <RadarDataSet>[
            RadarDataSet(
              fillColor: primary.withValues(alpha: 0.22),
              borderColor: primary,
              borderWidth: 2,
              entryRadius: 2,
              dataEntries: const <RadarEntry>[
                RadarEntry(value: 9),
                RadarEntry(value: 8),
                RadarEntry(value: 10),
                RadarEntry(value: 7),
                RadarEntry(value: 8),
                RadarEntry(value: 9),
              ],
            ),
            RadarDataSet(
              fillColor: secondary.withValues(alpha: 0.18),
              borderColor: secondary,
              borderWidth: 2,
              entryRadius: 2,
              dataEntries: const <RadarEntry>[
                RadarEntry(value: 6),
                RadarEntry(value: 5),
                RadarEntry(value: 6),
                RadarEntry(value: 9),
                RadarEntry(value: 5),
                RadarEntry(value: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A bar chart whose only job is to show the themed tooltip.
  static Widget tooltip(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color color = ChartTheme.seriesColor(theme, 1);

    return _Frame(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: 360,
          alignment: BarChartAlignment.spaceAround,
          gridData: ChartTheme.grid(theme, interval: 120),
          borderData: ChartTheme.border,
          titlesData: FlTitlesData(
            topTitles: ChartTheme.hidden,
            rightTitles: ChartTheme.hidden,
            leftTitles: ChartTheme.hidden,
            bottomTitles: ChartTheme.categoryAxis(theme, months),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: ChartTheme.barTooltip(
              theme,
              label: (BarChartGroupData group, BarChartRodData rod) =>
                  '${months[group.x]}\n${rod.toY.toInt()} visitors',
            ),
          ),
          barGroups: <BarChartGroupData>[
            for (int i = 0; i < months.length; i++)
              BarChartGroupData(
                x: i,
                barRods: <BarChartRodData>[
                  BarChartRodData(
                    toY: _visitors[i],
                    color: color,
                    width: 22,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(theme.radiusScale.sm),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 360,
                      color: theme.muted,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child, this.height = 240});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(height: height, child: child);
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(theme.radiusScale.sm / 2),
          ),
        ),
        const SizedBox(width: CairnSpacing.s2p5),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(color: theme.mutedForeground),
          ),
        ),
        Text(
          value,
          style: theme
              .textStyle(CairnTypography.sm)
              .copyWith(
                color: theme.foreground,
                fontWeight: CairnTypography.medium,
              ),
        ),
      ],
    );
  }
}
