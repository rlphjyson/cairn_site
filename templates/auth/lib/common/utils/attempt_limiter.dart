import 'clock.dart';

/// Counts failures per key and locks the key after too many.
///
/// Pure and clock-driven, so it is unit tested without waiting. The in-memory
/// server uses it for the sign-in lockout and the verification-code limit; a
/// real backend does the same job with a shared store such as Redis, keyed by
/// account *and* by IP address.
class AttemptLimiter {
  /// Creates a limiter that locks a key for [lockout] after [maxAttempts]
  /// failures.
  AttemptLimiter({
    required this.maxAttempts,
    required this.lockout,
    this._clock = systemClock,
  });

  /// Failures that trigger the lock.
  final int maxAttempts;

  /// How long a lock lasts.
  final Duration lockout;

  final Clock _clock;
  final Map<String, int> _failures = <String, int>{};
  final Map<String, DateTime> _lockedUntil = <String, DateTime>{};

  /// How much longer [key] is locked, or `null` when it is not.
  Duration? lockedFor(String key) {
    final DateTime? until = _lockedUntil[key];
    if (until == null) return null;
    final Duration left = until.difference(_clock());
    if (left <= Duration.zero) {
      _lockedUntil.remove(key);
      _failures.remove(key);
      return null;
    }
    return left;
  }

  /// Failures [key] may still make before it is locked.
  int attemptsLeft(String key) => maxAttempts - (_failures[key] ?? 0);

  /// Records a failure for [key].
  ///
  /// Returns the lock duration when this failure triggers (or lands during) a
  /// lock, and `null` while attempts remain.
  Duration? recordFailure(String key) {
    final Duration? locked = lockedFor(key);
    if (locked != null) return locked;
    final int count = (_failures[key] ?? 0) + 1;
    if (count >= maxAttempts) {
      _failures.remove(key);
      _lockedUntil[key] = _clock().add(lockout);
      return lockout;
    }
    _failures[key] = count;
    return null;
  }

  /// Forgets [key]: a success, or a fresh start.
  void reset(String key) {
    _failures.remove(key);
    _lockedUntil.remove(key);
  }
}
