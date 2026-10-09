/// The set of products the shopper has hearted.
abstract interface class SavedRepository {
  /// The ids currently saved.
  Future<Set<String>> getSavedIds();

  /// Saves [id] if it is not saved, removes it if it is. Returns the new set.
  Future<Set<String>> toggle(String id);
}
