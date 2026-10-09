// Regenerates the screenshots shown on the Templates page.
//
//     CAPTURE_SCREENSHOTS=1 FLUTTER_ROOT=<path to flutter> \
//       flutter test test/capture_template_screenshots_test.dart
//
// Skipped in normal runs: it writes into assets/screenshots/, and the PNGs are
// committed so the site shows them without running anything. FLUTTER_ROOT is
// only needed so the Material icon font can be loaded; without it icons render
// as boxes.
//
// Each template has a script: a list of named shots, each preceded by the
// taps that get the app into that state. Mobile templates are framed in a
// phone; web templates are captured at a fixed desktop size.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cairn_site/src/app/site_theme.dart';
import 'package:cairn_template_app_landing/cairn_template_app_landing.dart';
import 'package:cairn_template_auth/cairn_template_auth.dart';
import 'package:cairn_template_blog/cairn_template_blog.dart';
import 'package:cairn_template_chat/cairn_template_chat.dart';
import 'package:cairn_template_dashboard/cairn_template_dashboard.dart';
import 'package:cairn_template_docs/cairn_template_docs.dart';
import 'package:cairn_template_landing/cairn_template_landing.dart';
import 'package:cairn_template_onboarding/cairn_template_onboarding.dart';
import 'package:cairn_template_shop/cairn_template_shop.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final bool _capture = Platform.environment['CAPTURE_SCREENSHOTS'] != null;

