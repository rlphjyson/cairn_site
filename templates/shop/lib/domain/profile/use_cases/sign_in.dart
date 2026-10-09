import '../models/account.dart';
import '../repositories/profile_repository.dart';

/// Signs the demo shopper in.
class SignIn {
  /// Creates the use case.
  const SignIn(this._repository);

  final ProfileRepository _repository;

  /// Runs it.
  Future<Account> call() => _repository.signIn();
}
