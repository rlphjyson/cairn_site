import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../domain/auth/models/social_provider.dart';

/// Settings the host chose that views need to read.
class AuthConfig {
  /// Creates a config.
  const AuthConfig({
    this.socialProviders = const <SocialProvider>[
      SocialProvider.google,
      SocialProvider.apple,
    ],
    this.onLegalLink,
    this.showDemoHint = false,
    this.recoveryByLink = false,
  });

  /// Which social buttons the welcome screen shows, in order.
  final List<SocialProvider> socialProviders;

  /// Called when a Terms or Privacy link is tapped.
  final void Function(AuthLegalLink link)? onLegalLink;

  /// Whether to show the demo account and code on screen.
  final bool showDemoHint;

  /// Whether password recovery sends a link instead of a code.
  final bool recoveryByLink;
}

/// A legal document the screens link to.
enum AuthLegalLink {
  /// The terms of service.
  terms,

  /// The privacy policy.
  privacy,
}

/// Makes the template's [GetIt] container and [AuthConfig] available to the
/// widget tree.
///
/// The container is created per `AuthApp` mount rather than being the global
/// instance, so two copies of the template (or a hot restart) never share
/// state or collide on registrations.
class AuthScope extends InheritedWidget {
  /// Creates a scope.
  const AuthScope({
    super.key,
    required this.locator,
    required this.config,
    required super.child,
  });

  /// The container for this template instance.
  final GetIt locator;

  /// The host's settings.
  final AuthConfig config;

  /// The nearest container.
  static GetIt of(BuildContext context) {
    // Not a dependency: the container never changes for a mounted app, and
    // this is called from initState, where dependencies are not allowed.
    final AuthScope? scope = context.getInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope above this context.');
    return scope!.locator;
  }

  /// The nearest settings. Rebuilds the caller when they change.
  static AuthConfig configOf(BuildContext context) {
    final AuthScope? scope = context
        .dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope above this context.');
    return scope!.config;
  }

  @override
  bool updateShouldNotify(AuthScope oldWidget) =>
      locator != oldWidget.locator || config != oldWidget.config;
}
