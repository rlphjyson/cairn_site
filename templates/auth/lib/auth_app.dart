import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/di/auth_injection.dart';
import 'core/presentation/auth_scope.dart';
import 'core/presentation/navigation/auth_navigation_cubit.dart';
import 'data/auth/remote/auth_remote_data_source.dart';
import 'domain/auth/models/session.dart';
import 'domain/auth/models/social_provider.dart';
import 'presentation/shell/auth_providers.dart';
import 'presentation/shell/auth_shell.dart';

/// Authentication screens for a mobile app, built only from `cairn_ui` and
/// Cairn tokens.
///
/// Welcome, sign in, sign up, forgot password, verify code, reset password and
/// a signed-in placeholder, with their own back stack and transitions. It uses
/// the host app's [CairnTheme] (light and dark) and fills whatever space it is
/// given; on anything wider than a phone the content stays a centred column.
///
/// Wire it into your app with the callbacks and the data source:
///
/// ```dart
/// AuthApp(
///   authDataSource: MyRestAuthDataSource(client),
///   onAuthenticated: (Session session) => router.go('/home'),
///   onSignedOut: () => router.go('/'),
/// )
/// ```
///
/// It is organised as clean architecture, by layer and then by feature; see the
/// README next to this file.
class AuthApp extends StatefulWidget {
  /// Creates the app.
  ///
  /// * [onAuthenticated] runs with the [Session] whenever someone signs in or
  ///   up, by any route. Navigate to your home screen there. This is the hook
  ///   the signed-in placeholder screen explains.
  /// * [onSignedOut] runs after the signed-in screen's sign-out completes.
  /// * [authDataSource] replaces the in-memory stand-in server with yours. It
  ///   is read once, when the app is first built.
  /// * [startOn] is the first screen: [AuthScreen.welcome] (the default),
  ///   [AuthScreen.signIn], [AuthScreen.signUp] or
  ///   [AuthScreen.forgotPassword]. It is read once, and is also where the app
  ///   returns after a sign-out.
  /// * [onSocialSignIn] runs a provider's own sign-in SDK and returns its ID
  ///   token (or `null` if the person cancelled); see [SocialIdTokenProvider].
  ///   [socialProviders] chooses the buttons; pass an empty list to hide them.
  /// * [onLegalLink] opens the Terms or Privacy Policy.
  /// * [showDemoHint] prints the demo credentials on screen, for trying the
  ///   template without a backend. Leave it off in a real app.
  /// * [resetToken] opens the app on the reset-password screen, for a password
  ///   reset link that carries a token (see the docs on deep links). The token
  ///   is read once.
  /// * [recoveryByLink] is for backends that email a link instead of a code
  ///   (Firebase Auth does): the confirmation says so and the code screen is
  ///   skipped; the link comes back through [resetToken].
  const AuthApp({
    super.key,
    this.onAuthenticated,
    this.onSignedOut,
    this.authDataSource,
    this.startOn = AuthScreen.welcome,
    this.onSocialSignIn,
    this.socialProviders = const <SocialProvider>[
      SocialProvider.google,
      SocialProvider.apple,
    ],
    this.onLegalLink,
    this.showDemoHint = false,
    this.resetToken,
    this.recoveryByLink = false,
  }) : assert(
         startOn == AuthScreen.welcome ||
             startOn == AuthScreen.signIn ||
             startOn == AuthScreen.signUp ||
             startOn == AuthScreen.forgotPassword,
         'startOn must be welcome, signIn, signUp or forgotPassword.',
       );

  /// Called with the session when someone signs in or up.
  final void Function(Session session)? onAuthenticated;

  /// Called after sign-out.
  final VoidCallback? onSignedOut;

  /// The backend. Defaults to the in-memory stand-in.
  final AuthRemoteDataSource? authDataSource;

  /// The first screen.
  final AuthScreen startOn;

  /// Runs a social provider's sign-in and returns its ID token.
  final SocialIdTokenProvider? onSocialSignIn;

  /// Which social buttons to show, in order.
  final List<SocialProvider> socialProviders;

  /// Called when a Terms or Privacy Policy link is tapped.
  final void Function(AuthLegalLink link)? onLegalLink;

  /// Whether to show the demo account and code on screen.
  final bool showDemoHint;

  /// A password-reset token from a link, to start on the reset screen.
  final String? resetToken;

  /// Whether recovery emails a link instead of a code.
  final bool recoveryByLink;

  @override
  State<AuthApp> createState() => _AuthAppState();
}

class _AuthAppState extends State<AuthApp> {
  late final GetIt _locator = createAuthLocator(
    dataSource: widget.authDataSource,
    startOn: widget.startOn,
    resetToken: widget.resetToken,
    // Read at call time, so a rebuilt AuthApp with a new handler takes effect.
    socialIdToken: (SocialProvider provider) async {
      final SocialIdTokenProvider? handler = widget.onSocialSignIn;
      return handler == null
          ? placeholderSocialIdToken(provider)
          : handler(provider);
    },
  );

  @override
  void dispose() {
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthScope(
    locator: _locator,
    config: AuthConfig(
      socialProviders: widget.socialProviders,
      onLegalLink: widget.onLegalLink,
      showDemoHint: widget.showDemoHint,
      recoveryByLink: widget.recoveryByLink,
    ),
    child: AuthProviders(
      locator: _locator,
      onAuthenticated: widget.onAuthenticated,
      onSignedOut: widget.onSignedOut,
      // Text needs a Material ancestor for its default style; a transparent one
      // adds no visuals.
      child: const Material(
        type: MaterialType.transparency,
        child: AuthShell(),
      ),
    ),
  );
}
