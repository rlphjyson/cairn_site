import '../models/contact.dart';
import '../models/presence.dart';

/// People: your contacts, your own profile and their presence.
abstract interface class ContactRepository {
  /// Everyone you can talk to, blocked people included.
  Future<List<Contact>> getContacts();

  /// The signed-in user.
  Future<Contact> getCurrentUser();

  /// Changes the signed-in user's profile; arguments left `null` stay as they
  /// are. Returns the updated profile.
  Future<Contact> updateProfile({
    String? name,
    String? about,
    Presence? presence,
  });

  /// Blocks [contactId].
  Future<void> block(String contactId);

  /// Presence changes as they happen: each event is the contact's new state.
  ///
  /// The demo implements this with a stream controller; a real backend would
  /// push it over a WebSocket or SSE channel.
  Stream<Contact> watchPresence();
}
