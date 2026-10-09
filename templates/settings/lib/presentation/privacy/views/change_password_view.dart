import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/navigation/settings_navigator.dart';
import '../../../core/presentation/settings_appearance.dart';
import '../../../core/presentation/settings_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/labeled_field.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../domain/security/models/password_strength.dart';
import '../../../domain/security/models/password_validation.dart';
import '../bloc/change_password_cubit.dart';
import '../view_models/privacy_view_models.dart';

/// Change password: the current one, a new one with a strength meter, and a
/// confirmation. Errors appear after the first attempt to send.
class ChangePasswordView extends StatelessWidget {
  /// Creates the view.
  const ChangePasswordView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ChangePasswordViewModel>(
        builder: (BuildContext context, ChangePasswordViewModel vm) =>
            BlocProvider<ChangePasswordCubit>.value(
              value: vm.cubit,
              child: NoticeListener<ChangePasswordCubit, ChangePasswordState>(
                pick: (ChangePasswordState s) => s.notice,
                child: BlocListener<ChangePasswordCubit, ChangePasswordState>(
                  listenWhen: (ChangePasswordState a, ChangePasswordState b) =>
                      !a.done && b.done,
                  listener: (BuildContext context, ChangePasswordState _) =>
                      unawaited(
                        context.read<SettingsNavigator>().back(context),
                      ),
                  child: _Form(onBack: onBack),
                ),
              ),
            ),
      );
}

class _Form extends StatefulWidget {
  const _Form({required this.onBack});

  final VoidCallback? onBack;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() => unawaited(
    context.read<ChangePasswordCubit>().submit(
      current: _current.text,
      next: _next.text,
      confirm: _confirm.text,
    ),
  );

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
        builder: (BuildContext context, ChangePasswordState state) {
          final PasswordValidation errors = state.errors;
          return PageFrame(
            title: 'Change password',
            onBack: widget.onBack,
            bottom: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: DialogButton(
                label: state.saving ? 'Changing...' : 'Change password',
                busy: state.saving,
                onPressed: state.saving ? null : _submit,
              ),
            ),
            children: <Widget>[
              LabeledField(
                label: 'Current password',
                error: errors[PasswordField.current],
                child: CairnInput(
                  controller: _current,
                  semanticLabel: 'Current password',
                  obscureText: true,
                  hasError: errors[PasswordField.current] != null,
                  textInputAction: TextInputAction.next,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  LabeledField(
                    label: 'New password',
                    error: errors[PasswordField.next],
                    description:
                        'At least ${PasswordStrength.minLength} characters. '
                        'Mix capitals, numbers and a symbol.',
                    child: CairnInput(
                      controller: _next,
                      semanticLabel: 'New password',
                      obscureText: true,
                      hasError: errors[PasswordField.next] != null,
                      textInputAction: TextInputAction.next,
                      onChanged: context
                          .read<ChangePasswordCubit>()
                          .newPasswordChanged,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StrengthMeter(level: state.strength),
                ],
              ),
              LabeledField(
                label: 'Confirm new password',
                error: errors[PasswordField.confirm],
                child: CairnInput(
                  controller: _confirm,
                  semanticLabel: 'Confirm new password',
                  obscureText: true,
                  hasError: errors[PasswordField.confirm] != null,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          );
        },
      );
}

/// A bar and a word showing how strong the new password is.
class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.level});

  final PasswordStrengthLevel level;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color color = switch (level) {
      PasswordStrengthLevel.empty => theme.mutedForeground,
      PasswordStrengthLevel.weak => theme.destructive,
      PasswordStrengthLevel.fair => theme.mutedForeground,
      PasswordStrengthLevel.good ||
      PasswordStrengthLevel.strong => theme.primary,
    };
    return Semantics(
      liveRegion: true,
      label: level == PasswordStrengthLevel.empty
          ? 'Password strength: nothing typed yet'
          : 'Password strength: ${level.label}',
      excludeSemantics: true,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Theme(
              data: SettingsAppearance.tinted(context, color),
              child: CairnProgress(value: level.score / 4, height: 6),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: Text(
              level.label,
              style: settingsText(
                theme,
                CairnTypography.xs,
                color: theme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
