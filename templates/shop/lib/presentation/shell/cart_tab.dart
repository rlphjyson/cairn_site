import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../../domain/orders/models/shipping_details.dart';
import '../../domain/profile/models/account.dart';
import '../cart/views/cart_view.dart';
import '../checkout/bloc/checkout_cubit.dart';
import '../checkout/views/checkout_view.dart';
import '../checkout/views/order_confirmation_view.dart';
import '../profile/bloc/profile_cubit.dart';

/// The cart tab: the cart, the checkout steps, or the confirmation once an
/// order has gone through.
///
/// Composition lives here, in the shell, so the cart and checkout features
/// never import each other's presentation layer.
class CartTab extends StatelessWidget {
  /// Creates the tab.
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckoutState checkout = context.watch<CheckoutCubit>().state;
    final ShopNavigationCubit nav = context.read<ShopNavigationCubit>();

    if (checkout.status == CheckoutStatus.placed && checkout.order != null) {
      final String orderId = checkout.order!.id;
      return OrderConfirmationView(
        order: checkout.order!,
        onTrack: () {
          context.read<CheckoutCubit>().reset();
          nav.openOrder(orderId);
        },
        onContinue: () {
          context.read<CheckoutCubit>().reset();
          nav.selectTab(ShopTab.shop);
        },
      );
    }
    if (checkout.isActive) return const CheckoutView();
    return CartView(
      onCheckout: () {
        final Account? account = context.read<ProfileCubit>().state.account;
        context.read<CheckoutCubit>().begin(
          prefill: account == null
              ? null
              : ShippingDetails(fullName: account.name, email: account.email),
        );
      },
      onBrowse: () => nav.selectTab(ShopTab.shop),
    );
  }
}
