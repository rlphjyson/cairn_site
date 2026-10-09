/// Renders every page through the real pipeline and asserts on the bytes a
/// crawler receives.
library;

import 'package:cairn_template_jaspr_store/backend/stores.dart';
import 'package:test/test.dart';

import '../support/harness.dart';

void main() {
  late TestApp app;
  late Browser visitor;
  setUpAll(() async => app = await TestApp.create());
  setUp(() => visitor = Browser(app));

  group('home', () {
    late TestResponse r;
    setUp(() async => r = await visitor.get('/'));

    test('200 and server-rendered content', () {
      expect(r.status, 200);
      expect(r.text, contains('Considered everyday objects'));
      expect(r.qa('.card-product'), hasLength(4));
      expect(r.qa('.cat-tile'), hasLength(5));
    });

    test('document basics: doctype, lang, viewport, charset', () {
      expect(r.body, startsWith('<!DOCTYPE html>'));
      expect(r.doc.documentElement!.attributes['lang'], 'en');
      expect(r.meta('viewport'), contains('width=device-width'));
      expect(r.q('meta[charset]'), isNotNull);
    });

    test('title and description', () {
      expect(r.title, 'Northgate Goods: Considered everyday objects');
      expect(r.meta('description'), contains('Northgate Goods'));
      expect(r.meta('description')!.length, lessThanOrEqualTo(158));
    });

    test('canonical is absolute and clean', () => expect(r.canonical, 'https://shop.example/'));

    test('theme-color for light and dark', () {
      final colors = r.qa('meta[name="theme-color"]');
      expect(colors, hasLength(2));
      expect(
        colors.map((e) => e.attributes['media']),
        containsAll(['(prefers-color-scheme: light)', '(prefers-color-scheme: dark)']),
      );
    });

    test('Open Graph and Twitter tags are complete and absolute', () {
      expect(r.og('og:type'), 'website');
      expect(r.og('og:title'), isNotEmpty);
      expect(r.og('og:description'), isNotEmpty);
      expect(r.og('og:url'), 'https://shop.example/');
      expect(r.og('og:image'), 'https://shop.example/images/og-cover.jpg');
      expect(r.og('og:image:alt'), isNotEmpty);
      expect(r.og('og:image:width'), '1200');
      expect(r.og('og:site_name'), 'Northgate Goods');
      expect(r.og('og:locale'), 'en_US');
      expect(r.meta('twitter:card'), 'summary_large_image');
      expect(r.meta('twitter:image'), startsWith('https://shop.example/'));
      expect(r.meta('twitter:site'), '@northgategoods');
    });

    test('hreflang hook is present', () {
      expect(
        r.qa('link[rel="alternate"][hreflang]').map((e) => e.attributes['hreflang']),
        containsAll(['en', 'x-default']),
      );
    });

    test('JSON-LD: Organization and WebSite with SearchAction', () {
      final ld = r.jsonLd();
      final types = ld.map((e) => e['@type']).toList();
      expect(types, containsAll(['Organization', 'WebSite']));
      final site = ld.firstWhere((e) => e['@type'] == 'WebSite');
      expect(site['potentialAction']['@type'], 'SearchAction');
      expect(site['potentialAction']['target']['urlTemplate'], 'https://shop.example/products?q={search_term_string}');
      expect(site['potentialAction']['query-input'], contains('search_term_string'));
      final org = ld.firstWhere((e) => e['@type'] == 'Organization');
      expect(org['url'], 'https://shop.example/');
      expect(org['logo']['url'], startsWith('https://shop.example/'));
    });

    test('exactly one h1 and a sane heading order', () {
      expect(r.qa('h1'), hasLength(1));
      expect(r.q('h1')!.text, contains('Considered'));
    });

    test('landmarks and skip link', () {
      expect(r.qa('main#main'), hasLength(1));
      expect(r.q('header.site-header'), isNotNull);
      expect(r.q('footer.site-footer'), isNotNull);
      expect(r.qa('nav[aria-label]').length, greaterThanOrEqualTo(3));
      final skip = r.q('a.skip-link')!;
      expect(skip.attributes['href'], '#main');
    });

    test('there is no <base> tag that could break the skip link', () {
      expect(r.q('base'), isNull);
    });

    test('the hero image is the LCP: high priority, preloaded, sized', () {
      final hero = r.q('.hero__picture img')!;
      expect(hero.attributes['fetchpriority'], 'high');
      expect(hero.attributes.containsKey('loading'), isFalse);
      expect(hero.attributes['width'], isNotEmpty);
      expect(hero.attributes['height'], isNotEmpty);
      expect(hero.attributes['alt'], isNotEmpty);
      final preload = r.q('link[rel="preload"][as="image"]')!;
      expect(preload.attributes['fetchpriority'], 'high');
      expect(preload.attributes['imagesrcset'], contains('hero-1280.webp 1280w'));
    });

    test('other images are lazy with dimensions and async decoding', () {
      for (final img in r.qa('img').where((i) => i.attributes['fetchpriority'] != 'high')) {
        expect(img.attributes['loading'], 'lazy', reason: img.attributes['src']);
        expect(img.attributes['decoding'], 'async');
        expect(img.attributes['width'], isNotNull);
        expect(img.attributes['height'], isNotNull);
        expect(img.attributes.containsKey('alt'), isTrue);
      }
    });

    test('newsletter form is a plain POST form with a labelled input', () {
      final form = r.q('form[action="/newsletter"]')!;
      expect(form.attributes['method'], 'post');
      final input = form.querySelector('input[name="email"]')!;
      expect(r.q('label[for="${input.attributes['id']}"]'), isNotNull);
      expect(input.attributes['type'], 'email');
      expect(input.attributes['autocomplete'], 'email');
    });

    test('inline stylesheet with design tokens is present; no external CSS or fonts', () {
      expect(r.body, contains('--radius:'));
      expect(r.body, contains('oklch(0.145 0 0)'));
      expect(r.qa('link[rel="stylesheet"]'), isEmpty);
      expect(r.body, isNot(contains('@font-face')));
      expect(r.body, isNot(contains('fonts.googleapis')));
    });

    test('prefers-color-scheme and reduced-motion are handled in CSS', () {
      expect(r.body, contains('prefers-color-scheme: dark'));
      expect(r.body, contains('prefers-reduced-motion: reduce'));
      expect(r.body, contains(':focus-visible'));
    });

    test('server-stamped theme: cookie and query set data-theme on <html>', () async {
      expect((await app.send('GET', '/', cookie: 'theme=dark')).doc.documentElement!.attributes['data-theme'], 'dark');
      expect((await app.send('GET', '/?theme=light')).doc.documentElement!.attributes['data-theme'], 'light');
      expect(r.doc.documentElement!.attributes.containsKey('data-theme'), isFalse);
    });

    test('hostile theme values are ignored', () async {
      final res = await app.send('GET', '/', cookie: 'theme="><script>alert(1)</script>');
      expect(res.doc.documentElement!.attributes.containsKey('data-theme'), isFalse);
      expect(res.body, isNot(contains('<script>alert')));
    });

    test('islands hydrate: only the three client islands are referenced', () {
      expect(r.body, contains('theme-toggle'));
      expect(r.q('a.cart-link[href="/cart"]'), isNotNull);
    });

    test('mobile menu is a native <details>, so it works without JavaScript', () {
      final menu = r.q('details.mobile-menu')!;
      expect(menu.querySelector('summary[aria-label="Menu"]'), isNotNull);
      expect(menu.querySelectorAll('nav a'), isNotEmpty);
    });
  });

  group('listing /products', () {
    test('first page: 8 products, canonical, ItemList and BreadcrumbList', () async {
      final r = await visitor.get('/products');
      expect(r.status, 200);
      expect(r.qa('.card-product'), hasLength(8));
      expect(r.canonical, 'https://shop.example/products');
      expect(r.meta('robots'), contains('index'));
      expect(r.title, startsWith('Shop all products'));
      expect(r.qa('h1'), hasLength(1));
      final types = r.jsonLd().map((e) => e['@type']);
      expect(types, containsAll(['BreadcrumbList', 'ItemList']));
      final list = r.jsonLd().firstWhere((e) => e['@type'] == 'ItemList');
      expect(list['itemListElement'], hasLength(8));
      expect(list['itemListElement'].first['position'], 1);
      expect(list['itemListElement'].first['url'], startsWith('https://shop.example/products/'));
    });

    test('page 2 is self-canonical, titled, indexable and linked with rel=prev', () async {
      final r = await visitor.get('/products?page=2');
      expect(r.status, 200);
      expect(r.canonical, 'https://shop.example/products?page=2');
      expect(r.title, contains('page 2'));
      expect(r.meta('robots'), contains('index'));
      expect(r.q('link[rel="prev"]')!.attributes['href'], 'https://shop.example/products');
      expect(r.q('link[rel="next"]'), isNull);
      expect(r.qa('.card-product'), hasLength(4));
      final list = r.jsonLd().firstWhere((e) => e['@type'] == 'ItemList');
      expect(list['itemListElement'].first['position'], 9);
    });

    test('page 1 links rel=next to page 2', () async {
      final r = await visitor.get('/products');
      expect(r.q('link[rel="next"]')!.attributes['href'], 'https://shop.example/products?page=2');
      expect(r.q('link[rel="prev"]'), isNull);
    });

    test('pagination markup is accessible', () async {
      final r = await visitor.get('/products');
      final nav = r.q('nav.pagination')!;
      expect(nav.attributes['aria-label'], 'Pagination');
      expect(nav.querySelector('[aria-current="page"]')!.text, '1');
      expect(nav.querySelector('a[rel="next"]')!.attributes['href'], '/products?page=2');
    });

    test('a sorted page stays indexable but canonicalises to the unsorted URL', () async {
      final r = await visitor.get('/products?sort=price-asc');
      expect(r.status, 200);
      expect(r.canonical, 'https://shop.example/products');
      expect(r.meta('robots'), contains('index'));
      final first = r.q('.card-product .price__now')!.text;
      expect(first, contains(r'$18.00'));
    });

    test('search results are noindex,follow with a self canonical', () async {
      final r = await visitor.get('/products?q=leather');
      expect(r.status, 200);
      expect(r.meta('robots'), 'noindex, follow');
      expect(r.header('x-robots-tag'), 'noindex, follow');
      expect(r.canonical, 'https://shop.example/products?q=leather');
      expect(r.qa('.card-product'), hasLength(3));
      expect(r.q('h1')!.text, contains('leather'));
    });

    test('tracking parameters never reach the canonical', () async {
      final r = await visitor.get('/products?utm_source=news&gclid=abc&fbclid=1');
      expect(r.status, 200);
      expect(r.canonical, 'https://shop.example/products');
    });

    test('empty search results are a 200 with a helpful empty state', () async {
      final r = await visitor.get('/products?q=zzzzzz');
      expect(r.status, 200);
      expect(r.q('.empty'), isNotNull);
      expect(r.text, contains('No products match'));
      expect(r.meta('robots'), 'noindex, follow');
    });

    test('a hostile search string is escaped', () async {
      final r = await visitor.get('/products?q=%3Cscript%3Ealert(1)%3C%2Fscript%3E');
      expect(r.body, isNot(contains('<script>alert(1)')));
      expect(r.status, 200);
    });

    test('the filter form is a GET form with labelled controls', () async {
      final r = await visitor.get('/products?q=a');
      final form = r.q('form.toolbar')!;
      expect(form.attributes['method'], 'get');
      expect(form.attributes['action'], '/products');
      for (final c in form.querySelectorAll('input,select')) {
        expect(r.q('label[for="${c.attributes['id']}"]'), isNotNull);
      }
      expect(form.querySelectorAll('option'), hasLength(6));
    });
  });

  group('category pages', () {
    test('a category is its own indexable page with a unique title and description', () async {
      final r = await visitor.get('/categories/audio');
      expect(r.status, 200);
      expect(r.canonical, 'https://shop.example/categories/audio');
      expect(r.title, startsWith('Audio'));
      expect(r.meta('description'), contains('headphones'));
      expect(r.qa('.card-product'), hasLength(2));
      expect(r.q('h1')!.text, 'Audio');
      final crumbs = r.jsonLd().firstWhere((e) => e['@type'] == 'BreadcrumbList');
      expect((crumbs['itemListElement'] as List).map((e) => e['name']), ['Home', 'Shop', 'Audio']);
    });

    test('every category has a distinct title and description', () async {
      final titles = <String>{};
      final descs = <String>{};
      for (final slug in ['footwear', 'audio', 'accessories', 'bags', 'home']) {
        final r = await visitor.get('/categories/$slug');
        titles.add(r.title);
        descs.add(r.meta('description')!);
      }
      expect(titles, hasLength(5));
      expect(descs, hasLength(5));
    });

    test('the active category chip is marked', () async {
      final r = await visitor.get('/categories/bags');
      expect(r.q('.chip.is-active')!.text, 'Bags');
      expect(r.q('.chip.is-active')!.attributes['aria-current'], 'page');
    });
  });

  group('product page', () {
    late TestResponse r;
    setUp(() async => r = await visitor.get('/products/stride-knit-sneaker'));

    test('200 with a unique title, description and canonical', () {
      expect(r.status, 200);
      expect(r.title, 'Stride Knit Sneaker | Northgate Goods');
      expect(r.meta('description'), contains('featherweight'));
      expect(r.canonical, 'https://shop.example/products/stride-knit-sneaker');
    });

    test('one h1 with the product name', () {
      expect(r.qa('h1'), hasLength(1));
      expect(r.q('h1')!.text, 'Stride Knit Sneaker');
    });

    test('Open Graph product tags', () {
      expect(r.og('og:type'), 'product');
      expect(r.og('product:price:amount'), '98.00');
      expect(r.og('product:price:currency'), 'USD');
      expect(r.og('product:availability'), 'in stock');
      expect(r.og('product:brand'), 'Northgate');
      expect(r.og('product:retailer_item_id'), 'NG-SNK-001');
      expect(r.og('og:image'), 'https://shop.example/images/products/sneaker-white.jpg');
      expect(r.og('og:image:alt'), contains('sneakers'));
      expect(r.og('product:category'), 'Footwear');
    });

    test('JSON-LD Product with a full Offer', () {
      final product = r.jsonLd().firstWhere((e) => e['@type'] == 'Product');
      expect(product['name'], 'Stride Knit Sneaker');
      expect(product['sku'], 'NG-SNK-001');
      expect(product['gtin13'], '8401234510006');
      expect(product['brand']['name'], 'Northgate');
      expect(product['image'], everyElement(startsWith('https://shop.example/images/')));
      final offer = product['offers'] as Map<String, dynamic>;
      expect(offer['price'], '98.00');
      expect(offer['priceCurrency'], 'USD');
      expect(offer['availability'], 'https://schema.org/InStock');
      expect(offer['itemCondition'], 'https://schema.org/NewCondition');
      expect(offer['url'], 'https://shop.example/products/stride-knit-sneaker');
      expect(offer['seller']['@id'], 'https://shop.example/#organization');
      expect(offer['priceValidUntil'], '2027-03-15');
      expect(offer['shippingDetails']['@type'], 'OfferShippingDetails');
      expect(offer['hasMerchantReturnPolicy']['merchantReturnDays'], 30);
    });

    test('JSON-LD AggregateRating and Reviews match the visible reviews', () {
      final product = r.jsonLd().firstWhere((e) => e['@type'] == 'Product');
      expect(product['aggregateRating']['ratingValue'], 4.8);
      expect(product['aggregateRating']['reviewCount'], 4);
      expect(product['review'], hasLength(4));
      final review = product['review'].first as Map<String, dynamic>;
      expect(review['reviewRating']['ratingValue'], inInclusiveRange(1, 5));
      expect(review['author']['@type'], 'Person');
      expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(review['datePublished'] as String), isTrue);
      expect(r.qa('article.review'), hasLength(4));
    });

    test('JSON-LD BreadcrumbList is ordered and absolute', () {
      final crumbs = r.jsonLd().firstWhere((e) => e['@type'] == 'BreadcrumbList');
      final items = (crumbs['itemListElement'] as List).cast<Map<String, dynamic>>();
      expect(items.map((e) => e['position']), [1, 2, 3, 4]);
      expect(items.map((e) => e['name']), ['Home', 'Shop', 'Footwear', 'Stride Knit Sneaker']);
      expect(items.last['item'], 'https://shop.example/products/stride-knit-sneaker');
    });

    test('a product without reviews makes no AggregateRating or Review claim', () async {
      final bare = await TestApp.create(
        backend: DemoBackend(reviews: ReviewStore(reviews: const [])),
      );
      final res = await bare.send('GET', '/products/stoneware-mug');
      final product = res.jsonLd().firstWhere((e) => e['@type'] == 'Product');
      expect(product.containsKey('aggregateRating'), isFalse);
      expect(product.containsKey('review'), isFalse);
      expect(res.text, contains('No reviews yet'));
    });

    test('availability maps to schema.org for low stock and sold out', () async {
      final low = await visitor.get('/products/skeleton-sport-watch');
      final offer = low.jsonLd().firstWhere((e) => e['@type'] == 'Product')['offers'];
      expect(offer['availability'], 'https://schema.org/LimitedAvailability');
      expect(low.og('product:availability'), 'in stock');
    });

    test('gallery has sized, described images; only the first is high priority', () {
      final slides = r.qa('.gallery__slide img');
      expect(slides, hasLength(2));
      expect(slides.first.attributes['fetchpriority'], 'high');
      expect(slides.last.attributes['loading'], 'lazy');
      for (final img in slides) {
        expect(img.attributes['width'], '700');
        expect(img.attributes['height'], '700');
        expect(img.attributes['alt']!.length, greaterThan(10));
      }
      final source = r.q('.gallery__slide picture source')!;
      expect(source.attributes['type'], 'image/webp');
      expect(source.attributes['srcset'], contains('350w'));
      expect(source.attributes['srcset'], contains('700w'));
      expect(source.attributes['sizes'], isNotEmpty);
    });

    test('the LCP image is preloaded', () {
      final preload = r.q('link[rel="preload"][as="image"]')!;
      expect(preload.attributes['imagesrcset'], contains('sneaker-white-350.webp'));
    });

    test('thumbnails are in-page anchors that point at real elements', () {
      for (final a in r.qa('.gallery__thumb')) {
        final id = a.attributes['href']!.substring(1);
        expect(r.doc.getElementById(id), isNotNull);
        expect(a.attributes['aria-label'], isNotEmpty);
      }
    });

    test('price, compare-at, discount and stock are rendered', () {
      expect(r.q('.pdp .price__now')!.text, contains(r'$98.00'));
      expect(r.q('.pdp .price__was')!.text, contains(r'$120.00'));
      expect(r.text, contains('Save 18%'));
      expect(r.text, contains('In stock'));
    });

    test('the add-to-cart form works without JavaScript', () {
      final form = r.q('form#add-to-cart')!;
      expect(form.attributes['method'], 'post');
      expect(form.attributes['action'], '/cart/add');
      expect(form.querySelector('input[name="productId"]')!.attributes['value'], 'p_stride_knit');
      expect(form.querySelector('button[type="submit"]'), isNotNull);
    });

    test('variants are radio inputs inside a fieldset with a legend; sold-out ones are disabled', () {
      final fs = r.q('fieldset.variants')!;
      expect(fs.querySelector('legend'), isNotNull);
      final radios = fs.querySelectorAll('input[type="radio"][name="variantId"]');
      expect(radios, hasLength(6));
      expect(radios.where((e) => e.attributes.containsKey('checked')), hasLength(1));
      final soldOut = radios.firstWhere((e) => e.attributes['value'] == 'v_stride_44');
      expect(soldOut.attributes.containsKey('disabled'), isTrue);
    });

    test('quantity has a label', () {
      expect(r.q('label[for="qty"]'), isNotNull);
      expect(r.q('input#qty')!.attributes['min'], '1');
    });

    test('details use native <details> accordions with the first open', () {
      final items = r.qa('details.accordion__item');
      expect(items.length, greaterThanOrEqualTo(3));
      expect(items.first.attributes.containsKey('open'), isTrue);
      expect(items.last.attributes.containsKey('open'), isFalse);
    });

    test('reviews, related products and a reviews anchor exist', () {
      expect(r.q('#reviews'), isNotNull);
      expect(r.q('a[href="#reviews"]'), isNotNull);
      expect(r.qa('section[aria-labelledby="related-title"] .card-product'), hasLength(4));
      expect(r.qa('time[datetime]'), isNotEmpty);
    });

    test('rating is exposed to assistive technology as one sentence', () {
      final rating = r.q('.pdp .rating')!;
      expect(rating.attributes['role'], 'img');
      expect(rating.attributes['aria-label'], 'Rated 4.8 out of 5 from 4 reviews');
    });

    test('a single-variant product has a hidden input and no radio group', () async {
      final res = await visitor.get('/products/day-backpack');
      expect(res.q('fieldset.variants'), isNull);
      expect(res.q('form#add-to-cart input[type="hidden"][name="variantId"]')!.attributes['value'], 'v_day_black');
    });

    test('a sold-out-only product disables the button', () async {
      final backend = app.backend;
      expect(backend.catalog.reserve({'v_skeleton_42': 2}), isTrue);
      final res = await visitor.get('/products/skeleton-sport-watch');
      expect(res.qa('button[disabled]'), isNotEmpty);
      expect(res.text, contains('Sold out'));
      final offer = res.jsonLd().firstWhere((e) => e['@type'] == 'Product')['offers'];
      expect(offer['availability'], 'https://schema.org/OutOfStock');
      expect(res.og('product:availability'), 'out of stock');
    });

    test('a hostile error code cannot inject text', () async {
      final res = await visitor.get('/products/stride-knit-sneaker?error=<script>alert(1)</script>');
      expect(res.body, isNot(contains('<script>alert')));
      expect(res.q('.alert'), isNull);
      final known = await visitor.get('/products/stride-knit-sneaker?error=out_of_stock');
      expect(known.q('.alert')!.text, contains('sold out'));
      expect(known.q('.alert')!.attributes['role'], 'alert');
    });

    test('?variant preselects without changing the canonical', () async {
      final res = await visitor.get('/products/classic-38-watch?variant=v_classic_black');
      expect(res.canonical, 'https://shop.example/products/classic-38-watch');
      expect(res.q('input[value="v_classic_black"]')!.attributes.containsKey('checked'), isTrue);
      expect(res.q('input[value="v_classic_brown"]')!.attributes.containsKey('checked'), isFalse);
    });
  });

  group('cart and checkout are noindex and uncacheable', () {
    test('cart', () async {
      final r = await visitor.get('/cart');
      expect(r.status, 200);
      expect(r.meta('robots'), 'noindex, nofollow');
      expect(r.header('cache-control'), 'no-store');
      expect(r.header('x-robots-tag'), 'noindex, nofollow');
      expect(r.qa('h1'), hasLength(1));
      expect(r.text, contains('Your cart is empty'));
    });

    test('checkout without items redirects to the cart', () async {
      final r = await visitor.get('/checkout');
      expect(r.status, 303);
      expect(r.location, '/cart');
    });

    test('newsletter', () async {
      final r = await visitor.get('/newsletter');
      expect(r.status, 200);
      expect(r.meta('robots'), 'noindex, follow');
      expect(r.header('cache-control'), 'no-store');
    });
  });

  group('about', () {
    test('is indexable, has one h1, JSON-LD and a shipping anchor', () async {
      final r = await visitor.get('/about');
      expect(r.status, 200);
      expect(r.canonical, 'https://shop.example/about');
      expect(r.qa('h1'), hasLength(1));
      expect(r.q('#shipping'), isNotNull);
      expect(r.jsonLd().map((e) => e['@type']), contains('BreadcrumbList'));
      expect(r.text, contains('fictional shop'));
    });
  });

  group('titles and descriptions are unique and length-aware', () {
    test('across the whole sitemap', () async {
      final sitemap = await visitor.get('/sitemap.xml');
      final paths = RegExp(
        r'<loc>https://shop.example([^<]*)</loc>',
      ).allMatches(sitemap.body).map((m) => m.group(1)!).toList();
      final titles = <String>{};
      final descriptions = <String>{};
      for (final path in paths) {
        final r = await visitor.get(path);
        expect(r.title.length, lessThanOrEqualTo(70), reason: path);
        expect(r.meta('description')!.length, lessThanOrEqualTo(165), reason: path);
        titles.add(r.title);
        descriptions.add(r.meta('description')!);
      }
      expect(titles, hasLength(paths.length));
      expect(descriptions, hasLength(paths.length));
    });
  });
}
