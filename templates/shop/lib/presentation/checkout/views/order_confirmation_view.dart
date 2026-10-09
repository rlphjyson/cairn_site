import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/utils/dates.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/order_lines.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../core/presentation/widgets/totals_summary.dart';
import '../../../domain/orders/models/order.dart';

/// The last step of checkout: confirmation, a delivery estimate and a first
/// look at the order's journey.
class OrderConfirmationView extends StatelessWidget {
  /// Creates the view.
  const OrderConfirmationView({
    super.key,
    required this.order,
    required this.onTrack,
    required this.onContinue,
  });

  /// The order that was placed.
  final Order order;

  /// Called from "Track order".
  final VoidCallback onTrack;

  /// Called from "Continue shopping".
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String first = order.shipping.fullName.trim().split(' ').first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        const CairnSteps(
          current: 4,
          steps: <CairnStep>[
            CairnStep(label: 'Shipping'),
            CairnStep(label: 'Payment'),
            CairnStep(label: 'Review'),
            CairnStep(label: 'Done'),
          ],
        ),
        const SizedBox(height: 24),
        const Center(
          child: CairnRadialProgress(
            value: 1,
            size: 80,
            tone: CairnTone.success,
            child: CairnIcon(CairnIconData.check, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            first.isEmpty ? 'Thank you' : 'Thank you, $first',
            textAlign: TextAlign.center,
            style: shopText(
              theme,
              theme.textStyle(CairnTypography.xl2),
              weight: CairnTypography.semibold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Order ${order.id} is confirmed.\n'
          'Estimated delivery ${formatShortDate(order.estimatedDelivery)}.',
          textAlign: TextAlign.center,
          style: shopText(
            theme,
            theme.textStyle(CairnTypography.sm),
            color: theme.mutedForeground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'A receipt is on its way to ${order.shipping.email}.',
          textAlign: TextAlign.center,
          style: shopText(
            theme,
            theme.textStyle(CairnTypography.xs),
            color: theme.mutedForeground,
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader('What happens next'),
        const SizedBox(height: 12),
        CairnTimeline(
          items: <CairnTimelineItem>[
            const CairnTimelineItem(
              tone: CairnTone.success,
              icon: CairnIcon(CairnIconData.check),
              title: Text('Order placed'),
              time: Text('Just now'),
            ),
            const CairnTimelineItem(
              tone: CairnTone.info,
              title: Text('Packing'),
              description: Text('We are boxing it up.'),
              time: Text('Today'),
            ),
            CairnTimelineItem(
              title: const Text('Out for delivery'),
              time: Text(formatShortDate(order.estimatedDelivery)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionHeader('Order summary'),
        const SizedBox(height: 12),
        OrderLines(lines: order.lines),
        const SizedBox(height: 16),
        TotalsSummary(totals: order.totals, promoCode: order.promo?.code),
        const SizedBox(height: 24),
        CairnButton(
          expand: true,
          onPressed: onTrack,
          child: const Text('Track order'),
        ),
        const SizedBox(height: 10),
        CairnButton(
          expand: true,
          variant: CairnButtonVariant.outline,
          onPressed: onContinue,
          child: const Text('Continue shopping'),
        ),
      ],
    );
  }
}
