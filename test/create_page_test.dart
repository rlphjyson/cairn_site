import 'package:cairn_site/src/app/routes.dart';
import 'package:cairn_site/src/pages/create_page.dart';
import 'package:cairn_site/src/pages/home_page.dart';
import 'package:cairn_site/src/widgets/code_block.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'site_harness.dart';

/// The code currently rendered in the page's (single visible) code block.
String _emitted(WidgetTester tester) =>
    tester.widget<CodeBlock>(find.byType(CodeBlock).first).code;

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('the nav entry navigates to the page', (
    WidgetTester tester,
  ) async {
    await pumpSite(tester, Routes.home);
    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.widgetWithText(CairnButton, 'Create').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(CreatePage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the default output is a runnable main.dart', (
    WidgetTester tester,
  ) async {
    await pumpSite(tester, Routes.create);

    final String code = _emitted(tester);
    expect(code, contains('void main() => runApp(const MyApp());'));
    // The three API calls the snippet stands or falls on.
    expect(code, contains('CairnTheme.materialTheme(myAppLight)'));
    expect(code, contains('themeMode: ThemeMode.dark'));
    expect(code, contains('CairnToaster(child: child ?? const SizedBox'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the package name flows into the generated code', (
    WidgetTester tester,
  ) async {
    await pumpSite(tester, Routes.create);
    expect(_emitted(tester), contains('class MyApp extends StatelessWidget'));

    // The controls column is the first thing in the page, so its input is the
    // first editable field on screen.
    await tester.enterText(find.byType(EditableText).first, 'acme console!');
    await _settle(tester);

    final String code = _emitted(tester);
    // Sanitised to a legal package name, and pascal-cased for the app class.
    expect(code, contains('class AcmeConsole extends StatelessWidget'));
    expect(code, contains("title: 'acme_console'"));
    expect(code, isNot(contains('MyApp')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the radius control rewrites the emitted theme', (
    WidgetTester tester,
  ) async {
    await pumpSite(tester, Routes.create);

    await tester.tap(find.text('theme.dart'));
    await _settle(tester);
    expect(_emitted(tester), contains('const double kBaseRadius = 10.0;'));
    expect(_emitted(tester), contains('sm 6px, md 8px, lg 10px'));

    await tester.tap(find.widgetWithText(CairnButton, 'Round'));
    await _settle(tester);

    final String code = _emitted(tester);
    expect(code, contains('const double kBaseRadius = 16.0;'));
    // The derived scale is recomputed, not restated.
    expect(code, contains('sm 9.6px, md 12.8px, lg 16px'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme mode and accent reach the generated theme', (
    WidgetTester tester,
  ) async {
    await pumpSite(tester, Routes.create);
    expect(_emitted(tester), contains('themeMode: ThemeMode.dark'));

    await tester.tap(find.text('Follow the system'));
    await _settle(tester);
    expect(_emitted(tester), contains('themeMode: ThemeMode.system'));

    await tester.tap(find.text('theme.dart'));
    await _settle(tester);
    // Neutral emits no token overrides at all.
    expect(_emitted(tester), isNot(contains('primary:')));

    await tester.tap(find.text('Neutral'));
    await _settle(tester);
    await tester.tap(find.text('Violet').last);
    await _settle(tester);

    final String code = _emitted(tester);
    expect(code, contains('primary: const Color(0xFF7C3AED),'));
    expect(code, contains('ring: const Color(0xFF7C3AED),'));
    expect(code, contains("import 'package:flutter/material.dart';"));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the header still fits at the desktop breakpoint', (
    WidgetTester tester,
  ) async {
    await pumpSite(tester, Routes.create, surface: const Size(1024, 2400));
    expect(find.byType(CreatePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
