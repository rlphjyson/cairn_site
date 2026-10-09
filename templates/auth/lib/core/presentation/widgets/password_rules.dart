import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/validation/models/password_assessment.dart';
import '../auth_copy.dart';
import '../auth_text.dart';

/// The password rules as a checklist that updates as the password is typed.
class PasswordRules extends StatelessWidget {
  /// Creates the checklist.
  const PasswordRules({super.key, required this.met});

  /// The rules the current password satisfies.
  final Set<PasswordRule> met;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 6,
    children: <Widget>[
      for (final PasswordRule rule in PasswordRule.values)
        _RuleRow(rule: rule, met: met.contains(rule)),
    ],
  );
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule, required this.met});

  final PasswordRule rule;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String text = AuthCopy.rule(rule);
    return Semantics(
      label: '$text, ${met ? AuthCopy.ruleMet : AuthCopy.ruleUnmet}',
      excludeSemantics: true,
      child: Row(
        spacing: 8,
        children: <Widget>[
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: met
                ? CairnToneColors.resolve(theme, CairnTone.success).fill
                : theme.mutedForeground,
          ),
          Expanded(
            child: Text(
              text,
              style: authText(
                theme,
                CairnTypography.xs,
                color: met ? theme.foreground : theme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
