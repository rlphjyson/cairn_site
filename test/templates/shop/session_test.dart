import 'package:cairn_site/src/templates/shop/core/infrastructure/di/shop_injection.dart';
import 'package:cairn_site/src/templates/shop/presentation/cart/bloc/cart_cubit.dart';
import 'package:cairn_site/src/templates/shop/presentation/checkout/bloc/checkout_cubit.dart';
import 'package:cairn_site/src/templates/shop/presentation/profile/bloc/profile_cubit.dart';
import 'package:cairn_site/src/templates/shop/presentation/saved/bloc/saved_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The session cubits wired through the real container, with no widgets: the
/// point of the layering is that all of this runs without a UI.
void main() {
  late GetIt locator;

  setUp(() => locator = createShopLocator());
  tearDown(() => locator.reset());

  test('each container is independent', () {
    final GetIt other = createShopLocator();
    expect(identical(locator<CartCubit>(), other<CartCubit>()), isFalse);
    other.reset();
  });

  test('session cubits are singletons; screen cubits are not', () {
    expect(identical(locator<CartCubit>(), locator<CartCubit>()), isTrue);
  });

  test('saved starts with one item and toggles', () async {
    final SavedCubit saved = locator<SavedCubit>();
    await saved.load();
    expect(saved.state.ids, <String>{'classic-white'});
    expect(saved.state.products.single.id, 'classic-white');

    await saved.toggle('court-low');
    expect(saved.state.isSaved('court-low'), isTrue);
    await saved.toggle('court-low');
    expect(saved.state.isSaved('court-low'), isFalse);
  });

  test('adding to the cart accumulates and totals follow', () async {
    final CartCubit cart = locator<CartCubit>();
    await cart.load();
    expect(cart.state.isEmpty, isTrue);

    await cart.add('court-low');
    await cart.add('court-low');
    expect(cart.state.quantityOf('court-low'), 2);
    expect(cart.state.totals.subtotal, 178);
    expect(cart.state.totals.shipping, 0);

    await cart.setQuantity('court-low', 0);
    expect(cart.state.isEmpty, isTrue);
  });

  test('placing an order returns a reference and empties the cart', () async {
    final CartCubit cart = locator<CartCubit>();
    final CheckoutCubit checkout = locator<CheckoutCubit>();
    await cart.add('monitor-pro');

    await checkout.placeOrder();
    expect(checkout.state.status, CheckoutStatus.placed);
    expect(checkout.state.order?.id, 'CR-2048');
    expect(checkout.state.order?.totals.total, 249);

    await cart.load();
    expect(cart.state.isEmpty, isTrue);

    checkout.reset();
    expect(checkout.state.status, CheckoutStatus.idle);
  });

  test('checking out an empty cart places nothing', () async {
    final CheckoutCubit checkout = locator<CheckoutCubit>();
    await checkout.placeOrder();
    expect(checkout.state.status, CheckoutStatus.idle);
    expect(checkout.state.order, isNull);
  });

  test('preferences persist across a toggle', () async {
    final ProfileCubit profile = locator<ProfileCubit>();
    await profile.load();
    expect(profile.state.account?.name, 'Ada Lovelace');
    expect(profile.state.preferences.offers, isFalse);

    await profile.setOffers(true);
    expect(profile.state.preferences.offers, isTrue);
    expect(profile.state.preferences.orderUpdates, isTrue);
  });
}
