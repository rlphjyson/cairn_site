import 'package:cairn_site/src/templates/shop/common/constants/product_categories.dart';
import 'package:cairn_site/src/templates/shop/data/catalog/remote/product_remote_data_source.dart';
import 'package:cairn_site/src/templates/shop/data/catalog/repositories/product_repository_impl.dart';
import 'package:cairn_site/src/templates/shop/domain/cart/models/cart_line.dart';
import 'package:cairn_site/src/templates/shop/domain/cart/models/cart_totals.dart';
import 'package:cairn_site/src/templates/shop/domain/cart/use_cases/calculate_cart_totals.dart';
import 'package:cairn_site/src/templates/shop/domain/catalog/models/product.dart';
import 'package:cairn_site/src/templates/shop/domain/catalog/use_cases/filter_products.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(String id, double price, {String category = 'Shoes'}) =>
    Product(
      id: id,
      name: 'Product $id',
      category: category,
      price: price,
      rating: 4,
      reviews: 1,
      imageAsset: 'x.jpg',
      description: '',
      optionLabel: 'Size',
      options: const <String>['M'],
    );

void main() {
  group('CalculateCartTotals', () {
    const CalculateCartTotals calculate = CalculateCartTotals();

    test('an empty cart costs nothing and ships free of charge', () {
      expect(calculate(const <CartLine>[]), CartTotals.empty);
    });

    test('below the threshold it adds flat-rate shipping', () {
      final CartTotals t = calculate(<CartLine>[
        CartLine(product: _product('a', 40), quantity: 2),
      ]);
      expect(t.subtotal, 80);
      expect(t.shipping, 8);
      expect(t.total, 88);
      expect(t.itemCount, 2);
      expect(t.amountToFreeShipping, 70);
      expect(t.freeShippingProgress, closeTo(80 / 150, 1e-9));
    });

    test('at the threshold shipping is free', () {
      final CartTotals t = calculate(<CartLine>[
        CartLine(product: _product('a', 150), quantity: 1),
      ]);
      expect(t.shipping, 0);
      expect(t.amountToFreeShipping, 0);
      expect(t.freeShippingProgress, 1);
    });
  });

  group('FilterProducts', () {
    const FilterProducts filter = FilterProducts();
    final List<Product> all = <Product>[
      _product('a', 10),
      _product('b', 10, category: 'Audio'),
    ];

    test('All keeps everything', () {
      expect(filter(all), all);
    });

    test('filters by category', () {
      expect(filter(all, category: 'Audio').single.id, 'b');
    });

    test('matches the query case-insensitively', () {
      expect(filter(all, query: '  PRODUCT A ').single.id, 'a');
      expect(filter(all, query: 'nope'), isEmpty);
    });
  });

  group('catalogue data', () {
    final ProductRepositoryImpl repository = ProductRepositoryImpl(
      const InMemoryProductRemoteDataSource(),
    );

    test('every product belongs to a real category and has options', () async {
      final List<Product> products = await repository.getProducts();
      expect(products, isNotEmpty);
      for (final Product p in products) {
        expect(ProductCategories.values, contains(p.category), reason: p.id);
        expect(p.options, isNotEmpty, reason: p.id);
        expect(p.imageAsset, startsWith('assets/images/'), reason: p.id);
      }
    });

    test('ids are unique and resolvable', () async {
      final List<Product> products = await repository.getProducts();
      expect(products.map((Product p) => p.id).toSet().length, products.length);
      expect(
        (await repository.getProduct(products.first.id))?.id,
        products.first.id,
      );
      expect(await repository.getProduct('missing'), isNull);
    });
  });
}
