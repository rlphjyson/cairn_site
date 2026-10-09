import '../models/join_outcome.dart';
import '../repositories/waitlist_repository.dart';
import 'validate_email.dart';

/// Validates an email and, if it passes, adds it to the waitlist.
class JoinWaitlist {
  /// Creates the use case.
  const JoinWaitlist(this._validate, this._repository);

  final ValidateEmail _validate;
  final WaitlistRepository _repository;

  /// Runs the use case. Never throws.
  Future<JoinOutcome> call(String email) async {
    final String? problem = _validate(email);
    if (problem != null) return JoinOutcome.invalid(problem);
    try {
      return JoinOutcome.joined(await _repository.join(email.trim()));
    } on WaitlistException catch (e) {
      return JoinOutcome.failed(e.message);
    } on Object {
      return const JoinOutcome.failed(
        'Something went wrong. Please try again in a moment.',
      );
    }
  }
}
