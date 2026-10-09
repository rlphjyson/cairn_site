import 'package:cairn_ui/cairn_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/format.dart';
import '../../../core/presentation/charts/chart_theme.dart';
import '../../../core/presentation/dashboard_text.dart';
import '../../../core/presentation/widgets/legend_row.dart';
import '../../../domain/analytics/models/traffic_source.dart';

/// Traffic sources as a donut with a legend.
///
/// Side by side when there is room; the legend drops below the donut in a
/// narrow card.
class TrafficDonut extends StatelessWidget {
  /// Creates the chart.
  const TrafficDonut({super.key, required this.sources});

  /// The data.
  final List<TrafficSource> sources;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TrafficSource top = sources.first;

    final Widget donut = SizedBox(
      height: 196,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          PieChart(
            PieChartData(
              centerSpaceRadius: 54,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              sections: <PieChartSectionData>[
                for (int i = 0; i < sources.length; i++)
                  PieChartSectionData(
                    value: sources[i].share,
                    color: ChartTheme.seriesColor(theme, i),
                    radius: 44,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          // Sized to the hole, so the readout never spills over the ring.
          SizedBox(
            width: 92,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    DashboardFormat.percent(top.share, decimals: 0),
                    style: dashText(
                      theme,
                      theme.textStyle(CairnTypography.xl2),
                      weight: CairnTypography.semibold,
                    ),
                  ),
                  Text(
                    top.label,
                    style: dashText(
                      theme,
                      theme.textStyle(CairnTypography.xs),
                      color: theme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final Widget legend = Wrap(
      spacing: CairnSpacing.s5,
      runSpacing: CairnSpacing.s3,
      children: <Widget>[
        for (int i = 0; i < sources.length; i++)
          LegendRow(
            color: ChartTheme.seriesColor(theme, i),
            label: sources[i].label,
            value: DashboardFormat.percent(sources[i].share, decimals: 0),
            labelWidth: 64,
          ),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        if (box.maxWidth < 380) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: CairnSpacing.s4,
            children: <Widget>[donut, legend],
          );
        }
        return Row(
          children: <Widget>[
            Expanded(child: donut),
            const SizedBox(width: CairnSpacing.s4),
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: CairnSpacing.s3,
                children: <Widget>[
                  for (int i = 0; i < sources.length; i++)
                    LegendRow(
                      color: ChartTheme.seriesColor(theme, i),
                      label: sources[i].label,
                      value: DashboardFormat.percent(
                        sources[i].share,
                        decimals: 0,
                      ),
                      labelWidth: 64,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
