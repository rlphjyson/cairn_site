import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/auth_copy.dart';
import '../../../core/presentation/auth_scope.dart';
import '../../../core/presentation/form_status.dart';
import '../../../core/presentation/navigation/auth_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/auth_button.dart';
import '../../../core/presentation/widgets/auth_link.dart';
import '../../../core/presentation/widgets/auth_scaffold.dart';
import '../../../core/presentation/widgets/error_alert.dart';
import '../../../core/presentation/widgets/labeled_input.dart';
import '../../../core/presentation/widgets/screen_header.dart';
import '../../../core/presentation/widgets/status_panel.dart';
import '../bloc/forgot_password_cubit.dart';
import '../view_models/forgot_password_view_model.dart';

/// Step one of recovery: ask for a code by email.
///
/// The confirmation is the same whether or not an account exists for the
/// address, so this screen cannot be used to find out who has an account.
class ForgotPasswordView extends StatefulWidget {
  /// Creates the view.
  const ForgotPasswordView({
    super.key,
    required this.destination,
    required this.showBack,
  });

  /// The destination this screen was opened with. Its email prefills the form.
  final AuthDestination destination;

  /// Whether to show a back button.
  final bool showBack;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _email = TextEditingController(
    text: widget.destination.email,
  );

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthNavigationCubit nav = context.read<AuthNavigationCubit>();
    final bool byLink = AuthScope.configOf(context).recoveryByLink;

    return ViewModelBuilder<ForgotPasswordViewModel>(
      param: widget.destination,
      builder: (BuildContext context, ForgotPasswordViewModel vm) =>
          BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
            bloc: vm.cubit,
            builder: (BuildContext context, ForgotPasswordState state) {
              final bool sent = state.status == FormStatus.success;
              final bool busy = state.status == FormStatus.submitting;
              return AuthScaffold(
                onBack: widget.showBack ? nav.back : null,
                centered: sent,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: CairnMotion.d200,
                    child: KeyedSubtree(
                      key: ValueKey<bool>(sent),
                      child: sent
                          ? _Sent(
                              email: state.sentTo ?? '',
                              byLink: byLink,
                              onEnterCode: () => nav.push(
                                AuthScreen.verifyCode,
                                email: state.sentTo,
                              ),
                              onChangeEmail: vm.cubit.reset,
                              onBackToSignIn: () =>
                                  nav.switchTo(AuthScreen.signIn),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 16,
                              children: <Widget>[
                                const ScreenHeader(
                                  title: AuthCopy.forgotTitle,
                                  subtitle: AuthCopy.forgotSubtitle,
                                ),
                                if (state.failure != null)
                                  ErrorAlert(
                                    title: AuthCopy.failureTitle(
                                      state.failure!,
                                    ),
                                    message: AuthCopy.failure(state.failure!),
                                  ),
                                LabeledInput(
                                  label: AuthCopy.emailLabel,
                                  controller: _email,
                                  placeholder: AuthCopy.emailPlaceholder,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  enabled: !busy,
                                  error: state.issue == null
                                      ? null
                                      : AuthCopy.issue(state.issue!),
                                  onChanged: (_) => vm.cubit.edited(),
                                  onFocusLost: vm.cubit.validate,
                                  onSubmitted: vm.cubit.submit,
                                ),
                                AuthButton(
                                  label: AuthCopy.sendCode,
                                  loadingLabel: AuthCopy.sendingCode,
                                  loading: busy,
                                  onPressed: () => vm.cubit.submit(_email.text),
                                ),
                                AuthLink(
                                  label: AuthCopy.backToSignIn,
                                  muted: true,
                                  onPressed: busy
                                      ? null
                                      : () => nav.switchTo(AuthScreen.signIn),
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

class _Sent extends StatelessWidget {
  const _Sent({
    required this.email,
    required this.byLink,
    required this.onEnterCode,
    required this.onChangeEmail,
    required this.onBackToSignIn,
  });

  final String email;
  final bool byLink;
  final VoidCallback onEnterCode;
  final VoidCallback onChangeEmail;
  final VoidCallback onBackToSignIn;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: <Widget>[
      StatusPanel(
        icon: Icons.mark_email_read_outlined,
        title: AuthCopy.checkInboxTitle,
        body: byLink
            ? AuthCopy.checkInboxLinkBody(email)
            : AuthCopy.checkInboxBody(email),
      ),
      const SizedBox(height: 16),
      if (!byLink)
        AuthButton(label: AuthCopy.enterCode, onPressed: onEnterCode),
      AuthLink(label: AuthCopy.useDifferentEmail, onPressed: onChangeEmail),
      AuthLink(
        label: AuthCopy.backToSignIn,
        muted: true,
        onPressed: onBackToSignIn,
      ),
    ],
  );
}
