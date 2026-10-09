import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/orders/models/order_status.dart';

/// A badge naming where an order is in its journey.
class OrderStatusBadge extends StatelessWidget {
  /// Creates the badge.
  const OrderStatusBadge(this.status, {super.key});

  /// The status to show.
  final OrderStatus status;

  @override
  Widget build(BuildContext context) => CairnBadge(
    variant: switch (status) {
      OrderStatus.processing => CairnBadgeVariant.secondary,
      OrderStatus.shipped => CairnBadgeVariant.primary,
      OrderStatus.delivered => CairnBadgeVariant.outline,
    },
    label: Text(status.label),
  );
}
