/// Whether something has loaded.
enum LoadStatus {
  /// Waiting for the data source.
  loading,

  /// Loaded.
  ready,

  /// The data source failed. Offer a retry.
  failure,
}
