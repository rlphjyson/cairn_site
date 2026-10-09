import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/error_panel.dart';
import '../../../domain/filters/models/period.dart';
import '../../filters/bloc/period_cubit.dart';
import '../bloc/overview_cubit.dart';
import '../view_models/overview_view_model.dart';
import '../widgets/kpi_card.dart';
import '../widgets/recent_orders.dart';
import '../widgets/revenue_chart.dart';

/// The landing page: KPIs, revenue over time and the newest orders.
class OverviewView extends StatelessWidget {
  /// Creates the view.
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OverviewViewModel>(
      onCreate: (BuildContext context, OverviewViewModel vm) =>
          vm.cubit.load(context.read<PeriodCubit>().state),
      builder: (BuildContext context, OverviewViewModel vm) =>
          // The period lives in a session cubit; when it changes, this screen's
          // own cubit reloads.
          BlocListener<PeriodCubit, Period>(
            listener: (BuildContext context, Period period) =>
                vm.cubit.load(period),
            child: BlocBuilder<OverviewCubit, OverviewState>(
              bloc: vm.cubit,
              builder: (BuildContext context, OverviewState state) {
                if (state.loading) {
                  return const Center(child: CairnSpinner());
                }
                if (state.failed && state.kpis.isEmpty) {
                  return ErrorPanel(
                    onRetry: () =>
                        vm.cubit.load(context.read<PeriodCubit>().state),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: <Widget>[
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints box) {
                        const double gap = 16;
                        final int columns = box.maxWidth >= 860
                            ? 4
                            : box.maxWidth >= 520
                            ? 2
                            : 1;
                        final double width =
                            (box.maxWidth - gap * (columns - 1)) / columns;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: <Widget>[
                            for (final kpi in state.kpis)
                              SizedBox(
                                width: width,
                                child: KpiCard(kpi: kpi),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints box) {
                        final Widget revenue = CairnCard(
                          children: <Widget>[
                            const CairnCardHeader(
                              title: Text('Revenue'),
                              description: Text(
                                'Compared with the previous period',
                              ),
                            ),
                            CairnCardContent(
                              child: RevenueChart(points: state.revenue),
                            ),
                          ],
                        );
                        final Widget recent = CairnCard(
                          children: <Widget>[
                            const CairnCardHeader(
                              title: Text('Recent orders'),
                              description: Text('The latest five'),
                            ),
                            CairnCardContent(
                              child: RecentOrders(orders: state.recent),
                            ),
                          ],
                        );
                        if (box.maxWidth < 860) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 16,
                            children: <Widget>[revenue, recent],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: <Widget>[
                            Expanded(flex: 3, child: revenue),
                            Expanded(flex: 2, child: recent),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }
}
