import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/screen_title.dart';
import '../../../domain/checkout/models/order.dart';

/// The last step of checkout: confirmation and order tracking.
class OrderConfirmationView extends StatelessWidget {
  /// Creates the view.
  const OrderConfirmationView({
    super.key,
    required this.order,
    required this.onContinue,
  });

  /// The order that was placed.
  final Order order;

  /// Called from "Continue shopping".
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: <Widget>[
        const ScreenTitle('Order placed'),
        const SizedBox(height: 16),
        const CairnSteps(
          current: 2,
          steps: <CairnStep>[
            CairnStep(label: 'Cart'),
            CairnStep(label: 'Shipping'),
            CairnStep(label: 'Done'),
          ],
        ),
        const SizedBox(height: 24),
        const Center(
          child: CairnRadialProgress(
            value: 1,
            size: 88,
            tone: CairnTone.success,
            child: CairnIcon(CairnIconData.check, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Thank you',
          textAlign: TextAlign.center,
          style: shopText(
            theme,
            theme.textStyle(CairnTypography.lg),
            weight: CairnTypography.semibold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Order #${order.id} is confirmed.\nArrives in 2 to 3 days.',
          textAlign: TextAlign.center,
          style: shopText(
            theme,
            theme.textStyle(CairnTypography.sm),
            color: theme.mutedForeground,
          ),
        ),
        const SizedBox(height: 24),
        const CairnTimeline(
          items: <CairnTimelineItem>[
            CairnTimelineItem(
              tone: CairnTone.success,
              icon: CairnIcon(CairnIconData.check),
              title: Text('Order placed'),
              time: Text('Just now'),
            ),
            CairnTimelineItem(
              tone: CairnTone.info,
              title: Text('Packing'),
              description: Text('We are boxing it up.'),
              time: Text('Today'),
            ),
            CairnTimelineItem(
              title: Text('Out for delivery'),
              time: Text('Soon'),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
