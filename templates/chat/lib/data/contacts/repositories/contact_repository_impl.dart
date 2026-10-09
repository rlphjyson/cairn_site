import '../../../domain/contacts/mappers/contact_mapper.dart';
import '../../../domain/contacts/models/contact.dart';
import '../../../domain/contacts/models/presence.dart';
import '../../../domain/contacts/repositories/contact_repository.dart';
import '../../../domain/messages/models/chat_event.dart';
import '../../chat/remote/chat_event_stream.dart';
import '../../chat/remote/chat_remote_data_source.dart';

/// [ContactRepository] over a [ChatRemoteDataSource].
class ContactRepositoryImpl implements ContactRepository {
  /// Creates the repository.
  ContactRepositoryImpl(this._source);

  final ChatRemoteDataSource _source;

  @override
  Future<List<Contact>> getContacts() async => <Contact>[
    for (final Map<String, Object?> json in await _source.fetchContacts())
      ContactMapper.fromJson(json),
  ];

  @override
  Future<Contact> getCurrentUser() async =>
      ContactMapper.fromJson(await _source.fetchCurrentUser());

  @override
  Future<Contact> updateProfile({
    String? name,
    String? about,
    Presence? presence,
  }) async => ContactMapper.fromJson(
    await _source.patchProfile(<String, Object?>{
      'name': name,
      'about': about,
      'presence': presence?.wire,
    }),
  );

  @override
  Future<void> block(String contactId) => _source.blockContact(contactId);

  @override
  Stream<Contact> watchPresence() => decodeChatEvents(_source.events())
      .where((ChatEvent e) => e is PresenceChanged)
      .map((ChatEvent e) => (e as PresenceChanged).contact);
}
