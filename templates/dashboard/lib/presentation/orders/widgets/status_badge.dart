import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/orders/models/order.dart';

/// An order status as an outlined badge with a tone dot.
class StatusBadge extends StatelessWidget {
  /// Creates a badge.
  const StatusBadge({super.key, required this.status});

  /// The status to show.
  final OrderStatus status;

  static CairnTone _tone(OrderStatus s) => switch (s) {
    OrderStatus.paid => CairnTone.success,
    OrderStatus.pending => CairnTone.warning,
    OrderStatus.failed => CairnTone.destructive,
    OrderStatus.refunded => CairnTone.info,
  };

  @override
  Widget build(BuildContext context) => CairnBadge(
    variant: CairnBadgeVariant.outline,
    leading: CairnStatus(tone: _tone(status), size: 6),
    label: Text(status.label),
  );
}
