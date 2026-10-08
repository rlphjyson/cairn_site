// Regenerates the screenshots shown on the Templates page.
//
//     CAPTURE_SCREENSHOTS=1 flutter test test/capture_template_screenshots_test.dart
//
// Skipped in normal runs: it writes into assets/screenshots/, and the PNGs are
// committed so the site shows them without running anything.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cairn_site/src/app/site_theme.dart';
import 'package:cairn_site/src/templates/shop/shop_app.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final bool _capture = Platform.environment['CAPTURE_SCREENSHOTS'] != null;

/// Pumps in small steps so AnimatedSwitchers finish and drop the old child.
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _loadMaterialIcons() async {
  final String flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '';
  final File font = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  );
  if (!font.existsSync()) return;
  final FontLoader loader = FontLoader(
    'MaterialIcons',
  )..addFont(font.readAsBytes().then((Uint8List b) => ByteData.view(b.buffer)));
  await loader.load();
}

void main() {
  for (final Brightness brightness in Brightness.values) {
    final String mode = brightness.name;
    testWidgets('capture $mode', skip: !_capture, (WidgetTester tester) async {
      await tester.runAsync(_loadMaterialIcons);
      tester.view.physicalSize = const Size(520, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final GlobalKey boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SiteTokens.themeData(brightness),
          home: Builder(
            builder: (BuildContext context) => ColoredBox(
              color: CairnTheme.of(context).background,
              child: Center(
                child: RepaintBoundary(
                  key: boundary,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Material(
                      type: MaterialType.transparency,
                      child: CairnMockupPhone(width: 360, child: ShopApp()),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final BuildContext ctx = tester.element(find.byType(ShopApp));
        for (final String name in <String>[
          'sneaker-red',
          'sneaker-nike',
          'sneaker-box',
          'headphones-white',
          'headphones-black',
          'watch-classic',
          'watch-sport',
          'sunglasses-bag',
        ]) {
          await precacheImage(AssetImage('assets/images/$name.jpg'), ctx);
        }
      });
      await _settle(tester);

      Future<void> shot(String name) async {
        await _settle(tester);
        await tester.runAsync(() async {
          final RenderRepaintBoundary object =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final ui.Image image = await object.toImage(pixelRatio: 2);
          final ByteData? data = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          final File out = File('assets/screenshots/shop-$name-$mode.png');
          await out.create(recursive: true);
          await out.writeAsBytes(data!.buffer.asUint8List());
        });
      }

      Future<void> tapLast(String text) async {
        await tester.tap(find.text(text).last);
        await _settle(tester);
      }

      // Storefront, top then scrolled.
      await shot('1-shop');
      await tester.drag(find.byType(ListView).first, const Offset(0, -420));
      await _settle(tester);
      await shot('2-shop-grid');
      await tester.drag(find.byType(ListView).first, const Offset(0, 900));
      await _settle(tester);

      // A product page, then add two things to the cart.
      await tester.tap(find.text('Court Low Sneaker'));
      await _settle(tester);
      await shot('3-product');
      await tester.tap(find.text('Add to cart'));
      await _settle(tester);
      await tester.tap(find.bySemanticsLabel('Back'));
      await _settle(tester);
      await tester.tap(find.text('Street Low Sneaker'));
      await _settle(tester);
      await tester.tap(find.text('Add to cart'));
      await _settle(tester);
      await tester.tap(find.bySemanticsLabel('Back'));
      await _settle(tester);

      await tapLast('Saved');
      await shot('4-saved');
      await tapLast('Cart');
      await shot('5-cart');
      await tester.tap(find.text('Checkout'));
      await _settle(tester);
      await shot('6-confirmation');
      await tapLast('Profile');
      await shot('7-profile');
    });
  }
}
