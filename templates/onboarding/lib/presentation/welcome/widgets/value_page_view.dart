import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/onboarding_layout.dart';
import '../../../common/constants/onboarding_package.dart';
import '../../../core/presentation/onboarding_text.dart';
import '../../../domain/flow/models/value_page.dart';

/// One page of the welcome carousel: a large photograph, a title and a line of
/// body text.
///
/// The photograph takes the height the page has left after the text, so the
/// text always fits; if a very short screen or a very large text size needs
/// more room, the page scrolls instead of overflowing.
class ValuePageView extends StatelessWidget {
  /// Creates a page.
  const ValuePageView({super.key, required this.page});

  /// The content.
  final ValuePage page;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        // Whatever the text below needs (about 190 px for a two-line title and
        // three lines of body), the photograph takes the rest.
        final double photo = (box.maxHeight - 190).clamp(140.0, 480.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: OnboardingLayout.gutter,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Semantics(
                image: true,
                label: page.imageLabel,
                child: ExcludeSemantics(
                  child: SizedBox(
                    height: photo,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        theme.radiusScale.xl2,
                      ),
                      child: Image.asset(
                        page.asset,
                        package: OnboardingPackage.name,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder:
                            (BuildContext c, Object e, StackTrace? s) =>
                                ColoredBox(color: theme.muted),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: onboardingText(
                    theme,
                    theme.textStyle(CairnTypography.xl2),
                    weight: CairnTypography.semibold,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                page.body,
                textAlign: TextAlign.center,
                style: onboardingText(
                  theme,
                  theme.textStyle(CairnTypography.base),
                  color: theme.mutedForeground,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
