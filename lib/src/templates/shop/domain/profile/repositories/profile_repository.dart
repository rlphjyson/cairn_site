import '../models/account.dart';
import '../models/preferences.dart';

/// The shopper's account and settings.
abstract interface class ProfileRepository {
  /// The signed-in account.
  Future<Account> getAccount();

  /// The saved preferences.
  Future<Preferences> getPreferences();

  /// Stores [preferences] and returns them.
  Future<Preferences> savePreferences(Preferences preferences);
}
