import '../models/account.dart';
import '../models/preferences.dart';

/// The shopper's account and settings.
abstract interface class ProfileRepository {
  /// The signed-in account, or `null` when signed out.
  Future<Account?> getAccount();

  /// Signs in and returns the account.
  Future<Account> signIn();

  /// Signs out.
  Future<void> signOut();

  /// The saved preferences.
  Future<Preferences> getPreferences();

  /// Stores [preferences] and returns them.
  Future<Preferences> savePreferences(Preferences preferences);
}
