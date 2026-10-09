import '../models/subscribe_result.dart';
import '../repositories/newsletter_repository.dart';
import 'validate_email.dart';

/// Validates an address and subscribes it.
class SubscribeToNewsletter {
  /// Creates the use case.
  const SubscribeToNewsletter(this._repository, this._validate);

  final NewsletterRepository _repository;
  final ValidateEmail _validate;

  /// Runs it. Throws [InvalidEmailException] before any request is made if
  /// [email] is not valid, or a [NewsletterException] if the service fails.
  Future<SubscribeResult> call(String email) {
    final String? problem = _validate(email);
    if (problem != null) throw InvalidEmailException(problem);
    return _repository.subscribe(email.trim());
  }
}
