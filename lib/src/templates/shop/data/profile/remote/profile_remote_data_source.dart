import '../../../domain/profile/models/account.dart';
import '../../../domain/profile/models/preferences.dart';

/// Reads and writes the account and settings.
abstract interface class ProfileRemoteDataSource {
  /// The account.
  Account readAccount();

  /// The preferences.
  Preferences readPreferences();

  /// Replaces the preferences.
  void writePreferences(Preferences preferences);
}

/// A fixed demo account with in-memory preferences.
class InMemoryProfileRemoteDataSource implements ProfileRemoteDataSource {
  Preferences _preferences = const Preferences();

  @override
  Account readAccount() => const Account(
    name: 'Ada Lovelace',
    email: 'ada@example.com',
    initials: 'AL',
    orderCount: 12,
    reviewCount: 4,
  );

  @override
  Preferences readPreferences() => _preferences;

  @override
  void writePreferences(Preferences preferences) => _preferences = preferences;
}
