import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../common/utils/dates.dart';
import '../../../common/utils/money.dart';
import '../../../domain/orders/models/order.dart';
import 'order_status_badge.dart';

/// The shopper's orders as a bordered list, newest first. Tapping one calls
/// [onOpen].
class OrderHistoryList extends StatelessWidget {
  /// Creates the list.
  const OrderHistoryList({
    super.key,
    required this.orders,
    required this.onOpen,
  });

  /// The orders to show.
  final List<Order> orders;

  /// Called with the tapped order's id.
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnList(
      bordered: true,
      children: <Widget>[
        for (final Order o in orders)
          CairnListItem(
            title: Text('Order ${o.id}'),
            subtitle: Text(
              '${formatDate(o.placedAt)} · '
              '${o.totals.itemCount} ${o.totals.itemCount == 1 ? 'item' : 'items'}'
              ' · ${formatMoney(o.totals.total)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: <Widget>[
                OrderStatusBadge(o.status),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: theme.mutedForeground,
                ),
              ],
            ),
            onTap: () => onOpen(o.id),
          ),
      ],
    );
  }
}
