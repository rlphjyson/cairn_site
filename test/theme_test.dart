import 'package:cairn_site/src/app/routes.dart';
import 'package:cairn_site/src/app/site_theme.dart';
import 'package:cairn_site/src/shell/site_shell.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'site_harness.dart';

void main() {
  testWidgets('a fresh visitor gets the dark theme', (
    WidgetTester tester,
  ) async {
    await pumpSite(tester, Routes.home);

    final MaterialApp app = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(app.themeMode, ThemeMode.dark);

    // Not just the flag — the pixels. The shell paints its Scaffold with
    // CairnTheme.of(context).background, so this asserts the extension is
    // actually resolving to the dark token.
    final Scaffold scaffold = tester.widget<Scaffold>(
      find.byType(Scaffold).first,
    );
    expect(scaffold.backgroundColor, CairnColors.darkBackground);
  });

  testWidgets('the toggle reaches the light theme and back', (
    WidgetTester tester,
  ) async {
    await pumpSite(tester, Routes.home);

    Future<void> tapToggle() async {
      await tester.tap(find.byType(ThemeToggle));
      await tester.pump();
      // MaterialApp wraps the tree in an AnimatedTheme, so every token is
      // interpolated across the change. Wait for it to land.
      await tester.pump(const Duration(milliseconds: 600));
    }

    await tapToggle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      CairnColors.lightBackground,
    );

    await tapToggle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      CairnColors.darkBackground,
    );
  });

  testWidgets('the toggle survives navigation', (WidgetTester tester) async {
    await pumpSite(tester, Routes.home);
    await tester.tap(find.byType(ThemeToggle));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.widgetWithText(CairnButton, 'Components').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    // The ShellRoute keeps the header mounted across navigations, so the
    // choice is not reset by changing page.
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });

  group('SiteThemeController', () {
    test('defaults to dark', () {
      final SiteThemeController controller = SiteThemeController();
      expect(controller.mode, ThemeMode.dark);
      expect(controller.isDark, isTrue);
      controller.dispose();
    });

    test('only ever moves between the two explicit modes', () {
      final SiteThemeController controller = SiteThemeController();
      controller.toggle();
      expect(controller.mode, ThemeMode.light);
      controller.toggle();
      expect(controller.mode, ThemeMode.dark);
      controller.dispose();
    });

    test('notifies listeners once per change', () {
      final SiteThemeController controller = SiteThemeController();
      int calls = 0;
      controller
        ..addListener(() => calls++)
        ..set(ThemeMode.light)
        ..set(ThemeMode.light)
        ..toggle();
      expect(calls, 2);
      controller.dispose();
    });
  });
}
