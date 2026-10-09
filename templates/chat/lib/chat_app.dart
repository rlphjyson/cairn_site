import 'dart:async';
import 'dart:math' as math;

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/chat_session.dart';
import 'core/infrastructure/di/chat_injection.dart';
import 'core/presentation/navigation/chat_navigation_cubit.dart';
import 'core/presentation/view_model.dart';
import 'data/chat/remote/chat_remote_data_source.dart';
import 'data/chat/remote/in_memory_chat_data_source.dart';
import 'domain/messages/models/message.dart';
import 'presentation/contacts/bloc/contacts_cubit.dart';
import 'presentation/conversations/bloc/conversations_cubit.dart';
import 'presentation/profile/bloc/profile_cubit.dart';
import 'presentation/shell/chat_providers.dart';
import 'presentation/shell/chat_shell.dart';

/// A mobile chat app, built only from `cairn_ui` and Cairn tokens.
///
/// A conversation list with search, pinning, muting and an archive; threads
/// with grouped bubbles, delivery ticks, replies, reactions, images, typing
/// and history paging; a new chat and group creator; contact and group info;
/// and a profile with availability. On phones it is a column with a bottom
/// dock; from 700 px wide it becomes two panes.
///
/// It runs on an in-memory backend with a scripted "demo bot" by default. Pass
/// your own [chatDataSource] to connect a real service (REST for history, a
/// WebSocket or SSE channel for live events) without forking the template; see
/// `doc/index.html`.
///
/// It is organised as clean architecture, by layer and then by feature; see the
/// README next to this file. Photographs are from Pexels, used under the Pexels
/// licence.
class ChatApp extends StatefulWidget {
  /// Creates the app.
  ///
  /// * [chatDataSource] is the backend. Defaults to an in-memory one seeded
  ///   with people and history. A data source you pass stays yours to dispose.
  /// * [currentUserId] is who is signed in; it decides which messages are
  ///   "sent" (right side) and which are "received". With the default data
  ///   source it must stay `'me'` unless you supply your own seed.
  /// * [onMessageSent] is called with every message the backend accepted:
  ///   analytics, a draft cache, anything of yours.
  /// * [replyLatency] is how long the demo bot takes to answer. Use
  ///   [Duration.zero] in tests. Ignored when you pass [chatDataSource].
  /// * [now] is the clock; tests pass a fixed one so "Today" and relative
  ///   times are stable.
  /// * [initialConversationId] opens that conversation, for deep links. When
  ///   it changes while mounted, the new conversation opens (unless it is
  ///   already open).
  /// * [onConversationOpened] is called with the id of the open conversation
  ///   whenever it changes, and with `null` when the thread closes, so a
  ///   router can keep the URL in step.
  const ChatApp({
    super.key,
    this.chatDataSource,
    this.currentUserId = 'me',
    this.onMessageSent,
    this.replyLatency = const Duration(milliseconds: 900),
    this.now,
    this.initialConversationId,
    this.onConversationOpened,
  });

  /// The backend, or `null` for the in-memory demo.
  final ChatRemoteDataSource? chatDataSource;

  /// The signed-in user's id.
  final String currentUserId;

  /// Called after each message is accepted by the backend.
  final void Function(Message message)? onMessageSent;

  /// How long the demo bot takes to answer.
  final Duration replyLatency;

  /// The clock; defaults to [DateTime.now].
  final DateTime Function()? now;

  /// A conversation to open on start, or whenever it changes.
  final String? initialConversationId;

  /// Reports the open conversation (or `null`) as it changes.
  final ValueChanged<String?>? onConversationOpened;

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  late final ChatSession _session = ChatSession(
    userId: widget.currentUserId,
    now: widget.now ?? DateTime.now,
  );

  late final GetIt _locator = createChatLocator(
    dataSource:
        widget.chatDataSource ??
        InMemoryChatDataSource(
          currentUserId: widget.currentUserId,
          replyLatency: widget.replyLatency,
          now: _session.now,
        ),
    session: _session,
    ownsDataSource: widget.chatDataSource == null,
    onMessageSent: widget.onMessageSent,
  );

  @override
  void initState() {
    super.initState();
    // Session state is loaded once, up front, so every tab opens populated.
    unawaited(_locator<ConversationsCubit>().load());
    unawaited(_locator<ContactsCubit>().load());
    unawaited(_locator<ProfileCubit>().load());
    final ChatNavigationCubit nav = _locator<ChatNavigationCubit>();
    final String? initial = widget.initialConversationId;
    if (initial != null) nav.openThread(initial);
    _lastReported = nav.state.openThreadId;
    _navigation = nav.stream.listen(_reportOpenConversation);
  }

  StreamSubscription<ChatNavigationState>? _navigation;
  String? _lastReported;

  void _reportOpenConversation(ChatNavigationState state) {
    final String? id = state.openThreadId;
    if (id == _lastReported) return;
    _lastReported = id;
    widget.onConversationOpened?.call(id);
  }

  @override
  void didUpdateWidget(ChatApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String? wanted = widget.initialConversationId;
    if (wanted == oldWidget.initialConversationId) return;
    final ChatNavigationCubit nav = _locator<ChatNavigationCubit>();
    if (wanted == null) {
      if (nav.state.openThreadId != null) nav.clear();
    } else if (nav.state.openThreadId != wanted) {
      nav.openThread(wanted);
    }
  }

  @override
  void dispose() {
    unawaited(_navigation?.cancel());
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChatScope(
    locator: _locator,
    child: ChatSessionScope(
      session: _session,
      child: ChatProviders(
        locator: _locator,
        // The template brings its own toaster, so copy, attach and save can
        // toast in any host app.
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) => CairnToaster(
            alignment: Alignment.bottomCenter,
            width: math.min(356, box.maxWidth - 32),
            child: const Material(
              type: MaterialType.transparency,
              child: ChatShell(),
            ),
          ),
        ),
      ),
    ),
  );
}
