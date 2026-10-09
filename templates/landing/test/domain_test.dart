import 'package:cairn_template_landing/common/utils/json.dart';
import 'package:cairn_template_landing/common/utils/price_format.dart';
import 'package:cairn_template_landing/data/features/remote/features_remote_data_source.dart';
import 'package:cairn_template_landing/data/hero/remote/hero_remote_data_source.dart';
import 'package:cairn_template_landing/data/pricing/remote/pricing_remote_data_source.dart';
import 'package:cairn_template_landing/data/site/remote/site_remote_data_source.dart';
import 'package:cairn_template_landing/data/testimonials/remote/testimonials_remote_data_source.dart';
import 'package:cairn_template_landing/domain/features/mappers/features_mapper.dart';
import 'package:cairn_template_landing/domain/features/models/features_content.dart';
import 'package:cairn_template_landing/domain/hero/mappers/hero_mapper.dart';
import 'package:cairn_template_landing/domain/hero/models/hero_content.dart';
import 'package:cairn_template_landing/domain/logos/mappers/logos_mapper.dart';
import 'package:cairn_template_landing/domain/logos/models/logo_cloud.dart';
import 'package:cairn_template_landing/domain/pricing/mappers/pricing_mapper.dart';
import 'package:cairn_template_landing/domain/pricing/models/price_quote.dart';
import 'package:cairn_template_landing/domain/pricing/models/pricing_content.dart';
import 'package:cairn_template_landing/domain/pricing/use_cases/calculate_price.dart';
import 'package:cairn_template_landing/domain/shared/mappers/link_mapper.dart';
import 'package:cairn_template_landing/domain/shared/models/link.dart';
import 'package:cairn_template_landing/domain/site/mappers/site_mapper.dart';
import 'package:cairn_template_landing/domain/testimonials/mappers/testimonials_mapper.dart';
import 'package:cairn_template_landing/domain/waitlist/models/join_outcome.dart';
import 'package:cairn_template_landing/domain/waitlist/models/waitlist_content.dart';
import 'package:cairn_template_landing/domain/waitlist/repositories/waitlist_repository.dart';
import 'package:cairn_template_landing/domain/waitlist/use_cases/join_waitlist.dart';
import 'package:cairn_template_landing/domain/waitlist/use_cases/validate_email.dart';
import 'package:flutter_test/flutter_test.dart';

Plan _plan(double? monthly) => Plan(
  id: 'p',
  name: 'Plan',
  description: '',
  monthlyPrice: monthly,
  priceLabel: 'Custom',
  unit: '',
  highlighted: false,
  badge: null,
  cta: const Link(label: 'Go', href: '#waitlist'),
  featuresHeading: '',
  features: const <String>[],
);

class _FakeWaitlist implements WaitlistRepository {
  _FakeWaitlist(this.onJoin);

  final Future<WaitlistReceipt> Function(String email) onJoin;
  final List<String> joined = <String>[];

  @override
  Future<WaitlistContent> getWaitlist() => throw UnimplementedError();

  @override
  Future<WaitlistReceipt> join(String email) {
    joined.add(email);
    return onJoin(email);
  }
}

