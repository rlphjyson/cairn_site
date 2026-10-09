import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/dates.dart';
import '../../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/empty_state.dart';
import '../../../core/presentation/widgets/order_lines.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../core/presentation/widgets/totals_summary.dart';
import '../../../domain/orders/models/order.dart';
import '../../../domain/orders/models/order_status.dart';
import '../bloc/orders_cubit.dart';
import '../widgets/order_status_badge.dart';

/// One order: status, its journey, items, totals and where it is going.
class OrderDetailView extends StatelessWidget {
  /// Creates the view.
  const OrderDetailView({super.key, required this.orderId});

  /// Which order to show.
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Order? order = context.select(
      (OrdersCubit c) => c.state.byId(orderId),
    );
    if (order == null) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'We could not find that order',
        body: 'It may not have loaded yet.',
        action: 'Back to profile',
        onAction: context.read<ShopNavigationCubit>().back,
      );
    }
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
          child: Row(
            children: <Widget>[
              CairnButton.icon(
                variant: CairnButtonVariant.ghost,
                icon: const CairnIcon(CairnIconData.chevronLeft),
                semanticLabel: 'Back to profile',
                onPressed: context.read<ShopNavigationCubit>().back,
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Order ${order.id}',
                    style: shopText(
                      theme,
                      theme.textStyle(CairnTypography.xl),
                      weight: CairnTypography.semibold,
                    ),
                  ),
                ),
              ),
              OrderStatusBadge(order.status),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              Text(
                'Placed ${formatDate(order.placedAt)}. '
                '${order.status == OrderStatus.delivered ? 'Delivered' : 'Estimated delivery'} '
                '${formatShortDate(order.estimatedDelivery)}.',
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  color: theme.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),
              _Journey(status: order.status, order: order),
              const SizedBox(height: 20),
              const SectionHeader('Items'),
              const SizedBox(height: 12),
              OrderLines(lines: order.lines),
              const SizedBox(height: 16),
              TotalsSummary(totals: order.totals, promoCode: order.promo?.code),
              const SizedBox(height: 20),
              const SectionHeader('Shipping to'),
              const SizedBox(height: 6),
              for (final String line in <String>[
                order.shipping.fullName,
                order.shipping.address,
                '${order.shipping.city} ${order.shipping.postalCode}',
                order.shipping.email,
              ])
                Text(
                  line,
                  style: shopText(
                    theme,
                    theme.textStyle(CairnTypography.sm),
                    color: theme.mutedForeground,
                  ),
                ),
              const SizedBox(height: 16),
              const SectionHeader('Payment'),
              const SizedBox(height: 6),
              Text(
                order.cardLast4.isEmpty
                    ? 'Card'
                    : 'Card ending ${order.cardLast4}',
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  color: theme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Journey extends StatelessWidget {
  const _Journey({required this.status, required this.order});

  final OrderStatus status;
  final Order order;

  @override
  Widget build(BuildContext context) {
    final int step = status.index;
    CairnTone tone(int i) => i < step
        ? CairnTone.success
        : i == step
        ? CairnTone.info
        : CairnTone.neutral;
    return CairnTimeline(
      items: <CairnTimelineItem>[
        CairnTimelineItem(
          tone: CairnTone.success,
          icon: const CairnIcon(CairnIconData.check),
          title: const Text('Order placed'),
          time: Text(formatShortDate(order.placedAt)),
        ),
        CairnTimelineItem(
          tone: tone(0),
          icon: step > 0 ? const CairnIcon(CairnIconData.check) : null,
          title: const Text('Packed'),
          description: step == 0 ? const Text('We are boxing it up.') : null,
        ),
        CairnTimelineItem(
          tone: tone(1),
          icon: step > 1 ? const CairnIcon(CairnIconData.check) : null,
          title: const Text('On its way'),
          description: step == 1 ? const Text('With the courier.') : null,
        ),
        CairnTimelineItem(
          tone: step >= 2 ? CairnTone.success : CairnTone.neutral,
          icon: step >= 2 ? const CairnIcon(CairnIconData.check) : null,
          title: const Text('Delivered'),
          time: Text(formatShortDate(order.estimatedDelivery)),
        ),
      ],
    );
  }
}
