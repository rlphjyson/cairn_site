import 'package:cairn_site/src/app/routes.dart';
import 'package:cairn_site/src/templates/shop/shop_app.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'site_harness.dart';

/// A label inside the phone's dock, not the page's captions of the same name.
Finder _dock(String label) =>
    find.descendant(of: find.byType(CairnDock), matching: find.text(label));

/// Pumps in small steps: a single long pump jumps the clock but leaves an
/// AnimatedSwitcher's outgoing child mounted until the next frame.
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('e-commerce template', () {
    testWidgets('is served at /templates', (WidgetTester tester) async {
      await pumpSite(tester, Routes.templates);
      expect(find.byType(ShopApp), findsOneWidget);
      expect(find.text('Cairn MCP server'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('browse, add to cart and check out', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, Routes.templates);

      // Filter, then open a product.
      await tester.tap(find.text('Audio').first);
      await _settle(tester);
      expect(find.text('Court Low Sneaker'), findsNothing);
      await tester.tap(find.text('Monitor Pro Over-ear'));
      await _settle(tester);
      expect(find.text('Add to cart'), findsOneWidget);

      await tester.tap(find.text('Add to cart'));
      await _settle(tester);
      expect(find.text('Add another (1)'), findsOneWidget);

      // Cart.
      await tester.tap(_dock('Cart'));
      await _settle(tester);
      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text(r'$249'), findsWidgets);

      await tester.tap(find.text('Checkout'));
      await _settle(tester);
      expect(find.text('Order placed'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('saved tab lists the hearted product', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, Routes.templates);
      await tester.tap(_dock('Saved'));
      await _settle(tester);
      expect(find.text('Classic White Low'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
