import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/auth_copy.dart';
import '../../../core/presentation/form_status.dart';
import '../../../core/presentation/navigation/auth_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/auth_button.dart';
import '../../../core/presentation/widgets/auth_link.dart';
import '../../../core/presentation/widgets/auth_scaffold.dart';
import '../../../core/presentation/widgets/error_alert.dart';
import '../../../core/presentation/widgets/password_field.dart';
import '../../../core/presentation/widgets/password_rules.dart';
import '../../../core/presentation/widgets/password_strength_meter.dart';
import '../../../core/presentation/widgets/screen_header.dart';
import '../../../core/presentation/widgets/status_panel.dart';
import '../../../domain/auth/models/auth_failure.dart';
import '../../../domain/validation/models/auth_field.dart';
import '../../../domain/validation/models/validation_issue.dart';
import '../bloc/reset_password_cubit.dart';
import '../view_models/reset_password_view_model.dart';

/// Step three of recovery: choose a new password.
class ResetPasswordView extends StatefulWidget {
  /// Creates the view.
  const ResetPasswordView({
    super.key,
    required this.destination,
    required this.showBack,
  });

  /// The destination this screen was opened with. It carries the reset grant.
  final AuthDestination destination;

  /// Whether to show a back button.
  final bool showBack;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _error(ResetPasswordState state, AuthField field) {
    final ValidationIssue? issue = state.issues[field];
    return issue == null ? null : AuthCopy.issue(issue);
  }

  @override
  Widget build(BuildContext context) {
    final AuthNavigationCubit nav = context.read<AuthNavigationCubit>();

    return ViewModelBuilder<ResetPasswordViewModel>(
      param: widget.destination,
      builder: (BuildContext context, ResetPasswordViewModel vm) =>
          BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
            bloc: vm.cubit,
            listenWhen: (ResetPasswordState a, ResetPasswordState b) =>
                a.status != b.status && b.status == FormStatus.success,
            // The password never outlives the form.
            listener: (BuildContext context, ResetPasswordState state) {
              _password.clear();
              _confirm.clear();
            },
            builder: (BuildContext context, ResetPasswordState state) {
              final bool done = state.status == FormStatus.success;
              final bool busy = state.status == FormStatus.submitting;
              final bool expired = state.failure == AuthFailure.codeExpired;
              return AuthScaffold(
                onBack: widget.showBack && !done ? nav.back : null,
                centered: done,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: CairnMotion.d200,
                    child: KeyedSubtree(
                      key: ValueKey<bool>(done),
                      child: done
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 8,
                              children: <Widget>[
                                const StatusPanel(
                                  icon: Icons.check,
                                  tone: CairnTone.success,
                                  title: AuthCopy.resetDoneTitle,
                                  body: AuthCopy.resetDoneBody,
                                ),
                                const SizedBox(height: 16),
                                AuthButton(
                                  label: AuthCopy.continueToSignIn,
                                  onPressed: () => nav.switchTo(
                                    AuthScreen.signIn,
                                    email: widget.destination.email,
                                    fresh: true,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 16,
                              children: <Widget>[
                                const ScreenHeader(
                                  title: AuthCopy.resetTitle,
                                  subtitle: AuthCopy.resetSubtitle,
                                ),
                                if (state.failure != null)
                                  ErrorAlert(
                                    title: AuthCopy.failureTitle(
                                      state.failure!,
                                    ),
                                    message: AuthCopy.failure(state.failure!),
                                  ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  spacing: 8,
                                  children: <Widget>[
                                    PasswordField(
                                      label: AuthCopy.newPasswordLabel,
                                      controller: _password,
                                      autofocus: true,
                                      enabled: !busy,
                                      error: _error(state, AuthField.password),
                                      onChanged: vm.cubit.passwordChanged,
                                      onFocusLost: (String v) => vm.cubit
                                          .validate(AuthField.password, v),
                                    ),
                                    PasswordStrengthMeter(
                                      assessment: state.assessment,
                                      empty: state.passwordEmpty,
                                    ),
                                    PasswordRules(met: state.assessment.met),
                                  ],
                                ),
                                PasswordField(
                                  label: AuthCopy.confirmLabel,
                                  controller: _confirm,
                                  enabled: !busy,
                                  textInputAction: TextInputAction.done,
                                  error: _error(state, AuthField.confirmation),
                                  onChanged: (_) =>
                                      vm.cubit.edited(AuthField.confirmation),
                                  onFocusLost: (String v) => vm.cubit.validate(
                                    AuthField.confirmation,
                                    v,
                                    password: _password.text,
                                  ),
                                  onSubmitted: (_) => vm.cubit.submit(
                                    password: _password.text,
                                    confirmation: _confirm.text,
                                  ),
                                ),
                                AuthButton(
                                  label: AuthCopy.resetButton,
                                  loadingLabel: AuthCopy.resetting,
                                  loading: busy,
                                  onPressed: () => vm.cubit.submit(
                                    password: _password.text,
                                    confirmation: _confirm.text,
                                  ),
                                ),
                                if (expired)
                                  AuthLink(
                                    label: AuthCopy.startOver,
                                    onPressed: () => nav.switchTo(
                                      AuthScreen.forgotPassword,
                                      email: widget.destination.email,
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
