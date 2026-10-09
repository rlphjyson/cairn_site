/// Stores the saved ids.
abstract interface class SavedRemoteDataSource {
  /// Reads the ids.
  Set<String> read();

  /// Replaces the ids.
  void write(Set<String> ids);
}

/// Keeps saved ids in memory for the life of the template.
class InMemorySavedRemoteDataSource implements SavedRemoteDataSource {
  /// Creates the data source, starting with [initial] saved.
  InMemorySavedRemoteDataSource({
    Set<String> initial = const <String>{'classic-white'},
  }) : _ids = <String>{...initial};

  Set<String> _ids;

  @override
  Set<String> read() => <String>{..._ids};

  @override
  void write(Set<String> ids) => _ids = <String>{...ids};
}
