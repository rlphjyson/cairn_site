import 'package:cairn_site/src/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mounts the site at [location] on a desktop-sized surface.
///
/// Deliberately does **not** call `pumpAndSettle`. Several Cairn components —
/// Spinner, the Skeleton pulse, indeterminate Progress — never stop scheduling
/// frames by design, so `pumpAndSettle` would time out on any page containing
/// one rather than telling you anything about that page. Pumping a fixed span
/// gets past the route transition and the hero reveal, which is all these
/// tests need.
Future<void> pumpSite(
  WidgetTester tester,
  String location, {
  Size surface = const Size(1440, 2400),
}) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(CairnSiteApp(initialLocation: location));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
}
