import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/contacts/models/contact.dart';
import '../../../domain/contacts/use_cases/get_contacts.dart';
import '../../../domain/contacts/use_cases/group_contacts.dart';
import '../../../domain/contacts/use_cases/search_contacts.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/conversations/use_cases/create_group.dart';
import '../../../domain/conversations/use_cases/open_direct_conversation.dart';

/// State of the new chat screen.
class NewChatState extends Equatable {
  /// Creates a state.
  const NewChatState({
    this.loaded = false,
    this.contacts = const <Contact>[],
    this.query = '',
    this.sections = const <ContactSection>[],
    this.group = false,
    this.selected = const <String>[],
    this.groupName = '',
    this.problem,
    this.busy = false,
  });

  /// Whether the contacts finished loading.
  final bool loaded;

  /// Everyone you can message.
  final List<Contact> contacts;

  /// The search text.
  final String query;

  /// The matches in alphabetical sections.
  final List<ContactSection> sections;

  /// Whether the screen is picking people for a group.
  final bool group;

  /// Ids of the people picked for the group, in the order picked.
  final List<String> selected;

  /// The group's name so far.
  final String groupName;

  /// What stops the group from being created; shown after a failed attempt.
  final GroupProblem? problem;

  /// Whether a conversation is being created.
  final bool busy;

  /// The people picked, in the order picked.
  List<Contact> get selectedContacts => <Contact>[
    for (final String id in selected)
      ...contacts.where((Contact c) => c.id == id),
  ];

  /// A copy with some fields replaced.
  NewChatState copyWith({
    bool? loaded,
    List<Contact>? contacts,
    String? query,
    List<ContactSection>? sections,
    bool? group,
    List<String>? selected,
    String? groupName,
    GroupProblem? problem,
    bool clearProblem = false,
    bool? busy,
  }) => NewChatState(
    loaded: loaded ?? this.loaded,
    contacts: contacts ?? this.contacts,
    query: query ?? this.query,
    sections: sections ?? this.sections,
    group: group ?? this.group,
    selected: selected ?? this.selected,
    groupName: groupName ?? this.groupName,
    problem: clearProblem ? null : (problem ?? this.problem),
    busy: busy ?? this.busy,
  );

  @override
  List<Object?> get props => <Object?>[
    loaded,
    contacts,
    query,
    sections,
    group,
    selected,
    groupName,
    problem,
    busy,
  ];
}

/// State for the new chat screen: find a person to message, or pick several
/// and create a group.
class NewChatCubit extends Cubit<NewChatState> {
  /// Creates the cubit.
  NewChatCubit(
    this._getContacts,
    this._groupContacts,
    this._searchContacts,
    this._openDirect,
    this._createGroup,
  ) : super(const NewChatState());

  final GetContacts _getContacts;
  final GroupContacts _groupContacts;
  final SearchContacts _searchContacts;
  final OpenDirectConversation _openDirect;
  final CreateGroup _createGroup;

  /// Loads the contacts; [group] starts in group mode.
  Future<void> load({bool group = false}) async {
    emit(state.copyWith(group: group));
    try {
      final List<Contact> contacts = await _getContacts();
      if (isClosed) return;
      emit(_derive(state.copyWith(loaded: true, contacts: contacts)));
    } on Object {
      if (!isClosed) emit(state.copyWith(loaded: true));
    }
  }

  /// Filters by name or status line.
  void search(String query) => emit(_derive(state.copyWith(query: query)));

  /// Switches between picking one person and picking a group.
  void setGroupMode({required bool group}) => emit(
    state.copyWith(
      group: group,
      selected: const <String>[],
      groupName: '',
      clearProblem: true,
    ),
  );

  /// Picks or unpicks a person for the group.
  void toggle(Contact contact) {
    final List<String> next = state.selected.contains(contact.id)
        ? state.selected.where((String id) => id != contact.id).toList()
        : <String>[...state.selected, contact.id];
    emit(state.copyWith(selected: next, clearProblem: true));
  }

  /// Sets the group's name.
  void setGroupName(String name) =>
      emit(state.copyWith(groupName: name, clearProblem: true));

  /// Opens (creating if needed) the conversation with [contact]; returns its
  /// id, or `null` if that failed.
  Future<String?> startDirect(Contact contact) async {
    if (state.busy) return null;
    emit(state.copyWith(busy: true));
    try {
      final Conversation c = await _openDirect(contact.id);
      return c.id;
    } on Object {
      return null;
    } finally {
      if (!isClosed) emit(state.copyWith(busy: false));
    }
  }

  /// Creates the group; returns its id, or `null` with [NewChatState.problem]
  /// set when the name or the members are not valid.
  Future<String?> createGroup() async {
    if (state.busy) return null;
    final GroupProblem? problem = CreateGroup.validate(
      state.groupName,
      state.selected,
    );
    if (problem != null) {
      emit(state.copyWith(problem: problem));
      return null;
    }
    emit(state.copyWith(busy: true));
    try {
      final Conversation c = await _createGroup(
        state.groupName,
        state.selected,
      );
      return c.id;
    } on Object {
      return null;
    } finally {
      if (!isClosed) emit(state.copyWith(busy: false));
    }
  }

  NewChatState _derive(NewChatState s) => s.copyWith(
    sections: _groupContacts(_searchContacts(s.contacts, s.query)),
  );
}
