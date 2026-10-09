import '../models/contact.dart';
import '../repositories/contact_repository.dart';

/// The signed-in user's profile.
class GetCurrentUser {
  /// Creates the use case.
  const GetCurrentUser(this._contacts);

  final ContactRepository _contacts;

  /// Loads the profile.
  Future<Contact> call() => _contacts.getCurrentUser();
}
