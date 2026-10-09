import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/onboarding_text.dart';
import '../../../domain/personalise/models/goal.dart';

/// A single choice among goals, as large tappable cards around Cairn radios.
///
/// The whole card selects, not just the 16 px radio, so it is an easy target.
/// The radio carries the accessible name ("Build a routine. Do the same few
/// things every day.") and the visible text is hidden from assistive
/// technology so it is read once.
class GoalPicker extends StatelessWidget {
  /// Creates the picker.
  const GoalPicker({
    super.key,
    required this.goals,
    required this.selectedId,
    required this.showError,
    required this.onSelect,
  });

  /// Everything on offer.
  final List<Goal> goals;

  /// The chosen id.
  final String? selectedId;

  /// Whether to show that a goal is needed.
  final bool showError;

  /// Chooses a goal.
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CairnRadioGroup<String>(
          value: selectedId,
          onChanged: onSelect,
          spacing: 12,
          semanticLabel: 'Main goal',
          children: <Widget>[
            for (final Goal goal in goals)
              _GoalCard(
                goal: goal,
                selected: goal.id == selectedId,
                onTap: () => onSelect(goal.id),
              ),
          ],
        ),
        if (showError && selectedId == null) ...<Widget>[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Row(
              children: <Widget>[
                CairnIcon(
                  CairnIconData.alert,
                  size: 16,
                  color: theme.destructive,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Choose a goal to continue.',
                    style: onboardingText(
                      theme,
                      theme.textStyle(CairnTypography.sm),
                      color: theme.destructive,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  final Goal goal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? theme.accent : theme.card,
          borderRadius: BorderRadius.circular(theme.radiusScale.lg),
          border: Border.all(
            color: selected ? theme.primary : theme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            CairnRadioItem<String>(
              value: goal.id,
              semanticLabel: goal.hint.isEmpty
                  ? goal.label
                  : '${goal.label}. ${goal.hint}',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      goal.label,
                      style: onboardingText(
                        theme,
                        theme.textStyle(CairnTypography.base),
                        weight: CairnTypography.medium,
                        color: selected
                            ? theme.accentForeground
                            : theme.foreground,
                      ),
                    ),
                    if (goal.hint.isNotEmpty)
                      Text(
                        goal.hint,
                        style: onboardingText(
                          theme,
                          theme.textStyle(CairnTypography.sm),
                          color: theme.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
