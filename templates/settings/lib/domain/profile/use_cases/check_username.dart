import '../models/profile_validation.dart';
import '../repositories/profile_repository.dart';
import 'validate_profile.dart';

/// Checks a username's format, then asks whether it is free.
///
/// There is no debounce: the caller runs it on every change and ignores any
/// answer that is not for the latest text. The format check is synchronous, so
/// a malformed name never reaches the network.
class CheckUsername {
  /// Creates the use case.
  const CheckUsername(this._repository);

  final ProfileRepository _repository;

  /// The result for [username]. [current] is the person's saved username, which
  /// is always available to them.
  Future<UsernameCheck> call(String username, {String? current}) async {
    final String u = username.trim();
    if (u.isEmpty) return const UsernameCheck(UsernameStatus.unknown);
    final String? problem = ValidateProfile.usernameProblem(u);
    if (problem != null) return UsernameCheck(UsernameStatus.invalid, problem);
    if (u == current) {
      return const UsernameCheck(UsernameStatus.available, 'This is you.');
    }
    final bool free = await _repository.isUsernameAvailable(u);
    return free
        ? UsernameCheck(UsernameStatus.available, '@$u is available.')
        : UsernameCheck(UsernameStatus.taken, '@$u is taken.');
  }
}
