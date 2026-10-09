import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/onboarding_layout.dart';
import '../onboarding_text.dart';

/// The frame every step shares: a scrolling area with a heading, and a footer
/// that stays pinned to the bottom.
///
/// Content scrolls rather than overflowing, so large text sizes and short
/// screens still work, while the primary action never leaves the screen.
class StepLayout extends StatelessWidget {
  /// Creates a layout.
  const StepLayout({
    super.key,
    this.title,
    this.body,
    this.leading,
    required this.child,
    required this.footer,
    this.centered = false,
  });

  /// The heading. It is announced as a header.
  final String? title;

  /// The line under the heading.
  final String? body;

  /// A widget above the heading, such as an illustration.
  final Widget? leading;

  /// The step's content.
  final Widget child;

  /// The actions, pinned below the content.
  final Widget footer;

  /// Whether the heading and body are centred.
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextAlign align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              OnboardingLayout.gutter,
              8,
              OnboardingLayout.gutter,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ?leading,
                if (leading != null) const SizedBox(height: 24),
                if (title != null && title!.isNotEmpty)
                  Semantics(
                    header: true,
                    child: Text(
                      title!,
                      textAlign: align,
                      style: onboardingText(
                        theme,
                        theme.textStyle(CairnTypography.xl2),
                        weight: CairnTypography.semibold,
                        height: 1.2,
                      ),
                    ),
                  ),
                if (body != null && body!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    body!,
                    textAlign: align,
                    style: onboardingText(
                      theme,
                      theme.textStyle(CairnTypography.base),
                      color: theme.mutedForeground,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OnboardingLayout.gutter,
            8,
            OnboardingLayout.gutter,
            16,
          ),
          child: footer,
        ),
      ],
    );
  }
}
