import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/error_panel.dart';
import '../../../domain/filters/models/period.dart';
import '../../filters/bloc/period_cubit.dart';
import '../bloc/analytics_cubit.dart';
import '../view_models/analytics_view_model.dart';
import '../widgets/conversion_gauge.dart';
import '../widgets/device_bars.dart';
import '../widgets/traffic_donut.dart';
import '../widgets/visits_line.dart';

/// Traffic sources, devices, visitors and conversion.
class AnalyticsView extends StatelessWidget {
  /// Creates the view.
  const AnalyticsView({super.key});

  Widget _card(String title, String description, Widget child) => CairnCard(
    children: <Widget>[
      CairnCardHeader(title: Text(title), description: Text(description)),
      CairnCardContent(child: child),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AnalyticsViewModel>(
      onCreate: (BuildContext context, AnalyticsViewModel vm) =>
          vm.cubit.load(context.read<PeriodCubit>().state),
      builder: (BuildContext context, AnalyticsViewModel vm) =>
          BlocListener<PeriodCubit, Period>(
            listener: (BuildContext context, Period period) =>
                vm.cubit.load(period),
            child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
              bloc: vm.cubit,
              builder: (BuildContext context, AnalyticsState state) {
                final conversion = state.conversion;
                if (state.failed && conversion == null) {
                  return ErrorPanel(
                    onRetry: () =>
                        vm.cubit.load(context.read<PeriodCubit>().state),
                  );
                }
                if (state.loading || conversion == null) {
                  return const Center(child: CairnSpinner());
                }
                final List<Widget> cards = <Widget>[
                  _card(
                    'Traffic sources',
                    'Where sessions come from',
                    TrafficDonut(sources: state.traffic),
                  ),
                  _card(
                    'Devices',
                    'Sessions by device',
                    DeviceBars(devices: state.devices),
                  ),
                  _card(
                    'Visitors',
                    'All visitors and those who came back',
                    VisitsLine(points: state.visits),
                  ),
                  _card(
                    'Conversion',
                    'Against the quarterly target',
                    ConversionGauge(conversion: conversion),
                  ),
                ];
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: <Widget>[
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints box) {
                        const double gap = 16;
                        final int columns = box.maxWidth >= 760 ? 2 : 1;
                        final double width =
                            (box.maxWidth - gap * (columns - 1)) / columns;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: <Widget>[
                            for (final Widget c in cards)
                              SizedBox(width: width, child: c),
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
