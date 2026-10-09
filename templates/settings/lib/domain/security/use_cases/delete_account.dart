import '../../../common/constants/confirmation_phrases.dart';
import '../../../common/utils/settings_failure.dart';
import '../repositories/security_repository.dart';

/// Permanently deletes the account, but only after the person has typed the
/// confirmation word.
class DeleteAccount {
  /// Creates the use case.
  const DeleteAccount(this._repository);

  final SecurityRepository _repository;

  /// Whether [typed] is the confirmation word. Exact and case-sensitive, so the
  /// button cannot be pressed by accident or by autofill.
  static bool isConfirmed(String typed) =>
      typed.trim() == deleteConfirmationPhrase;

  /// Deletes the account. Throws a [SettingsFailure] when [typed] is wrong or
  /// the server refuses.
  Future<void> call(String typed) async {
    if (!isConfirmed(typed)) {
      throw const SettingsFailure('Type $deleteConfirmationPhrase to confirm.');
    }
    final result = await _repository.deleteAccount();
    if (!result.ok) {
      throw SettingsFailure(result.message ?? 'Could not delete the account.');
    }
  }
}

/// Hides the account but keeps its data.
class DeactivateAccount {
  /// Creates the use case.
  const DeactivateAccount(this._repository);

  final SecurityRepository _repository;

  /// Throws a [SettingsFailure] when the server refuses.
  Future<void> call() async {
    final result = await _repository.deactivateAccount();
    if (!result.ok) {
      throw SettingsFailure(result.message ?? 'Could not deactivate.');
    }
  }
}
