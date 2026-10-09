/// Where a form is in its life.
enum FormStatus {
  /// Nothing sent yet, or the last attempt was dismissed.
  idle,

  /// A request is in flight.
  submitting,

  /// The request succeeded.
  success,

  /// The request failed; see the state's failure.
  failure,
}
