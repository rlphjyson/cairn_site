import '../models/onboarding_progress.dart';
import '../repositories/progress_repository.dart';

/// Saves the user's progress.
class SaveProgress {
  /// Creates the use case.
  const SaveProgress(this._repository);

  final ProgressRepository _repository;

  /// Runs it. A storage failure is swallowed: losing the ability to resume
  /// must never stop the user from finishing.
  Future<void> call(OnboardingProgress progress) async {
    try {
      await _repository.write(progress);
    } on Object {
      return;
    }
  }
}
