/// Hands out order references.
abstract interface class OrderRemoteDataSource {
  /// The next unused order number.
  int nextNumber();
}

/// Counts up from a fixed starting number, in memory.
class InMemoryOrderRemoteDataSource implements OrderRemoteDataSource {
  /// Creates the data source.
  InMemoryOrderRemoteDataSource({int start = 2048}) : _next = start;

  int _next;

  @override
  int nextNumber() => _next++;
}
