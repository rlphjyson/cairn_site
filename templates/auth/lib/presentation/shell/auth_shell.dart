import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/presentation/navigation/auth_navigation_cubit.dart';
import '../recovery/views/forgot_password_view.dart';
import '../recovery/views/reset_password_view.dart';
import '../recovery/views/verify_code_view.dart';
import '../session/views/signed_in_view.dart';
import '../sign_in/views/sign_in_view.dart';
import '../sign_up/views/sign_up_view.dart';
import '../welcome/views/welcome_view.dart';
import 'auth_page.dart';

/// Shows the screen on top of the navigation cubit's stack.
///
/// A nested [Navigator] driven by the cubit: the cubit is the single source of
/// truth, and the navigator animates and keeps the pages. The system back
/// gesture is routed to the navigator while there is something to go back to,
/// and falls through to the host app otherwise.
class AuthShell extends StatefulWidget {
  /// Creates the shell.
  const AuthShell({super.key});

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell> {
  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();

  Widget _screen(AuthDestination destination, bool showBack) =>
      switch (destination.screen) {
        AuthScreen.welcome => WelcomeView(destination: destination),
        AuthScreen.signIn => SignInView(
          destination: destination,
          showBack: showBack,
        ),
        AuthScreen.signUp => SignUpView(
          destination: destination,
          showBack: showBack,
        ),
        AuthScreen.forgotPassword => ForgotPasswordView(
          destination: destination,
          showBack: showBack,
        ),
        AuthScreen.verifyCode => VerifyCodeView(
          destination: destination,
          showBack: showBack,
        ),
        AuthScreen.resetPassword => ResetPasswordView(
          destination: destination,
          showBack: showBack,
        ),
        AuthScreen.signedIn => const SignedInView(),
      };

  @override
  Widget build(BuildContext context) {
    final AuthNavigationCubit cubit = context.read<AuthNavigationCubit>();
    return BlocBuilder<AuthNavigationCubit, AuthNavigationState>(
      builder: (BuildContext context, AuthNavigationState nav) =>
          NavigatorPopHandler<void>(
            enabled: nav.canGoBack,
            onPopWithResult: (void _) => _navigator.currentState?.maybePop(),
            child: Navigator(
              key: _navigator,
              pages: <Page<void>>[
                for (int i = 0; i < nav.stack.length; i++)
                  AuthPage(
                    destination: nav.stack[i],
                    child: _screen(nav.stack[i], i > 0),
                  ),
              ],
              onDidRemovePage: (Page<Object?> page) {
                if (page is AuthPage) cubit.didPop(page.destination);
              },
            ),
          ),
    );
  }
}
