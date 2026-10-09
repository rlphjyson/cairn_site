import 'package:flutter/widgets.dart';

import '../../domain/site/models/site_info.dart';

/// Opens links and store buttons from the content.
///
/// Links that start with `#` scroll to that section. Everything else goes to
/// the `onCtaTap` callback given to `AppLandingApp`; the two store buttons go
/// to `onStoreTap`. The host decides what to do (open a URL, push a route).
class AppLandingActions extends InheritedWidget {
  /// Creates the actions.
  const AppLandingActions({
    super.key,
    required this.open,
    required this.openStore,
    required super.child,
  });

  /// Opens [href]: an anchor scrolls, anything else reaches `onCtaTap`.
  final ValueChanged<String> open;

  /// Opens a store listing.
  final void Function(StoreKind store, String href) openStore;

  /// The nearest actions.
  static AppLandingActions of(BuildContext context) {
    final AppLandingActions? a = context
        .dependOnInheritedWidgetOfExactType<AppLandingActions>();
    assert(a != null, 'No AppLandingActions above this context.');
    return a!;
  }

  @override
  bool updateShouldNotify(AppLandingActions oldWidget) =>
      open != oldWidget.open || openStore != oldWidget.openStore;
}
