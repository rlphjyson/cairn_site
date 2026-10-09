import '../models/contact.dart';
import '../repositories/contact_repository.dart';

/// A stream of contacts whose presence just changed.
class WatchPresence {
  /// Creates the use case.
  const WatchPresence(this._contacts);

  final ContactRepository _contacts;

  /// Subscribes.
  Stream<Contact> call() => _contacts.watchPresence();
}
