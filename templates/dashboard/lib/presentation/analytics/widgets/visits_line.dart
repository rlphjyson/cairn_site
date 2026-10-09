import 'package:cairn_ui/cairn_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/chart_scale.dart';
import '../../../common/utils/format.dart';
import '../../../core/presentation/charts/chart_theme.dart';
import '../../../core/presentation/widgets/legend_row.dart';
import '../../../domain/analytics/models/visits_point.dart';

/// All visitors against returning visitors, as two lines.
class VisitsLine extends StatelessWidget {
  /// Creates the chart.
  const VisitsLine({super.key, required this.points});

  /// The data.
  final List<VisitsPoint> points;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color primary = ChartTheme.seriesColor(theme, 0);
    final Color secondary = ChartTheme.seriesColor(theme, 2);
    final double maxY = niceCeil(
      points.fold(
        0,
        (double m, VisitsPoint p) => p.visitors > m ? p.visitors : m,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 196,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              gridData: ChartTheme.grid(theme, interval: maxY / 4),
              borderData: ChartTheme.border,
              titlesData: FlTitlesData(
                topTitles: ChartTheme.hidden,
                rightTitles: ChartTheme.hidden,
                bottomTitles: ChartTheme.categoryAxis(theme, <String>[
                  for (final VisitsPoint p in points) p.label,
                ]),
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
                      '${spot.barIndex == 0 ? 'Visitors' : 'Returning'}  '
                      '${DashboardFormat.number(spot.y)}',
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
                    for (int i = 0; i < points.length; i++)
                      FlSpot(i.toDouble(), points[i].visitors),
                  ],
                ),
                LineChartBarData(
                  isCurved: true,
                  color: secondary,
                  barWidth: 2,
                  dashArray: const <int>[6, 4],
                  dotData: ChartTheme.dots(theme, secondary),
                  spots: <FlSpot>[
                    for (int i = 0; i < points.length; i++)
                      FlSpot(i.toDouble(), points[i].returning),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: CairnSpacing.s3),
        Wrap(
          spacing: CairnSpacing.s5,
          children: <Widget>[
            LegendRow(color: primary, label: 'Visitors'),
            LegendRow(color: secondary, label: 'Returning'),
          ],
        ),
      ],
    );
  }
}
