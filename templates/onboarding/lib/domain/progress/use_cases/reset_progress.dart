import '../repositories/progress_repository.dart';

/// Forgets the user's progress, so the flow starts over (the demo's replay).
class ResetProgress {
  /// Creates the use case.
  const ResetProgress(this._repository);

  final ProgressRepository _repository;

  /// Runs it.
  Future<void> call() async {
    try {
      await _repository.clear();
    } on Object {
      return;
    }
  }
}
