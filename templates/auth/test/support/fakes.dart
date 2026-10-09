import 'dart:async';

/// A clock the test moves by hand.
class FakeClock {
  FakeClock([DateTime? start]) : _now = start ?? DateTime.utc(2026, 1, 1, 9);

  DateTime _now;

  /// The current fake time. Pass the tear-off, `clock.call`, as a `Clock`.
  DateTime call() => _now;

  /// Moves time forward.
  void advance(Duration by) => _now = _now.add(by);
}

/// A ticker whose timers fire only when the test says so.
///
/// Hand [call] to anything that takes a `TickerFactory`, then call [tick] to
/// run one period of every timer that has not been cancelled. Nothing waits.
class FakeTicker {
  final List<FakeTimer> timers = <FakeTimer>[];

  /// The `TickerFactory` entry point.
  Timer call(Duration period, void Function(Timer timer) onTick) {
    final FakeTimer timer = FakeTimer(onTick);
    timers.add(timer);
    return timer;
  }

  /// Timers that are still running.
  int get active => timers.where((FakeTimer t) => t.isActive).length;

  /// Fires every active timer [times] times.
  void tick([int times = 1]) {
    for (int i = 0; i < times; i++) {
      for (final FakeTimer t in List<FakeTimer>.of(timers)) {
        if (t.isActive) t.fire();
      }
    }
  }
}

/// A [Timer] that never fires by itself.
class FakeTimer implements Timer {
  FakeTimer(this._onTick);

  final void Function(Timer timer) _onTick;
  bool _active = true;
  int _ticks = 0;

  void fire() {
    _ticks++;
    _onTick(this);
  }

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => _ticks;
}
