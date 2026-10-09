import '../repositories/profile_repository.dart';

/// Signs the shopper out.
class SignOut {
  /// Creates the use case.
  const SignOut(this._repository);

  final ProfileRepository _repository;

  /// Runs it.
  Future<void> call() => _repository.signOut();
}
