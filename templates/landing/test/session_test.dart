import 'package:cairn_template_landing/core/infrastructure/di/landing_injection.dart';
import 'package:cairn_template_landing/core/presentation/content_cubit.dart';
import 'package:cairn_template_landing/core/presentation/navigation/landing_navigation_cubit.dart';
import 'package:cairn_template_landing/data/waitlist/remote/waitlist_remote_data_source.dart';
import 'package:cairn_template_landing/domain/hero/models/hero_content.dart';
import 'package:cairn_template_landing/domain/pricing/models/price_quote.dart';
import 'package:cairn_template_landing/domain/pricing/models/pricing_content.dart';
import 'package:cairn_template_landing/domain/site/models/site_info.dart';
import 'package:cairn_template_landing/presentation/pricing/bloc/pricing_cubit.dart';
import 'package:cairn_template_landing/presentation/pricing/view_models/pricing_view_model.dart';
import 'package:cairn_template_landing/presentation/waitlist/bloc/waitlist_cubit.dart';
import 'package:cairn_template_landing/presentation/waitlist/view_models/waitlist_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The cubits wired through the real container, with no widgets: the point of
/// the layering is that all of this runs without a UI.
void main() {
  late GetIt locator;

  setUp(() {
    locator = createLandingLocator()
      // Instant signups, so tests do not wait on the demo latency.
      ..unregister<WaitlistRemoteDataSource>()
      ..registerLazySingleton<WaitlistRemoteDataSource>(
        () => InMemoryWaitlistRemoteDataSource(latency: Duration.zero),
      );
  });
  tearDown(() => locator.reset());

  test('each container is independent', () {
    final GetIt other = createLandingLocator();
    expect(
      identical(
        locator<LandingNavigationCubit>(),
        other<LandingNavigationCubit>(),
      ),
      isFalse,
    );
    other.reset();
  });

  test('session cubits are singletons; screen view models are not', () {
    expect(
      identical(
        locator<LandingNavigationCubit>(),
        locator<LandingNavigationCubit>(),
      ),
      isTrue,
    );
    expect(
      identical(
        locator<ContentCubit<SiteInfo>>(),
        locator<ContentCubit<SiteInfo>>(),
      ),
      isTrue,
    );
    final PricingViewModel a = locator<PricingViewModel>();
    final PricingViewModel b = locator<PricingViewModel>();
    expect(identical(a, b), isFalse);
    a.dispose();
    b.dispose();
  });

  group('ContentCubit', () {
    test('loads once and holds the content', () async {
      final ContentCubit<SiteInfo> cubit = locator<ContentCubit<SiteInfo>>();
      expect(cubit.state.status, ContentStatus.initial);
      await cubit.load();
      expect(cubit.state.status, ContentStatus.loaded);
      expect(cubit.state.data!.brandName, 'Kestrel');
    });

    test('a section view model resolves and loads', () async {
      final ContentViewModel<HeroContent> vm =
          locator<ContentViewModel<HeroContent>>();
      await vm.cubit.load();
      expect(vm.cubit.state.data!.primaryCta.href, '#waitlist');
      vm.dispose();
      expect(vm.cubit.isClosed, isTrue);
    });

    test('a failing load reports failure and can retry', () async {
      int calls = 0;
      final ContentCubit<String> cubit = ContentCubit<String>(() async {
        calls++;
        if (calls == 1) throw StateError('offline');
        return 'ok';
      });
      await cubit.load();
      expect(cubit.state.status, ContentStatus.failure);
      await cubit.load();
      expect(cubit.state.data, 'ok');
      await cubit.close();
    });
  });

  group('LandingNavigationCubit', () {
    test('records requests and the active section', () {
      final LandingNavigationCubit nav = locator<LandingNavigationCubit>();
      expect(nav.state.activeId, 'hero');
      nav.goTo('pricing');
      nav.goTo('pricing');
      expect(nav.state.requestedId, 'pricing');
      expect(nav.state.requests, 2);
      nav.activate('faq');
      expect(nav.state.activeId, 'faq');
      expect(nav.state.requestedId, 'pricing');
    });
  });

  group('PricingCubit', () {
    test('loads the plans priced monthly', () async {
      final PricingViewModel vm = locator<PricingViewModel>();
      await vm.cubit.load();
      final PricingState s = vm.cubit.state;
      expect(s.status, ContentStatus.loaded);
      expect(s.period, BillingPeriod.monthly);
      expect(s.quotes.keys, <String>['starter', 'team', 'scale']);
      expect(s.quotes['team']!.perMonth, 12);
      vm.dispose();
    });

    test('the toggle re-prices every plan and back', () async {
      final PricingViewModel vm = locator<PricingViewModel>();
      await vm.cubit.load();
      final Plan team = vm.cubit.state.content!.plans[1];

      vm.cubit.setPeriod(BillingPeriod.yearly);
      expect(vm.cubit.state.quoteFor(team)!.perMonth, 9.6);
      expect(vm.cubit.state.quoteFor(team)!.billedAmount, 115.2);
      expect(vm.cubit.state.quotes['starter']!.kind, PriceKind.free);

      vm.cubit.setPeriod(BillingPeriod.monthly);
      expect(vm.cubit.state.quoteFor(team)!.perMonth, 12);
      vm.dispose();
    });

    test('setting the same period emits nothing', () async {
      final PricingViewModel vm = locator<PricingViewModel>();
      await vm.cubit.load();
      final List<PricingState> seen = <PricingState>[];
      final sub = vm.cubit.stream.listen(seen.add);
      vm.cubit.setPeriod(BillingPeriod.monthly);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
      await sub.cancel();
      vm.dispose();
    });
  });

  group('WaitlistCubit', () {
    test('rejects an invalid email inline', () async {
      final WaitlistViewModel vm = locator<WaitlistViewModel>();
      await vm.cubit.load();
      await vm.cubit.submit('nope');
      expect(vm.cubit.state.status, WaitlistStatus.invalid);
      expect(
        vm.cubit.state.message,
        'That does not look like an email address.',
      );

      vm.cubit.clearError();
      expect(vm.cubit.state.status, WaitlistStatus.idle);
      vm.dispose();
    });

    test('joins, numbering signups in order', () async {
      final WaitlistViewModel vm = locator<WaitlistViewModel>();
      await vm.cubit.load();
      await vm.cubit.submit('ada@example.com');
      expect(vm.cubit.state.status, WaitlistStatus.success);
      expect(vm.cubit.state.receipt!.position, 1284);

      vm.cubit.reset();
      await vm.cubit.submit('grace@example.com');
      expect(vm.cubit.state.receipt!.position, 1285);
      expect(vm.cubit.state.submissions, 2);
      vm.dispose();
    });

    test('passes through submitting and reports a refusal', () async {
      final WaitlistViewModel vm = locator<WaitlistViewModel>();
      await vm.cubit.load();
      final List<WaitlistStatus> seen = <WaitlistStatus>[];
      final sub = vm.cubit.stream.listen(
        (WaitlistState s) => seen.add(s.status),
      );
      await vm.cubit.submit('ada@fail.example');
      await Future<void>.delayed(Duration.zero);
      expect(seen, <WaitlistStatus>[
        WaitlistStatus.submitting,
        WaitlistStatus.failure,
      ]);
      expect(vm.cubit.state.message, contains('could not add you'));
      await sub.cancel();
      vm.dispose();
    });
  });
}
