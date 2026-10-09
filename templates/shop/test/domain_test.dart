import 'dart:io';

import 'package:cairn_template_shop/common/constants/product_categories.dart';
import 'package:cairn_template_shop/common/utils/dates.dart';
import 'package:cairn_template_shop/common/utils/luhn.dart';
import 'package:cairn_template_shop/core/presentation/formatters/card_formatters.dart';
import 'package:cairn_template_shop/data/cart/remote/cart_remote_data_source.dart';
import 'package:cairn_template_shop/data/cart/repositories/cart_repository_impl.dart';
import 'package:cairn_template_shop/data/catalog/remote/product_remote_data_source.dart';
import 'package:cairn_template_shop/data/catalog/repositories/product_repository_impl.dart';
import 'package:cairn_template_shop/domain/cart/models/cart.dart';
import 'package:cairn_template_shop/domain/cart/models/cart_line.dart';
import 'package:cairn_template_shop/domain/cart/models/cart_totals.dart';
import 'package:cairn_template_shop/domain/cart/models/delivery_method.dart';
import 'package:cairn_template_shop/domain/cart/models/promo_code.dart';
import 'package:cairn_template_shop/domain/cart/use_cases/add_to_cart.dart';
import 'package:cairn_template_shop/domain/cart/use_cases/apply_promo_code.dart';
import 'package:cairn_template_shop/domain/cart/use_cases/calculate_cart_totals.dart';
import 'package:cairn_template_shop/domain/cart/use_cases/get_cart.dart';
import 'package:cairn_template_shop/domain/cart/use_cases/remove_promo_code.dart';
import 'package:cairn_template_shop/domain/cart/use_cases/set_cart_quantity.dart';
import 'package:cairn_template_shop/domain/catalog/mappers/product_mapper.dart';
import 'package:cairn_template_shop/domain/catalog/models/product.dart';
import 'package:cairn_template_shop/domain/catalog/models/product_sort.dart';
import 'package:cairn_template_shop/domain/catalog/models/review.dart';
import 'package:cairn_template_shop/domain/catalog/models/variant_group.dart';
import 'package:cairn_template_shop/domain/catalog/use_cases/filter_products.dart';
import 'package:cairn_template_shop/domain/catalog/use_cases/recommend_products.dart';
import 'package:cairn_template_shop/domain/catalog/use_cases/sort_products.dart';
import 'package:cairn_template_shop/domain/checkout/models/payment_details.dart';
import 'package:cairn_template_shop/domain/checkout/use_cases/validate_payment_details.dart';
import 'package:cairn_template_shop/domain/checkout/use_cases/validate_shipping_details.dart';
import 'package:cairn_template_shop/domain/orders/models/order.dart';
import 'package:cairn_template_shop/domain/orders/models/shipping_details.dart';
import 'package:cairn_template_shop/domain/orders/use_cases/get_saved_addresses.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(
  String id,
  double price, {
  String category = 'Shoes',
  double rating = 4,
  int ratingCount = 1,
  double? compareAt,
  bool isNew = false,
  int stock = 20,
}) => Product(
  id: id,
  name: 'Product $id',
  category: category,
  price: price,
  compareAtPrice: compareAt,
  rating: rating,
  ratingCount: ratingCount,
  imageAsset: 'x.jpg',
  description: '',
  isNew: isNew,
  stock: stock,
  variantGroups: const <VariantGroup>[
    VariantGroup(label: 'Size', values: <String>['M', 'L']),
  ],
);

const PromoCode _cairn10 = PromoCode(code: 'CAIRN10', percentOff: 10);

