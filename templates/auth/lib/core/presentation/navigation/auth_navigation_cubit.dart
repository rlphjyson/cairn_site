import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/auth/models/reset_grant.dart';

/// The screens of the template.
enum AuthScreen {
  /// Brand, social buttons and the email entry points.
  welcome,

  /// Email and password.
  signIn,

  /// Create an account.
  signUp,

  /// Ask for a reset code. Can also be a start screen.
  forgotPassword,

  /// Enter the emailed code. Needs an email, so it is never a start screen.
  verifyCode,

  /// Choose a new password. Needs a grant, so it is never a start screen.
  resetPassword,

  /// The placeholder shown once signed in.
  signedIn,
}

/// One screen on the stack, with what it was opened with.
class AuthDestination extends Equatable {
  /// Creates a destination. [id] distinguishes two visits to the same screen.
  const AuthDestination(this.screen, {this.email, this.grant, this.id = 0});

  /// Which screen.
  final AuthScreen screen;

  /// The email the screen is about: the address a code was sent to, or one to
  /// prefill.
  final String? email;

  /// The reset grant, for [AuthScreen.resetPassword].
  final ResetGrant? grant;

  /// A number unique among the destinations of one navigation cubit.
  final int id;

  @override
  List<Object?> get props => <Object?>[screen, email, grant, id];
}

/// The back stack.
class AuthNavigationState extends Equatable {
  /// Creates a state. The stack is never empty.
  const AuthNavigationState(this.stack);

  /// The screens, root first.
  final List<AuthDestination> stack;

  /// The visible screen.
  AuthDestination get top => stack.last;

  /// Whether there is a screen to go back to.
  bool get canGoBack => stack.length > 1;

  @override
  List<Object?> get props => <Object?>[stack];
}

/// Navigation between the template's screens.
///
/// The template deliberately does not use the host app's router: it has to run
/// unchanged inside any Flutter app, whatever that app uses for routing. In a
/// real project you can drive your own router from `AuthApp`'s callbacks, or
/// replace this cubit with `go_router` calls and keep every view as it is (see
/// `doc/index.html`).
class AuthNavigationCubit extends Cubit<AuthNavigationState> {
  /// Creates the cubit showing [start], or, when a reset link opened the app,
  /// the reset-password screen for [resetGrant] (and [start] is where the app
  /// returns after a sign-out).
  AuthNavigationCubit({this.start = AuthScreen.welcome, ResetGrant? resetGrant})
    : super(
        AuthNavigationState(<AuthDestination>[
          resetGrant == null
              ? AuthDestination(start)
              : AuthDestination(AuthScreen.resetPassword, grant: resetGrant),
        ]),
      );

  /// The screen the template starts on, and returns to after signing out.
  final AuthScreen start;

  int _nextId = 1;

  AuthDestination _make(AuthScreen screen, String? email, ResetGrant? grant) =>
      AuthDestination(screen, email: email, grant: grant, id: _nextId++);

  /// Opens [screen] on top of the current one.
  void push(AuthScreen screen, {String? email, ResetGrant? grant}) => emit(
    AuthNavigationState(<AuthDestination>[
      ...state.stack,
      _make(screen, email, grant),
    ]),
  );

  /// Replaces the current screen, so back skips it.
  void replaceTop(AuthScreen screen, {String? email, ResetGrant? grant}) =>
      emit(
        AuthNavigationState(<AuthDestination>[
          ...state.stack.take(state.stack.length - 1),
          _make(screen, email, grant),
        ]),
      );

  /// Replaces the trailing run of [finished] screens with [screen].
  ///
  /// Used when a multi-step flow ends: once the code is verified, the screens
  /// that asked for it are done with, so back skips over them.
  void replaceTrailing(
    Set<AuthScreen> finished,
    AuthScreen screen, {
    String? email,
    ResetGrant? grant,
  }) {
    final List<AuthDestination> kept = <AuthDestination>[...state.stack];
    while (kept.isNotEmpty && finished.contains(kept.last.screen)) {
      kept.removeLast();
    }
    emit(
      AuthNavigationState(<AuthDestination>[
        ...kept,
        _make(screen, email, grant),
      ]),
    );
  }

  /// Shows [screen] without growing the stack: returns to it when it is already
  /// below the current screen, and otherwise replaces the current screen.
  ///
  /// With [fresh] the screen that is returned to is rebuilt (so it forgets what
  /// was typed and any error it showed) and prefilled with [email].
  void switchTo(AuthScreen screen, {String? email, bool fresh = false}) {
    final int index = state.stack.lastIndexWhere(
      (AuthDestination d) => d.screen == screen,
    );
    if (index >= 0 && index < state.stack.length - 1) {
      emit(
        AuthNavigationState(<AuthDestination>[
          ...state.stack.take(index),
          if (fresh) _make(screen, email, null) else state.stack[index],
        ]),
      );
    } else {
      replaceTop(screen, email: email);
    }
  }

  /// Replaces the whole stack with [screens] (root first).
  void resetTo(List<AuthScreen> screens, {String? email}) => emit(
    AuthNavigationState(<AuthDestination>[
      for (final AuthScreen s in screens)
        _make(s, s == screens.last ? email : null, null),
    ]),
  );

  /// Returns to [start] with nothing behind it (after signing out).
  void resetToStart() => resetTo(<AuthScreen>[start]);

  /// Goes back one screen. Does nothing on the root.
  void back() {
    if (!state.canGoBack) return;
    emit(
      AuthNavigationState(
        state.stack.take(state.stack.length - 1).toList(growable: false),
      ),
    );
  }

  /// Called when the navigator popped [destination] by itself (the system back
  /// gesture) so the stack follows.
  void didPop(AuthDestination destination) {
    if (state.top == destination) back();
  }
}
