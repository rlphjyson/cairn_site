import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/auth/models/session.dart';
import '../../../domain/auth/use_cases/sign_out.dart';

/// Who is signed in, if anyone.
class SessionState extends Equatable {
  /// Creates a state.
  const SessionState({this.session, this.signingOut = false});

  /// The session, or `null` when signed out.
  final Session? session;

  /// Whether a sign-out request is in flight.
  final bool signingOut;

  /// Whether someone is signed in.
  bool get signedIn => session != null;

  @override
  List<Object?> get props => <Object?>[session, signingOut];
}

/// The in-memory session. A session cubit: a lazy singleton, provided once and
/// closed only by the container.
///
/// `AuthProviders` listens to it to run the host's `onAuthenticated` and
/// `onSignedOut` callbacks and to move the navigation.
class SessionCubit extends Cubit<SessionState> {
  /// Creates the cubit.
  SessionCubit(this._signOut) : super(const SessionState());

  final SignOut _signOut;

  /// Records a successful sign-in.
  void start(Session session) => emit(SessionState(session: session));

  /// Ends the session. The local session is cleared even if the server could
  /// not be told.
  Future<void> signOut() async {
    if (!state.signedIn || state.signingOut) return;
    emit(SessionState(session: state.session, signingOut: true));
    await _signOut();
    if (isClosed) return;
    emit(const SessionState());
  }
}
