import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/contacts/models/contact.dart';
import '../../../domain/contacts/use_cases/block_contact.dart';
import '../../../domain/contacts/use_cases/get_contacts.dart';
import '../../../domain/contacts/use_cases/get_current_user.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/conversations/use_cases/delete_conversation.dart';
import '../../../domain/conversations/use_cases/get_conversation.dart';
import '../../../domain/conversations/use_cases/leave_group.dart';
import '../../../domain/conversations/use_cases/update_conversation.dart';
import '../../../domain/messages/models/message.dart';
import '../../../domain/messages/use_cases/get_shared_media.dart';

/// State of the contact and group information screen.
class InfoState extends Equatable {
  /// Creates a state.
  const InfoState({
    this.loaded = false,
    this.conversation,
    this.peer,
    this.members = const <Contact>[],
    this.me,
    this.media = const <Message>[],
  });

  /// Whether loading finished.
  final bool loaded;

  /// The conversation, or `null` when it no longer exists.
  final Conversation? conversation;

  /// The other person, for a one-to-one conversation.
  final Contact? peer;

  /// The other members of a group.
  final List<Contact> members;

  /// You.
  final Contact? me;

  /// Photos shared in the conversation, newest first.
  final List<Message> media;

  /// A copy with some fields replaced.
  InfoState copyWith({
    bool? loaded,
    Conversation? conversation,
    Contact? peer,
    List<Contact>? members,
    Contact? me,
    List<Message>? media,
  }) => InfoState(
    loaded: loaded ?? this.loaded,
    conversation: conversation ?? this.conversation,
    peer: peer ?? this.peer,
    members: members ?? this.members,
    me: me ?? this.me,
    media: media ?? this.media,
  );

  @override
  List<Object?> get props => <Object?>[
    loaded,
    conversation,
    peer,
    members,
    me,
    media,
  ];
}

/// State for the information screen of one conversation.
class InfoCubit extends Cubit<InfoState> {
  /// Creates the cubit.
  InfoCubit(
    this._getConversation,
    this._getContacts,
    this._getCurrentUser,
    this._getMedia,
    this._update,
    this._leave,
    this._block,
    this._delete,
  ) : super(const InfoState());

  final GetConversation _getConversation;
  final GetContacts _getContacts;
  final GetCurrentUser _getCurrentUser;
  final GetSharedMedia _getMedia;
  final UpdateConversation _update;
  final LeaveGroup _leave;
  final BlockContact _block;
  final DeleteConversation _delete;

  /// Loads everything the screen shows about [conversationId].
  Future<void> load(String conversationId) async {
    try {
      final Conversation? conversation = await _getConversation(conversationId);
      final List<Contact> contacts = await _getContacts();
      final Contact me = await _getCurrentUser();
      final List<Message> media = await _getMedia(conversationId);
      if (isClosed) return;
      if (conversation == null) {
        emit(state.copyWith(loaded: true));
        return;
      }
      emit(
        InfoState(
          loaded: true,
          conversation: conversation,
          me: me,
          media: media,
          peer: conversation.isGroup
              ? null
              : _first(contacts, (Contact c) => c.id == conversation.peerId),
          members: conversation.isGroup
              ? <Contact>[
                  for (final String id in conversation.memberIds)
                    ...contacts.where((Contact c) => c.id == id),
                ]
              : const <Contact>[],
        ),
      );
    } on Object {
      if (!isClosed) emit(state.copyWith(loaded: true));
    }
  }

  /// Mutes or unmutes the conversation.
  Future<void> setMuted({required bool muted}) async {
    final Conversation? c = state.conversation;
    if (c == null) return;
    final Conversation updated = await _update(c.id, muted: muted);
    if (!isClosed) emit(state.copyWith(conversation: updated));
  }

  /// Leaves the group.
  Future<void> leaveGroup() async {
    final Conversation? c = state.conversation;
    if (c != null) await _leave(c.id);
  }

  /// Blocks the other person and deletes the conversation.
  Future<void> blockPeer() async {
    final Conversation? c = state.conversation;
    final Contact? peer = state.peer;
    if (c == null || peer == null) return;
    await _block(peer.id);
    await _delete(c.id);
  }

  Contact? _first(List<Contact> list, bool Function(Contact) test) {
    for (final Contact c in list) {
      if (test(c)) return c;
    }
    return null;
  }
}
