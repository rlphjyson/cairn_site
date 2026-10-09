import 'package:cairn_template_landing/cairn_template_landing.dart';
import 'package:cairn_template_landing/core/presentation/navigation/landing_navigation_cubit.dart';
import 'package:cairn_template_landing/presentation/shell/landing_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'support/pump_landing.dart';

LandingNavigationCubit _nav(WidgetTester tester) =>
    BlocProvider.of<LandingNavigationCubit>(
      tester.element(find.byType(LandingShell)),
    );

/// Scrolls so [finder] is on screen, then lets reveals finish.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  // ensureVisible stops at the edge, which can be under the sticky navbar.
  final ScrollPosition position = pagePosition(tester);
  position.jumpTo((position.pixels - 250).clamp(0, position.maxScrollExtent));
  await settle(tester);
}

class _RecordingWaitlist implements WaitlistRemoteDataSource {
  final WaitlistRemoteDataSource _copy = InMemoryWaitlistRemoteDataSource();
  final List<String> emails = <String>[];

  @override
  Future<JsonMap> fetchWaitlist() => _copy.fetchWaitlist();

  @override
  Future<JsonMap> submit(String email) async {
    emails.add(email);
    return <String, Object?>{'position': 42};
  }
}

/// The demo pricing with checkout links that carry the period.
class _CheckoutPricing implements PricingRemoteDataSource {
  @override
  Future<JsonMap> fetchPricing() async {
    final JsonMap json = await const InMemoryPricingRemoteDataSource()
        .fetchPricing();
    return <String, Object?>{
      ...json,
      'plans': <Object?>[
        for (final JsonMap plan in json.objects('plans'))
          <String, Object?>{
            ...plan,
            'cta': <String, Object?>{
              'label': plan.object('cta').string('label'),
              'href':
                  'https://pay.example/${plan.string('id')}?period={period}',
            },
          },
      ],
    };
  }
}

