import 'package:cairn_template_docs/cairn_template_docs.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The sizes the widget tests exercise: phone, tablet, desktop.
const Size phone = Size(390, 844);

/// Tablet width: sidebar is still a drawer, no table-of-contents rail.
const Size tablet = Size(768, 1024);

/// Desktop width: sidebar and table-of-contents rail are both visible.
const Size desktop = Size(1280, 900);

/// Pumps in small steps, never `pumpAndSettle`: Cairn has components that
/// repeat forever (spinner, skeleton), so the tree never goes idle.
Future<void> settle(WidgetTester tester, {int steps = 8}) async {
  for (int i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The theme a host would build: Cairn tokens and the Geist family.
ThemeData docsTheme(Brightness brightness) {
  final CairnTheme base = brightness == Brightness.dark
      ? CairnTheme.dark
      : CairnTheme.light;
  return CairnTheme.materialTheme(base.copyWith(fontFamily: 'Geist'));
}

/// Mounts [DocsApp] in a host sized [size] and lets the content load.
///
/// Returns the clipboard text written so far through the `copied` list, so a
/// test can assert what "copy" put on it.
Future<List<String>> pumpDocs(
  WidgetTester tester, {
  Size size = desktop,
  Brightness brightness = Brightness.light,
  DocsLocation initialLocation = const DocsLocation(),
  ValueChanged<DocsLocation>? onLocationChanged,
  OpenExternalLink? onOpenExternal,
  DocsRemoteDataSource? remote,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final List<String> copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add(
          (call.arguments as Map<Object?, Object?>)['text']! as String,
        );
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: docsTheme(brightness),
      home: Scaffold(
        body: DocsApp(
          initialLocation: initialLocation,
          onLocationChanged: onLocationChanged,
          onOpenExternal: onOpenExternal,
          remote: remote,
        ),
      ),
    ),
  );
  await settle(tester, steps: 6);
  return copied;
}

/// A `testWidgets` with semantics switched on, so `bySemanticsLabel` works.
void docsTest(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await body(tester);
    } finally {
      handle.dispose();
    }
  });
}

/// Finds a widget whose semantics label starts with [label]. Buttons merge
/// their visible text into the label, so an exact match would miss them.
Finder sem(String label) =>
    find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}'));
