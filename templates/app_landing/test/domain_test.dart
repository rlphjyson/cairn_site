import 'package:cairn_template_app_landing/common/constants/content_sections.dart';
import 'package:cairn_template_app_landing/common/utils/date_format.dart';
import 'package:cairn_template_app_landing/common/utils/json.dart';
import 'package:cairn_template_app_landing/common/utils/price_format.dart';
import 'package:cairn_template_app_landing/data/content/remote/app_content_data_source.dart';
import 'package:cairn_template_app_landing/domain/download/mappers/download_mapper.dart';
import 'package:cairn_template_app_landing/domain/download/models/download_content.dart';
import 'package:cairn_template_app_landing/domain/download/models/qr_pattern.dart';
import 'package:cairn_template_app_landing/domain/download/models/send_outcome.dart';
import 'package:cairn_template_app_landing/domain/download/repositories/download_repository.dart';
import 'package:cairn_template_app_landing/domain/download/use_cases/build_qr_pattern.dart';
import 'package:cairn_template_app_landing/domain/download/use_cases/send_download_link.dart';
import 'package:cairn_template_app_landing/domain/download/use_cases/validate_contact.dart';
import 'package:cairn_template_app_landing/domain/faq/mappers/faq_mapper.dart';
import 'package:cairn_template_app_landing/domain/features/mappers/features_mapper.dart';
import 'package:cairn_template_app_landing/domain/features/models/features_content.dart';
import 'package:cairn_template_app_landing/domain/features/repositories/features_repository.dart';
import 'package:cairn_template_app_landing/domain/features/use_cases/get_features.dart';
import 'package:cairn_template_app_landing/domain/footer/mappers/footer_mapper.dart';
import 'package:cairn_template_app_landing/domain/gallery/mappers/gallery_mapper.dart';
import 'package:cairn_template_app_landing/domain/hero/mappers/hero_mapper.dart';
import 'package:cairn_template_app_landing/domain/hero/models/hero_content.dart';
import 'package:cairn_template_app_landing/domain/how_it_works/mappers/how_it_works_mapper.dart';
import 'package:cairn_template_app_landing/domain/pricing/mappers/pricing_mapper.dart';
import 'package:cairn_template_app_landing/domain/pricing/models/price_quote.dart';
import 'package:cairn_template_app_landing/domain/pricing/models/pricing_content.dart';
import 'package:cairn_template_app_landing/domain/pricing/use_cases/calculate_price.dart';
import 'package:cairn_template_app_landing/domain/reviews/mappers/reviews_mapper.dart';
import 'package:cairn_template_app_landing/domain/reviews/models/reviews_content.dart';
import 'package:cairn_template_app_landing/domain/reviews/repositories/reviews_repository.dart';
import 'package:cairn_template_app_landing/domain/reviews/use_cases/get_reviews.dart';
import 'package:cairn_template_app_landing/domain/shared/mappers/app_screen_mapper.dart';
import 'package:cairn_template_app_landing/domain/shared/models/app_screen.dart';
import 'package:cairn_template_app_landing/domain/shared/models/link.dart';
import 'package:cairn_template_app_landing/domain/site/mappers/site_mapper.dart';
import 'package:cairn_template_app_landing/domain/site/models/site_info.dart';
import 'package:cairn_template_app_landing/domain/stats/mappers/stats_mapper.dart';
import 'package:cairn_template_app_landing/domain/trust/mappers/trust_mapper.dart';
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
  cta: const Link(label: 'Go', href: '#download'),
  featuresHeading: '',
  features: const <String>[],
);

class _FakeDownload implements DownloadRepository {
  _FakeDownload(this.onSend);

  final Future<void> Function(Contact contact) onSend;
  final List<Contact> sent = <Contact>[];

  @override
  Future<DownloadContent> getDownload() => throw UnimplementedError();

  @override
  Future<void> sendLink(Contact contact) {
    sent.add(contact);
    return onSend(contact);
  }
}

class _FakeReviews implements ReviewsRepository {
  _FakeReviews(this.reviews);

  final List<Review> reviews;

  @override
  Future<ReviewsContent> getReviews() async => ReviewsContent(
    eyebrow: 'e',
    title: 't',
    subtitle: 's',
    distribution: const RatingDistribution(<int, int>{5: 1}),
    reviews: reviews,
    writeReview: const WriteReviewPrompt(
      label: 'l',
      toastTitle: 't',
      toastMessage: 'm',
    ),
  );
}

