import 'dart:io';

import 'package:cairn_template_landing/cairn_template_landing.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The three widths every widget test runs at: phone, tablet, desktop.
const List<double> testWidths = <double>[390, 768, 1280];

/// The test viewport height.
const double testHeight = 900;

bool _fontsLoaded = false;

/// Loads Geist when the repo's `fonts/` folder is reachable, so text metrics
/// match the real app. Without it Flutter's test font (Ahem) is far wider and
/// would trigger overflows that never happen on a device.
Future<void> loadTestFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  final List<String> candidates = <String>[
    '../../fonts',
    'fonts',
    'test/fonts',
  ];
  for (final String dir in candidates) {
    final File regular = File('$dir/Geist-Regular.ttf');
    if (!regular.existsSync()) continue;
    final FontLoader loader = FontLoader('Geist');
    for (final String name in <String>[
      'Geist-Regular.ttf',
      'Geist-Medium.ttf',
      'Geist-SemiBold.ttf',
      'Geist-Bold.ttf',
    ]) {
      final File f = File('$dir/$name');
      if (f.existsSync()) {
        loader.addFont(
          Future<ByteData>.value(ByteData.sublistView(f.readAsBytesSync())),
        );
      }
    }
    await loader.load();
    return;
  }
}

/// Mounts [LandingApp] at [width] and lets the content load.
///
/// Never uses `pumpAndSettle`: Cairn has repeating animations (spinners), so
/// the tree never settles. Tests pump fixed durations instead.
Future<void> pumpLanding(
  WidgetTester tester, {
  double width = 1280,
  bool dark = false,
  ValueChanged<String>? onLink,
  String? initialSection,
  ValueChanged<String>? onSectionChanged,
  void Function(GetIt locator)? overrides,
}) async {
  await tester.runAsync(loadTestFonts);
  tester.view.physicalSize = Size(width, testHeight);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final CairnTheme base = (dark ? CairnTheme.dark : CairnTheme.light).copyWith(
    fontFamily: 'Geist',
  );
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CairnTheme.materialTheme(base),
      home: Scaffold(
        body: LandingApp(
          onLink: onLink,
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
