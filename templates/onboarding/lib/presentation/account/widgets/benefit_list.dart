import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/onboarding_text.dart';

/// A short list of reasons, each with a tick.
class BenefitList extends StatelessWidget {
  /// Creates the list.
  const BenefitList({super.key, required this.items});

  /// One line each.
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Semantics(
      container: true,
      label: 'Benefits of an account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final String item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primary.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: ExcludeSemantics(
                        child: CairnIcon(
                          CairnIconData.check,
                          size: 14,
                          color: theme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item,
                        style: onboardingText(
                          theme,
                          theme.textStyle(CairnTypography.base),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
