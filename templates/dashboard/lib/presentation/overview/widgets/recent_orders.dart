import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/format.dart';
import '../../../core/presentation/dashboard_text.dart';
import '../../../domain/orders/models/order.dart';
import '../../orders/widgets/status_badge.dart';

/// The newest orders as a compact list.
class RecentOrders extends StatelessWidget {
  /// Creates the list.
  const RecentOrders({super.key, required this.orders});

  /// What to show.
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnList(
      children: <Widget>[
        for (final Order o in orders)
          CairnListItem(
            title: Text(o.customer),
            subtitle: Text(o.id),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 4,
              children: <Widget>[
                Text(
                  DashboardFormat.currency(o.amount),
                  style: dashText(
                    theme,
                    theme.textStyle(CairnTypography.sm),
                    weight: CairnTypography.medium,
                  ),
                ),
                StatusBadge(status: o.status),
              ],
            ),
          ),
      ],
    );
  }
}
