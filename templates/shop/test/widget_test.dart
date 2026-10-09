import 'package:cairn_template_shop/core/presentation/navigation/shop_navigation_cubit.dart';
import 'package:cairn_template_shop/domain/catalog/models/product_sort.dart';
import 'package:cairn_template_shop/presentation/cart/bloc/cart_cubit.dart';
import 'package:cairn_template_shop/presentation/cart/widgets/promo_code_field.dart';
import 'package:cairn_template_shop/presentation/catalog/bloc/catalog_cubit.dart';
import 'package:cairn_template_shop/presentation/catalog/views/storefront_view.dart';
import 'package:cairn_template_shop/presentation/profile/bloc/profile_cubit.dart';
import 'package:cairn_template_shop/presentation/saved/bloc/saved_cubit.dart';
import 'package:cairn_template_shop/presentation/shell/shop_shell.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shop_harness.dart';

Finder _promoInput() => find.descendant(
  of: find.byType(PromoCodeField),
  matching: find.byType(EditableText),
);

Finder _chip(String label) => find.widgetWithText(CairnButton, label);

/// The whole journey: browse, filter, sort, open a product, choose a variant,
/// add to cart, apply a promo code, check out with valid data, see the
/// confirmation and find the order in the profile's history.
Future<void> _purchaseJourney(WidgetTester tester, double width) async {
  final SemanticsHandle semantics = tester.ensureSemantics();
  await mountShop(tester, width: width, height: width >= 700 ? 900 : 780);

  // Browse.
  expect(find.text('Discover'), findsOneWidget);
  expect(find.text('Featured'), findsOneWidget);
  await reveal(tester, find.text('New arrivals'));
  await reveal(tester, find.text('All products'));
  expect(find.text('Sale'), findsWidgets);

  // Filter.
  await tester.drag(verticalScrollable(), const Offset(0, 5000));
  await pumpFrames(tester);
  await tester.tap(_chip('Shoes'));
  await pumpFrames(tester);
  expect(find.text('4 results'), findsOneWidget);
  await reveal(tester, find.text('Street Low Sneaker'));
  expect(find.text('Studio Air Headphones'), findsNothing);

  // Sort: cheapest first puts Cloud Runner ($74) ahead of Court Low ($89).
  await tester.drag(verticalScrollable(), const Offset(0, 5000));
  await pumpFrames(tester);
  await tester.tap(find.byType(CairnSelect<ProductSort>));
  await pumpFrames(tester);
  await tester.tap(find.text('Price: low to high').last);
  await pumpFrames(tester);
  expect(read<CatalogCubit>(tester).state.sort, ProductSort.priceLowHigh);
  await reveal(tester, find.text('Court Low Sneaker'));
  final Offset cloud = tester.getTopLeft(find.text('Cloud Runner Trainer'));
  final Offset court = tester.getTopLeft(find.text('Court Low Sneaker'));
  expect(cloud.dy, lessThanOrEqualTo(court.dy));
  expect(cloud.dx, lessThan(court.dx));

  // Open the product, pick a variant and a quantity.
  await tapVisible(tester, find.text('Cloud Runner Trainer'));
  expect(find.text('Add to cart'), findsOneWidget);
  expect(find.text('-25%'), findsOneWidget);
  await tapText(tester, '43');
  await tapText(tester, 'Grey');
  await tester.tap(
    find.bySemanticsLabel('Increase quantity of Cloud Runner Trainer'),
  );
  await pumpFrames(tester);
  expect(find.text('\$148'), findsOneWidget);
  await tapText(tester, 'Add to cart');
  expect(find.text('2 in your cart'), findsOneWidget);
  expect(read<CartCubit>(tester).state.lines.single.variant, '43 / Grey');

  // Same product, another variant: a separate line.
  await tapText(tester, '44');
  expect(find.text('2 in your cart'), findsNothing);
  await tester.tap(
    find.bySemanticsLabel('Decrease quantity of Cloud Runner Trainer'),
  );
  await pumpFrames(tester);
  await tapText(tester, 'Add to cart');
  expect(read<CartCubit>(tester).state.lines, hasLength(2));

  // The cart: lines keep their variants.
  await tapText(tester, 'View cart');
  expect(find.text('Cart'), findsWidgets);
  expect(find.text('43 / Grey'), findsOneWidget);
  expect(find.text('44 / Grey'), findsOneWidget);
  expect(find.text('3 items'), findsOneWidget);

  // Promo codes: a bad one is refused, the good one takes 10% off.
  await tester.enterText(_promoInput(), 'WRONG');
  await tapText(tester, 'Apply');
  expect(find.text('That code is not valid.'), findsOneWidget);
  await tester.enterText(_promoInput(), 'cairn10');
  await tapText(tester, 'Apply');
  expect(find.text('CAIRN10 applied: 10% off'), findsOneWidget);
  await reveal(tester, find.text('Checkout'));
  expect(find.text('Discount (CAIRN10)'), findsOneWidget);
  expect(find.text('-\$22.20'), findsOneWidget);
  // 222 less 22.20 is 199.80, over the threshold: shipping is free.
  expect(find.text('\$199.80'), findsWidgets);

  // Shipping: an incomplete form shows inline errors and stays put.
  await tapText(tester, 'Checkout');
  expect(find.text('Continue to payment'), findsOneWidget);
  expect(field('Full name'), findsOneWidget);
  await tapText(tester, 'Continue to payment');
  expect(find.text('Enter a valid phone number.'), findsOneWidget);
  expect(find.text('Enter your street address.'), findsOneWidget);
  expect(find.text('Continue to payment'), findsOneWidget);

  await fill(tester, 'Phone', '555 010 9999');
  expect(find.text('Enter a valid phone number.'), findsNothing);
  await fill(tester, 'Address', '1 Compiler Way');
  await fill(tester, 'City', 'Arlington');
  await fill(tester, 'Postal code', '22201');
  await tapText(tester, 'Continue to payment');

  // Payment: the demo notice, Luhn, and back navigation that keeps data.
  expect(find.text('This is a demo checkout'), findsOneWidget);
  await tapText(tester, 'Review order');
  expect(find.text('Enter a valid card number.'), findsOneWidget);
  await fill(tester, 'Name on card', 'Ada Lovelace');
  await fill(tester, 'Card number', '4242424242424241');
  expect(find.text('4242 4242 4242 4241'), findsOneWidget);
  expect(find.text('Enter a valid card number.'), findsOneWidget);
  await fill(tester, 'Card number', '4242424242424242');
  expect(find.text('Enter a valid card number.'), findsNothing);
  await fill(tester, 'Expiry', '1299');
  expect(find.text('12/99'), findsOneWidget);
  await fill(tester, 'CVC', '123');

  await tester.tap(find.bySemanticsLabel('Back to Shipping'));
  await pumpFrames(tester);
  expect(find.text('555 010 9999'), findsOneWidget);
  expect(find.text('1 Compiler Way'), findsOneWidget);
  await tapText(tester, 'Continue to payment');
  expect(find.text('4242 4242 4242 4242'), findsOneWidget);
  await tapText(tester, 'Review order');

  // Review, then place the order.
  expect(find.text('Card ending 4242'), findsOneWidget);
  expect(find.text('Ship to'), findsOneWidget);
  await tapText(tester, 'Place order');

  // Confirmation.
  await pumpFrames(tester, 10);
  expect(find.textContaining('Order CR-2048 is confirmed'), findsOneWidget);
  expect(find.text('Thank you, Ada'), findsOneWidget);
  expect(find.byType(CairnTimeline), findsOneWidget);
  await reveal(tester, find.text('Continue shopping'));
  await reveal(tester, find.text('Track order'));
  expect(read<CartCubit>(tester).state.isEmpty, isTrue);

  // Track it: the order page, then the history in the profile.
  await tapText(tester, 'Track order');
  await pumpFrames(tester, 10);
  expect(find.text('Order CR-2048'), findsOneWidget);
  expect(find.text('Processing'), findsOneWidget);
  await tester.tap(find.bySemanticsLabel('Back to profile'));
  await pumpFrames(tester, 10);
  expect(find.text('Order history'), findsOneWidget);
  expect(find.text('Order CR-2048'), findsOneWidget);
  expect(find.text('Order CR-2041'), findsOneWidget);
  expect(find.text('Shipped'), findsOneWidget);
  expect(find.text('Delivered'), findsOneWidget);
  await reveal(tester, find.text('1 Compiler Way'));

  semantics.dispose();
}

