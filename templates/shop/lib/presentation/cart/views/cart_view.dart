import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../../../core/presentation/widgets/empty_state.dart';
import '../../../core/presentation/widgets/screen_title.dart';
import '../../../core/presentation/widgets/totals_summary.dart';
import '../../../domain/cart/models/cart_line.dart';
import '../../catalog/widgets/suggested_products.dart';
import '../bloc/cart_cubit.dart';
import '../widgets/cart_row.dart';
import '../widgets/free_shipping_progress.dart';
import '../widgets/promo_code_field.dart';

/// The cart: lines, promo code, free-shipping progress and the order summary.
class CartView extends StatelessWidget {
  /// Creates the view.
  const CartView({super.key, required this.onCheckout, required this.onBrowse});

  /// Called when "Checkout" is pressed.
  final VoidCallback onCheckout;

  /// Called from the empty state.
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (BuildContext context, CartState state) {
        if (state.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Your cart is empty',
            body: 'Add something from the shop and it will show up here.',
            action: 'Start shopping',
            onAction: onBrowse,
            below: const SuggestedProducts(title: 'Popular right now'),
          );
        }
        final CartCubit cart = context.read<CartCubit>();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: <Widget>[
            ScreenTitle(
              'Cart',
              trailing: CairnBadge(
                variant: CairnBadgeVariant.secondary,
                label: Text(
                  '${state.itemCount} ${state.itemCount == 1 ? 'item' : 'items'}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            CairnList(
              bordered: true,
              children: <Widget>[
                for (final CartLine line in state.lines)
                  CartRow(
                    key: ValueKey<String>(line.key),
                    line: line,
                    onQuantity: (int q) => cart.setQuantity(line.key, q),
                    onRemove: () => cart.remove(line.key),
                    onOpen: () => context
                        .read<ShopNavigationCubit>()
                        .openProduct(line.product.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const PromoCodeField(),
            const SizedBox(height: 16),
            FreeShippingProgress(totals: state.totals),
            const SizedBox(height: 20),
            TotalsSummary(totals: state.totals, promoCode: state.promo?.code),
            const SizedBox(height: 16),
            CairnButton(
              expand: true,
              size: CairnButtonSize.lg,
              onPressed: onCheckout,
              trailing: const CairnIcon(CairnIconData.chevronRight),
              child: const Text('Checkout'),
            ),
          ],
        );
      },
    );
  }
}
