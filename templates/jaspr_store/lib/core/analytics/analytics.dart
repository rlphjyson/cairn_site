/// Pluggable analytics. The default is a no-op so the template makes no network
/// calls and sets no tracking cookies out of the box.
library;

abstract interface class AnalyticsService {
  void track(String event, {Map<String, Object?> properties});
}

class NoopAnalytics implements AnalyticsService {
  const NoopAnalytics();
  @override
  void track(String event, {Map<String, Object?> properties = const {}}) {}
}

class ConsoleAnalytics implements AnalyticsService {
  const ConsoleAnalytics(this.sink);
  final void Function(String message) sink;
  @override
  void track(String event, {Map<String, Object?> properties = const {}}) => sink('[analytics] $event $properties');
}

/// Collects events in memory. Used by tests to assert on what was tracked.
class RecordingAnalytics implements AnalyticsService {
  final List<({String event, Map<String, Object?> properties})> events = [];
  @override
  void track(String event, {Map<String, Object?> properties = const {}}) {
    events.add((event: event, properties: properties));
  }
}
