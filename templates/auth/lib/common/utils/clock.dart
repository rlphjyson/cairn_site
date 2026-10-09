/// Tells the time. Injected wherever time matters so tests can control it.
typedef Clock = DateTime Function();

/// The real clock.
DateTime systemClock() => DateTime.now();
