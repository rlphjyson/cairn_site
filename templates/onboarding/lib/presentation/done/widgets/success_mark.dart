import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/motion.dart';

/// A calm success mark: a check in a soft disc. It fades in once; with reduced
/// motion it is simply there. Decorative: the heading says what happened.
class SuccessMark extends StatelessWidget {
  /// Creates the mark.
  const SuccessMark({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: OnboardingMotion.of(context, CairnMotion.d500),
        curve: CairnMotion.easeOut,
        builder: (BuildContext context, double t, Widget? child) =>
            Opacity(opacity: t, child: child),
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primary.withValues(alpha: 0.08),
          ),
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primary.withValues(alpha: 0.14),
              ),
              child: Center(
                child: CairnIcon(
                  CairnIconData.check,
                  size: 28,
                  color: theme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
