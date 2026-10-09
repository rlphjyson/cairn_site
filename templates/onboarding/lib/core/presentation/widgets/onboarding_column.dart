import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/onboarding_layout.dart';

/// Keeps the flow a phone-shaped column on wide screens.
///
/// On a phone (or any narrow space) it does nothing. From
/// [OnboardingLayout.wideBreakpoint] up the content stays centred at
/// [OnboardingLayout.maxWidth], with hairlines either side.
class OnboardingColumn extends StatelessWidget {
  /// Creates a column.
  const OnboardingColumn({super.key, required this.child});

  /// The flow.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        if (box.maxWidth < OnboardingLayout.wideBreakpoint) {
          return ColoredBox(color: theme.background, child: child);
        }
        return ColoredBox(
          color: theme.muted.withValues(alpha: 0.4),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.background,
                border: Border.symmetric(
                  vertical: BorderSide(color: theme.border),
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: OnboardingLayout.maxWidth,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
