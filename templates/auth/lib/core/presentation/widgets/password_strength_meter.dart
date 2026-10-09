import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/validation/models/password_assessment.dart';
import '../auth_copy.dart';
import '../auth_text.dart';

/// The strength bar and its label: Too short, Weak, Fair or Strong.
///
/// The bar is Cairn's [CairnProgress]; a [CairnStatus] dot in the level's tone
/// and the word carry the meaning, so colour is never the only signal. Nothing
/// is shown until something is typed. Changes to the level are announced.
class PasswordStrengthMeter extends StatelessWidget {
  /// Creates a meter.
  const PasswordStrengthMeter({
    super.key,
    required this.assessment,
    required this.empty,
  });

  /// The score to show.
  final PasswordAssessment assessment;

  /// Whether the field is still empty.
  final bool empty;

  CairnTone get _tone => switch (assessment.level) {
    PasswordStrengthLevel.tooShort => CairnTone.destructive,
    PasswordStrengthLevel.weak => CairnTone.destructive,
    PasswordStrengthLevel.fair => CairnTone.warning,
    PasswordStrengthLevel.strong => CairnTone.success,
  };

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String word = empty
        ? AuthCopy.strengthIdle
        : AuthCopy.strength(assessment.level);
    return Semantics(
      liveRegion: !empty,
      label: '${AuthCopy.strengthLabel}: $word',
      excludeSemantics: true,
      child: Row(
        spacing: 12,
        children: <Widget>[
          Expanded(
            child: CairnProgress(
              value: empty ? 0 : assessment.score,
              height: 6,
              semanticLabel: AuthCopy.strengthLabel,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: <Widget>[
              if (!empty) CairnStatus(tone: _tone, size: 8),
              Text(
                word,
                style: authText(
                  theme,
                  CairnTypography.xs,
                  color: empty ? theme.mutedForeground : theme.foreground,
                  weight: CairnTypography.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
