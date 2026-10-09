import 'package:cairn_template_app_landing/cairn_template_app_landing.dart';
import 'package:cairn_template_app_landing/core/presentation/navigation/app_landing_navigation_cubit.dart';
import 'package:cairn_template_app_landing/presentation/shell/app_landing_shell.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'support/pump_app_landing.dart';

AppLandingNavigationCubit _nav(WidgetTester tester) =>
    BlocProvider.of<AppLandingNavigationCubit>(
      tester.element(find.byType(AppLandingShell)),
    );

/// Walks the whole page so every section lays out at the current width.
Future<void> _walk(WidgetTester tester) async {
  final ScrollPosition position = pagePosition(tester);
  for (double y = 0; y < position.maxScrollExtent; y += 600) {
    position.jumpTo(y);
    await tester.pump(const Duration(milliseconds: 120));
  }
  position.jumpTo(position.maxScrollExtent);
  await settle(tester);
}

/// The carousel's buttons, found by their glyph.
Finder get _next => find.byWidgetPredicate(
  (Widget w) => w is CairnIcon && w.icon == CairnIconData.chevronRight,
);
Finder get _previous => find.byWidgetPredicate(
  (Widget w) => w is CairnIcon && w.icon == CairnIconData.chevronLeft,
);

/// The text field of the send-me-the-link form (the page's only one).
Finder get _field => find.byType(EditableText);

class _RenamedContent implements AppContentDataSource {
  @override
  Future<JsonMap> fetchSection(String section) async {
    final JsonMap json = await const InMemoryAppContentDataSource()
        .fetchSection(section);
    return section == ContentSections.site
        ? <String, Object?>{...json, 'brandName': 'Zest'}
        : json;
  }
}

