import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/analytics/models/conversion_rate.dart';
import '../../../domain/analytics/models/device_usage.dart';
import '../../../domain/analytics/models/traffic_source.dart';
import '../../../domain/analytics/models/visits_point.dart';
import '../../../domain/analytics/use_cases/get_conversion_rate.dart';
import '../../../domain/analytics/use_cases/get_device_breakdown.dart';
import '../../../domain/analytics/use_cases/get_traffic_sources.dart';
import '../../../domain/analytics/use_cases/get_visits_series.dart';
import '../../../domain/filters/models/period.dart';

/// What the analytics page is showing.
class AnalyticsState extends Equatable {
  /// Creates a state.
  const AnalyticsState({
    this.loading = true,
    this.traffic = const <TrafficSource>[],
    this.devices = const <DeviceUsage>[],
    this.visits = const <VisitsPoint>[],
    this.conversion,
    this.failed = false,
  });

  /// Whether the first load is still running.
  final bool loading;

  /// Share of sessions by channel.
  final List<TrafficSource> traffic;

  /// Sessions by device.
  final List<DeviceUsage> devices;

  /// Visitors over time.
  final List<VisitsPoint> visits;

  /// Conversion rate against target.
  final ConversionRate? conversion;

  /// Whether the last load failed.
  final bool failed;

  @override
  List<Object?> get props => <Object?>[
    loading,
    traffic,
    devices,
    visits,
    conversion,
    failed,
  ];
}

/// State for the analytics page. Scoped to one visit; its view model closes it.
class AnalyticsCubit extends Cubit<AnalyticsState> {
  /// Creates the cubit.
  AnalyticsCubit(
    this._getTraffic,
    this._getDevices,
    this._getVisits,
    this._getConversion,
  ) : super(const AnalyticsState());

  final GetTrafficSources _getTraffic;
  final GetDeviceBreakdown _getDevices;
  final GetVisitsSeries _getVisits;
  final GetConversionRate _getConversion;

  /// Loads everything for [period].
  Future<void> load(Period period) async {
    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        _getTraffic(period),
        _getDevices(period),
        _getVisits(period),
        _getConversion(period),
      ]);
      if (isClosed) return;
      emit(
        AnalyticsState(
          loading: false,
          traffic: results[0] as List<TrafficSource>,
          devices: results[1] as List<DeviceUsage>,
          visits: results[2] as List<VisitsPoint>,
          conversion: results[3] as ConversionRate,
        ),
      );
    } on Object {
      if (isClosed) return;
      emit(
        AnalyticsState(
          loading: false,
          traffic: state.traffic,
          devices: state.devices,
          visits: state.visits,
          conversion: state.conversion,
          failed: true,
        ),
      );
    }
  }
}
