import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../common/constants/onboarding_brand.dart';
import '../../../core/presentation/onboarding_text.dart';
import '../../../core/presentation/widgets/brand_mark.dart';
import '../../../domain/personalise/models/reminder_option.dart';

/// A `CairnSelect` for the reminder time or frequency, with a preview of what
/// a reminder looks like.
class ReminderPicker extends StatelessWidget {
  /// Creates the picker.
  const ReminderPicker({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelect,
  });

  /// Everything on offer.
  final List<ReminderOption> options;

  /// The chosen id.
  final String? selectedId;

  /// Chooses an option.
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Remind me',
          style: onboardingText(
            theme,
            theme.textStyle(CairnTypography.sm),
            weight: CairnTypography.medium,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) =>
              CairnSelect<String>(
                width: box.maxWidth,
                value: selectedId,
                placeholder: 'Choose when',
                semanticLabel: 'Reminder time',
                onChanged: onSelect,
                options: <CairnSelectOption<String>>[
                  for (final ReminderOption o in options)
                    CairnSelectOption<String>(value: o.id, label: o.label),
                ],
              ),
        ),
        const SizedBox(height: 24),
        ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.muted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(theme.radiusScale.xl),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              children: <Widget>[
                const BrandMark(size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        OnboardingBrand.name,
                        style: onboardingText(
                          theme,
                          theme.textStyle(CairnTypography.sm),
                          weight: CairnTypography.semibold,
                        ),
                      ),
                      Text(
                        OnboardingBrand.reminderPreview,
                        style: onboardingText(
                          theme,
                          theme.textStyle(CairnTypography.sm),
                          color: theme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'now',
                  style: onboardingText(
                    theme,
                    theme.textStyle(CairnTypography.xs),
                    color: theme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A preview of a reminder.',
          textAlign: TextAlign.center,
          style: onboardingText(
            theme,
            theme.textStyle(CairnTypography.xs),
            color: theme.mutedForeground,
          ),
        ),
      ],
    );
  }
}
