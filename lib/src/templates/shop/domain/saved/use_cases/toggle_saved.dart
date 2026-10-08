import '../repositories/saved_repository.dart';

/// Saves or un-saves one product.
class ToggleSaved {
  /// Creates the use case.
  const ToggleSaved(this._repository);

  final SavedRepository _repository;

  /// Runs it, returning the new set of saved ids.
  Future<Set<String>> call(String id) => _repository.toggle(id);
}
