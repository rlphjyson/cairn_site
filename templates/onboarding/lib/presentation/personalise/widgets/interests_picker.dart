import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/onboarding_text.dart';
import '../../../core/presentation/widgets/touch_target.dart';
import '../../../domain/personalise/models/interest.dart';
import '../../../domain/personalise/models/interests_validation.dart';

/// Selectable chips for choosing several interests.
///
/// Each chip is a `CairnToggle`; a chosen one also shows a tick, so the state
/// never depends on colour alone. Below the chips, a live-region line says how
/// many more are needed and turns into a warning if the user tries to continue
/// too early.
class InterestsPicker extends StatelessWidget {
  /// Creates the picker.
  const InterestsPicker({
    super.key,
    required this.interests,
    required this.selected,
    required this.validation,
    required this.showError,
    required this.onToggle,
  });

  /// Everything on offer.
  final List<Interest> interests;

  /// The chosen ids.
  final Set<String> selected;

  /// How the choice stands against the minimum.
  final InterestsValidation validation;

  /// Whether to show the problem as a warning.
  final bool showError;

  /// Adds or removes an interest.
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool warn = showError && !validation.isValid;
    final String status = validation.isValid
        ? '${validation.count} picked. Add more if you like.'
        : warn
        ? validation.message!
        : 'Pick at least ${validation.min}. ${validation.count} so far.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          container: true,
          label: 'Interests',
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              for (final Interest interest in interests)
                TouchTarget(
                  onTap: () => onToggle(interest.id),
                  child: CairnToggle(
                    value: selected.contains(interest.id),
                    variant: CairnToggleVariant.outline,
                    semanticLabel: interest.label,
                    onChanged: (bool _) => onToggle(interest.id),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: <Widget>[
                        if (selected.contains(interest.id))
                          const CairnIcon(CairnIconData.check, size: 14),
                        Text(interest.label),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (warn) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: CairnIcon(
                    CairnIconData.alert,
                    size: 16,
                    color: theme.destructive,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  status,
                  style: onboardingText(
                    theme,
                    theme.textStyle(CairnTypography.sm),
                    color: warn ? theme.destructive : theme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
