import '../models/account.dart';
import '../repositories/profile_repository.dart';

/// Loads the signed-in account.
class GetAccount {
  /// Creates the use case.
  const GetAccount(this._repository);

  final ProfileRepository _repository;

  /// Runs it.
  Future<Account> call() => _repository.getAccount();
}