void main() {
  group('CalculatePrice', () {
    const CalculatePrice calculate = CalculatePrice();

    test('monthly billing charges the list price', () {
      final PriceQuote q = calculate(_plan(12), BillingPeriod.monthly, 20);
      expect(q.kind, PriceKind.paid);
      expect(q.perMonth, 12);
      expect(q.billedAmount, 12);
      expect(q.yearlySavings, 0);
    });

    test('yearly billing takes the discount off and bills twelve months', () {
      final PriceQuote q = calculate(_plan(12), BillingPeriod.yearly, 20);
      expect(q.perMonth, 9.6);
      expect(q.billedAmount, 115.2);
      expect(q.yearlySavings, 28.8);
    });

    test('rounds to the cent', () {
      final PriceQuote q = calculate(_plan(29), BillingPeriod.yearly, 15);
      expect(q.perMonth, 24.65);
      expect(q.billedAmount, 295.8);
      expect(q.yearlySavings, 52.2);
    });

    test('a zero discount makes the periods equal', () {
      final PriceQuote m = calculate(_plan(10), BillingPeriod.monthly, 0);
      final PriceQuote y = calculate(_plan(10), BillingPeriod.yearly, 0);
      expect(y.perMonth, m.perMonth);
      expect(y.yearlySavings, 0);
    });

    test('a free plan stays free in both periods', () {
      for (final BillingPeriod p in BillingPeriod.values) {
        final PriceQuote q = calculate(_plan(0), p, 20);
        expect(q.kind, PriceKind.free);
        expect(q.billedAmount, 0);
      }
    });

    test('a plan with no list price is custom', () {
      final PriceQuote q = calculate(_plan(null), BillingPeriod.yearly, 20);
      expect(q.kind, PriceKind.custom);
    });
  });

  group('formatPrice', () {
    test('drops cents on whole amounts only', () {
      expect(formatPrice(12), r'$12');
      expect(formatPrice(9.6), r'$9.60');
      expect(formatPrice(115.2, currency: '€'), '€115.20');
    });
  });

  group('ValidateEmail', () {
    const ValidateEmail validate = ValidateEmail();

    test('accepts ordinary addresses, trimming spaces', () {
      expect(validate('ada@example.com'), isNull);
      expect(validate('  ada.lovelace+news@mail.example.co.uk '), isNull);
    });

    test('asks for an address when empty', () {
      expect(validate(''), 'Enter your email address.');
      expect(validate('   '), 'Enter your email address.');
    });

    test('rejects malformed addresses', () {
      for (final String bad in <String>[
        'ada',
        'ada@',
        '@example.com',
        'ada@example',
        'ada@example.c',
        'ada lovelace@example.com',
        'a@@example.com',
      ]) {
        expect(validate(bad), isNotNull, reason: bad);
      }
    });
  });

  group('JoinWaitlist', () {
    const ValidateEmail validate = ValidateEmail();

    test('does not call the service for an invalid email', () async {
      final _FakeWaitlist repo = _FakeWaitlist(
        (_) async => const WaitlistReceipt(position: 1),
      );
      final JoinOutcome o = await JoinWaitlist(validate, repo)('nope');
      expect(o.status, JoinStatus.invalid);
      expect(o.message, isNotNull);
      expect(repo.joined, isEmpty);
    });

    test('joins with the trimmed address', () async {
      final _FakeWaitlist repo = _FakeWaitlist(
        (_) async => const WaitlistReceipt(position: 7),
      );
      final JoinOutcome o = await JoinWaitlist(validate, repo)(
        ' ada@example.com ',
      );
      expect(o.status, JoinStatus.joined);
      expect(o.receipt!.position, 7);
      expect(repo.joined, <String>['ada@example.com']);
    });

    test('turns a refusal into a failure with its message', () async {
      final _FakeWaitlist repo = _FakeWaitlist(
        (_) async => throw const WaitlistException('Try later.'),
      );
      final JoinOutcome o = await JoinWaitlist(validate, repo)('a@b.co');
      expect(o.status, JoinStatus.failed);
      expect(o.message, 'Try later.');
    });

    test('turns an unexpected error into a generic failure', () async {
      final _FakeWaitlist repo = _FakeWaitlist(
        (_) async => throw StateError('boom'),
      );
      final JoinOutcome o = await JoinWaitlist(validate, repo)('a@b.co');
      expect(o.status, JoinStatus.failed);
      expect(o.message, contains('try again'));
    });
  });

  group('JsonReader', () {
    test('names the key when a required value is missing or mistyped', () {
      const JsonMap json = <String, Object?>{'a': 1};
      expect(
        () => json.string('a'),
        throwsA(
          isA<FormatException>().having(
            (FormatException e) => e.message,
            'message',
            contains('"a"'),
          ),
        ),
      );
      expect(() => json.string('missing'), throwsFormatException);
      expect(() => json.objects('a'), throwsFormatException);
    });

    test('reads optional values and defaults', () {
      const JsonMap json = <String, Object?>{'n': 2, 't': true};
      expect(json.maybeString('n'), isNull);
      expect(json.maybeNumber('n'), 2.0);
      expect(json.flag('t'), isTrue);
      expect(json.flag('f'), isFalse);
      expect(json.strings('none'), isEmpty);
    });
  });

  group('mappers over the bundled content', () {
    test('site', () async {
      final site = mapSiteInfo(
        await const InMemorySiteRemoteDataSource().fetchSiteInfo(),
      );
      expect(site.brandName, 'Kestrel');
      expect(site.navLinks.map((l) => l.href), contains('#pricing'));
      expect(site.cta.href, '#waitlist');
    });

    test('hero', () async {
      final HeroContent hero = mapHero(
        await const InMemoryHeroRemoteDataSource().fetchHero(),
      );
      expect(hero.headline, isNotEmpty);
      expect(hero.proof.avatars, hasLength(4));
      expect(hero.visual.bars, everyElement(inInclusiveRange(0, 1)));
      expect(hero.visual.tasks, hasLength(3));
      expect(hero.visual.sidebar.where((e) => e.active), hasLength(1));
    });

    test('features', () async {
      final FeaturesContent f = mapFeatures(
        await const InMemoryFeaturesRemoteDataSource().fetchFeatures(),
      );
      expect(f.items, hasLength(6));
      expect(f.items.first.tag, 'New');
      expect(f.items[1].tag, isNull);
      expect(f.spotlights, hasLength(3));
      expect(f.spotlights.first.cta, isNotNull);
    });

    test('pricing', () async {
      final PricingContent p = mapPricing(
        await const InMemoryPricingRemoteDataSource().fetchPricing(),
      );
      expect(p.plans.map((Plan x) => x.id), <String>[
        'starter',
        'team',
        'scale',
      ]);
      expect(p.plans.where((Plan x) => x.highlighted).single.id, 'team');
      expect(p.plans.first.monthlyPrice, 0);
      expect(p.yearlyDiscountPercent, 20);
      expect(p.currency, r'$');
    });

    test('testimonials clamp ratings to five stars', () {
      final t = mapTestimonials(const <String, Object?>{
        'eyebrow': 'e',
        'title': 't',
        'subtitle': 's',
        'items': <Object?>[
          <String, Object?>{
            'quote': 'q',
            'name': 'n',
            'role': 'r',
            'company': 'c',
            'avatar': 'a',
            'rating': 9,
          },
        ],
      });
      expect(t.items.single.rating, 5);
    });

    test('testimonials content has six quotes with avatars', () async {
      final t = mapTestimonials(
        await const InMemoryTestimonialsRemoteDataSource().fetchTestimonials(),
      );
      expect(t.items, hasLength(6));
      expect(t.items.map((x) => x.avatar), everyElement(startsWith('assets/')));
    });

    test('logo styles fall back to bold', () {
      final LogoCloud c = mapLogoCloud(const <String, Object?>{
        'heading': 'h',
        'logos': <Object?>[
          <String, Object?>{'name': 'A', 'icon': 'bolt', 'style': 'italic'},
          <String, Object?>{'name': 'B', 'icon': 'bolt', 'style': 'nope'},
          <String, Object?>{'name': 'C', 'icon': 'bolt'},
        ],
      });
      expect(c.logos.map((CompanyLogo l) => l.style), <WordmarkStyle>[
        WordmarkStyle.italic,
        WordmarkStyle.bold,
        WordmarkStyle.bold,
      ]);
    });

    test('links', () {
      expect(
        mapLink(const <String, Object?>{'label': 'L', 'href': '#x'}),
        const Link(label: 'L', href: '#x'),
      );
      expect(
        () => mapLink(const <String, Object?>{'label': 'L'}),
        throwsFormatException,
      );
    });
  });
}