void main() {
  group('CalculateCartTotals', () {
    const CalculateCartTotals calculate = CalculateCartTotals();

    test('an empty cart costs nothing', () {
      expect(calculate(const <CartLine>[]), CartTotals.empty);
    });

    test('below the threshold it adds the standard rate', () {
      final CartTotals t = calculate(<CartLine>[
        CartLine(product: _product('a', 40), quantity: 2),
      ]);
      expect(t.subtotal, 80);
      expect(t.discount, 0);
      expect(t.shipping, 8);
      expect(t.total, 88);
      expect(t.itemCount, 2);
      expect(t.amountToFreeShipping, 70);
      expect(t.freeShippingProgress, closeTo(80 / 150, 1e-9));
    });

    test('at the threshold standard shipping is free', () {
      final CartTotals t = calculate(<CartLine>[
        CartLine(product: _product('a', 150), quantity: 1),
      ]);
      expect(t.shipping, 0);
      expect(t.amountToFreeShipping, 0);
      expect(t.freeShippingProgress, 1);
    });

    test('express always costs the express rate', () {
      final List<CartLine> rich = <CartLine>[
        CartLine(product: _product('a', 500), quantity: 1),
      ];
      expect(calculate(rich, delivery: DeliveryMethod.express).shipping, 12);
      expect(calculate(rich).shipping, 0);
    });

    test('a promo code takes its percentage off the subtotal', () {
      final CartTotals t = calculate(<CartLine>[
        CartLine(product: _product('a', 89), quantity: 2),
      ], promo: _cairn10);
      expect(t.subtotal, 178);
      expect(t.discount, closeTo(17.8, 1e-9));
      expect(t.total, closeTo(160.2, 1e-9));
    });

    test('free shipping is judged after the discount', () {
      // 160 qualifies on its own, 160 less 10% (144) does not.
      final List<CartLine> lines = <CartLine>[
        CartLine(product: _product('a', 160), quantity: 1),
      ];
      expect(calculate(lines).shipping, 0);
      final CartTotals discounted = calculate(lines, promo: _cairn10);
      expect(discounted.shipping, 8);
      expect(discounted.amountToFreeShipping, closeTo(6, 1e-9));
      expect(discounted.total, closeTo(152, 1e-9));
    });

    test('lines expose compare-at totals and a quantity cap', () {
      final CartLine line = CartLine(
        product: _product('a', 80, compareAt: 100, stock: 3),
        quantity: 2,
      );
      expect(line.total, 160);
      expect(line.compareTotal, 200);
      expect(line.maxQuantity, 3);
      expect(
        CartLine(product: _product('b', 1, stock: 99), quantity: 1).maxQuantity,
        10,
      );
    });

    test('the same product in two variants is two lines', () {
      final Product p = _product('a', 10);
      expect(
        CartLine(product: p, variant: 'M', quantity: 1).key,
        isNot(CartLine(product: p, variant: 'L', quantity: 1).key),
      );
    });
  });

  group('cart repository and promo codes', () {
    late CartRepositoryImpl repository;

    setUp(() {
      repository = CartRepositoryImpl(
        InMemoryCartRemoteDataSource(),
        ProductRepositoryImpl(const InMemoryProductRemoteDataSource()),
      );
    });

    test(
      'adding the same variant merges, another variant is a new line',
      () async {
        final AddToCart add = AddToCart(repository);
        await add('court-low', '42 / Red');
        await add('court-low', '42 / Red', quantity: 2);
        await add('court-low', '43 / Red');
        final Cart cart = await GetCart(repository)();
        expect(cart.lines, hasLength(2));
        expect(cart.lines.first.quantity, 3);
        expect(cart.lines.first.variant, '42 / Red');
        expect(cart.lines.last.variant, '43 / Red');
      },
    );

    test('adding fewer than one adds nothing', () async {
      await AddToCart(repository)('court-low', '', quantity: 0);
      expect((await GetCart(repository)()).lines, isEmpty);
    });

    test('setting a quantity of zero removes only that line', () async {
      final AddToCart add = AddToCart(repository);
      await add('court-low', 'a');
      await add('court-low', 'b');
      await SetCartQuantity(repository)(CartLine.lineKey('court-low', 'a'), 0);
      final Cart cart = await GetCart(repository)();
      expect(cart.lines.single.variant, 'b');
    });

    test('CAIRN10 is accepted in any case and survives a reload', () async {
      final ApplyPromoCode apply = ApplyPromoCode(repository);
      final PromoCode? promo = await apply('  cairn10 ');
      expect(promo?.code, 'CAIRN10');
      expect(promo?.percentOff, 10);
      expect((await GetCart(repository)()).promo, promo);
    });

    test('an invalid code is rejected and changes nothing', () async {
      final ApplyPromoCode apply = ApplyPromoCode(repository);
      expect(await apply('NOPE'), isNull);
      expect(await apply(''), isNull);
      expect((await GetCart(repository)()).promo, isNull);
    });

    test('removing a code clears it', () async {
      await ApplyPromoCode(repository)('CAIRN10');
      await RemovePromoCode(repository)();
      expect((await GetCart(repository)()).promo, isNull);
    });

    test('clearing the cart drops lines and code', () async {
      await AddToCart(repository)('court-low', '');
      await ApplyPromoCode(repository)('CAIRN10');
      await repository.clear();
      final Cart cart = await GetCart(repository)();
      expect(cart.lines, isEmpty);
      expect(cart.promo, isNull);
    });
  });

  group('FilterProducts', () {
    const FilterProducts filter = FilterProducts();
    final List<Product> all = <Product>[
      _product('a', 10),
      _product('b', 10, category: 'Audio'),
    ];

    test('All keeps everything', () => expect(filter(all), all));

    test('filters by category', () {
      expect(filter(all, category: 'Audio').single.id, 'b');
    });

    test('matches the query case-insensitively, by name or category', () {
      expect(filter(all, query: '  PRODUCT A ').single.id, 'a');
      expect(filter(all, query: 'audio').single.id, 'b');
      expect(filter(all, query: 'nope'), isEmpty);
    });

    test('category and query combine', () {
      expect(filter(all, category: 'Shoes', query: 'product b'), isEmpty);
    });
  });

  group('SortProducts', () {
    const SortProducts sort = SortProducts();
    final List<Product> all = <Product>[
      _product('mid', 50, rating: 4.0, ratingCount: 10),
      _product('cheap', 20, rating: 3.0, ratingCount: 300),
      _product('dear', 90, rating: 5.0, ratingCount: 5),
      _product('tie', 50, rating: 5.0, ratingCount: 50),
    ];

    List<String> ids(ProductSort s) =>
        sort(all, s).map((Product p) => p.id).toList();

    test('popular puts the most-rated first', () {
      expect(ids(ProductSort.popular), <String>['cheap', 'tie', 'mid', 'dear']);
    });

    test('price low to high, ties in catalogue order', () {
      expect(ids(ProductSort.priceLowHigh), <String>[
        'cheap',
        'mid',
        'tie',
        'dear',
      ]);
    });

    test('price high to low', () {
      expect(ids(ProductSort.priceHighLow), <String>[
        'dear',
        'mid',
        'tie',
        'cheap',
      ]);
    });

    test('top rated breaks ties by how many rated it', () {
      expect(ids(ProductSort.topRated), <String>[
        'tie',
        'dear',
        'mid',
        'cheap',
      ]);
    });

    test('it never mutates its input', () {
      final List<String> before = all.map((Product p) => p.id).toList();
      sort(all, ProductSort.priceHighLow);
      expect(all.map((Product p) => p.id).toList(), before);
    });

    test('every sort has a label', () {
      for (final ProductSort s in ProductSort.values) {
        expect(s.label, isNotEmpty);
      }
    });
  });

  group('RecommendProducts', () {
    const RecommendProducts recommend = RecommendProducts();
    final List<Product> all = <Product>[
      _product('shoe1', 10, rating: 3),
      _product('audio1', 10, category: 'Audio', rating: 5),
      _product('shoe2', 10, rating: 4),
      _product('audio2', 10, category: 'Audio', rating: 4.5),
    ];

    test('prefers the same category, then the best rated', () {
      final List<String> ids = recommend(
        all,
        exclude: <String>{'shoe1'},
        category: 'Shoes',
      ).map((Product p) => p.id).toList();
      expect(ids, <String>['shoe2', 'audio1', 'audio2']);
    });

    test('without a category it is simply the best rated, limited', () {
      final List<Product> top = recommend(all, limit: 2);
      expect(top.map((Product p) => p.id), <String>['audio1', 'audio2']);
    });
  });

  group('Product', () {
    test('sale maths', () {
      final Product p = _product('a', 75, compareAt: 100);
      expect(p.isOnSale, isTrue);
      expect(p.discountPercent, 25);
      expect(_product('b', 75).isOnSale, isFalse);
      expect(_product('b', 75).discountPercent, 0);
      expect(_product('c', 75, compareAt: 75).isOnSale, isFalse);
    });

    test('stock states', () {
      expect(_product('a', 1, stock: 0).inStock, isFalse);
      expect(_product('a', 1, stock: 3).isLowStock, isTrue);
      expect(_product('a', 1, stock: 6).isLowStock, isFalse);
    });

    test('variant labels follow the group order and default to the first', () {
      final Product p = _product('a', 1);
      expect(p.defaultSelection, <String, String>{'Size': 'M'});
      expect(p.variantLabel(const <String, String>{'Size': 'L'}), 'L');
      expect(p.variantLabel(const <String, String>{}), 'M');
    });

    test('reviews have initials', () {
      final Review r = Review(
        author: 'Maya R.',
        rating: 5,
        text: '',
        date: DateTime(2026),
      );
      expect(r.initials, 'MR');
    });
  });

  group('ProductMapper', () {
    test('maps every field, including variants and reviews', () {
      final Product p = ProductMapper.fromJson(<String, Object?>{
        'id': 'x',
        'name': 'X',
        'category': 'Bags',
        'price': 10,
        'compareAtPrice': 12.5,
        'rating': 4,
        'ratingCount': 7,
        'image': 'assets/images/x.jpg',
        'blurb': 'Blurb',
        'isNew': true,
        'stock': 2,
        'details': <String>['One', 'Two'],
        'variants': <Map<String, Object?>>[
          <String, Object?>{
            'label': 'Colour',
            'values': <String>['Red', 'Blue'],
          },
        ],
        'reviews': <Map<String, Object?>>[
          <String, Object?>{
            'author': 'A B',
            'rating': 4,
            'text': 'Nice',
            'date': '2026-09-18',
          },
        ],
      });
      expect(p.price, 10);
      expect(p.compareAtPrice, 12.5);
      expect(p.imageAsset, 'assets/images/x.jpg');
      expect(p.description, 'Blurb');
      expect(p.isNew, isTrue);
      expect(p.stock, 2);
      expect(p.details, <String>['One', 'Two']);
      expect(p.variantGroups.single.values, <String>['Red', 'Blue']);
      expect(p.reviews.single.date, DateTime(2026, 9, 18));
    });

    test('optional fields default sensibly', () {
      final Product p = ProductMapper.fromJson(<String, Object?>{
        'id': 'x',
        'name': 'X',
        'category': 'Bags',
        'price': 10,
        'rating': 4,
        'image': 'i.jpg',
        'blurb': 'b',
      });
      expect(p.compareAtPrice, isNull);
      expect(p.isNew, isFalse);
      expect(p.variantGroups, isEmpty);
      expect(p.reviews, isEmpty);
    });
  });

  group('catalogue data', () {
    final ProductRepositoryImpl repository = ProductRepositoryImpl(
      const InMemoryProductRemoteDataSource(),
    );

    test('has a dozen products across every category', () async {
      final List<Product> products = await repository.getProducts();
      expect(products, hasLength(12));
      final Set<String> categories = products
          .map((Product p) => p.category)
          .toSet();
      expect(
        categories,
        ProductCategories.values.where((String c) => c != 'All').toSet(),
      );
    });

    test('every product is complete and its image exists', () async {
      for (final Product p in await repository.getProducts()) {
        expect(ProductCategories.values, contains(p.category), reason: p.id);
        expect(p.variantGroups, isNotEmpty, reason: p.id);
        expect(p.details, isNotEmpty, reason: p.id);
        expect(p.reviews.length, inInclusiveRange(2, 4), reason: p.id);
        expect(p.stock, greaterThan(0), reason: p.id);
        expect(File(p.imageAsset).existsSync(), isTrue, reason: p.id);
        if (p.compareAtPrice != null) {
          expect(p.compareAtPrice, greaterThan(p.price), reason: p.id);
        }
      }
    });

    test('there are sale items, new items and a low-stock item', () async {
      final List<Product> products = await repository.getProducts();
      expect(products.where((Product p) => p.isOnSale), isNotEmpty);
      expect(products.where((Product p) => p.isNew), hasLength(greaterThan(2)));
      expect(products.where((Product p) => p.isLowStock), isNotEmpty);
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

    test('a latency delays the answer but not the data', () async {
      final Stopwatch watch = Stopwatch()..start();
      final List<Map<String, Object?>> json =
          await const InMemoryProductRemoteDataSource(
            latency: Duration(milliseconds: 40),
          ).fetchProducts();
      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(30));
      expect(json, hasLength(12));
    });
  });

  group('ValidateShippingDetails', () {
    const ValidateShippingDetails validate = ValidateShippingDetails();
    const ShippingDetails good = ShippingDetails(
      fullName: 'Ada Lovelace',
      email: 'ada@example.com',
      phone: '+44 20 7946 0958',
      address: '12 Analytical Row',
      city: 'London',
      postalCode: 'N1 9GU',
    );

    test('accepts a complete form', () => expect(validate(good), isEmpty));

    test('an empty form fails every field', () {
      expect(validate(const ShippingDetails()).keys, ShippingField.values);
    });

    test('rejects a malformed email', () {
      for (final String bad in <String>['ada', 'ada@', 'a@b', 'a b@c.com']) {
        expect(validate(good.copyWith(email: bad)).keys, <ShippingField>[
          ShippingField.email,
        ], reason: bad);
      }
    });

    test('rejects short or lettered phone numbers', () {
      expect(validate(good.copyWith(phone: '12345')), isNotEmpty);
      expect(validate(good.copyWith(phone: 'call me maybe')), isNotEmpty);
      expect(validate(good.copyWith(phone: '(555) 010-9999')), isEmpty);
    });

    test('checks the postal code shape', () {
      expect(validate(good.copyWith(postalCode: '1')), isNotEmpty);
      expect(validate(good.copyWith(postalCode: '10115')), isEmpty);
      expect(validate(good.copyWith(postalCode: 'SW1A 1AA')), isEmpty);
      expect(validate(good.copyWith(postalCode: '!!!!!')), isNotEmpty);
    });

    test('messages are human', () {
      expect(
        validate(good.copyWith(fullName: ''))[ShippingField.fullName],
        'Enter your full name.',
      );
    });
  });

  group('ValidatePaymentDetails', () {
    final ValidatePaymentDetails validate = ValidatePaymentDetails(
      () => DateTime(2026, 10, 9),
    );
    const PaymentDetails good = PaymentDetails(
      cardHolder: 'Ada Lovelace',
      cardNumber: '4242 4242 4242 4242',
      expiry: '12/28',
      cvc: '123',
    );

    test('accepts a good card', () => expect(validate(good), isEmpty));

    test('Luhn catches a mistyped number', () {
      expect(passesLuhn('4242424242424242'), isTrue);
      expect(passesLuhn('4242424242424241'), isFalse);
      expect(passesLuhn('378282246310005'), isTrue);
      expect(passesLuhn(''), isFalse);
      expect(passesLuhn('42a2'), isFalse);
      expect(
        validate(good.copyWith(cardNumber: '4242 4242 4242 4241')).keys,
        <PaymentField>[PaymentField.cardNumber],
      );
    });

    test('rejects numbers of the wrong length', () {
      expect(validate(good.copyWith(cardNumber: '4242')), isNotEmpty);
    });

    test('expiry must be MM/YY and not in the past', () {
      expect(validate(good.copyWith(expiry: '1228')), isNotEmpty);
      expect(validate(good.copyWith(expiry: '13/28')), isNotEmpty);
      expect(
        validate(good.copyWith(expiry: '09/26'))[PaymentField.expiry],
        'This card has expired.',
      );
      // Good through the end of its month.
      expect(validate(good.copyWith(expiry: '10/26')), isEmpty);
      expect(validate(good.copyWith(expiry: '11/26')), isEmpty);
    });

    test('cvc is three or four digits', () {
      expect(validate(good.copyWith(cvc: '12')), isNotEmpty);
      expect(validate(good.copyWith(cvc: '12345')), isNotEmpty);
      expect(validate(good.copyWith(cvc: '1234')), isEmpty);
      expect(validate(good.copyWith(cvc: 'abc')), isNotEmpty);
    });

    test('an empty form fails every field', () {
      expect(validate(const PaymentDetails()).keys, PaymentField.values);
    });

    test('last4 never reveals more', () {
      expect(good.last4, '4242');
      expect(const PaymentDetails(cardNumber: '12').last4, '12');
    });
  });

  group('GetSavedAddresses', () {
    Order order(String id, ShippingDetails s) => Order(
      id: id,
      lines: const <CartLine>[],
      totals: CartTotals.empty,
      shipping: s,
      cardLast4: '4242',
      placedAt: DateTime(2026),
      estimatedDelivery: DateTime(2026),
    );

    test('keeps distinct addresses, newest first', () {
      const ShippingDetails home = ShippingDetails(
        fullName: 'A',
        address: '1 Road',
        city: 'Town',
        postalCode: '111',
      );
      const ShippingDetails work = ShippingDetails(
        fullName: 'A',
        address: '2 Street',
        city: 'Town',
        postalCode: '222',
      );
      final List<ShippingDetails> result = const GetSavedAddresses()(<Order>[
        order('3', work),
        order('2', home.copyWith(address: '1 ROAD')),
        order('1', home),
      ]);
      expect(result, <ShippingDetails>[work, home.copyWith(address: '1 ROAD')]);
    });
  });

  group('helpers', () {
    test('business days skip weekends', () {
      // Friday 9 Oct 2026 plus 2 business days is Tuesday 13 Oct.
      expect(addBusinessDays(DateTime(2026, 10, 9), 2), DateTime(2026, 10, 13));
      expect(addBusinessDays(DateTime(2026, 10, 5), 5), DateTime(2026, 10, 12));
    });

    test('dates format', () {
      expect(formatDate(DateTime(2026, 10, 9)), '9 Oct 2026');
      expect(formatShortDate(DateTime(2026, 10, 9)), 'Fri 9 Oct');
    });

    test('card number formatter groups digits in fours', () {
      const CardNumberFormatter f = CardNumberFormatter();
      TextEditingValue format(String s) =>
          f.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: s));
      expect(format('4242424242424242').text, '4242 4242 4242 4242');
      expect(format('42a4-2').text, '4242');
      expect(format('12345').text, '1234 5');
      expect(format('1' * 30).text.replaceAll(' ', ''), hasLength(19));
    });

    test('expiry formatter inserts the slash', () {
      const ExpiryFormatter f = ExpiryFormatter();
      TextEditingValue format(String s, [String old = '']) =>
          f.formatEditUpdate(
            TextEditingValue(text: old),
            TextEditingValue(text: s),
          );
      expect(format('1').text, '1');
      expect(format('12').text, '12/');
      expect(format('122').text, '12/2');
      expect(format('1228').text, '12/28');
      expect(format('12/289').text, '12/28');
      // Backspacing over the slash leaves just the month.
      expect(format('12', '12/').text, '12');
    });
  });
}
