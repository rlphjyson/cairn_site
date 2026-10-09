import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/money.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../domain/cart/models/cart_totals.dart';
import '../../cart/bloc/cart_cubit.dart';
import '../bloc/checkout_cubit.dart';
import '../widgets/payment_step.dart';
import '../widgets/review_step.dart';
import '../widgets/shipping_step.dart';

/// The checkout: a progress bar, the current step and a sticky action bar.
///
/// The confirmation is a separate view ([OrderConfirmationView]) shown once
/// the order is placed.
class CheckoutView extends StatelessWidget {
  /// Creates the view.
  const CheckoutView({super.key});

  static const List<CairnStep> _steps = <CairnStep>[
    CairnStep(label: 'Shipping'),
    CairnStep(label: 'Payment'),
    CairnStep(label: 'Review'),
    CairnStep(label: 'Done'),
  ];

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (BuildContext context, CheckoutState state) {
        final CheckoutCubit cubit = context.read<CheckoutCubit>();
        final bool placing = state.status == CheckoutStatus.placing;
        // Watching the cart keeps the total current if its lines change.
        final CartTotals totals = context.watch<CartCubit>().totalsFor(
          state.delivery,
        );
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: <Widget>[
                  CairnButton.icon(
                    variant: CairnButtonVariant.ghost,
                    icon: const CairnIcon(CairnIconData.chevronLeft),
                    semanticLabel: state.step == CheckoutStep.shipping
                        ? 'Back to cart'
                        : 'Back to ${CheckoutStep.values[state.step.index - 1].label}',
                    onPressed: placing ? null : cubit.back,
                  ),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Checkout',
                        style: shopText(
                          theme,
                          theme.textStyle(CairnTypography.xl),
                          weight: CairnTypography.semibold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: CairnSteps(
                current: state.step.index,
                steps: _steps,
                onStepTap: (int i) {
                  if (i < state.step.index && !placing) {
                    cubit.goTo(CheckoutStep.values[i]);
                  }
                },
              ),
            ),
            Expanded(
              child: ListView(
                key: ValueKey<CheckoutStep>(state.step),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: <Widget>[
                  switch (state.step) {
                    CheckoutStep.shipping => const ShippingStep(),
                    CheckoutStep.payment => const PaymentStep(),
                    CheckoutStep.review => const ReviewStep(),
                  },
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.background,
                border: Border(top: BorderSide(color: theme.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  spacing: 16,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Total',
                          style: shopText(
                            theme,
                            theme.textStyle(CairnTypography.xs),
                            color: theme.mutedForeground,
                          ),
                        ),
                        Text(
                          formatMoney(totals.total),
                          style: shopText(
                            theme,
                            theme.textStyle(CairnTypography.lg),
                            weight: CairnTypography.semibold,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: CairnButton(
                        expand: true,
                        onPressed: placing
                            ? null
                            : state.step == CheckoutStep.review
                            ? cubit.placeOrder
                            : cubit.next,
                        leading: placing ? const CairnSpinner(size: 16) : null,
                        child: Text(switch (state.step) {
                          CheckoutStep.shipping => 'Continue to payment',
                          CheckoutStep.payment => 'Review order',
                          CheckoutStep.review =>
                            placing ? 'Placing order' : 'Place order',
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
