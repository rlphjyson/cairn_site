import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/onboarding_text.dart';

/// One line of the summary: what it is, and what the user chose.
class SummaryEntry {
  /// Creates an entry.
  const SummaryEntry(this.label, this.value);

  /// What the entry describes, such as "Goal".
  final String label;

  /// What the user chose.
  final String value;
}

/// A card listing the user's choices.
///
/// Rows are stacked (label above value) so long values, such as several
/// interests, wrap instead of overflowing on a narrow phone.
class SummaryCard extends StatelessWidget {
  /// Creates the card.
  const SummaryCard({super.key, required this.entries});

  /// The rows.
  final List<SummaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Semantics(
      container: true,
      label: 'Your choices',
      child: CairnCard(
        gap: 12,
        children: <Widget>[
          for (int i = 0; i < entries.length; i++) ...<Widget>[
            if (i > 0) const CairnCardContent(child: CairnSeparator()),
            CairnCardContent(
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entries[i].label,
                      style: onboardingText(
                        theme,
                        theme.textStyle(CairnTypography.xs),
                        color: theme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entries[i].value,
                      style: onboardingText(
                        theme,
                        theme.textStyle(CairnTypography.sm),
                        weight: CairnTypography.medium,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
