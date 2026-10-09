library;

import '../../core/result.dart';
import '../checkout/use_cases/validate_checkout.dart';

abstract interface class NewsletterRepository {
  /// Returns `true` when the address was newly added, `false` if it already existed.
  Future<bool> subscribe(String email);
}

class SubscribeToNewsletter {
  const SubscribeToNewsletter(this._repository);
  final NewsletterRepository _repository;

  Future<Result<bool>> call(String rawEmail) async {
    final email = rawEmail.trim().toLowerCase();
    if (email.isEmpty) {
      return const Result.err(
        Failure('invalid_email', 'Enter your email address.', fieldErrors: {'email': 'Enter your email address.'}),
      );
    }
    if (!isValidEmail(email)) {
      return const Result.err(
        Failure(
          'invalid_email',
          'Enter a valid email address.',
          fieldErrors: {'email': 'Enter a valid email address, like name@example.com.'},
        ),
      );
    }
    return Result.ok(await _repository.subscribe(email));
  }
}
