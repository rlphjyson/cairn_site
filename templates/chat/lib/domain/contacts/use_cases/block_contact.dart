import '../repositories/contact_repository.dart';

/// Blocks a contact.
class BlockContact {
  /// Creates the use case.
  const BlockContact(this._contacts);

  final ContactRepository _contacts;

  /// Blocks [contactId].
  Future<void> call(String contactId) => _contacts.block(contactId);
}
