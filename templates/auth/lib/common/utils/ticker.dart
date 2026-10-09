import 'dart:async';

/// Starts a repeating timer.
///
/// Cubits that count down (the resend cooldown, the sign-in lockout) receive
/// one of these instead of calling `Timer.periodic` themselves, so a test can
/// hand in a fake that fires on demand and never waits a real second. The
/// cubit owns the returned [Timer] and cancels it when it closes.
typedef TickerFactory =
    Timer Function(Duration period, void Function(Timer timer) onTick);

/// The real ticker.
Timer periodicTicker(Duration period, void Function(Timer timer) onTick) =>
    Timer.periodic(period, onTick);
