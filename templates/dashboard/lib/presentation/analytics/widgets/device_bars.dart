import 'package:cairn_ui/cairn_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/chart_scale.dart';
import '../../../common/utils/format.dart';
import '../../../core/presentation/charts/chart_theme.dart';
import '../../../domain/analytics/models/device_usage.dart';

/// Sessions by device as rounded bars.
class DeviceBars extends StatelessWidget {
  /// Creates the chart.
  const DeviceBars({super.key, required this.devices});

  /// The data.
  final List<DeviceUsage> devices;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final double maxY = niceCeil(
      devices.fold(
        0,
        (double m, DeviceUsage d) => d.sessions > m ? d.sessions.toDouble() : m,
      ),
    );
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: ChartTheme.grid(theme, interval: maxY / 4),
          borderData: ChartTheme.border,
          titlesData: FlTitlesData(
            topTitles: ChartTheme.hidden,
            rightTitles: ChartTheme.hidden,
            bottomTitles: ChartTheme.categoryAxis(theme, <String>[
              for (final DeviceUsage d in devices) d.label,
            ]),
            leftTitles: ChartTheme.valueAxis(
              theme,
              interval: maxY / 4,
              format: (double v) => DashboardFormat.compact(v),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: ChartTheme.barTooltip(
              theme,
              label: (BarChartGroupData group, BarChartRodData rod) =>
                  '${devices[group.x].label}  '
                  '${DashboardFormat.number(rod.toY)}',
            ),
          ),
          barGroups: <BarChartGroupData>[
            for (int i = 0; i < devices.length; i++)
              BarChartGroupData(
                x: i,
                barRods: <BarChartRodData>[
                  BarChartRodData(
                    toY: devices[i].sessions.toDouble(),
                    color: ChartTheme.seriesColor(theme, 0),
                    width: 28,
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
}
