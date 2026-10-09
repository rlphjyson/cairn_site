import 'dart:io';

import 'package:cairn_template_jaspr_store/backend/seed_reviews.dart';
import 'package:cairn_template_jaspr_store/backend/stores.dart';
import 'package:cairn_template_jaspr_store/data/catalog/catalog_repository_impl.dart';
import 'package:cairn_template_jaspr_store/domain/catalog/models/product.dart';
import 'package:cairn_template_jaspr_store/domain/catalog/models/product_query.dart';
import 'package:cairn_template_jaspr_store/domain/catalog/use_cases/product_lookup.dart';
import 'package:cairn_template_jaspr_store/domain/catalog/use_cases/query_products.dart';
import 'package:cairn_template_jaspr_store/domain/reviews/models/review.dart';
import 'package:test/test.dart';

CatalogRepositoryImpl repo() => CatalogRepositoryImpl(CatalogStore(), ReviewStore());

void main() {
  late List<Product> products;
  late List<Category> categories;
  setUp(() async {
    final r = repo();
    products = await r.allProducts();
    categories = await r.categories();
  });

  group('seed data integrity', () {
    test('there are 12 products across 5 categories', () {
      expect(products, hasLength(12));
      expect(categories, hasLength(5));
    });

    test('ids, slugs, SKUs, GTINs and variant ids are unique', () {
      expect(products.map((p) => p.id).toSet(), hasLength(products.length));
      expect(products.map((p) => p.slug).toSet(), hasLength(products.length));
      expect(products.map((p) => p.sku).toSet(), hasLength(products.length));
      expect(products.map((p) => p.gtin).toSet(), hasLength(products.length));
      final variants = products.expand((p) => p.variants).toList();
      expect(variants.map((v) => v.id).toSet(), hasLength(variants.length));
      expect(variants.map((v) => v.sku).toSet(), hasLength(variants.length));
    });

    test('every GTIN-13 has a valid check digit', () {
      for (final p in products) {
        expect(p.gtin, matches(RegExp(r'^\d{13}$')));
        final digits = p.gtin.split('').map(int.parse).toList();
        final sum = [for (var i = 0; i < 12; i++) digits[i] * (i.isOdd ? 3 : 1)].reduce((a, b) => a + b);
        expect((10 - sum % 10) % 10, digits[12], reason: p.name);
      }
    });

    test('every product belongs to a real category and has a variant, image and details', () {
      final slugs = categories.map((c) => c.slug).toSet();
      for (final p in products) {
        expect(slugs, contains(p.categorySlug), reason: p.name);
        expect(p.variants, isNotEmpty, reason: p.name);
        expect(p.images, isNotEmpty, reason: p.name);
        expect(p.summary.length, greaterThan(20), reason: p.name);
        expect(p.description, isNotEmpty, reason: p.name);
        expect(p.priceCents, greaterThan(0), reason: p.name);
      }
    });

    test('every category has at least one product and alt text on its image', () {
      for (final c in categories) {
        expect(products.where((p) => p.categorySlug == c.slug), isNotEmpty, reason: c.slug);
        expect(c.image.alt, isNotEmpty);
      }
    });

    test('every image file referenced exists on disk in all widths', () {
      final images = [...products.expand((p) => p.images), ...categories.map((c) => c.image)];
      for (final image in images) {
        expect(image.alt.length, greaterThan(10), reason: image.base);
        expect(File('web${image.fallbackUrl}').existsSync(), isTrue, reason: image.fallbackUrl);
        for (final w in image.widths) {
          expect(File('web${image.urlAt(w)}').existsSync(), isTrue, reason: image.urlAt(w));
        }
      }
    });

    test('compare-at prices are above the price', () {
      for (final p in products.where((p) => p.compareAtCents != null)) {
        expect(p.compareAtCents, greaterThan(p.priceCents), reason: p.name);
      }
    });

    test('previous slugs never collide with live slugs', () {
      final live = products.map((p) => p.slug).toSet();
      for (final p in products) {
        for (final old in p.previousSlugs) {
          expect(live, isNot(contains(old)));
        }
      }
    });

    test('reviews reference real products and have valid ratings', () {
      final ids = products.map((p) => p.id).toSet();
      for (final r in seedReviews()) {
        expect(ids, contains(r.productId));
        expect(r.rating, inInclusiveRange(1, 5));
      }
    });

    test('seed includes a sold-out variant, a low-stock product and a sale', () {
      expect(products.any((p) => p.variants.any((v) => !v.inStock)), isTrue);
      expect(products.any((p) => p.availability == Availability.lowStock), isTrue);
      expect(products.any((p) => p.onSale), isTrue);
    });
  });

  group('models', () {
    test('ProductImage builds srcset and fallback URLs', () {
      const image = ProductImage(base: 'x', alt: 'alt');
      expect(image.srcset, '/images/products/x-350.webp 350w, /images/products/x-700.webp 700w');
      expect(image.fallbackUrl, '/images/products/x.jpg');
      expect(image.width, 700);
    });

    test('availability follows total stock', () {
      Product withStock(List<int> stocks) => products.first.copyWith(
        variants: [
          for (var i = 0; i < stocks.length; i++) ProductVariant(id: 'v$i', label: '$i', sku: 's$i', stock: stocks[i]),
        ],
      );
      expect(withStock([0, 0]).availability, Availability.outOfStock);
      expect(withStock([3, 2]).availability, Availability.lowStock);
      expect(withStock([3, 3]).availability, Availability.inStock);
      expect(withStock([0, 0]).inStock, isFalse);
    });

    test('defaultVariant prefers an in-stock variant', () {
      final p = products.firstWhere((p) => p.slug == 'halo-wireless-headphones');
      expect(p.defaultVariant.inStock, isTrue);
      final reversed = p.copyWith(variants: p.variants.reversed.toList());
      expect(reversed.defaultVariant.inStock, isTrue);
    });

    test('priceFor uses a variant override when present', () {
      final p = products.first;
      const v = ProductVariant(id: 'x', label: 'x', sku: 'x', stock: 1, priceCents: 1);
      expect(p.priceFor(v), 1);
      expect(p.priceFor(p.variants.first), p.priceCents);
    });

    test('RatingSummary computes average, count and distribution', () {
      final reviews = [
        for (final r in [5, 5, 4, 3])
          Review(id: '$r', productId: 'p', author: 'a', rating: r, title: 't', body: 'b', date: DateTime.utc(2026)),
      ];
      final s = RatingSummary.from(reviews);
      expect(s.count, 4);
      expect(s.average, 4.3);
      expect(s.distribution[5], 2);
      expect(s.distribution[1], 0);
      expect(RatingSummary.from(const []).hasReviews, isFalse);
    });

    test('products carry ratings joined from reviews', () {
      final watch = products.firstWhere((p) => p.slug == 'classic-38-watch');
      expect(watch.rating.count, 4);
      expect(watch.rating.average, greaterThan(4.5));
      final satchel = products.firstWhere((p) => p.slug == 'courier-leather-satchel');
      expect(satchel.rating.count, 2);
    });
  });

  group('applyQuery', () {
    ProductListing run(ProductQuery q) => applyQuery(products, q, categories: categories);

    test('default query returns the first page, featured first', () {
      final l = run(const ProductQuery());
      expect(l.total, 12);
      expect(l.items, hasLength(8));
      expect(l.pageCount, 2);
      expect(l.items.first.featured, isTrue);
      expect(l.hasNext, isTrue);
      expect(l.hasPrev, isFalse);
    });

    test('second page has the remaining products', () {
      final l = run(const ProductQuery(page: 2));
      expect(l.items, hasLength(4));
      expect(l.hasPrev, isTrue);
      expect(l.hasNext, isFalse);
      expect(l.firstIndex, 9);
      expect(l.lastIndex, 12);
    });

    test('pages do not overlap and cover everything', () {
      final a = run(const ProductQuery()).items.map((p) => p.id).toList();
      final b = run(const ProductQuery(page: 2)).items.map((p) => p.id).toList();
      expect({...a, ...b}, hasLength(12));
    });

    test('page beyond the end is flagged out of range', () {
      final l = run(const ProductQuery(page: 9));
      expect(l.items, isEmpty);
      expect(l.pageOutOfRange, isTrue);
    });

    test('an empty result is not out of range', () {
      final l = run(const ProductQuery(search: 'zzzzz', page: 1));
      expect(l.isEmpty, isTrue);
      expect(l.pageOutOfRange, isFalse);
      expect(l.pageCount, 1);
    });

    test('category filter', () {
      final l = run(const ProductQuery(categorySlug: 'bags'));
      expect(l.total, 3);
      expect(l.items.every((p) => p.categorySlug == 'bags'), isTrue);
    });

    test('unknown category yields nothing', () {
      expect(run(const ProductQuery(categorySlug: 'nope')).total, 0);
    });

    test('in-stock filter', () {
      final l = run(const ProductQuery(inStockOnly: true));
      expect(l.items.every((p) => p.inStock), isTrue);
    });

    test('search matches names case-insensitively', () {
      final l = run(const ProductQuery(search: 'SNEAKER'));
      expect(l.items.map((p) => p.slug), containsAll(['stride-knit-sneaker', 'court-low-sneaker']));
    });

    test('search matches category names, tags, brand and SKU', () {
      expect(run(const ProductQuery(search: 'footwear')).total, 2);
      expect(run(const ProductQuery(search: 'bluetooth')).items.single.slug, 'halo-wireless-headphones');
      expect(run(const ProductQuery(search: 'northgate audio')).total, 2);
      expect(run(const ProductQuery(search: 'NG-WCH-002')).items.first.slug, 'skeleton-sport-watch');
    });

    test('search uses AND semantics across terms', () {
      expect(run(const ProductQuery(search: 'leather satchel')).items.single.slug, 'courier-leather-satchel');
      expect(run(const ProductQuery(search: 'leather watch xyz')).total, 0);
    });

    test('search ranks name hits above description hits', () {
      final l = run(const ProductQuery(search: 'watch'));
      expect(l.items.first.name.toLowerCase(), contains('watch'));
    });

    test('search ignores punctuation', () {
      expect(run(const ProductQuery(search: '  lay-flat!! ')).items.first.slug, 'lay-flat-notebook');
    });

    test('search combined with a category', () {
      final l = run(const ProductQuery(search: 'leather', categorySlug: 'bags'));
      expect(l.total, 2);
    });

    test('sort by price ascending and descending', () {
      final asc = run(
        const ProductQuery(sort: ProductSort.priceAsc, pageSize: 50),
      ).items.map((p) => p.priceCents).toList();
      expect(asc, [...asc]..sort());
      final desc = run(
        const ProductQuery(sort: ProductSort.priceDesc, pageSize: 50),
      ).items.map((p) => p.priceCents).toList();
      expect(desc, [...asc.reversed]);
    });

    test('sort by newest', () {
      final l = run(const ProductQuery(sort: ProductSort.newest, pageSize: 50));
      final dates = l.items.map((p) => p.createdAt).toList();
      expect(dates, [...dates]..sort((a, b) => b.compareTo(a)));
    });

    test('sort by rating', () {
      final l = run(const ProductQuery(sort: ProductSort.rating, pageSize: 50));
      final avgs = l.items.map((p) => p.rating.average).toList();
      expect(avgs, [...avgs]..sort((a, b) => b.compareTo(a)));
    });

    test('sort by name', () {
      final names = run(
        const ProductQuery(sort: ProductSort.name, pageSize: 50),
      ).items.map((p) => p.name.toLowerCase()).toList();
      expect(names, [...names]..sort());
    });

    test('ProductSort.parse', () {
      expect(ProductSort.parse('price-asc'), ProductSort.priceAsc);
      expect(ProductSort.parse('bogus'), isNull);
      expect(ProductSort.parse(null), isNull);
    });

    test('page size and page are clamped to sane values', () {
      final l = run(const ProductQuery(page: -4, pageSize: 0));
      expect(l.page, 1);
      expect(l.pageSize, 1);
      expect(l.items, hasLength(1));
    });
  });

  group('use cases', () {
    late CatalogRepositoryImpl r;
    setUp(() => r = repo());

    test('ResolveProductSlug finds, redirects and misses', () async {
      final resolve = ResolveProductSlug(r);
      expect(await resolve('classic-38-watch'), isA<SlugFound>());
      final moved = await resolve('classic-watch');
      expect(moved, isA<SlugMoved>());
      expect((moved as SlugMoved).product.slug, 'classic-38-watch');
      expect(await resolve('nope'), isA<SlugNotFound>());
    });

    test('GetFeaturedProducts returns in-stock featured products only', () async {
      final list = await GetFeaturedProducts(r)(limit: 4);
      expect(list, hasLength(4));
      expect(list.every((p) => p.featured && p.inStock), isTrue);
    });

    test('GetRelatedProducts excludes the product and prefers its category', () async {
      final duffel = (await r.productBySlug('weekender-leather-duffel'))!;
      final related = await GetRelatedProducts(r)(duffel);
      expect(related, hasLength(4));
      expect(related.map((p) => p.id), isNot(contains(duffel.id)));
      expect(related.take(2).every((p) => p.categorySlug == 'bags'), isTrue);
    });

    test('QueryProducts reads through the repository', () async {
      final l = await QueryProducts(r)(const ProductQuery(categorySlug: 'audio'));
      expect(l.total, 2);
    });

    test('reserveStock is all-or-nothing', () async {
      final stride = (await r.productBySlug('stride-knit-sneaker'))!;
      final v42 = stride.variantById('v_stride_42')!;
      final v44 = stride.variantById('v_stride_44')!; // sold out
      expect(await r.reserveStock({v42.id: 1, v44.id: 1}), isFalse);
      expect((await r.productBySlug('stride-knit-sneaker'))!.variantById(v42.id)!.stock, v42.stock);
      expect(await r.reserveStock({v42.id: 2}), isTrue);
      expect((await r.productBySlug('stride-knit-sneaker'))!.variantById(v42.id)!.stock, v42.stock - 2);
      expect(await r.reserveStock({v42.id: 999}), isFalse);
      expect(await r.reserveStock({'unknown': 1}), isFalse);
    });
  });
}
