import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/dates.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/order_lines.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../core/presentation/widgets/totals_summary.dart';
import '../../../domain/cart/models/cart_totals.dart';
import '../../../domain/orders/models/shipping_details.dart';
import '../../cart/bloc/cart_cubit.dart';
import '../bloc/checkout_cubit.dart';

/// Step three: everything in one place, with links back to change it.
class ReviewStep extends StatelessWidget {
  /// Creates the step.
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final CheckoutState checkout = context.watch<CheckoutCubit>().state;
    final CartState cart = context.watch<CartCubit>().state;
    final CartTotals totals = context.read<CartCubit>().totalsFor(
      checkout.delivery,
    );
    final ShippingDetails s = checkout.shipping;
    final DateTime arrives = addBusinessDays(
      DateTime.now(),
      checkout.delivery.businessDays,
    );

    Widget block({
      required String title,
      required String editLabel,
      required VoidCallback onEdit,
      required List<String> lines,
    }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title,
          trailing: CairnButton(
            size: CairnButtonSize.sm,
            variant: CairnButtonVariant.link,
            semanticLabel: editLabel,
            onPressed: onEdit,
            child: const Text('Edit'),
          ),
        ),
        const SizedBox(height: 4),
        for (final String line in lines)
          Text(
            line,
            style: shopText(
              theme,
              theme.textStyle(CairnTypography.sm),
              color: theme.mutedForeground,
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        const SectionHeader('Your items'),
        OrderLines(lines: cart.lines),
        const CairnSeparator(),
        block(
          title: 'Ship to',
          editLabel: 'Edit shipping address',
          onEdit: () =>
              context.read<CheckoutCubit>().goTo(CheckoutStep.shipping),
          lines: <String>[s.fullName, s.address, '${s.city} ${s.postalCode}'],
        ),
        block(
          title: 'Delivery',
          editLabel: 'Edit delivery method',
          onEdit: () =>
              context.read<CheckoutCubit>().goTo(CheckoutStep.shipping),
          lines: <String>[
            '${checkout.delivery.label}, about '
                '${checkout.delivery.businessDays} business days',
            'Arrives around ${formatShortDate(arrives)}',
          ],
        ),
        block(
          title: 'Payment',
          editLabel: 'Edit payment details',
          onEdit: () =>
              context.read<CheckoutCubit>().goTo(CheckoutStep.payment),
          lines: <String>[
            'Card ending ${checkout.payment.last4}',
            checkout.payment.cardHolder,
          ],
        ),
        const CairnSeparator(),
        TotalsSummary(totals: totals, promoCode: cart.promo?.code),
        if (checkout.failure != null)
          CairnAlert(
            variant: CairnAlertVariant.destructive,
            icon: const Icon(Icons.error_outline),
            title: Text(checkout.failure!),
          ),
      ],
    );
  }
}
