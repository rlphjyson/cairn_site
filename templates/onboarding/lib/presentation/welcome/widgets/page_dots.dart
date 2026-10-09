import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/motion.dart';

/// A row of dots showing which page is current.
///
/// Purely an indicator: swiping and the Next button are the controls, so the
/// dots are not tap targets. A screen reader hears one label, "Page 2 of 4".
class PageDots extends StatelessWidget {
  /// Creates the dots.
  const PageDots({super.key, required this.count, required this.index});

  /// How many pages there are.
  final int count;

  /// The current page, from zero.
  final int index;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Semantics(
      container: true,
      label: 'Page ${index + 1} of $count',
      child: ExcludeSemantics(
        child: SizedBox(
          height: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < count; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedContainer(
                    duration: OnboardingMotion.of(context, CairnMotion.d200),
                    curve: CairnMotion.standard,
                    width: i == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == index
                          ? theme.primary
                          : theme.mutedForeground.withValues(alpha: 0.35),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
