import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/presentation/navigation/auth_navigation_cubit.dart';
import '../../domain/auth/models/session.dart';
import '../session/bloc/session_cubit.dart';

/// Exposes the session cubits to every screen and bridges the session to the
/// host app.
///
/// The cubits are lazy singletons owned by the container, so they are provided
/// with `BlocProvider.value` (which never closes them). Views read them with
/// `context.read` and never touch the container.
class AuthProviders extends StatelessWidget {
  /// Creates the providers.
  const AuthProviders({
    super.key,
    required this.locator,
    required this.child,
    this.onAuthenticated,
    this.onSignedOut,
  });

  /// The container that owns the cubits.
  final GetIt locator;

  /// The app.
  final Widget child;

  /// Called with the session when sign-in succeeds, by any route.
  final void Function(Session session)? onAuthenticated;

  /// Called after the person signs out.
  final VoidCallback? onSignedOut;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<AuthNavigationCubit>.value(
        value: locator<AuthNavigationCubit>(),
      ),
      BlocProvider<SessionCubit>.value(value: locator<SessionCubit>()),
    ],
    // The one place that reacts to the session: it moves the navigation and
    // tells the host. Screens only ever call `SessionCubit.start`.
    child: BlocListener<SessionCubit, SessionState>(
      listenWhen: (SessionState previous, SessionState current) =>
          previous.signedIn != current.signedIn,
      listener: (BuildContext context, SessionState state) {
        final AuthNavigationCubit nav = context.read<AuthNavigationCubit>();
        final Session? session = state.session;
        if (session != null) {
          nav.resetTo(<AuthScreen>[AuthScreen.signedIn]);
          onAuthenticated?.call(session);
        } else {
          nav.resetToStart();
          onSignedOut?.call();
        }
      },
      child: child,
    ),
  );
}
