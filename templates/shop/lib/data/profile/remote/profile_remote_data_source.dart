/// Reads and writes the account and settings as decoded JSON.
abstract interface class ProfileRemoteDataSource {
  /// The account, or `null` when signed out. See `ProfileMapper`.
  Map<String, Object?>? readAccount();

  /// Signs in and returns the account.
  Map<String, Object?> signIn();

  /// Signs out.
  void signOut();

  /// The preferences.
  Map<String, Object?> readPreferences();

  /// Replaces the preferences.
  void writePreferences(Map<String, Object?> preferences);
}

/// A fixed demo account with in-memory preferences.
class InMemoryProfileRemoteDataSource implements ProfileRemoteDataSource {
  bool _signedIn = true;
  Map<String, Object?> _preferences = <String, Object?>{
    'orderUpdates': true,
    'offers': false,
  };

  static const Map<String, Object?> _account = <String, Object?>{
    'name': 'Ada Lovelace',
    'email': 'ada@example.com',
    'reviewCount': 4,
    'memberSince': 2024,
  };

  @override
  Map<String, Object?>? readAccount() => _signedIn ? _account : null;

  @override
  Map<String, Object?> signIn() {
    _signedIn = true;
    return _account;
  }

  @override
  void signOut() => _signedIn = false;

  @override
  Map<String, Object?> readPreferences() => _preferences;

  @override
  void writePreferences(Map<String, Object?> preferences) =>
      _preferences = <String, Object?>{...preferences};
}
