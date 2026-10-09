import 'package:cairn_ui/cairn_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/chart_scale.dart';
import '../../../common/utils/format.dart';
import '../../../core/presentation/charts/chart_theme.dart';
import '../../../core/presentation/widgets/legend_row.dart';
import '../../../domain/overview/models/revenue_point.dart';

/// Revenue as an area, with the previous period as a dashed line.
class RevenueChart extends StatelessWidget {
  /// Creates the chart.
  const RevenueChart({super.key, required this.points, this.height = 260});

  /// The data.
  final List<RevenuePoint> points;

  /// Chart height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color color = ChartTheme.seriesColor(theme, 0);
    final Color previous = ChartTheme.seriesColor(theme, 2);
    final double maxY = niceCeil(
      points.fold(
        0,
        (double m, RevenuePoint p) => [
          m,
          p.current,
          p.previous,
        ].reduce((double a, double b) => a > b ? a : b),
      ),
    );
    final List<String> labels = <String>[
      for (final RevenuePoint p in points) p.label,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              gridData: ChartTheme.grid(theme, interval: maxY / 4),
              borderData: ChartTheme.border,
              titlesData: FlTitlesData(
                topTitles: ChartTheme.hidden,
                rightTitles: ChartTheme.hidden,
                bottomTitles: ChartTheme.categoryAxis(theme, labels),
                leftTitles: ChartTheme.valueAxis(
                  theme,
                  interval: maxY / 4,
                  format: (double v) => DashboardFormat.compact(v),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: ChartTheme.lineTooltip(
                  theme,
                  label: (LineBarSpot spot) =>
                      '${spot.barIndex == 0 ? 'This period' : 'Previous'}  '
                      '${DashboardFormat.currency(spot.y)}',
                ),
              ),
              lineBarsData: <LineChartBarData>[
                LineChartBarData(
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
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
                    for (int i = 0; i < points.length; i++)
                      FlSpot(i.toDouble(), points[i].current),
                  ],
                ),
                LineChartBarData(
                  isCurved: true,
                  color: previous,
                  barWidth: 2,
                  dashArray: const <int>[6, 4],
                  dotData: const FlDotData(show: false),
                  spots: <FlSpot>[
                    for (int i = 0; i < points.length; i++)
                      FlSpot(i.toDouble(), points[i].previous),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: CairnSpacing.s4),
        Wrap(
          spacing: CairnSpacing.s5,
          children: <Widget>[
            LegendRow(color: color, label: 'This period'),
            LegendRow(color: previous, label: 'Previous period'),
          ],
        ),
      ],
    );
  }
}
