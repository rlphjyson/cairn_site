import '../models/contact.dart';
import '../repositories/contact_repository.dart';

/// Everyone you can message, alphabetical, without yourself or blocked people.
class GetContacts {
  /// Creates the use case.
  const GetContacts(this._contacts, this._currentUserId);

  final ContactRepository _contacts;
  final String _currentUserId;

  /// Loads and sorts the contacts.
  Future<List<Contact>> call() async {
    final List<Contact> all = await _contacts.getContacts();
    return all
        .where((Contact c) => c.id != _currentUserId && !c.blocked)
        .toList()
      ..sort(
        (Contact a, Contact b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
  }
}
