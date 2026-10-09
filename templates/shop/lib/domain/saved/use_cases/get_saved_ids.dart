import '../repositories/saved_repository.dart';

/// Loads the saved product ids.
class GetSavedIds {
  /// Creates the use case.
  const GetSavedIds(this._repository);

  final SavedRepository _repository;

  /// Runs it.
  Future<Set<String>> call() => _repository.getSavedIds();
}
