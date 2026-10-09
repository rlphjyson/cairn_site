import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The tabs in the bottom dock, in order.
enum ChatTab {
  /// The conversation list.
  chats,

  /// Everyone you can message.
  contacts,

  /// Your profile and settings.
  profile,
}

/// A screen opened over the tabs (or, on a tablet, in the right-hand pane).
sealed class ChatRoute extends Equatable {
  const ChatRoute();
}

/// An open conversation.
class ThreadRoute extends ChatRoute {
  /// Opens [conversationId].
  const ThreadRoute(this.conversationId);

  /// The conversation.
  final String conversationId;

  @override
  List<Object?> get props => <Object?>[conversationId];
}

/// Contact or group information.
class InfoRoute extends ChatRoute {
  /// Shows [conversationId]'s details.
  const InfoRoute(this.conversationId);

  /// The conversation.
  final String conversationId;

  @override
  List<Object?> get props => <Object?>[conversationId];
}

/// The new chat screen.
class NewChatRoute extends ChatRoute {
  /// Opens the picker, in group mode when [group] is true.
  const NewChatRoute({this.group = false});

  /// Start in "new group" mode.
  final bool group;

  @override
  List<Object?> get props => <Object?>[group];
}

/// Where the user is: a tab, plus a stack of screens on top of it.
class ChatNavigationState extends Equatable {
  /// Creates a state.
  const ChatNavigationState({
    this.tab = ChatTab.chats,
    this.stack = const <ChatRoute>[],
  });

  /// The selected tab.
  final ChatTab tab;

  /// Screens above the tabs, the last one on top.
  final List<ChatRoute> stack;

  /// The screen on top, or `null` when only the tabs are showing.
  ChatRoute? get top => stack.isEmpty ? null : stack.last;

  /// The conversation whose thread is open, or `null`.
  String? get openThreadId {
    for (final ChatRoute r in stack.reversed) {
      if (r is ThreadRoute) return r.conversationId;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[tab, stack];
}

/// Navigation inside the chat.
///
/// The template deliberately does not use the host app's router: it has to run
/// unchanged inside any Flutter app, whatever that app uses for routing. In a
/// real project, swap this cubit for `go_router` or `Navigator` and keep every
/// view as it is (see `doc/index.html`).
class ChatNavigationCubit extends Cubit<ChatNavigationState> {
  /// Creates the cubit.
  ChatNavigationCubit() : super(const ChatNavigationState());

  /// Switches tab. Screens already open stay open.
  void selectTab(ChatTab tab) =>
      emit(ChatNavigationState(tab: tab, stack: state.stack));

  /// Opens a conversation, replacing whatever was open.
  void openThread(String conversationId) => emit(
    ChatNavigationState(
      tab: state.tab,
      stack: <ChatRoute>[ThreadRoute(conversationId)],
    ),
  );

  /// Opens the details of a conversation over its thread (or alone).
  void openInfo(String conversationId) => emit(
    ChatNavigationState(
      tab: state.tab,
      stack: <ChatRoute>[
        ...state.stack.whereType<ThreadRoute>(),
        InfoRoute(conversationId),
      ],
    ),
  );

  /// Opens the new chat screen, replacing whatever was open.
  void openNewChat({bool group = false}) => emit(
    ChatNavigationState(
      tab: state.tab,
      stack: <ChatRoute>[NewChatRoute(group: group)],
    ),
  );

  /// Closes the screen on top.
  void back() {
    if (state.stack.isEmpty) return;
    emit(
      ChatNavigationState(
        tab: state.tab,
        stack: state.stack.sublist(0, state.stack.length - 1),
      ),
    );
  }

  /// Closes every screen and shows only the tabs.
  void clear() => emit(ChatNavigationState(tab: state.tab));

  /// Closes everything that shows [conversationId]; used after it is deleted
  /// or left.
  void closeConversation(String conversationId) {
    final List<ChatRoute> kept = state.stack
        .where(
          (ChatRoute r) =>
              !(r is ThreadRoute && r.conversationId == conversationId) &&
              !(r is InfoRoute && r.conversationId == conversationId),
        )
        .toList();
    if (kept.length == state.stack.length) return;
    emit(ChatNavigationState(tab: state.tab, stack: kept));
  }
}
