import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/money.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/empty_state.dart';
import '../../../core/presentation/widgets/screen_title.dart';
import '../../../domain/cart/models/cart_line.dart';
import '../../../domain/cart/models/cart_totals.dart';
import '../bloc/cart_cubit.dart';
import '../widgets/cart_row.dart';

/// The cart: steps, lines, free-shipping progress and totals.
class CartView extends StatelessWidget {
  /// Creates the view.
  const CartView({super.key, required this.onCheckout, required this.onBrowse});

  /// Called when "Checkout" is pressed.
  final VoidCallback onCheckout;

  /// Called from the empty state.
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return BlocBuilder<CartCubit, CartState>(
      builder: (BuildContext context, CartState state) {
        if (state.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Your cart is empty',
            body: 'Add something from the shop and it will show up here.',
            action: 'Start shopping',
            onAction: onBrowse,
          );
        }
        final CartTotals totals = state.totals;

        Widget row(String label, String value, {bool strong = false}) => Row(
          children: <Widget>[
            Text(
              label,
              style: shopText(
                theme,
                theme.textStyle(CairnTypography.sm),
                color: strong ? theme.foreground : theme.mutedForeground,
                weight: strong ? CairnTypography.semibold : null,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: shopText(
                theme,
                theme.textStyle(CairnTypography.sm),
                weight: strong
                    ? CairnTypography.semibold
                    : CairnTypography.medium,
              ),
            ),
          ],
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: <Widget>[
            const ScreenTitle('Cart'),
            const SizedBox(height: 16),
            const CairnSteps(
              current: 0,
              steps: <CairnStep>[
                CairnStep(label: 'Cart'),
                CairnStep(label: 'Shipping'),
                CairnStep(label: 'Done'),
              ],
            ),
            const SizedBox(height: 16),
            CairnList(
              bordered: true,
              children: <Widget>[
                for (final CartLine line in state.lines)
                  CartRow(
                    line: line,
                    onQuantity: (int q) => context
                        .read<CartCubit>()
                        .setQuantity(line.product.id, q),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (totals.amountToFreeShipping > 0) ...<Widget>[
              Text(
                'Add ${formatMoney(totals.amountToFreeShipping)} more for '
                'free shipping.',
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.xs),
                  color: theme.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
            ],
            CairnProgress(
              value: totals.freeShippingProgress,
              semanticLabel: 'Progress to free shipping',
            ),
            const SizedBox(height: 16),
            row('Subtotal', formatMoney(totals.subtotal)),
            const SizedBox(height: 6),
            row(
              'Shipping',
              totals.shipping == 0 ? 'Free' : formatMoney(totals.shipping),
            ),
            const SizedBox(height: 10),
            const CairnSeparator(),
            const SizedBox(height: 10),
            row('Total', formatMoney(totals.total), strong: true),
            const SizedBox(height: 16),
            CairnButton(
              expand: true,
              onPressed: onCheckout,
              child: const Text('Checkout'),
            ),
          ],
        );
      },
    );
  }
}