/// Pumps in small steps so AnimatedSwitchers finish and drop the old child.
Future<void> _settle(WidgetTester tester, [int frames = 12]) async {
  for (int i = 0; i < frames; i++) {
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

  // Code samples ask for a platform monospace face that tests do not have.
  final File mono = File('C:/Windows/Fonts/consola.ttf');
  if (!mono.existsSync()) return;
  for (final String family in <String>[
    'monospace',
    'ui-monospace',
    'SFMono-Regular',
    'Menlo',
    'Consolas',
  ]) {
    final FontLoader l = FontLoader(family)
      ..addFont(
        mono.readAsBytes().then((Uint8List b) => ByteData.view(b.buffer)),
      );
    await l.load();
  }
}

typedef _Shot = Future<void> Function(String name);

class _Script {
  const _Script({
    required this.slug,
    required this.frame,
    required this.size,
    required this.app,
    required this.run,
    this.pixelRatio = 1,
  });

  final String slug;

  /// Wraps the app for the screenshot: a phone or a plain fixed-size box.
  final Widget Function(Widget app) frame;

  /// The logical size of the test surface.
  final Size size;
  final Widget app;
  final Future<void> Function(WidgetTester tester, _Shot shot) run;
  final double pixelRatio;
}

Widget _phone(Widget app) => Padding(
  padding: const EdgeInsets.all(16),
  child: CairnMockupPhone(width: 360, child: app),
);

Widget _desktop(Widget app) => SizedBox(width: 1200, height: 800, child: app);

Finder _vertical() => find
    .byWidgetPredicate(
      (Widget w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .first;

Future<void> _scroll(WidgetTester tester, double dy) async {
  await tester.drag(_vertical(), Offset(0, -dy));
  await _settle(tester, 6);
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    200,
    scrollable: _vertical(),
    maxScrolls: 80,
  );
  await tester.ensureVisible(find.text(text).first);
  await tester.pump();
  await tester.tap(find.text(text).first);
  await _settle(tester);
}

/// The text field inside the shop's labelled field titled [label].
Finder _shopField(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (Widget w) =>
        w.runtimeType.toString() == 'LabeledField' &&
        find
            .descendant(of: find.byWidget(w), matching: find.text(label))
            .evaluate()
            .isNotEmpty,
  ),
  matching: find.byType(EditableText),
);

Future<void> _fill(WidgetTester tester, String label, String text) async {
  await tester.scrollUntilVisible(
    _shopField(label),
    200,
    scrollable: _vertical(),
    maxScrolls: 80,
  );
  await tester.ensureVisible(_shopField(label));
  await tester.pump();
  await tester.enterText(_shopField(label), text);
  await _settle(tester, 2);
}

final List<_Script> _scripts = <_Script>[
  _Script(
    slug: 'shop',
    frame: _phone,
    size: const Size(520, 900),
    pixelRatio: 2,
    app: const ShopApp(),
    run: (WidgetTester tester, _Shot shot) async {
      await shot('1-shop');
      await _scroll(tester, 700);
      await shot('2-shop-grid');
      await tester.drag(_vertical(), const Offset(0, 5000));
      await _settle(tester, 4);

      await _tap(tester, 'Cloud Runner Trainer');
      await shot('3-product');
      await _tap(tester, 'Add to cart');
      await _tap(tester, 'View cart');
      await shot('4-cart');

      await _tap(tester, 'Checkout');
      await _fill(tester, 'Phone', '555 010 9999');
      await _fill(tester, 'Address', '1 Compiler Way');
      await _fill(tester, 'City', 'Arlington');
      await _fill(tester, 'Postal code', '22201');
      await shot('5-checkout');
      await _tap(tester, 'Continue to payment');
      await _fill(tester, 'Name on card', 'Ada Lovelace');
      await _fill(tester, 'Card number', '4242424242424242');
      await _fill(tester, 'Expiry', '1299');
      await _fill(tester, 'CVC', '123');
      await shot('6-payment');
      await _tap(tester, 'Review order');
      await _tap(tester, 'Place order');
      await _settle(tester, 8);
      await shot('7-confirmation');

      await tester.tap(
        find
            .descendant(
              of: find.byType(CairnDock),
              matching: find.text('Profile'),
            )
            .first,
      );
      await _settle(tester);
      await shot('8-profile');
    },
  ),
  _Script(
    slug: 'dashboard',
    frame: _desktop,
    size: const Size(1200, 800),
    app: const DashboardApp(),
    run: (WidgetTester tester, _Shot shot) async {
      await shot('1-overview');
      await tester.tap(find.text('Analytics').first);
      await _settle(tester);
      await shot('2-analytics');
      await tester.tap(find.text('Orders').first);
      await _settle(tester);
      await shot('3-orders');
      await tester.tap(find.text('Overview').first);
      await _settle(tester);
      await tester.tap(find.text('12 months'));
      await _settle(tester);
      await shot('4-overview-year');
    },
  ),
  _Script(
    slug: 'blog',
    frame: _desktop,
    size: const Size(1200, 800),
    app: const BlogApp(),
    run: (WidgetTester tester, _Shot shot) async {
      await shot('1-home');
      await _scroll(tester, 560);
      await shot('2-home-grid');
      await tester.drag(_vertical(), const Offset(0, 5000));
      await _settle(tester, 4);
      await tester.tap(
        find.text('Design tokens are a contract, not a colour palette').first,
      );
      await _settle(tester);
      await shot('3-post');
      await tester.tap(find.text('About').first);
      await _settle(tester);
      await shot('4-about');
    },
  ),
  _Script(
    slug: 'docs',
    frame: _desktop,
    size: const Size(1200, 800),
    app: const DocsApp(),
    run: (WidgetTester tester, _Shot shot) async {
      await shot('1-introduction');
      await tester.tap(find.text('Installation').first);
      await _settle(tester);
      await shot('2-installation');
      await tester.tap(find.text('AcmeClient').first);
      await _settle(tester);
      await shot('3-api');
    },
  ),
  _Script(
    slug: 'landing',
    frame: _desktop,
    size: const Size(1200, 800),
    app: const LandingApp(),
    run: (WidgetTester tester, _Shot shot) async {
      await shot('1-hero');
      await tester.tap(find.text('Features').first);
      await _settle(tester, 15);
      await shot('2-features');
      await tester.tap(find.text('Pricing').first);
      await _settle(tester, 15);
      await shot('3-pricing');
      await tester.tap(find.text('FAQ').first);
      await _settle(tester, 15);
      await shot('4-faq');
    },
  ),
  _Script(
    slug: 'onboarding',
    frame: _phone,
    size: const Size(520, 900),
    pixelRatio: 2,
    app: const OnboardingApp(),
    run: (WidgetTester tester, _Shot shot) async {
      Future<void> tapAny(String text) async {
        await tester.tap(find.text(text).first);
        await _settle(tester);
      }

      await shot('1-welcome');
      await tapAny('Next');
      await shot('2-value');
      await tapAny('Next');
      await tapAny('Next');
      await tapAny('Get started');
      await tapAny('Allow notifications');
      await shot('3-permissions');
      await tapAny('Continue');
      for (final String chip in <String>['Focus', 'Fitness', 'Reading']) {
        await tapAny(chip);
      }
      await shot('4-interests');
      await tapAny('Continue');
      await tapAny('Feel calmer');
      await tapAny('Continue');
      await tapAny('Continue');
      await tapAny('Create account');
      await shot('5-done');
    },
  ),
  _Script(
    slug: 'auth',
    frame: _phone,
    size: const Size(520, 900),
    pixelRatio: 2,
    app: const AuthApp(showDemoHint: true),
    run: (WidgetTester tester, _Shot shot) async {
      Future<void> tapAny(String text) async {
        await tester.tap(find.text(text).first);
        await _settle(tester);
      }

      Future<void> type(int index, String text) async {
        final Finder f = find.byType(EditableText).at(index);
        await tester.ensureVisible(f);
        await tester.enterText(f, text);
        await _settle(tester, 2);
      }

      await shot('1-welcome');
      await tapAny('Sign in with email');
      await type(0, 'ada@example.com');
      await type(1, 'Cairn-demo-1');
      await shot('2-signin');
      await tapAny('Sign in');
      await shot('3-signed-in');
      await tapAny('Sign out');
      await tapAny('Create an account');
      await type(0, 'Grace Hopper');
      await type(1, 'grace@example.com');
      await type(2, 'Compile-r-1');
      // Typing scrolls the form; bring the title back before the shot.
      await tester.drag(_vertical(), const Offset(0, 1000));
      await _settle(tester, 4);
      await shot('4-signup');
    },
  ),
  _Script(
    slug: 'chat',
    frame: _phone,
    size: const Size(520, 900),
    pixelRatio: 2,
    app: const ChatApp(replyLatency: Duration.zero),
    run: (WidgetTester tester, _Shot shot) async {
      Future<void> tapAny(String text) async {
        await tester.tap(find.text(text).last);
        await _settle(tester);
      }

      await shot('1-chats');
      await tapAny('Contacts');
      await shot('2-contacts');
      await tapAny('Profile');
      await shot('3-profile');
      await tapAny('Chats');
      await tester.tap(find.text('Mina Park').first);
      await _settle(tester);
      await shot('4-thread');
    },
  ),
  _Script(
    slug: 'app_landing',
    frame: _desktop,
    size: const Size(1200, 800),
    app: const AppLandingApp(),
    run: (WidgetTester tester, _Shot shot) async {
      await shot('1-hero');
      for (final (String, String) s in <(String, String)>[
        ('Features', '2-features'),
        ('Reviews', '3-reviews'),
        ('Pricing', '4-pricing'),
      ]) {
        await tester.tap(find.text(s.$1).first);
        await _settle(tester, 15);
        await shot(s.$2);
      }
    },
  ),
];

void main() {
  for (final _Script script in _scripts) {
    for (final Brightness brightness in Brightness.values) {
      final String mode = brightness.name;
      testWidgets('capture ${script.slug} $mode', skip: !_capture, (
        WidgetTester tester,
      ) async {
        await tester.runAsync(_loadMaterialIcons);
        tester.view.physicalSize = script.size;
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
                    child: Material(
                      type: MaterialType.transparency,
                      child: script.frame(script.app),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        // Decode every photo once, so the first frame is not a placeholder.
        await tester.runAsync(() async {
          final BuildContext ctx = tester.element(find.byWidget(script.app));
          final AssetManifest manifest =
              await AssetManifest.loadFromAssetBundle(rootBundle);
          for (final String key in manifest.listAssets()) {
            if (key.startsWith('packages/cairn_template_${script.slug}/') &&
                key.endsWith('.jpg')) {
              await precacheImage(AssetImage(key), ctx);
            }
          }
        });
        await _settle(tester);

        Future<void> shot(String name) async {
          await _settle(tester, 6);
          await tester.runAsync(() async {
            final RenderRepaintBoundary object =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final ui.Image image = await object.toImage(
              pixelRatio: script.pixelRatio,
            );
            final ByteData? data = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final File out = File(
              'assets/screenshots/${script.slug}-$name-$mode.png',
            );
            await out.create(recursive: true);
            await out.writeAsBytes(data!.buffer.asUint8List());
          });
        }

        await script.run(tester, shot);
      });
    }
  }
}
