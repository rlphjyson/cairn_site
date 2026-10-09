import 'package:cairn_template_app_landing/cairn_template_app_landing.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The three widths every widget test runs at: phone, tablet, desktop.
const List<double> testWidths = <double>[390, 768, 1280];

/// The test viewport height.
const double testHeight = 900;

/// A link service that accepts instantly, so tests do not wait on the demo
/// latency.
InMemoryDownloadLinkService instantLinks() =>
    InMemoryDownloadLinkService(latency: Duration.zero);

/// Mounts [AppLandingApp] at [width] and lets the content load.
///
/// Never uses `pumpAndSettle`: Cairn has repeating animations (spinners), so
/// the tree never settles. Tests pump fixed durations instead. Geist is loaded
/// for every test by `flutter_test_config.dart`.
Future<void> pumpAppLanding(
  WidgetTester tester, {
  double width = 1280,
  bool dark = false,
  AppContentDataSource? contentDataSource,
  DownloadLinkService? linkService,
  void Function(StoreKind store, String href)? onStoreTap,
  ValueChanged<String>? onCtaTap,
  String? initialSection,
  ValueChanged<String>? onSectionChanged,
  void Function(GetIt locator)? overrides,
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = Size(width, testHeight);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  final CairnTheme base = (dark ? CairnTheme.dark : CairnTheme.light).copyWith(
    fontFamily: 'Geist',
  );
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CairnTheme.materialTheme(base),
      home: Scaffold(
        body: AppLandingApp(
          contentDataSource: contentDataSource,
          linkService: linkService ?? instantLinks(),
          onStoreTap: onStoreTap,
          onCtaTap: onCtaTap,
          initialSection: initialSection,
          onSectionChanged: onSectionChanged,
          overrides: overrides,
        ),
      ),
    ),
  );
  await settle(tester);
}

/// Pumps long enough for loads, entrance animations and scrolls to finish.
Future<void> settle(WidgetTester tester, [int milliseconds = 900]) async {
  for (int i = 0; i < milliseconds ~/ 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The page's scroll position.
ScrollPosition pagePosition(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable).first).position;

/// Scrolls so [finder] sits well clear of the sticky navbar, then lets reveals
/// finish.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  final ScrollPosition position = pagePosition(tester);
  final double dy = tester.getCenter(finder.first).dy;
  position.jumpTo(
    (position.pixels + dy - 360).clamp(0, position.maxScrollExtent),
  );
  await settle(tester);
}
