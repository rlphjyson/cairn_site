import 'package:cairn_template_app_landing/common/utils/json.dart';
import 'package:cairn_template_app_landing/core/infrastructure/di/app_landing_injection.dart';
import 'package:cairn_template_app_landing/core/presentation/content_cubit.dart';
import 'package:cairn_template_app_landing/core/presentation/navigation/app_landing_navigation_cubit.dart';
import 'package:cairn_template_app_landing/data/content/remote/app_content_data_source.dart';
import 'package:cairn_template_app_landing/data/download/remote/download_link_service.dart';
import 'package:cairn_template_app_landing/domain/download/models/send_outcome.dart';
import 'package:cairn_template_app_landing/domain/hero/models/hero_content.dart';
import 'package:cairn_template_app_landing/domain/pricing/models/price_quote.dart';
import 'package:cairn_template_app_landing/domain/pricing/models/pricing_content.dart';
import 'package:cairn_template_app_landing/domain/reviews/models/reviews_content.dart';
import 'package:cairn_template_app_landing/domain/site/models/site_info.dart';
import 'package:cairn_template_app_landing/presentation/download/bloc/download_cubit.dart';
import 'package:cairn_template_app_landing/presentation/download/view_models/download_view_model.dart';
import 'package:cairn_template_app_landing/presentation/features/bloc/features_cubit.dart';
import 'package:cairn_template_app_landing/presentation/features/view_models/features_view_model.dart';
import 'package:cairn_template_app_landing/presentation/gallery/view_models/gallery_view_model.dart';
import 'package:cairn_template_app_landing/presentation/pricing/bloc/pricing_cubit.dart';
import 'package:cairn_template_app_landing/presentation/pricing/view_models/pricing_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// A content source that renames the app and counts requests.
class _RenamedContent implements AppContentDataSource {
  final List<String> requested = <String>[];

  @override
  Future<JsonMap> fetchSection(String section) async {
    requested.add(section);
    final JsonMap json = await const InMemoryAppContentDataSource()
        .fetchSection(section);
    return section == 'site'
        ? <String, Object?>{...json, 'brandName': 'Zest'}
        : json;
  }
}

