import '../models/contact.dart';
import '../models/presence.dart';
import '../repositories/contact_repository.dart';

/// Changes the signed-in user's name, status line or availability.
class UpdateProfile {
  /// Creates the use case.
  const UpdateProfile(this._contacts);

  final ContactRepository _contacts;

  /// Saves the fields that are not `null`. A blank [name] is ignored: you
  /// cannot have no name.
  Future<Contact> call({String? name, String? about, Presence? presence}) {
    final String? trimmed = name?.trim();
    return _contacts.updateProfile(
      name: trimmed == null || trimmed.isEmpty ? null : trimmed,
      about: about?.trim(),
      presence: presence,
    );
  }
}
