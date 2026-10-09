/// Failures are values, not exceptions: use cases return a [Result] so the
/// presentation layer must decide what to do about an error.
library;

import 'package:meta/meta.dart';

@immutable
class Failure {
  const Failure(this.code, this.message, {this.fieldErrors = const {}});

  /// Stable, machine-readable code, e.g. `out_of_stock`.
  final String code;

  /// Safe-to-display copy. Never contains user input verbatim.
  final String message;

  /// Per-field messages for forms, keyed by field name.
  final Map<String, String> fieldErrors;

  @override
  String toString() => 'Failure($code: $message)';
}

sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };
  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };

  R fold<R>(R Function(T value) ok, R Function(Failure failure) err) => switch (this) {
    Ok<T>(:final value) => ok(value),
    Err<T>(:final failure) => err(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
