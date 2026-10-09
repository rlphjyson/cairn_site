import 'package:cairn_ui/cairn_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/format.dart';
import '../../../core/presentation/charts/chart_theme.dart';
import '../../../core/presentation/dashboard_text.dart';
import '../../../domain/analytics/models/conversion_rate.dart';

/// The conversion rate as a radial gauge against its target.
class ConversionGauge extends StatelessWidget {
  /// Creates the gauge.
  const ConversionGauge({super.key, required this.conversion});

  /// The figure.
  final ConversionRate conversion;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final double progress = conversion.progress;
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          PieChart(
            PieChartData(
              centerSpaceRadius: 62,
              sectionsSpace: 0,
              startDegreeOffset: -90,
              sections: <PieChartSectionData>[
                PieChartSectionData(
                  value: progress * 100,
                  color: ChartTheme.seriesColor(theme, 0),
                  radius: 16,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: (1 - progress) * 100,
                  color: theme.primary.withValues(alpha: 0.2),
                  radius: 16,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                DashboardFormat.percent(conversion.rate),
                style: dashText(
                  theme,
                  theme.textStyle(CairnTypography.xl2),
                  weight: CairnTypography.semibold,
                ),
              ),
              Text(
                'of ${DashboardFormat.percent(conversion.target)} target',
                style: dashText(
                  theme,
                  theme.textStyle(CairnTypography.xs),
                  color: theme.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
