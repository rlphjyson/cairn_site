import 'package:cairn_template_dashboard/cairn_template_dashboard.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps in small steps: Cairn has repeating animations, so pumpAndSettle
/// would never return, and an AnimatedSwitcher keeps its old child mounted
/// until a couple of frames after it finishes.
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _mount(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          CairnTheme.light.copyWith(fontFamily: 'Geist'),
        ],
      ),
      home: const Material(child: DashboardApp()),
    ),
  );
  await _settle(tester);
}

String _firstCurrency(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((Text t) => t.data)
    .whereType<String>()
    .firstWhere((String s) => s.startsWith('\$') && s.length > 4);

void main() {
  for (final Size size in const <Size>[
    Size(1200, 760),
    Size(900, 700),
    Size(390, 800),
  ]) {
    testWidgets('renders every page at ${size.width.toInt()}px', (
      WidgetTester tester,
    ) async {
      await _mount(tester, size);
      expect(find.text('Total revenue'), findsOneWidget);

      await tester.tap(find.text('Analytics').first);
      await _settle(tester);
      expect(find.text('Traffic sources'), findsOneWidget);
      expect(find.text('Conversion'), findsWidgets);

      await tester.tap(find.text('Orders').first);
      await _settle(tester);
      expect(find.text('24 of 24 orders'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('changing the period reloads the figures', (
    WidgetTester tester,
  ) async {
    await _mount(tester, const Size(1200, 760));
    final String before = _firstCurrency(tester);

    await tester.tap(find.text('12 months'));
    await _settle(tester);
    expect(_firstCurrency(tester), isNot(before));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the orders page filters by status', (WidgetTester tester) async {
    await _mount(tester, const Size(1200, 900));
    await tester.tap(find.text('Orders').first);
    await _settle(tester);

    await tester.tap(find.text('Failed').first);
    await _settle(tester);
    expect(find.text('24 of 24 orders'), findsNothing);
    expect(find.textContaining(' of 24 orders'), findsOneWidget);

    await tester.tap(find.text('All').first);
    await _settle(tester);
    expect(find.text('24 of 24 orders'), findsOneWidget);
  });

  testWidgets('two apps do not share state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            CairnTheme.light.copyWith(fontFamily: 'Geist'),
          ],
        ),
        home: const Material(
          child: Row(
            children: <Widget>[
              Expanded(child: DashboardApp()),
              Expanded(child: DashboardApp()),
            ],
          ),
        ),
      ),
    );
    await _settle(tester);
    expect(tester.takeException(), isNull);
  });
}