void main() {
  for (final double width in testWidths) {
    group('at $width px', () {
      testWidgets('shows every section without layout errors', (
        WidgetTester tester,
      ) async {
        await pumpLanding(tester, width: width);

        expect(find.text('Kestrel'), findsWidgets);
        expect(
          find.text('Plan work your whole team can actually see.'),
          findsOneWidget,
        );

        // Walk the whole page so every section lays out at this width.
        final ScrollPosition position = pagePosition(tester);
        for (double y = 0; y < position.maxScrollExtent; y += 600) {
          position.jumpTo(y);
          await tester.pump(const Duration(milliseconds: 120));
        }
        position.jumpTo(position.maxScrollExtent);
        await settle(tester);

        expect(
          find.text('Everything a project needs, in one place'),
          findsOneWidget,
        );
        expect(find.text('Questions, answered'), findsOneWidget);
        expect(find.textContaining('2026 Kestrel Labs'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('the pricing toggle re-prices every plan', (
        WidgetTester tester,
      ) async {
        await pumpLanding(tester, width: width);
        await _reveal(
          tester,
          find.text('Simple pricing that scales with your team'),
        );

        expect(find.text(r'$12'), findsOneWidget);
        expect(find.text(r'$29'), findsOneWidget);
        expect(find.text('Billed monthly'), findsNWidgets(2));

        await tester.tap(find.text('Yearly'));
        await settle(tester, 600);

        expect(find.text(r'$9.60'), findsOneWidget);
        expect(find.text(r'$23.20'), findsOneWidget);
        expect(
          find.text(r'Billed $115.20 yearly, save $28.80'),
          findsOneWidget,
        );

        await tester.tap(find.text('Monthly'));
        await settle(tester, 600);
        expect(find.text(r'$12'), findsOneWidget);
      });

      testWidgets('an FAQ answer opens when its question is tapped', (
        WidgetTester tester,
      ) async {
        await pumpLanding(tester, width: width);
        await _reveal(tester, find.text('Is there a free trial?'));

        const String answer = 'Every paid plan starts with a 14-day trial';
        expect(find.textContaining(answer), findsNothing);

        await tester.tap(find.text('Is there a free trial?'));
        await settle(tester, 500);
        expect(find.textContaining(answer), findsOneWidget);

        await tester.tap(find.text('Is there a free trial?'));
        await settle(tester, 500);
        expect(find.textContaining(answer), findsNothing);
      });

      testWidgets('the waitlist validates, submits and confirms', (
        WidgetTester tester,
      ) async {
        await pumpLanding(tester, width: width);
        await _reveal(tester, find.text('Be first in line for Kestrel'));

        // Empty.
        await tester.tap(find.text('Join the waitlist').last);
        await settle(tester, 300);
        expect(find.text('Enter your email address.'), findsOneWidget);

        // Not an email.
        await tester.enterText(find.byType(EditableText), 'not-an-email');
        await tester.pump();
        expect(find.text('Enter your email address.'), findsNothing);
        await tester.tap(find.text('Join the waitlist').last);
        await settle(tester, 300);
        expect(
          find.text('That does not look like an email address.'),
          findsOneWidget,
        );

        // Valid.
        await tester.enterText(find.byType(EditableText), 'ada@example.com');
        await tester.pump();
        await tester.tap(find.text('Join the waitlist').last);
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Join the waitlist'), findsWidgets);
        await settle(tester, 1200);

        expect(find.text('You are number 1284 in line'), findsOneWidget);
        // The panel and the toast both carry the title.
        expect(find.text('You are on the list!'), findsNWidgets(2));

        // Let the toast dismiss itself so no timer is left pending.
        await settle(tester, 5000);
        expect(find.text('You are on the list!'), findsOneWidget);
      });

      testWidgets('a refused signup shows the service message', (
        WidgetTester tester,
      ) async {
        await pumpLanding(tester, width: width);
        await _reveal(tester, find.text('Be first in line for Kestrel'));

        await tester.enterText(find.byType(EditableText), 'ada@fail.example');
        await tester.pump();
        await tester.tap(find.text('Join the waitlist').last);
        await settle(tester, 1200);

        expect(
          find.text(
            'We could not add you right now. Please try again in a moment.',
          ),
          findsWidgets,
        );
        await settle(tester, 5000);
      });
    });
  }

  group('navigation', () {
    testWidgets('a navbar link scrolls to its section and highlights', (
      WidgetTester tester,
    ) async {
      await pumpLanding(tester);
      expect(pagePosition(tester).pixels, 0);

      await tester.tap(find.text('Pricing').first);
      await settle(tester, 1200);

      expect(pagePosition(tester).pixels, greaterThan(1000));
      final double top = tester
          .getTopLeft(find.text('Simple pricing that scales with your team'))
          .dy;
      expect(top, lessThan(400));

      final LandingNavigationCubit nav = _nav(tester);
      expect(nav.state.activeId, SectionIds.pricing);
    });

    testWidgets('the brand returns to the top', (WidgetTester tester) async {
      await pumpLanding(tester);
      pagePosition(tester).jumpTo(2400);
      await settle(tester, 300);

      await tester.tap(find.text('Kestrel').first);
      await settle(tester, 1200);
      expect(pagePosition(tester).pixels, 0);
    });

    testWidgets('links that are not anchors reach onLink', (
      WidgetTester tester,
    ) async {
      final List<String> opened = <String>[];
      await pumpLanding(tester, onLink: opened.add);

      await tester.tap(find.text('Sign in'));
      await tester.pump();
      expect(opened, <String>['/sign-in']);
    });

    testWidgets('initialSection scrolls there and onSectionChanged follows', (
      WidgetTester tester,
    ) async {
      final List<String> seen = <String>[];
      await pumpLanding(
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
      await pumpLanding(tester, width: 390);
      expect(find.text('Sign in'), findsNothing);

      await tester.tap(find.byIcon(Icons.menu));
      await settle(tester, 600);

      expect(
        find.text('Plan, track and ship work your whole team can see.'),
        findsOneWidget,
      );
      expect(find.text('How it works'), findsWidgets);

      await tester.tap(find.text('FAQ').last);
      await settle(tester, 1500);

      // The sheet closed and the page scrolled to the FAQ.
      expect(
        find.text('Plan, track and ship work your whole team can see.'),
        findsNothing,
      );
      expect(_nav(tester).state.requestedId, SectionIds.faq);
      expect(pagePosition(tester).pixels, greaterThan(1000));
    });
  });

  group('overrides', () {
    testWidgets('a custom waitlist service receives the email', (
      WidgetTester tester,
    ) async {
      final _RecordingWaitlist service = _RecordingWaitlist();
      await pumpLanding(
        tester,
        overrides: (GetIt locator) => locator
          ..unregister<WaitlistRemoteDataSource>()
          ..registerLazySingleton<WaitlistRemoteDataSource>(() => service),
      );
      await _reveal(tester, find.text('Be first in line for Kestrel'));

      await tester.enterText(find.byType(EditableText), 'ada@example.com');
      await tester.pump();
      await tester.tap(find.text('Join the waitlist').last);
      await settle(tester, 600);

      expect(service.emails, <String>['ada@example.com']);
      expect(find.text('You are number 42 in line'), findsOneWidget);
      await settle(tester, 5000);
    });

    testWidgets('plan links carry the billing period', (
      WidgetTester tester,
    ) async {
      final List<String> opened = <String>[];
      await pumpLanding(
        tester,
        onLink: opened.add,
        overrides: (GetIt locator) => locator
          ..unregister<PricingRemoteDataSource>()
          ..registerLazySingleton<PricingRemoteDataSource>(
            _CheckoutPricing.new,
          ),
      );
      await _reveal(
        tester,
        find.text('Simple pricing that scales with your team'),
      );

      await tester.tap(find.text('Start free trial').first);
      await tester.pump();
      expect(opened.last, 'https://pay.example/team?period=monthly');

      await tester.tap(find.text('Yearly'));
      await settle(tester, 600);
      await tester.tap(find.text('Start free trial').first);
      await tester.pump();
      expect(opened.last, 'https://pay.example/team?period=yearly');
    });
  });

  testWidgets('renders in dark mode without errors', (
    WidgetTester tester,
  ) async {
    await pumpLanding(tester, width: 390, dark: true);
    final ScrollPosition position = pagePosition(tester);
    for (double y = 0; y < position.maxScrollExtent; y += 700) {
      position.jumpTo(y);
      await tester.pump(const Duration(milliseconds: 120));
    }
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two mounted pages do not share state', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(loadTestFonts);
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: <Widget>[
            Expanded(child: LandingApp()),
            Expanded(child: LandingApp()),
          ],
        ),
      ),
    );
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(LandingApp), findsNWidgets(2));
  });
}
