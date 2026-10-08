import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../cart/bloc/cart_cubit.dart';
import '../cart/views/cart_view.dart';
import '../checkout/bloc/checkout_cubit.dart';
import '../checkout/views/order_confirmation_view.dart';

/// The cart tab: the cart, or the confirmation once an order has gone through.
///
/// Composition lives here, in the shell, so the cart and checkout features
/// never import each other's presentation layer.
class CartTab extends StatelessWidget {
  /// Creates the tab.
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckoutState checkout = context.watch<CheckoutCubit>().state;
    final bool cartEmpty = context.watch<CartCubit>().state.isEmpty;

    // Placed *and* nothing new added since: show the confirmation. Adding
    // another product naturally brings the cart back.
    if (checkout.status == CheckoutStatus.placed && cartEmpty) {
      return OrderConfirmationView(
        order: checkout.order!,
        onContinue: () {
          context.read<CheckoutCubit>().reset();
          context.read<ShopNavigationCubit>().selectTab(ShopTab.shop);
        },
      );
    }
    return CartView(
      onCheckout: () => context.read<CheckoutCubit>().placeOrder(),
      onBrowse: () =>
          context.read<ShopNavigationCubit>().selectTab(ShopTab.shop),
    );
  }
}