Review _review(String id, String date) => Review(
  id: id,
  title: id,
  body: '',
  author: 'A',
  date: DateTime.parse(date),
  rating: 5,
  avatar: null,
);

void main() {
  const AppContentDataSource content = InMemoryAppContentDataSource();

  group('CalculatePrice', () {
    const CalculatePrice calculate = CalculatePrice();

    test('monthly billing charges the list price', () {
      final PriceQuote q = calculate(_plan(6.99), BillingPeriod.monthly, 40);
      expect(q.kind, PriceKind.paid);
      expect(q.perMonth, 6.99);
      expect(q.billedAmount, 6.99);
      expect(q.yearlySavings, 0);
    });

    test('yearly billing takes the discount off and bills twelve months', () {
      final PriceQuote q = calculate(_plan(6.99), BillingPeriod.yearly, 40);
      expect(q.perMonth, 4.19);
      expect(q.billedAmount, 50.28);
      expect(q.yearlySavings, 33.6);
    });

    test('a zero discount makes the periods equal', () {
      final PriceQuote m = calculate(_plan(10), BillingPeriod.monthly, 0);
      final PriceQuote y = calculate(_plan(10), BillingPeriod.yearly, 0);
      expect(y.perMonth, m.perMonth);
      expect(y.yearlySavings, 0);
    });

    test('a free plan stays free in both periods', () {
      for (final BillingPeriod p in BillingPeriod.values) {
        final PriceQuote q = calculate(_plan(0), p, 40);
        expect(q.kind, PriceKind.free);
        expect(q.billedAmount, 0);
      }
    });

    test('a plan with no list price is custom', () {
      final PriceQuote q = calculate(_plan(null), BillingPeriod.yearly, 40);
      expect(q.kind, PriceKind.custom);
    });
  });

  group('formatting', () {
    test('formatPrice drops cents on whole amounts only', () {
      expect(formatPrice(12), r'$12');
      expect(formatPrice(4.19), r'$4.19');
      expect(formatPrice(33.6, currency: '€'), '€33.60');
    });

    test('formatCount abbreviates thousands and millions', () {
      expect(formatCount(950), '950');
      expect(formatCount(1200), '1.2K');
      expect(formatCount(120000), '120K');
      expect(formatCount(2400000), '2.4M');
    });

    test('formatDate is month, day and year', () {
      expect(formatDate(DateTime(2026, 9, 14)), 'Sep 14, 2026');
    });
  });

  group('RatingDistribution', () {
    const RatingDistribution d = RatingDistribution(<int, int>{
      5: 6,
      4: 2,
      3: 1,
      2: 1,
      1: 0,
    });

    test('derives total, average and shares from the counts', () {
      expect(d.total, 10);
      expect(d.average, closeTo(4.3, 1e-9));
      expect(d.averageLabel, '4.3');
      expect(d.shareFor(5), 0.6);
      expect(d.shareFor(1), 0);
      expect(d.countFor(7), 0);
    });

    test('is safe with no ratings', () {
      const RatingDistribution empty = RatingDistribution(<int, int>{});
      expect(empty.total, 0);
      expect(empty.average, 0);
      expect(empty.shareFor(5), 0);
    });

    test('the demo distribution averages 4.8 over 120K ratings', () async {
      final ReviewsContent reviews = mapReviews(
        await content.fetchSection(ContentSections.reviews),
      );
      expect(reviews.distribution.total, 120000);
      expect(reviews.distribution.averageLabel, '4.8');
    });

    test('the hero rating line agrees with the distribution', () async {
      final HeroContent hero = mapHero(
        await content.fetchSection(ContentSections.hero),
      );
      final ReviewsContent reviews = mapReviews(
        await content.fetchSection(ContentSections.reviews),
      );
      expect(hero.rating, double.parse(reviews.distribution.averageLabel));
      expect(hero.ratingText, startsWith('4.8'));
    });
  });

  group('GetReviews', () {
    test('puts the newest review first', () async {
      final GetReviews get = GetReviews(
        _FakeReviews(<Review>[
          _review('old', '2026-01-02'),
          _review('new', '2026-09-30'),
          _review('mid', '2026-05-05'),
        ]),
      );
      final ReviewsContent c = await get();
      expect(c.reviews.map((Review r) => r.id), <String>['new', 'mid', 'old']);
    });

    test('mapping reads dates and clamps ratings', () {
      final ReviewsContent c = mapReviews(<String, Object?>{
        'eyebrow': 'e',
        'title': 't',
        'subtitle': 's',
        'distribution': <String, Object?>{
          '5': 1,
          '4': 0,
          '3': 0,
          '2': 0,
          '1': 0,
        },
        'reviews': <Object?>[
          <String, Object?>{
            'id': 'a',
            'title': 'T',
            'body': 'B',
            'author': 'Au',
            'date': '2026-09-14',
            'rating': 9,
          },
        ],
        'writeReview': <String, Object?>{
          'label': 'l',
          'toastTitle': 't',
          'toastMessage': 'm',
        },
      });
      expect(c.reviews.single.date, DateTime(2026, 9, 14));
      expect(c.reviews.single.rating, 5);
      expect(c.reviews.single.avatar, isNull);
    });
  });

  group('ValidateContact', () {
    const ValidateContact validate = ValidateContact();

    test('accepts ordinary email addresses, trimming spaces', () {
      final ContactCheck c = validate('  ada@example.com ');
      expect(c.isValid, isTrue);
      expect(c.contact, const Contact(ContactKind.email, 'ada@example.com'));
    });

    test('accepts phone numbers and normalises them', () {
      expect(
        validate('+1 (415) 555-0134').contact,
        const Contact(ContactKind.phone, '+14155550134'),
      );
      expect(
        validate('020 7946 0958').contact,
        const Contact(ContactKind.phone, '02079460958'),
      );
      expect(validate('415.555.0134').contact?.kind, ContactKind.phone);
    });

    test('asks for something when empty', () {
      expect(
        validate('   ').message,
        'Enter your email address or phone number.',
      );
    });

    test('rejects malformed emails', () {
      for (final String bad in <String>[
        'ada@',
        '@example.com',
        'ada@example',
        'ada lovelace@example.com',
        'a@@example.com',
      ]) {
        expect(validate(bad).isValid, isFalse, reason: bad);
        expect(
          validate(bad).message,
          'That does not look like an email address.',
          reason: bad,
        );
      }
    });

    test('rejects phone numbers that are too short or too long', () {
      expect(validate('12345').isValid, isFalse);
      expect(validate('1234567890123456').isValid, isFalse);
      expect(validate('12345').message, contains('7 to 15 digits'));
    });

    test('rejects text that is neither', () {
      expect(validate('hello there').isValid, isFalse);
      expect(validate('555-CALL-NOW').isValid, isFalse);
    });
  });

  group('SendDownloadLink', () {
    const ValidateContact validate = ValidateContact();

    test('does not call the service for an invalid entry', () async {
      final _FakeDownload repo = _FakeDownload((Contact _) async {});
      final SendOutcome o = await SendDownloadLink(validate, repo)('nope@');
      expect(o.status, SendStatus.invalid);
      expect(repo.sent, isEmpty);
    });

    test('sends to a valid email and a valid phone', () async {
      final _FakeDownload repo = _FakeDownload((Contact _) async {});
      final SendDownloadLink send = SendDownloadLink(validate, repo);
      final SendOutcome email = await send('ada@example.com');
      final SendOutcome phone = await send('+44 20 7946 0958');
      expect(email.status, SendStatus.sent);
      expect(email.contact?.kind, ContactKind.email);
      expect(phone.status, SendStatus.sent);
      expect(repo.sent.last.value, '+442079460958');
    });

    test('reports the service message when the service refuses', () async {
      final _FakeDownload repo = _FakeDownload(
        (Contact _) => throw const DownloadLinkException('Try later.'),
      );
      final SendOutcome o = await SendDownloadLink(validate, repo)(
        'ada@example.com',
      );
      expect(o.status, SendStatus.failed);
      expect(o.message, 'Try later.');
    });

    test('never throws, even for an unexpected error', () async {
      final _FakeDownload repo = _FakeDownload(
        (Contact _) => throw StateError('boom'),
      );
      final SendOutcome o = await SendDownloadLink(validate, repo)(
        'ada@example.com',
      );
      expect(o.status, SendStatus.failed);
      expect(o.message, contains('Something went wrong'));
    });
  });

  group('BuildQrPattern', () {
    const BuildQrPattern build = BuildQrPattern();

    test('is deterministic for a seed and differs between seeds', () {
      expect(build('a'), build('a'));
      expect(build('a'), isNot(build('b')));
    });

    test('draws the three finder squares and leaves the fourth corner', () {
      final QrPattern p = build('https://ember.example/get');
      expect(p.size, 25);
      expect(p.modules.length, 625);
      for (final (int x, int y) in <(int, int)>[(0, 0), (18, 0), (0, 18)]) {
        // The outer ring and the 3x3 core are dark, the ring between is light.
        expect(p.isDark(x, y), isTrue);
        expect(p.isDark(x + 6, y + 6), isTrue);
        expect(p.isDark(x + 3, y + 3), isTrue);
        expect(p.isDark(x + 1, y + 1), isFalse);
      }
    });

    test('never shrinks below the smallest grid', () {
      expect(build('x', size: 5).size, BuildQrPattern.minSize);
    });
  });

  group('GetFeatures', () {
    test('loads four features, each with a screen', () async {
      final FeaturesRepository repo = _FeaturesFromContent(content);
      final FeaturesContent c = await GetFeatures(repo)();
      expect(c.items.map((Feature f) => f.id), <String>[
        'check-in',
        'insights',
        'calendar',
        'reminders',
      ]);
      expect(c.items.map((Feature f) => f.screen.kind), <ScreenKind>[
        ScreenKind.today,
        ScreenKind.progress,
        ScreenKind.calendar,
        ScreenKind.settings,
      ]);
      expect(c.byId('insights').tabLabel, 'Insights');
      expect(c.byId('missing').id, 'check-in');
    });
  });

  group('mappers', () {
    test('every section of the demo content maps', () async {
      Future<JsonMap> j(String s) => content.fetchSection(s);
      expect(mapSiteInfo(await j(ContentSections.site)).brandName, 'Ember');
      mapHero(await j(ContentSections.hero));
      expect(mapTrust(await j(ContentSections.trust)).awards, hasLength(3));
      expect(
        mapFeatures(await j(ContentSections.features)).items,
        hasLength(4),
      );
      expect(
        mapHowItWorks(await j(ContentSections.howItWorks)).steps,
        hasLength(3),
      );
      expect(mapGallery(await j(ContentSections.gallery)).slides, hasLength(5));
      expect(mapStats(await j(ContentSections.stats)).stats, hasLength(4));
      expect(
        mapReviews(await j(ContentSections.reviews)).reviews,
        hasLength(6),
      );
      expect(mapPricing(await j(ContentSections.pricing)).plans, hasLength(2));
      expect(mapFaq(await j(ContentSections.faq)).items, hasLength(6));
      expect(mapDownload(await j(ContentSections.download)).qr.badge, 'Demo');
      expect(mapFooter(await j(ContentSections.footer)).columns, hasLength(3));
    });

    test('the site names both stores', () async {
      final SiteInfo site = mapSiteInfo(
        await content.fetchSection(ContentSections.site),
      );
      expect(site.appStore.spoken, 'Download on the App Store');
      expect(site.googlePlay.spoken, 'Get it on Google Play');
      expect(site.storeFor(StoreKind.googlePlay), site.googlePlay);
    });

    test('a screen with an unknown kind fails loudly', () {
      expect(
        () => mapScreen(<String, Object?>{
          'kind': 'hologram',
          'title': 't',
          'description': 'd',
        }),
        throwsFormatException,
      );
    });

    test('a missing required key names the key', () {
      expect(
        () => mapFaq(<String, Object?>{}),
        throwsA(
          isA<FormatException>().having(
            (FormatException e) => e.message,
            'message',
            contains('eyebrow'),
          ),
        ),
      );
    });

    test('screens clamp out-of-range values', () {
      final AppScreen s = mapScreen(<String, Object?>{
        'kind': 'progress',
        'title': 't',
        'description': 'd',
        'bars': <Object?>[2, -1, 0.5],
        'tab': 9,
        'items': <Object?>[
          <String, Object?>{'label': 'x', 'value': 3},
        ],
      });
      expect(s.bars, <double>[1, 0, 0.5]);
      expect(s.tab, 3);
      expect(s.items.single.value, 1);
    });

    test('the dock always has four labels', () {
      final AppScreen s = mapScreen(<String, Object?>{
        'kind': 'today',
        'title': 't',
        'description': 'd',
        'dock': <Object?>['Heute'],
      });
      expect(s.dock, <String>['Heute', 'Progress', 'Calendar', 'Settings']);
    });

    test('the content source rejects an unknown section', () {
      expect(() => content.fetchSection('nope'), throwsArgumentError);
    });
  });
}

class _FeaturesFromContent implements FeaturesRepository {
  _FeaturesFromContent(this._source);

  final AppContentDataSource _source;

  @override
  Future<FeaturesContent> getFeatures() async =>
      mapFeatures(await _source.fetchSection(ContentSections.features));
}
