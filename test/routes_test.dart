import 'package:cairn_site/src/app/routes.dart';
import 'package:cairn_site/src/data/blocks_catalog.dart';
import 'package:cairn_site/src/data/components_catalog.dart';
import 'package:cairn_site/src/data/docs_catalog.dart';
import 'package:cairn_site/src/pages/blocks_page.dart';
import 'package:cairn_site/src/pages/charts_page.dart';
import 'package:cairn_site/src/pages/component_detail_page.dart';
import 'package:cairn_site/src/pages/components_page.dart';
import 'package:cairn_site/src/pages/directory_page.dart';
import 'package:cairn_site/src/pages/docs_page.dart';
import 'package:cairn_site/src/pages/home_page.dart';
import 'package:cairn_site/src/pages/not_found_page.dart';
import 'package:cairn_site/src/pages/typeset_page.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'site_harness.dart';

void main() {
  group('every top-level section renders', () {
    testWidgets('home', (WidgetTester tester) async {
      await pumpSite(tester, Routes.home);
      expect(find.byType(HomePage), findsOneWidget);
      expect(
        find.text('shadcn/ui, measured and rebuilt in Flutter.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('docs redirects to the introduction', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, Routes.docs);
      expect(find.byType(DocsPage), findsOneWidget);
      expect(find.text('Introduction'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('components', (WidgetTester tester) async {
      await pumpSite(tester, Routes.components);
      expect(find.byType(ComponentsPage), findsOneWidget);
      expect(
        find.text('${componentCatalog.length} components'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('blocks', (WidgetTester tester) async {
      await pumpSite(tester, Routes.blocks);
      expect(find.byType(BlocksPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('charts', (WidgetTester tester) async {
      await pumpSite(tester, Routes.charts);
      expect(find.byType(ChartsPage), findsOneWidget);
      expect(
        find.text('Cairn does not ship a chart component'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('directory', (WidgetTester tester) async {
      await pumpSite(tester, Routes.directory);
      expect(find.byType(DirectoryPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('typeset', (WidgetTester tester) async {
      await pumpSite(tester, Routes.typeset);
      expect(find.byType(TypesetPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unknown path renders the 404 page', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, '/nope');
      expect(find.byType(NotFoundPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('every documentation page renders', () {
    for (final DocPage page in docsCatalog) {
      testWidgets(page.slug, (WidgetTester tester) async {
        await pumpSite(tester, page.path);
        expect(find.byType(DocsPage), findsOneWidget);
        expect(find.text(page.title), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('every component detail page renders', () {
    for (final ComponentEntry entry in componentCatalog) {
      testWidgets(entry.slug, (WidgetTester tester) async {
        await pumpSite(tester, entry.path);
        expect(find.byType(ComponentDetailPage), findsOneWidget);
        expect(find.text(entry.name), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('narrow layouts do not overflow', () {
    const Size phone = Size(390, 3600);

    for (final String location in <String>[
      Routes.home,
      Routes.components,
      Routes.blocks,
      Routes.charts,
      Routes.directory,
      Routes.typeset,
      Routes.docsIntroduction,
    ]) {
      testWidgets(location, (WidgetTester tester) async {
        await pumpSite(tester, location, surface: phone);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('the blocks page renders every block', (
    WidgetTester tester,
  ) async {
    await pumpSite(tester, Routes.blocks);
    for (final BlockEntry block in blockCatalog) {
      expect(find.text(block.name), findsWidgets, reason: block.slug);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('the nav bar actually navigates', (WidgetTester tester) async {
    await pumpSite(tester, Routes.home);
    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.widgetWithText(CairnButton, 'Typeset').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(TypesetPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