void main() {
  for (final double width in testWidths) {
    group('at ${width.toInt()} px wide', () {
      testWidgets('the purchase journey, end to end', (
        WidgetTester tester,
      ) async {
        await _purchaseJourney(tester, width);
      });

      testWidgets('every tab lays out without overflow', (
        WidgetTester tester,
      ) async {
        await mountShop(tester, width: width);
        for (final ShopTab tab in ShopTab.values) {
          await goToTab(tester, tab);
          await tester.drag(verticalScrollable(), const Offset(0, -3000));
          await pumpFrames(tester);
        }
        read<ShopNavigationCubit>(tester).openProduct('chrono-rose');
        await pumpFrames(tester);
        await tester.drag(verticalScrollable(), const Offset(0, -3000));
        await pumpFrames(tester);
        expect(tester.takeException(), isNull);
      });
    });
  }

  group('on a tablet', () {
    testWidgets('the content stays a centred 480px column', (
      WidgetTester tester,
    ) async {
      await mountShop(tester, width: 900, height: 900);
      final Rect shell = tester.getRect(find.byType(ShopShell));
      expect(shell.width, 480);
      expect(shell.center.dx, closeTo(450, 0.5));
    });

    testWidgets('a phone-wide space is filled edge to edge', (
      WidgetTester tester,
    ) async {
      await mountShop(tester, width: 390, height: 800);
      expect(tester.getSize(find.byType(ShopShell)).width, 390);
    });
  });

  group('storefront', () {
    testWidgets('shows skeletons while the catalogue loads', (
      WidgetTester tester,
    ) async {
      await mountShop(tester, latency: const Duration(seconds: 3));
      expect(find.byType(CairnSkeleton), findsWidgets);
      expect(find.text('Featured'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      await pumpFrames(tester);
      expect(find.byType(CairnSkeleton), findsNothing);
      expect(find.text('Featured'), findsOneWidget);
    });

    testWidgets('the promo banner swipes between three slides', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      expect(find.text('New season'), findsOneWidget);
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await pumpFrames(tester, 20);
      expect(find.text('Code CAIRN10'), findsOneWidget);
      await tester.tap(find.text('Shop audio'));
      await pumpFrames(tester);
      expect(read<CatalogCubit>(tester).state.category, 'Audio');
      expect(find.textContaining('results'), findsOneWidget);
    });

    testWidgets('search narrows the list and an empty result can be cleared', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      final Finder search = find.descendant(
        of: find.byType(StorefrontView),
        matching: find.byType(EditableText),
      );
      await tester.enterText(search, 'watch');
      await pumpFrames(tester);
      expect(find.text('2 results'), findsOneWidget);
      expect(find.text('Slim Rose Watch'), findsOneWidget);

      await tester.enterText(search, 'zzzz');
      await pumpFrames(tester);
      expect(find.text('Nothing matches'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await pumpFrames(tester);
      expect(find.text('Featured'), findsOneWidget);
      expect(
        tester.widget<EditableText>(search).controller.text,
        isEmpty,
        reason: 'clearing the filters also clears the search box',
      );
    });

    testWidgets('filters survive opening a product and coming back', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      await tester.tap(_chip('Audio'));
      await pumpFrames(tester);
      await tapText(tester, 'Pastel Studio Over-ear');
      expect(find.text('Add to cart'), findsOneWidget);
      read<ShopNavigationCubit>(tester).back();
      await pumpFrames(tester, 10);
      expect(find.text('2 results'), findsOneWidget);
    });

    testWidgets('the header cart button counts what is in the cart', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await mountShop(tester);
      expect(find.bySemanticsLabel('Cart, empty'), findsOneWidget);
      await read<CartCubit>(tester).add('court-low', quantity: 2);
      await pumpFrames(tester);
      expect(find.bySemanticsLabel('Cart, 2 items'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Cart, 2 items'));
      await pumpFrames(tester);
      expect(read<ShopNavigationCubit>(tester).state.tab, ShopTab.cart);
      semantics.dispose();
    });
  });

  group('product page', () {
    testWidgets('shows stock, ratings and reviews, and gates the cart', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      read<ShopNavigationCubit>(tester).openProduct('street-low');
      await pumpFrames(tester, 10);
      expect(find.text('Only 3 left'), findsOneWidget);
      expect(find.text('New'), findsWidgets);
      expect(find.text('4.0 · 98 ratings'), findsOneWidget);

      await tapText(tester, 'Reviews (2)');
      expect(find.text('Jonas K.'), findsOneWidget);
      expect(find.byType(CairnAvatar), findsWidgets);
      await tapText(tester, 'Shipping & returns');
      expect(
        find.textContaining('Free standard delivery over'),
        findsOneWidget,
      );
      expect(find.text('You may also like'), findsOneWidget);

      // Only three exist: the third add reaches the limit.
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Add to cart'));
        await pumpFrames(tester);
      }
      expect(find.text('3 in your cart'), findsOneWidget);
      expect(find.text('Maximum in cart'), findsOneWidget);
      expect(read<CartCubit>(tester).state.itemCount, 3);
    });

    testWidgets('an unknown product says so and offers a way back', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      read<ShopNavigationCubit>(tester).openProduct('nope');
      await pumpFrames(tester, 10);
      expect(find.text('We could not find that product'), findsOneWidget);
      await tester.tap(find.text('Back to the shop'));
      await pumpFrames(tester, 10);
      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('the save button toggles the saved list', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await mountShop(tester);
      read<ShopNavigationCubit>(tester).openProduct('court-low');
      await pumpFrames(tester, 10);
      await tester.tap(find.bySemanticsLabel('Save').first);
      await pumpFrames(tester);
      expect(read<SavedCubit>(tester).state.isSaved('court-low'), isTrue);
      semantics.dispose();
    });
  });

  group('cart', () {
    testWidgets('an empty cart suggests products and leads back to the shop', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      await goToTab(tester, ShopTab.cart);
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Popular right now'), findsOneWidget);
      expect(find.text('Classic White Low'), findsOneWidget);
      await tester.tap(find.text('Start shopping'));
      await pumpFrames(tester, 10);
      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('quantities change, lines are removed, totals follow', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await mountShop(tester);
      await read<CartCubit>(tester).add('court-low', variant: '42 / Red');
      await goToTab(tester, ShopTab.cart);
      expect(find.text('Add \$61 more for free shipping.'), findsOneWidget);
      await tester.tap(
        find.bySemanticsLabel(
          'Increase quantity of Court Low Sneaker, 42 / Red',
        ),
      );
      await pumpFrames(tester);
      expect(find.text('You have free standard shipping.'), findsOneWidget);
      await tester.tap(
        find.bySemanticsLabel('Remove Court Low Sneaker from cart'),
      );
      await pumpFrames(tester, 10);
      expect(find.text('Your cart is empty'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a promo code can be removed again', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      await read<CartCubit>(tester).add('court-low');
      await goToTab(tester, ShopTab.cart);
      expect(find.text('Try CAIRN10 for 10% off.'), findsOneWidget);
      await tester.enterText(_promoInput(), '');
      await tapText(tester, 'Apply');
      expect(find.text('Enter a promo code.'), findsOneWidget);
      await tester.enterText(_promoInput(), 'CAIRN10');
      await tapText(tester, 'Apply');
      expect(find.text('CAIRN10 applied: 10% off'), findsOneWidget);
      await tapText(tester, 'Remove');
      expect(find.text('CAIRN10 applied: 10% off'), findsNothing);
      expect(read<CartCubit>(tester).state.promo, isNull);
    });
  });

  group('checkout', () {
    testWidgets('leaving checkout returns to the cart and keeps the form', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await mountShop(tester);
      await read<CartCubit>(tester).add('monitor-pro');
      await goToTab(tester, ShopTab.cart);
      await tapText(tester, 'Checkout');
      // The signed-in account pre-fills the name and email.
      expect(find.text('Ada Lovelace'), findsOneWidget);
      await fill(tester, 'City', 'Paris');
      await tester.tap(find.bySemanticsLabel('Back to cart'));
      await pumpFrames(tester, 10);
      expect(find.text('Checkout'), findsOneWidget);
      await tapText(tester, 'Checkout');
      expect(find.text('Paris'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('express delivery changes the total and the radio group', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      await read<CartCubit>(tester).add('court-low');
      await goToTab(tester, ShopTab.cart);
      await tapText(tester, 'Checkout');
      expect(find.text('\$97'), findsOneWidget);
      await tapText(tester, 'Express · \$12');
      expect(find.text('\$101'), findsOneWidget);
    });

    testWidgets('the payment step refuses an expired card', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      await read<CartCubit>(tester).add('court-low');
      await goToTab(tester, ShopTab.cart);
      await tapText(tester, 'Checkout');
      await fill(tester, 'Phone', '555 010 9999');
      await fill(tester, 'Address', '1 Compiler Way');
      await fill(tester, 'City', 'Arlington');
      await fill(tester, 'Postal code', '22201');
      await tapText(tester, 'Continue to payment');
      await fill(tester, 'Name on card', 'Ada Lovelace');
      await fill(tester, 'Card number', '4242424242424242');
      await fill(tester, 'Expiry', '0120');
      await fill(tester, 'CVC', '12');
      await tapText(tester, 'Review order');
      expect(find.text('This card has expired.'), findsOneWidget);
      expect(find.text('Enter the 3 or 4 digit code.'), findsOneWidget);
      expect(find.text('Review order'), findsOneWidget);
    });

    testWidgets('continue shopping after an order goes back to the shop', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      await read<CartCubit>(tester).add('court-low');
      await goToTab(tester, ShopTab.cart);
      await tapText(tester, 'Checkout');
      await fill(tester, 'Phone', '555 010 9999');
      await fill(tester, 'Address', '1 Compiler Way');
      await fill(tester, 'City', 'Arlington');
      await fill(tester, 'Postal code', '22201');
      await tapText(tester, 'Continue to payment');
      await fill(tester, 'Name on card', 'Ada Lovelace');
      await fill(tester, 'Card number', '4242424242424242');
      await fill(tester, 'Expiry', '1299');
      await fill(tester, 'CVC', '123');
      await tapText(tester, 'Review order');
      await tapText(tester, 'Place order');
      await pumpFrames(tester, 10);
      expect(find.textContaining('Order CR-2048 is confirmed'), findsOneWidget);
      await tapText(tester, 'Continue shopping');
      await pumpFrames(tester, 10);
      expect(find.text('Discover'), findsOneWidget);
      // A fresh visit to the cart finds it empty.
      await goToTab(tester, ShopTab.cart);
      expect(find.text('Your cart is empty'), findsOneWidget);
    });
  });

  group('saved', () {
    testWidgets('shows the grid, then a helpful empty state', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      await goToTab(tester, ShopTab.saved);
      expect(find.text('Saved'), findsWidgets);
      expect(find.text('Classic White Low'), findsWidgets);
      expect(find.text('You might also like'), findsOneWidget);

      await read<SavedCubit>(tester).toggle('classic-white');
      await pumpFrames(tester, 10);
      expect(find.text('Nothing saved yet'), findsOneWidget);
      expect(find.text('Start with these'), findsOneWidget);
      await tester.tap(find.text('Browse the shop'));
      await pumpFrames(tester, 10);
      expect(find.text('Discover'), findsOneWidget);
    });
  });

  group('profile', () {
    testWidgets('shows the account, history, addresses and settings', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      await goToTab(tester, ShopTab.profile);
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Member since 2024'), findsOneWidget);
      expect(find.text('Order CR-2041'), findsOneWidget);
      expect(find.text('Shipped'), findsOneWidget);

      await tapText(tester, 'Order CR-1987');
      await pumpFrames(tester, 10);
      expect(find.text('Order CR-1987'), findsOneWidget);
      expect(find.text('Delivered'), findsWidgets);
      expect(find.text('Discount (CAIRN10)'), findsOneWidget);
      read<ShopNavigationCubit>(tester).back();
      await pumpFrames(tester, 10);

      await reveal(tester, find.text('Saved addresses'));
      expect(find.text('12 Analytical Row'), findsOneWidget);
      await reveal(tester, find.text('Offers'));
      await tester.tap(find.byType(CairnSwitch).last);
      await pumpFrames(tester);
      expect(read<ProfileCubit>(tester).state.preferences.offers, isTrue);

      await tapText(tester, 'How long does delivery take?');
      expect(
        find.textContaining('Standard delivery takes about'),
        findsOneWidget,
      );
    });

    testWidgets('signing out shows a sign-in empty state', (
      WidgetTester tester,
    ) async {
      await mountShop(tester);
      await goToTab(tester, ShopTab.profile);
      await tapText(tester, 'Sign out');
      await pumpFrames(tester, 10);
      expect(find.text('You are signed out'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);

      await goToTab(tester, ShopTab.shop);
      expect(find.text('Welcome to Cairn'), findsOneWidget);

      await goToTab(tester, ShopTab.profile);
      await tapText(tester, 'Sign in');
      await pumpFrames(tester, 10);
      expect(find.text('Ada Lovelace'), findsOneWidget);
    });

    testWidgets('works in the dark theme too', (WidgetTester tester) async {
      await mountShop(tester, theme: CairnTheme.dark);
      for (final ShopTab tab in ShopTab.values) {
        await goToTab(tester, tab);
      }
      expect(find.byType(ShopShell), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
