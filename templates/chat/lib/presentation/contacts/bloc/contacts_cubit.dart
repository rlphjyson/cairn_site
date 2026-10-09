import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/contacts/models/contact.dart';
import '../../../domain/contacts/use_cases/block_contact.dart';
import '../../../domain/contacts/use_cases/get_contacts.dart';
import '../../../domain/contacts/use_cases/group_contacts.dart';
import '../../../domain/contacts/use_cases/search_contacts.dart';
import '../../../domain/contacts/use_cases/watch_presence.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/conversations/use_cases/open_direct_conversation.dart';

/// State of the contact directory.
class ContactsState extends Equatable {
  /// Creates a state.
  const ContactsState({
    this.loaded = false,
    this.contacts = const <Contact>[],
    this.query = '',
    this.sections = const <ContactSection>[],
  });

  /// Whether the first load finished.
  final bool loaded;

  /// Everyone except you and blocked people, alphabetical.
  final List<Contact> contacts;

  /// The search text.
  final String query;

  /// The matches, in alphabetical sections.
  final List<ContactSection> sections;

  /// The contact with [id], or `null` (you are not in this list).
  Contact? byId(String id) {
    for (final Contact c in contacts) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// A copy with some fields replaced.
  ContactsState copyWith({
    bool? loaded,
    List<Contact>? contacts,
    String? query,
    List<ContactSection>? sections,
  }) => ContactsState(
    loaded: loaded ?? this.loaded,
    contacts: contacts ?? this.contacts,
    query: query ?? this.query,
    sections: sections ?? this.sections,
  );

  @override
  List<Object?> get props => <Object?>[loaded, contacts, query, sections];
}

/// Everyone you can message, with live presence.
///
/// A session cubit: threads and the list read it for names and presence dots.
class ContactsCubit extends Cubit<ContactsState> {
  /// Creates the cubit.
  ContactsCubit(
    this._get,
    this._group,
    this._search,
    this._block,
    this._watchPresence,
    this._openDirect,
    this._currentUserId,
  ) : super(const ContactsState());

  final GetContacts _get;
  final GroupContacts _group;
  final SearchContacts _search;
  final BlockContact _block;
  final WatchPresence _watchPresence;
  final OpenDirectConversation _openDirect;
  final String _currentUserId;

  StreamSubscription<Contact>? _subscription;

  /// Loads the contacts and starts following their presence.
  Future<void> load() async {
    _subscription ??= _watchPresence().listen(_onPresence);
    try {
      final List<Contact> contacts = await _get();
      if (isClosed) return;
      emit(_derive(state.copyWith(loaded: true, contacts: contacts)));
    } on Object {
      if (isClosed) return;
      emit(state.copyWith(loaded: true));
    }
  }

  /// Filters by name or status line.
  void search(String query) => emit(_derive(state.copyWith(query: query)));

  /// Blocks a contact, who then leaves the directory.
  Future<void> block(Contact contact) async {
    await _block(contact.id);
    await load();
  }

  /// Opens (creating if needed) the conversation with [contact]; returns its
  /// id, or `null` if that failed.
  Future<String?> openChat(Contact contact) async {
    try {
      final Conversation c = await _openDirect(contact.id);
      return c.id;
    } on Object {
      return null;
    }
  }

  void _onPresence(Contact updated) {
    if (updated.id == _currentUserId) return;
    final List<Contact> next = <Contact>[
      for (final Contact c in state.contacts) c.id == updated.id ? updated : c,
    ];
    emit(_derive(state.copyWith(contacts: next)));
  }

  ContactsState _derive(ContactsState s) =>
      s.copyWith(sections: _group(_search(s.contacts, s.query)));

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
