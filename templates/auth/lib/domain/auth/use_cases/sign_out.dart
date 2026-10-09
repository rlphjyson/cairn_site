import '../repositories/auth_repository.dart';

/// Ends the session.
class SignOut {
  /// Creates the use case.
  const SignOut(this._repository);

  final AuthRepository _repository;

  /// Runs it. A server that cannot be reached must not trap someone in a
  /// signed-in screen, so failures are swallowed: the caller clears its own
  /// session regardless, and the server's token expires on its own.
  Future<void> call() async {
    try {
      await _repository.signOut();
    } on Object {
      // Intentionally ignored; see above.
    }
  }
}
