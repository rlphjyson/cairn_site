import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../core/presentation/navigation/auth_navigation_cubit.dart';

/// One screen on the in-template back stack.
///
/// A [Page] keyed by its destination, so the navigator keeps the screens below
/// the top one alive (their forms keep what was typed) and animates only the
/// screen that arrives or leaves. The transition is a short slide and fade
/// built from Cairn's motion tokens; with the platform's reduce-motion setting
/// on, screens simply swap.
class AuthPage extends Page<void> {
  /// Creates a page showing [child] for [destination].
  AuthPage({required this.destination, required this.child})
    : super(key: ValueKey<int>(destination.id), name: destination.screen.name);

  /// What this page is.
  final AuthDestination destination;

  /// The screen.
  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) => PageRouteBuilder<void>(
    settings: this,
    transitionDuration: CairnMotion.d300,
    reverseTransitionDuration: CairnMotion.d200,
    pageBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) => child,
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
          // Screens arrive from the reading direction's end.
          final double sign = Directionality.of(context) == TextDirection.rtl
              ? -1
              : 1;
          final Animation<double> entering = CurvedAnimation(
            parent: animation,
            curve: CairnMotion.easeOut,
            reverseCurve: CairnMotion.easeIn,
          );
          final Animation<double> covered = CurvedAnimation(
            parent: secondaryAnimation,
            curve: CairnMotion.standard,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(-0.08 * sign, 0),
            ).animate(covered),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0).animate(covered),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.12 * sign, 0),
                  end: Offset.zero,
                ).animate(entering),
                child: FadeTransition(opacity: entering, child: child),
              ),
            ),
          );
        },
  );
}
