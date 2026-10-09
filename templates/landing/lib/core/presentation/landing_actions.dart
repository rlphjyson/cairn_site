import 'package:flutter/widgets.dart';

/// Opens a link from the content.
///
/// Links that start with `#` scroll to that section. Everything else goes to
/// the `onLink` callback given to `LandingApp`, where the host decides what to
/// do (open a URL, push a route, start a checkout).
class LandingActions extends InheritedWidget {
  /// Creates the actions.
  const LandingActions({super.key, required this.open, required super.child});

  /// Opens [href].
  final ValueChanged<String> open;

  /// The nearest actions.
  static LandingActions of(BuildContext context) {
    final LandingActions? a = context
        .dependOnInheritedWidgetOfExactType<LandingActions>();
    assert(a != null, 'No LandingActions above this context.');
    return a!;
  }

  @override
  bool updateShouldNotify(LandingActions oldWidget) => open != oldWidget.open;
}
