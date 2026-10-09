import 'package:cairn_template_docs/cairn_template_docs.dart';
import 'package:cairn_template_docs/core/presentation/navigation/docs_navigation_cubit.dart';
import 'package:cairn_template_docs/presentation/docs/widgets/toc_rail.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

DocsNavigationCubit navOf(WidgetTester tester) =>
    BlocProvider.of<DocsNavigationCubit>(
      tester.element(find.byType(CairnToaster)),
    );

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(sem('Open navigation menu'));
  await settle(tester);
}

Future<void> openPalette(WidgetTester tester) async {
  await tester.tap(sem('Search documentation').first);
  await settle(tester);
}

double articleOffset(WidgetTester tester) {
  final Finder article = find
      .byWidgetPredicate(
        (Widget w) =>
            w is SingleChildScrollView &&
            w.scrollDirection == Axis.vertical &&
            w.controller != null,
      )
      .first;
  return tester.widget<SingleChildScrollView>(article).controller!.offset;
}

void main() {
  group('layout at every width', () {
    for (final Brightness brightness in Brightness.values) {
      for (final Size size in <Size>[phone, tablet, desktop]) {
        docsTest(
          'renders pages without overflow: ${size.width.toInt()} ${brightness.name}',
          (WidgetTester tester) async {
            await pumpDocs(tester, size: size, brightness: brightness);
            for (final String slug in <String>[
              'introduction',
              'installation',
              'quick-start',
              'configuration',
              'authentication',
              'error-handling',
              'api-projects',
              'changelog',
            ]) {
              navOf(tester).openPage(slug);
              await settle(tester, steps: 4);
              expect(find.byType(Scrollable), findsWidgets);
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    docsTest('desktop shows sidebar and rail', (WidgetTester tester) async {
      await pumpDocs(tester);
      expect(sem('Documentation navigation'), findsOneWidget);
      expect(find.byType(TocRail), findsOneWidget);
      expect(sem('Open navigation menu'), findsNothing);
      expect(find.text('On this page'), findsOneWidget);
    });

    docsTest('tablet has a drawer and no rail', (WidgetTester tester) async {
      await pumpDocs(tester, size: tablet);
      expect(find.byType(TocRail), findsNothing);
      expect(sem('Open navigation menu'), findsOneWidget);
      expect(sem('Documentation navigation'), findsNothing);
    });

    docsTest('1099 px hides the rail, 1100 px shows it', (
      WidgetTester tester,
    ) async {
      await pumpDocs(tester, size: const Size(1099, 800));
      expect(find.byType(TocRail), findsNothing);
      await pumpDocs(tester, size: const Size(1100, 800));
      expect(find.byType(TocRail), findsOneWidget);
    });
  });

  group('navigation', () {
    docsTest('sidebar opens a page and marks it active', (
      WidgetTester tester,
    ) async {
      await pumpDocs(tester);
      await tester.tap(sem('Installation').first);
      await settle(tester);
      expect(navOf(tester).state.pageSlug, 'installation');
      expect(find.text('Add the package'), findsWidgets);
      expect(
        tester.getSemantics(sem('Installation').first),
        isSemantics(isSelected: true, isButton: true),
      );
    });

    docsTest('a section collapses and expands', (WidgetTester tester) async {
      await pumpDocs(tester);
      expect(find.text('Testing'), findsOneWidget);
      await tester.tap(find.text('Guides').first);
      await settle(tester);
      expect(find.text('Testing'), findsNothing);
      await tester.tap(find.text('Guides').first);
      await settle(tester);
      expect(find.text('Testing'), findsOneWidget);
    });

    docsTest('previous and next links walk the reading order', (
      WidgetTester tester,
    ) async {
      await pumpDocs(
        tester,
        initialLocation: const DocsLocation(pageSlug: 'quick-start'),
      );
      await tester.ensureVisible(sem('Next: Configuration'));
      await tester.tap(sem('Next: Configuration'));
      await settle(tester);
      expect(navOf(tester).state.pageSlug, 'configuration');
      await tester.ensureVisible(sem('Previous: Quick start'));
      await tester.tap(sem('Previous: Quick start'));
      await settle(tester);
      expect(navOf(tester).state.pageSlug, 'quick-start');
    });

    docsTest('breadcrumb links back to the section', (
      WidgetTester tester,
    ) async {
      await pumpDocs(
        tester,
        initialLocation: const DocsLocation(pageSlug: 'pagination'),
      );
      await tester.tap(find.text('Guides').last);
      await settle(tester);
      expect(navOf(tester).state.pageSlug, 'configuration');
    });

    docsTest('an unknown page shows the not-found state', (
      WidgetTester tester,
    ) async {
      await pumpDocs(
        tester,
        initialLocation: const DocsLocation(pageSlug: 'nope'),
      );
      expect(find.text('Page not found'), findsOneWidget);
      await tester.tap(find.text('Go to the first page'));
      await settle(tester);
      expect(navOf(tester).state.pageSlug, 'introduction');
      expect(find.text('Page not found'), findsNothing);
    });

    docsTest('reports location changes and follows initialLocation', (
      WidgetTester tester,
    ) async {
      final List<DocsLocation> seen = <DocsLocation>[];
      await pumpDocs(tester, onLocationChanged: seen.add);
      navOf(tester).openPage('faq');
      await settle(tester);
      expect(seen.single, const DocsLocation(pageSlug: 'faq'));

      await tester.pumpWidget(
        MaterialApp(
          theme: docsTheme(Brightness.light),
          home: Scaffold(
            body: DocsApp(
              initialLocation: const DocsLocation(pageSlug: 'testing'),
              onLocationChanged: seen.add,
            ),
          ),
        ),
      );
      await settle(tester);
      expect(navOf(tester).state.pageSlug, 'testing');
    });

    docsTest('external links go to the host handler', (
      WidgetTester tester,
    ) async {
      final List<String> opened = <String>[];
      await pumpDocs(tester, onOpenExternal: opened.add);
      await tester.ensureVisible(sem('Edit this page'));
      await tester.tap(sem('Edit this page'));
      expect(opened.single, endsWith('/v2.0/introduction.md'));
    });

    docsTest('without a host handler an external link is copied', (
      WidgetTester tester,
    ) async {
      final List<String> copied = await pumpDocs(tester);
      navOf(tester).openPage('installation');
      await settle(tester);
      await tester.ensureVisible(sem('Report an issue'));
      await tester.tap(sem('Report an issue'));
      await settle(tester, steps: 3);
      expect(copied.single, contains('github.com'));
      expect(find.text('Link copied'), findsOneWidget);
      await settle(tester, steps: 30);
    });
  });

  group('search', () {
    for (final Size size in <Size>[phone, tablet, desktop]) {
      docsTest(
        'palette finds a heading and scrolls to it: ${size.width.toInt()}',
        (WidgetTester tester) async {
          await pumpDocs(tester, size: size);
          await openPalette(tester);
          expect(find.byType(CairnCommand), findsOneWidget);
          await tester.enterText(find.byType(EditableText), 'back-off');
          await settle(tester, steps: 3);
          await tester.tap(find.text('Configuration › Retries and back-off'));
          await settle(tester);
          final DocsNavigationState nav = navOf(tester).state;
          expect(nav.pageSlug, 'configuration');
          expect(nav.headingId, 'retries-and-back-off');
          expect(find.byType(CairnCommand), findsNothing);
          expect(articleOffset(tester), greaterThan(0));
        },
      );
    }

    docsTest('palette lists pages by section and says when nothing matches', (
      WidgetTester tester,
    ) async {
      await pumpDocs(tester);
      await openPalette(tester);
      expect(find.text('Getting started'), findsWidgets);
      await tester.enterText(find.byType(EditableText), 'zzzzqq');
      await settle(tester, steps: 3);
      expect(find.text('No results found.'), findsOneWidget);
    });

    docsTest('Ctrl+K opens the palette', (WidgetTester tester) async {
      await pumpDocs(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await settle(tester);
      expect(find.byType(CairnCommand), findsOneWidget);
    });

    docsTest('the desktop search button shows the shortcut hint', (
      WidgetTester tester,
    ) async {
      await pumpDocs(tester);
      expect(find.byType(CairnKbdGroup), findsOneWidget);
      expect(find.text('Search docs...'), findsOneWidget);
    });
  });

  group('versions', () {
    docsTest('switching to v1.x shows another content set and a notice', (
      WidgetTester tester,
    ) async {
      await pumpDocs(tester);
      await tester.tap(find.byType(CairnSelect<String>));
      await settle(tester);
      await tester.tap(find.text('v1.x').last);
      await settle(tester);
      expect(navOf(tester).state.versionId, 'v1.x');
      expect(find.text('Authentication'), findsNothing);
      expect(find.text('You are reading v1.x'), findsOneWidget);
      await tester.tap(find.text('Switch to v2.0'));
      await settle(tester);
      expect(navOf(tester).state.versionId, 'v2.0');
      expect(find.text('Authentication'), findsOneWidget);
    });

    docsTest('a page missing from the other version says so', (
      WidgetTester tester,
    ) async {
      await pumpDocs(
        tester,
        initialLocation: const DocsLocation(pageSlug: 'authentication'),
      );
      navOf(tester).selectVersion('v1.x');
      await settle(tester);
      expect(find.text('Page not found'), findsOneWidget);
      expect(find.textContaining('v1.x'), findsWidgets);
    });
  });

  group('content', () {
    docsTest('copy puts the code on the clipboard and shows a toast', (
      WidgetTester tester,
    ) async {
      final List<String> copied = await pumpDocs(
        tester,
        initialLocation: const DocsLocation(pageSlug: 'installation'),
      );
      await tester.tap(sem('Copy code to clipboard').first);
      await settle(tester, steps: 3);
      expect(copied.single, 'dart pub add acme_sdk');
      expect(find.text('Copied to clipboard'), findsOneWidget);
      await settle(tester, steps: 30);
      expect(find.text('Copied to clipboard'), findsNothing);
    });

    docsTest('tabs switch the code shown', (WidgetTester tester) async {
      await pumpDocs(
        tester,
        initialLocation: const DocsLocation(pageSlug: 'installation'),
      );
      expect(find.text('pubspec.yaml'), findsOneWidget);
      await tester.tap(find.text('pubspec.yaml'));
      await settle(tester, steps: 3);
      expect(find.text('Then run'), findsNothing);
      expect(
        find.textContaining('Then run', findRichText: true),
        findsOneWidget,
      );
    });

    docsTest('steps and tables render', (WidgetTester tester) async {
      await pumpDocs(
        tester,
        initialLocation: const DocsLocation(pageSlug: 'quick-start'),
      );
      expect(find.text('Create a client'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      navOf(tester).openPage('configuration');
      await settle(tester);
      expect(find.byType(CairnTable<List<String>>), findsOneWidget);
    });

    docsTest('an internal link in a paragraph navigates', (
      WidgetTester tester,
    ) async {
      await pumpDocs(
        tester,
        initialLocation: const DocsLocation(pageSlug: 'installation'),
      );
      TapGestureRecognizer? recognizer;
      void visit(InlineSpan span) {
        if (span is! TextSpan) return;
        if (span.text == 'quick start' && span.recognizer != null) {
          recognizer = span.recognizer! as TapGestureRecognizer;
        }
        span.children?.forEach(visit);
      }

      for (final RichText rich in tester.widgetList<RichText>(
        find.byType(RichText),
      )) {
        visit(rich.text);
      }
      expect(recognizer, isNotNull);
      recognizer!.onTap!();
      await settle(tester);
      expect(navOf(tester).state.pageSlug, 'quick-start');
    });
  });

  group('on this page', () {
    docsTest('clicking an entry scrolls and highlights it', (
      WidgetTester tester,
    ) async {
      await pumpDocs(
        tester,
        initialLocation: const DocsLocation(pageSlug: 'error-handling'),
      );
      final Finder entry = find.descendant(
        of: find.byType(TocRail),
        matching: find.text('Error payloads'),
      );
      expect(articleOffset(tester), 0);
      await tester.tap(entry);
      await settle(tester, steps: 8);
      expect(articleOffset(tester), greaterThan(0));
      expect(navOf(tester).state.headingId, 'error-payloads');
      final TocRail rail = tester.widget<TocRail>(find.byType(TocRail));
      expect(rail.viewModel.toc.state, 'error-payloads');
    });

    docsTest('the highlight follows manual scrolling', (
      WidgetTester tester,
    ) async {
      await pumpDocs(
        tester,
        initialLocation: const DocsLocation(pageSlug: 'error-handling'),
      );
      final TocRail rail = tester.widget<TocRail>(find.byType(TocRail));
      expect(rail.viewModel.toc.state, 'the-exception-types');
      rail.viewModel.scroll.jumpTo(
        rail.viewModel.scroll.position.maxScrollExtent,
      );
      await settle(tester, steps: 3);
      expect(rail.viewModel.toc.state, 'error-payloads');
    });

    docsTest('a deep link opens the page already scrolled', (
      WidgetTester tester,
    ) async {
      await pumpDocs(
        tester,
        initialLocation: const DocsLocation(
          pageSlug: 'error-handling',
          headingId: 'error-payloads',
        ),
      );
      await settle(tester);
      expect(articleOffset(tester), greaterThan(0));
    });
  });

  group('drawer', () {
    for (final Size size in <Size>[phone, tablet]) {
      docsTest(
        'menu opens the page tree and closes on choosing: ${size.width.toInt()}',
        (WidgetTester tester) async {
          await pumpDocs(tester, size: size);
          await openDrawer(tester);
          expect(sem('Documentation navigation'), findsOneWidget);
          await tester.tap(sem('Quick start'));
          await settle(tester);
          expect(navOf(tester).state.pageSlug, 'quick-start');
          expect(sem('Documentation navigation'), findsNothing);
        },
      );
    }
  });

  group('states', () {
    docsTest('shows a skeleton while loading', (WidgetTester tester) async {
      await pumpDocs(
        tester,
        remote: const InMemoryDocsRemoteDataSource(
          latency: Duration(seconds: 1),
        ),
      );
      expect(sem('Loading documentation'), findsOneWidget);
      await settle(tester, steps: 30);
      expect(sem('Loading documentation'), findsNothing);
    });

    docsTest('shows an error and recovers on retry', (
      WidgetTester tester,
    ) async {
      final _Flaky remote = _Flaky();
      await pumpDocs(tester, remote: remote);
      expect(find.text('Could not load the documentation'), findsOneWidget);
      remote.fail = false;
      await tester.tap(find.text('Try again'));
      await settle(tester);
      expect(find.text('Could not load the documentation'), findsNothing);
      expect(find.text('Introduction'), findsWidgets);
    });
  });
}

class _Flaky implements DocsRemoteDataSource {
  bool fail = true;
  final InMemoryDocsRemoteDataSource _real = const InMemoryDocsRemoteDataSource(
    latency: Duration.zero,
  );

  @override
  Future<Map<String, dynamic>> fetchManifest() => fail
      ? Future<Map<String, dynamic>>.error(StateError('offline'))
      : _real.fetchManifest();

  @override
  Future<Map<String, dynamic>> fetchSite(String versionId) => fail
      ? Future<Map<String, dynamic>>.error(StateError('offline'))
      : _real.fetchSite(versionId);
}
