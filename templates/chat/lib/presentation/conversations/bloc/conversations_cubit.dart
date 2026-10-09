import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/conversations/models/conversation_inbox.dart';
import '../../../domain/conversations/use_cases/delete_conversation.dart';
import '../../../domain/conversations/use_cases/get_conversations.dart';
import '../../../domain/conversations/use_cases/search_conversations.dart';
import '../../../domain/conversations/use_cases/update_conversation.dart';
import '../../../domain/conversations/use_cases/watch_conversation_changes.dart';
import 'conversations_state.dart';

/// State for the Chats tab: the list, its search and the archive view.
///
/// A session cubit: it lives as long as the app, listens for changes pushed by
/// the backend (a new message, an unread count) and reloads the list.
class ConversationsCubit extends Cubit<ConversationsState> {
  /// Creates the cubit.
  ConversationsCubit(
    this._get,
    this._search,
    this._update,
    this._delete,
    this._watch,
  ) : super(const ConversationsState());

  final GetConversations _get;
  final SearchConversations _search;
  final UpdateConversation _update;
  final DeleteConversation _delete;
  final WatchConversationChanges _watch;

  StreamSubscription<String>? _subscription;
  int _loads = 0;

  /// Loads the list. The first call shows skeletons; later ones (also made
  /// whenever the backend reports a change) update in place.
  Future<void> load() async {
    _subscription ??= _watch().listen((String _) => unawaited(load()));
    final int ticket = ++_loads;
    try {
      final ConversationInbox inbox = await _get();
      if (isClosed || ticket != _loads) return;
      emit(
        _derive(
          state.copyWith(status: ConversationsStatus.ready, inbox: inbox),
        ),
      );
    } on Object {
      if (isClosed || ticket != _loads) return;
      if (state.status == ConversationsStatus.loading) {
        emit(state.copyWith(status: ConversationsStatus.failed));
      }
    }
  }

  /// Retries after a failed first load.
  Future<void> retry() {
    emit(state.copyWith(status: ConversationsStatus.loading));
    return load();
  }

  /// Filters the list by name or last message.
  void search(String query) => emit(_derive(state.copyWith(query: query)));

  /// Shows the archive, or the main list again.
  void showArchive({required bool show}) =>
      emit(_derive(state.copyWith(showArchived: show)));

  /// Pins or unpins.
  Future<void> setPinned(Conversation c, {required bool pinned}) =>
      _apply(c.id, pinned: pinned);

  /// Mutes or unmutes.
  Future<void> setMuted(Conversation c, {required bool muted}) =>
      _apply(c.id, muted: muted);

  /// Archives or restores.
  Future<void> setArchived(Conversation c, {required bool archived}) async {
    await _apply(c.id, archived: archived);
    // Leave the archive view when the last archived chat has been restored.
    if (!archived && state.showArchived && state.inbox.archived.isEmpty) {
      showArchive(show: false);
    }
  }

  /// Flags as unread, or clears the flag.
  Future<void> setMarkedUnread(Conversation c, {required bool unread}) =>
      _apply(c.id, markedUnread: unread);

  /// Deletes a conversation and its history.
  Future<void> delete(Conversation c) async {
    await _delete(c.id);
    await load();
  }

  Future<void> _apply(
    String id, {
    bool? pinned,
    bool? muted,
    bool? archived,
    bool? markedUnread,
  }) async {
    await _update(
      id,
      pinned: pinned,
      muted: muted,
      archived: archived,
      markedUnread: markedUnread,
    );
    await load();
  }

  ConversationsState _derive(ConversationsState s) {
    if (s.showArchived) {
      return s.copyWith(
        visiblePinned: const <Conversation>[],
        visibleOthers: _search(s.inbox.archived, s.query),
      );
    }
    return s.copyWith(
      visiblePinned: _search(s.inbox.pinned, s.query),
      visibleOthers: _search(s.inbox.others, s.query),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