void main() {
  for (final double width in testWidths) {
    group('at $width px', () {
      for (final bool dark in <bool>[false, true]) {
        final String mode = dark ? 'dark' : 'light';

        testWidgets('shows every section without layout errors ($mode)', (
          WidgetTester tester,
        ) async {
          await pumpAppLanding(tester, width: width, dark: dark);

          expect(find.text('Ember'), findsWidgets);
          expect(find.textContaining('Small habits.'), findsOneWidget);
          expect(find.text('Download on the'), findsWidgets);

          await _walk(tester);

          expect(
            find.text('Everything you need, nothing you do not'),
            findsOneWidget,
          );
          expect(find.text('A closer look inside Ember'), findsOneWidget);
          expect(find.text('Ember by the numbers'), findsOneWidget);
          expect(
            find.text('Rated 4.8 by people who stuck with it'),
            findsOneWidget,
          );
          expect(find.text('Questions, answered'), findsOneWidget);
          expect(find.text('Take Ember with you'), findsOneWidget);
          expect(find.textContaining('2026 Ember Labs'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }

      testWidgets('switching feature tabs swaps the copy and the screen', (
        WidgetTester tester,
      ) async {
        await pumpAppLanding(tester, width: width);
        await reveal(
          tester,
          find.text('Everything you need, nothing you do not'),
        );

        final Finder tabs = find.byType(CairnTabs<String>);
        expect(find.text('One tap a day is all it takes'), findsOneWidget);
        expect(find.text('Friday, 9 October'), findsWidgets);

        await tester.tap(
          find.descendant(of: tabs, matching: find.text('Insights')),
        );
        await settle(tester, 600);
        expect(
          find.text('See your momentum, not just your misses'),
          findsOneWidget,
        );
        expect(find.text('One tap a day is all it takes'), findsNothing);

        await tester.tap(
          find.descendant(of: tabs, matching: find.text('Calendar')),
        );
        await settle(tester, 600);
        expect(find.text('Every perfect day, at a glance'), findsOneWidget);
        expect(find.text('October 2026'), findsWidgets);

        await tester.tap(
          find.descendant(of: tabs, matching: find.text('Reminders')),
        );
        await settle(tester, 600);
        expect(
          find.text('Reminders that know when to stay quiet'),
          findsOneWidget,
        );
        expect(find.text('Daily reminder'), findsWidgets);
      });

      testWidgets('the screenshots carousel pages with next and previous', (
        WidgetTester tester,
      ) async {
        await pumpAppLanding(tester, width: width);
        await reveal(tester, _next);

        expect(find.text('1 of 5: Choose your goals'), findsOneWidget);

        await tester.tap(_next);
        await settle(tester, 600);
        expect(find.text('2 of 5: Check in'), findsOneWidget);

        await tester.tap(_next);
        await settle(tester, 600);
        expect(find.text('3 of 5: Track progress'), findsOneWidget);

        await tester.tap(_previous);
        await settle(tester, 600);
        expect(find.text('2 of 5: Check in'), findsOneWidget);
      });

      testWidgets('the pricing toggle re-prices Premium', (
        WidgetTester tester,
      ) async {
        await pumpAppLanding(tester, width: width);
        await reveal(
          tester,
          find.text('Free to start. Premium when you are ready.'),
        );

        expect(find.text(r'$6.99'), findsOneWidget);
        expect(find.text('Billed monthly'), findsOneWidget);

        await tester.tap(find.text('Yearly'));
        await settle(tester, 600);
        expect(find.text(r'$4.19'), findsOneWidget);
        expect(find.text(r'Billed $50.28 yearly, save $33.60'), findsOneWidget);

        // The switch toggles it back.
        await tester.tap(find.byType(CairnSwitch));
        await settle(tester, 600);
        expect(find.text(r'$6.99'), findsOneWidget);

        await tester.tap(find.byType(CairnSwitch));
        await settle(tester, 600);
        expect(find.text(r'$4.19'), findsOneWidget);
      });

      testWidgets('an FAQ answer opens when its question is tapped', (
        WidgetTester tester,
      ) async {
        await pumpAppLanding(tester, width: width);
        await reveal(tester, find.text('Is Ember really free?'));

        const String answer = 'The free plan includes up to five habits';
        expect(find.textContaining(answer), findsNothing);

        await tester.tap(find.text('Is Ember really free?'));
        await settle(tester, 500);
        expect(find.textContaining(answer), findsOneWidget);

        await tester.tap(find.text('Is Ember really free?'));
        await settle(tester, 500);
        expect(find.textContaining(answer), findsNothing);
      });

      testWidgets('send me the link validates an email or a phone number', (
        WidgetTester tester,
      ) async {
        await pumpAppLanding(tester, width: width);
        await reveal(tester, find.text('Take Ember with you'));
        await reveal(tester, find.text('Send link'));

        // Empty.
        await tester.tap(find.text('Send link'));
        await settle(tester, 300);
        expect(
          find.text('Enter your email address or phone number.'),
          findsOneWidget,
        );

        // Not an email.
        await tester.enterText(_field, 'ada@nope');
        await tester.pump();
        expect(
          find.text('Enter your email address or phone number.'),
          findsNothing,
        );
        await tester.tap(find.text('Send link'));
        await settle(tester, 300);
        expect(
          find.text('That does not look like an email address.'),
          findsOneWidget,
        );

        // A phone number that is too short.
        await tester.enterText(_field, '12345');
        await tester.pump();
        await tester.tap(find.text('Send link'));
        await settle(tester, 300);
        expect(find.textContaining('7 to 15 digits'), findsOneWidget);
      });

      testWidgets('a valid email is sent, confirmed and toasted', (
        WidgetTester tester,
      ) async {
        final InMemoryDownloadLinkService link = InMemoryDownloadLinkService(
          latency: const Duration(milliseconds: 300),
        );
        await pumpAppLanding(tester, width: width, linkService: link);
        await reveal(tester, find.text('Take Ember with you'));
        await reveal(tester, find.text('Send link'));

        await tester.enterText(_field, 'ada@example.com');
        await tester.pump();
        await tester.tap(find.text('Send link'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(CairnSpinner), findsOneWidget);

        await settle(tester, 800);
        expect(link.sent.single.value, 'ada@example.com');
        // The panel and the toast both carry the title.
        expect(find.text('Link on its way'), findsNWidgets(2));
        expect(find.text('Email: ada@example.com'), findsOneWidget);

        // Let the toast dismiss itself so no timer is left pending.
        await settle(tester, 5000);
        expect(find.text('Link on its way'), findsOneWidget);

        await tester.tap(find.text('Send to a different address'));
        await settle(tester, 400);
        expect(find.text('Send link'), findsOneWidget);
      });

      testWidgets('a phone number is sent as an SMS', (
        WidgetTester tester,
      ) async {
        final InMemoryDownloadLinkService link = instantLinks();
        await pumpAppLanding(tester, width: width, linkService: link);
        await reveal(tester, find.text('Take Ember with you'));
        await reveal(tester, find.text('Send link'));

        await tester.enterText(_field, '+1 (415) 555-0134');
        await tester.pump();
        await tester.tap(find.text('Send link'));
        await settle(tester, 600);

        expect(link.sent.single.value, '+14155550134');
        expect(find.text('SMS: +14155550134'), findsOneWidget);
        await settle(tester, 5000);
      });

      testWidgets('a refused send shows the service message', (
        WidgetTester tester,
      ) async {
        await pumpAppLanding(tester, width: width);
        await reveal(tester, find.text('Take Ember with you'));
        await reveal(tester, find.text('Send link'));

        await tester.enterText(_field, 'ada@fail.example');
        await tester.pump();
        await tester.tap(find.text('Send link'));
        await settle(tester, 800);

        // Inline under the field and in the toast.
        expect(
          find.text(
            'We could not send the link right now. Please try again in a '
            'moment.',
          ),
          findsNWidgets(2),
        );
        expect(find.text('Could not send the link'), findsOneWidget);
        await settle(tester, 5000);
      });

      testWidgets('write a review opens a toast', (WidgetTester tester) async {
        await pumpAppLanding(tester, width: width);
        await reveal(tester, find.text('Write a review'));

        await tester.tap(find.text('Write a review'));
        await settle(tester, 600);
        expect(find.text('Thanks for sharing'), findsOneWidget);
        await settle(tester, 5000);
        expect(find.text('Thanks for sharing'), findsNothing);
      });

      testWidgets('store buttons and links reach the host callbacks', (
        WidgetTester tester,
      ) async {
        final List<(StoreKind, String)> stores = <(StoreKind, String)>[];
        final List<String> links = <String>[];
        await pumpAppLanding(
          tester,
          width: width,
          onStoreTap: (StoreKind s, String h) => stores.add((s, h)),
          onCtaTap: links.add,
        );

        await tester.tap(find.text('App Store').first);
        await tester.pump();
        await tester.tap(find.text('Google Play').first);
        await tester.pump();
        expect(stores, <(StoreKind, String)>[
          (StoreKind.appStore, 'https://ember.example/get/ios'),
          (StoreKind.googlePlay, 'https://ember.example/get/android'),
        ]);

        await reveal(tester, find.text('Start free trial'));
        await tester.tap(find.text('Start free trial'));
        await tester.pump();
        expect(
          links.last,
          'https://ember.example/trial?plan=premium&period=monthly',
        );
        await reveal(tester, find.text('Yearly'));
        await tester.tap(find.text('Yearly'));
        await settle(tester, 600);
        await reveal(tester, find.text('Start free trial'));
        await tester.tap(find.text('Start free trial'));
        await tester.pump();
        expect(
          links.last,
          'https://ember.example/trial?plan=premium&period=yearly',
        );

        // Footer links that are not anchors reach onCtaTap too.
        await reveal(tester, find.text('Careers'));
        await tester.tap(find.text('Careers'));
        await tester.pump();
        expect(links.last, '/careers');
      });
    });
  }

  group('navigation', () {
    testWidgets('a navbar link scrolls to its section and highlights', (
      WidgetTester tester,
    ) async {
      await pumpAppLanding(tester);
      expect(pagePosition(tester).pixels, 0);

      await tester.tap(find.text('Pricing').first);
      await settle(tester, 1200);

      expect(pagePosition(tester).pixels, greaterThan(1000));
      final double top = tester
          .getTopLeft(find.text('Free to start. Premium when you are ready.'))
          .dy;
      expect(top, lessThan(400));
      expect(_nav(tester).state.activeId, SectionIds.pricing);

      await tester.tap(find.text('Reviews').first);
      await settle(tester, 1200);
      expect(_nav(tester).state.activeId, SectionIds.reviews);
    });

    testWidgets('the navbar button goes to the download section', (
      WidgetTester tester,
    ) async {
      await pumpAppLanding(tester);
      await tester.tap(find.text('Get the app').first);
      await settle(tester, 1200);
      expect(_nav(tester).state.requestedId, SectionIds.download);
      expect(pagePosition(tester).pixels, greaterThan(1000));
    });

    testWidgets('the brand returns to the top', (WidgetTester tester) async {
      await pumpAppLanding(tester);
      pagePosition(tester).jumpTo(2400);
      await settle(tester, 300);

      await tester.tap(find.text('Ember').first);
      await settle(tester, 1200);
      expect(pagePosition(tester).pixels, 0);
    });

    testWidgets('initialSection scrolls there and onSectionChanged follows', (
      WidgetTester tester,
    ) async {
      final List<String> seen = <String>[];
      await pumpAppLanding(
        tester,
        initialSection: SectionIds.pricing,
        onSectionChanged: seen.add,
      );
      await settle(tester, 2000);

      expect(pagePosition(tester).pixels, greaterThan(1000));
      expect(seen.last, SectionIds.pricing);

      pagePosition(tester).jumpTo(0);
      await settle(tester, 200);
      expect(seen.last, SectionIds.hero);
    });

    testWidgets('the phone menu opens a sheet and navigates', (
      WidgetTester tester,
    ) async {
      await pumpAppLanding(tester, width: 390);
      expect(find.byType(CairnSheet), findsNothing);

      await tester.tap(find.byIcon(Icons.menu));
      await settle(tester, 600);

      expect(
        find.text('Build habits that stick, one small win at a time.'),
        findsOneWidget,
      );
      expect(find.byType(CairnSheet), findsOneWidget);
      expect(find.text('How it works'), findsWidgets);

      await tester.tap(find.text('FAQ').last);
      await settle(tester, 1500);

      // The sheet closed and the page scrolled to the FAQ.
      expect(
        find.text('Build habits that stick, one small win at a time.'),
        findsNothing,
      );
      expect(_nav(tester).state.requestedId, SectionIds.faq);
      expect(pagePosition(tester).pixels, greaterThan(1000));
    });

    testWidgets('the tablet width also collapses into the menu', (
      WidgetTester tester,
    ) async {
      await pumpAppLanding(tester, width: 768);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      await tester.tap(find.byIcon(Icons.menu));
      await settle(tester, 600);
      await tester.tap(find.text('Pricing').last);
      await settle(tester, 1500);
      expect(_nav(tester).state.requestedId, SectionIds.pricing);
    });
  });

  group('injection', () {
    testWidgets('a custom content source drives the page', (
      WidgetTester tester,
    ) async {
      await pumpAppLanding(tester, contentDataSource: _RenamedContent());
      expect(find.text('Zest'), findsWidgets);
      expect(find.text('Ember'), findsNothing);
    });

    testWidgets('overrides can swap any registration', (
      WidgetTester tester,
    ) async {
      bool resolved = false;
      await pumpAppLanding(
        tester,
        overrides: (GetIt locator) {
          resolved = locator.isRegistered<AppContentDataSource>();
        },
      );
      expect(resolved, isTrue);
    });
  });

  group('motion and accessibility', () {
    testWidgets('renders without entrance animations when motion is reduced', (
      WidgetTester tester,
    ) async {
      await pumpAppLanding(tester, width: 390, reduceMotion: true);
      expect(find.textContaining('Small habits.'), findsOneWidget);
      await _walk(tester);
      expect(find.text('Take Ember with you'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'the mock phones are described, not read out widget by widget',
      (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        await pumpAppLanding(tester);
        expect(
          find.bySemanticsLabel(RegExp('The Today screen: three of five')),
          findsWidgets,
        );
        expect(
          find.bySemanticsLabel('Download on the App Store'),
          findsWidgets,
        );
        semantics.dispose();
      },
    );

    testWidgets('two mounted pages do not share state', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: Row(
            children: <Widget>[
              Expanded(child: AppLandingApp()),
              Expanded(child: AppLandingApp()),
            ],
          ),
        ),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(AppLandingApp), findsNWidgets(2));
    });
  });
}