/// The cubits wired through the real container, with no widgets: the point of
/// the layering is that all of this runs without a UI.
void main() {
  late InMemoryDownloadLinkService link;
  late GetIt locator;

  setUp(() {
    link = InMemoryDownloadLinkService(latency: Duration.zero);
    locator = createAppLandingLocator(linkService: link);
  });
  tearDown(() => locator.reset());

  test('each container is independent', () {
    final GetIt other = createAppLandingLocator();
    expect(
      identical(
        locator<AppLandingNavigationCubit>(),
        other<AppLandingNavigationCubit>(),
      ),
      isFalse,
    );
    other.reset();
  });

  test('session cubits are singletons; screen view models are not', () {
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
    expect(a.cubit.isClosed, isTrue);
  });

  test('a custom content source and link service are used', () async {
    final _RenamedContent source = _RenamedContent();
    final GetIt g = createAppLandingLocator(contentDataSource: source);
    final ContentCubit<SiteInfo> site = g<ContentCubit<SiteInfo>>();
    await site.load();
    expect(site.state.data!.brandName, 'Zest');
    expect(source.requested, <String>['site']);
    expect(g<DownloadLinkService>(), isA<InMemoryDownloadLinkService>());

    final GetIt h = createAppLandingLocator(linkService: link);
    expect(identical(h<DownloadLinkService>(), link), isTrue);
    await g.reset();
    await h.reset();
  });

  group('ContentCubit', () {
    test('loads once and holds the content', () async {
      final ContentCubit<SiteInfo> cubit = locator<ContentCubit<SiteInfo>>();
      expect(cubit.state.status, ContentStatus.initial);
      await cubit.load();
      expect(cubit.state.status, ContentStatus.loaded);
      expect(cubit.state.data!.brandName, 'Ember');
      expect(cubit.state.data!.cta.href, '#download');
    });

    test('a section view model resolves, loads and closes', () async {
      final ContentViewModel<HeroContent> vm =
          locator<ContentViewModel<HeroContent>>();
      await vm.cubit.load();
      expect(vm.cubit.state.data!.headline, contains('Small habits'));
      vm.dispose();
      expect(vm.cubit.isClosed, isTrue);
    });

    test('reviews load newest first with the derived average', () async {
      final ContentViewModel<ReviewsContent> vm =
          locator<ContentViewModel<ReviewsContent>>();
      await vm.cubit.load();
      final ReviewsContent c = vm.cubit.state.data!;
      expect(c.reviews.first.date.isAfter(c.reviews.last.date), isTrue);
      expect(c.distribution.averageLabel, '4.8');
      vm.dispose();
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

  group('AppLandingNavigationCubit', () {
    test('records requests and the active section', () {
      final AppLandingNavigationCubit nav =
          locator<AppLandingNavigationCubit>();
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

  group('FeaturesCubit', () {
    test('selects the first feature, then switches', () async {
      final FeaturesViewModel vm = locator<FeaturesViewModel>();
      expect(vm.cubit.state.selected, isNull);
      await vm.cubit.load();
      expect(vm.cubit.state.status, ContentStatus.loaded);
      expect(vm.cubit.state.selected!.id, 'check-in');

      vm.cubit.select('calendar');
      expect(vm.cubit.state.selected!.tabLabel, 'Calendar');
      vm.dispose();
    });

    test('ignores unknown ids and repeats', () async {
      final FeaturesViewModel vm = locator<FeaturesViewModel>();
      await vm.cubit.load();
      final List<FeaturesState> seen = <FeaturesState>[];
      final sub = vm.cubit.stream.listen(seen.add);
      vm.cubit.select('check-in');
      vm.cubit.select('nope');
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
      await sub.cancel();
      vm.dispose();
    });
  });

  group('GalleryCubit', () {
    test('tracks the slide in view within bounds', () async {
      final GalleryViewModel vm = locator<GalleryViewModel>();
      await vm.cubit.load();
      expect(vm.cubit.state.current!.title, 'Choose your goals');
      vm.cubit.setPage(2);
      expect(vm.cubit.state.current!.title, 'Track progress');
      vm.cubit.setPage(99);
      vm.cubit.setPage(-1);
      expect(vm.cubit.state.page, 2);
      vm.dispose();
    });
  });

  group('PricingCubit', () {
    test('loads the plans priced monthly', () async {
      final PricingViewModel vm = locator<PricingViewModel>();
      await vm.cubit.load();
      final PricingState s = vm.cubit.state;
      expect(s.status, ContentStatus.loaded);
      expect(s.period, BillingPeriod.monthly);
      expect(s.quotes.keys, <String>['free', 'premium']);
      expect(s.quotes['premium']!.perMonth, 6.99);
      vm.dispose();
    });

    test('the toggle re-prices every plan and back', () async {
      final PricingViewModel vm = locator<PricingViewModel>();
      await vm.cubit.load();
      final Plan premium = vm.cubit.state.content!.plans[1];

      vm.cubit.setPeriod(BillingPeriod.yearly);
      expect(vm.cubit.state.quoteFor(premium)!.perMonth, 4.19);
      expect(vm.cubit.state.quoteFor(premium)!.billedAmount, 50.28);
      expect(vm.cubit.state.quotes['free']!.kind, PriceKind.free);

      vm.cubit.setPeriod(BillingPeriod.monthly);
      expect(vm.cubit.state.quoteFor(premium)!.perMonth, 6.99);
      vm.dispose();
    });
  });

  group('DownloadCubit', () {
    test('loads the copy and a demo QR pattern', () async {
      final DownloadViewModel vm = locator<DownloadViewModel>();
      await vm.cubit.load();
      expect(vm.cubit.state.load, ContentStatus.loaded);
      expect(vm.cubit.state.qr!.size, 25);
      expect(vm.cubit.state.content!.qr.badge, 'Demo');
      vm.dispose();
    });

    test('rejects an invalid entry inline, then clears on edit', () async {
      final DownloadViewModel vm = locator<DownloadViewModel>();
      await vm.cubit.load();
      await vm.cubit.submit('nope');
      expect(vm.cubit.state.status, DownloadStatus.invalid);
      expect(vm.cubit.state.message, isNotNull);
      expect(link.sent, isEmpty);

      vm.cubit.clearError();
      expect(vm.cubit.state.status, DownloadStatus.idle);
      vm.dispose();
    });

    test('sends to an email and to a phone number', () async {
      final DownloadViewModel vm = locator<DownloadViewModel>();
      await vm.cubit.load();
      await vm.cubit.submit('ada@example.com');
      expect(vm.cubit.state.status, DownloadStatus.sent);
      expect(vm.cubit.state.contact!.kind, ContactKind.email);

      vm.cubit.reset();
      await vm.cubit.submit('+1 415 555 0134');
      expect(vm.cubit.state.contact!.value, '+14155550134');
      expect(vm.cubit.state.attempts, 2);
      expect(link.sent, hasLength(2));
      vm.dispose();
    });

    test('passes through sending and reports a refusal', () async {
      final DownloadViewModel vm = locator<DownloadViewModel>();
      await vm.cubit.load();
      final List<DownloadStatus> seen = <DownloadStatus>[];
      final sub = vm.cubit.stream.listen(
        (DownloadState s) => seen.add(s.status),
      );
      await vm.cubit.submit('ada@fail.example');
      await Future<void>.delayed(Duration.zero);
      expect(seen, <DownloadStatus>[
        DownloadStatus.sending,
        DownloadStatus.failure,
      ]);
      expect(vm.cubit.state.message, contains('could not send'));
      await sub.cancel();
      vm.dispose();
    });
  });
}
