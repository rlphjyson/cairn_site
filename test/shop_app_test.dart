import 'package:cairn_site/src/app/routes.dart';
import 'package:cairn_site/src/data/templates_catalog.dart';
import 'package:cairn_site/src/pages/template_detail_page.dart';
import 'package:cairn_site/src/pages/templates_page.dart';
import 'package:cairn_template_app_landing/cairn_template_app_landing.dart';
import 'package:cairn_template_auth/cairn_template_auth.dart';
import 'package:cairn_template_blog/cairn_template_blog.dart';
import 'package:cairn_template_chat/cairn_template_chat.dart';
import 'package:cairn_template_dashboard/cairn_template_dashboard.dart';
import 'package:cairn_template_docs/cairn_template_docs.dart';
import 'package:cairn_template_landing/cairn_template_landing.dart';
import 'package:cairn_template_onboarding/cairn_template_onboarding.dart';
import 'package:cairn_template_settings/cairn_template_settings.dart';
import 'package:cairn_template_shop/cairn_template_shop.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'site_harness.dart';

/// Pumps in small steps: Cairn has repeating animations, so pumpAndSettle
/// would never return.
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The templates have their own thorough suites under `templates/<name>/test`;
/// these tests only check that the site mounts each one and links to it.
void main() {
  group('templates page', () {
    testWidgets('lists every template as a card, with no app mounted', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pumpSite(tester, Routes.templates, surface: const Size(1440, 2600));
      await _settle(tester);
      expect(find.byType(TemplatesPage), findsOneWidget);
      expect(find.byType(TemplateCard), findsNWidgets(templateCatalog.length));
      expect(find.byType(ShopApp), findsNothing);
      // A grid, not a sideways scroller.
      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
        findsNothing,
      );
      for (final TemplateEntry t in templateCatalog) {
        expect(
          find.bySemanticsLabel(
            RegExp('^${RegExp.escape(t.name)} template, ${t.kind.label}'),
          ),
          findsOneWidget,
          reason: t.slug,
        );
      }
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    const Map<String, Type> apps = <String, Type>{
      'shop': ShopApp,
      'dashboard': DashboardApp,
      'blog': BlogApp,
      'docs': DocsApp,
      'landing': LandingApp,
      'onboarding': OnboardingApp,
      'auth': AuthApp,
      'chat': ChatApp,
      'app_landing': AppLandingApp,
      'settings': SettingsApp,
    };
    for (final MapEntry<String, Type> e in apps.entries) {
      testWidgets('/templates/${e.key} mounts its template', (
        WidgetTester tester,
      ) async {
        await pumpSite(
          tester,
          Routes.template(e.key),
          surface: const Size(1440, 2600),
        );
        await _settle(tester);
        // The template's own frame; the landing page adds a second browser
        // inside its hero.
        expect(
          find.byType(CairnMockupBrowser).evaluate().length +
              find.byType(CairnMockupPhone).evaluate().length,
          greaterThanOrEqualTo(1),
        );
        expect(
          find.byWidgetPredicate((Widget w) => w.runtimeType == e.value),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'a server-rendered template shows its screenshots, not an app',
      (WidgetTester tester) async {
        await pumpSite(
          tester,
          Routes.template('jaspr_store'),
          surface: const Size(1440, 2600),
        );
        await _settle(tester);
        expect(find.text('Server-rendered with Jaspr'), findsOneWidget);
        expect(find.byType(CairnMockupBrowser), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('a card opens the template page', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await pumpSite(tester, Routes.templates, surface: const Size(1440, 2600));
      await _settle(tester);
      await tester.tap(
        find.bySemanticsLabel(RegExp('^Dashboard template, Web')),
      );
      await _settle(tester);
      expect(find.byType(TemplatesPage), findsNothing);
      expect(find.byType(TemplateDetailPage), findsOneWidget);
      expect(find.byType(DashboardApp), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    testWidgets('a template page steps to the next and back to the index', (
      WidgetTester tester,
    ) async {
      await pumpSite(
        tester,
        Routes.template(templateCatalog.first.slug),
        surface: const Size(1440, 3200),
      );
      await _settle(tester);
      final TemplateEntry second = templateCatalog[1];
      await tester.tap(find.widgetWithText(CairnButton, second.name).last);
      await _settle(tester);
      expect(
        find.byWidgetPredicate(
          (Widget w) => w is TemplateDetailPage && w.entry.slug == second.slug,
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.text('Back to all ${templateCatalog.length} templates'),
      );
      await _settle(tester);
      expect(find.byType(TemplatesPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unknown template is a 404', (WidgetTester tester) async {
      await pumpSite(tester, '/templates/nope');
      expect(find.byType(TemplatesPage), findsNothing);
      expect(find.byType(TemplateDetailPage), findsNothing);
    });
  });
}
