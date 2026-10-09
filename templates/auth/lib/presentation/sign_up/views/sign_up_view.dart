import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/auth_copy.dart';
import '../../../core/presentation/auth_scope.dart';
import '../../../core/presentation/auth_text.dart';
import '../../../core/presentation/form_status.dart';
import '../../../core/presentation/navigation/auth_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/auth_button.dart';
import '../../../core/presentation/widgets/auth_scaffold.dart';
import '../../../core/presentation/widgets/check_row.dart';
import '../../../core/presentation/widgets/error_alert.dart';
import '../../../core/presentation/widgets/inline_link.dart';
import '../../../core/presentation/widgets/labeled_input.dart';
import '../../../core/presentation/widgets/password_field.dart';
import '../../../core/presentation/widgets/password_rules.dart';
import '../../../core/presentation/widgets/password_strength_meter.dart';
import '../../../core/presentation/widgets/prompt_row.dart';
import '../../../core/presentation/widgets/screen_header.dart';
import '../../../domain/validation/models/auth_field.dart';
import '../../../domain/validation/models/validation_issue.dart';
import '../../session/bloc/session_cubit.dart';
import '../bloc/sign_up_cubit.dart';
import '../view_models/sign_up_view_model.dart';

/// Create an account: name, email, a password with a live strength meter and
/// rules checklist, confirmation and the terms.
class SignUpView extends StatefulWidget {
  /// Creates the view.
  const SignUpView({
    super.key,
    required this.destination,
    required this.showBack,
  });

  /// The destination this screen was opened with.
  final AuthDestination destination;

  /// Whether to show a back button.
  final bool showBack;

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _terms = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit(SignUpCubit cubit) => cubit.submit(
    name: _name.text,
    email: _email.text,
    password: _password.text,
    confirmation: _confirm.text,
    acceptedTerms: _terms,
  );

  String? _error(SignUpState state, AuthField field) {
    final ValidationIssue? issue = state.issues[field];
    return issue == null ? null : AuthCopy.issue(issue);
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final AuthNavigationCubit nav = context.read<AuthNavigationCubit>();
    final void Function(AuthLegalLink)? openLegal = AuthScope.configOf(
      context,
    ).onLegalLink;

    return ViewModelBuilder<SignUpViewModel>(
      param: widget.destination,
      builder: (BuildContext context, SignUpViewModel vm) =>
          BlocConsumer<SignUpCubit, SignUpState>(
            bloc: vm.cubit,
            listenWhen: (SignUpState a, SignUpState b) =>
                a.status != b.status && b.status == FormStatus.success,
            listener: (BuildContext context, SignUpState state) {
              // Passwords never outlive the form.
              _password.clear();
              _confirm.clear();
              context.read<SessionCubit>().start(state.session!);
            },
            builder: (BuildContext context, SignUpState state) {
              final bool busy = state.status == FormStatus.submitting;
              return AuthScaffold(
                onBack: widget.showBack ? nav.back : null,
                spacing: 16,
                children: <Widget>[
                  const ScreenHeader(
                    title: AuthCopy.signUpTitle,
                    subtitle: AuthCopy.signUpSubtitle,
                  ),
                  if (state.failure != null)
                    ErrorAlert(
                      title: AuthCopy.failureTitle(state.failure!),
                      message: AuthCopy.failure(state.failure!),
                    ),
                  LabeledInput(
                    label: AuthCopy.nameLabel,
                    controller: _name,
                    placeholder: AuthCopy.namePlaceholder,
                    keyboardType: TextInputType.name,
                    enabled: !busy,
                    error: _error(state, AuthField.name),
                    onChanged: (_) => vm.cubit.edited(AuthField.name),
                    onFocusLost: (String v) =>
                        vm.cubit.validate(AuthField.name, v),
                  ),
                  LabeledInput(
                    label: AuthCopy.emailLabel,
                    controller: _email,
                    placeholder: AuthCopy.emailPlaceholder,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !busy,
                    error: _error(state, AuthField.email),
                    onChanged: (_) => vm.cubit.edited(AuthField.email),
                    onFocusLost: (String v) =>
                        vm.cubit.validate(AuthField.email, v),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: <Widget>[
                      PasswordField(
                        label: AuthCopy.newPasswordLabel,
                        controller: _password,
                        enabled: !busy,
                        error: _error(state, AuthField.password),
                        onChanged: (String v) {
                          vm.cubit
                            ..passwordChanged(v)
                            ..edited(AuthField.password);
                        },
                        onFocusLost: (String v) =>
                            vm.cubit.validate(AuthField.password, v),
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
                    onChanged: (_) => vm.cubit.edited(AuthField.confirmation),
                    onFocusLost: (String v) => vm.cubit.validate(
                      AuthField.confirmation,
                      v,
                      password: _password.text,
                    ),
                    onSubmitted: (_) => _submit(vm.cubit),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CheckRow(
                        value: _terms,
                        hasError: state.issues.containsKey(AuthField.terms),
                        semanticLabel: AuthCopy.agreeSemantics,
                        onChanged: (bool v) {
                          setState(() => _terms = v);
                          vm.cubit.edited(AuthField.terms);
                        },
                        label: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: <Widget>[
                            ExcludeSemantics(
                              child: Text(
                                AuthCopy.agreeTo,
                                style: authText(theme, CairnTypography.sm),
                              ),
                            ),
                            InlineLink(
                              label: AuthCopy.terms,
                              padding: 2,
                              onPressed: () =>
                                  openLegal?.call(AuthLegalLink.terms),
                            ),
                            ExcludeSemantics(
                              child: Text(
                                AuthCopy.and,
                                style: authText(theme, CairnTypography.sm),
                              ),
                            ),
                            InlineLink(
                              label: AuthCopy.privacy,
                              padding: 2,
                              onPressed: () =>
                                  openLegal?.call(AuthLegalLink.privacy),
                            ),
                          ],
                        ),
                      ),
                      if (state.issues[AuthField.terms] != null)
                        Semantics(
                          liveRegion: true,
                          container: true,
                          child: Text(
                            AuthCopy.issue(state.issues[AuthField.terms]!),
                            style: authText(
                              theme,
                              CairnTypography.xs,
                              color: theme.destructive,
                            ),
                          ),
                        ),
                    ],
                  ),
                  AuthButton(
                    label: AuthCopy.signUpButton,
                    loadingLabel: AuthCopy.signingUp,
                    loading: busy,
                    onPressed: () => _submit(vm.cubit),
                  ),
                  PromptRow(
                    prompt: AuthCopy.haveAccount,
                    linkLabel: AuthCopy.signInLink,
                    onPressed: busy
                        ? null
                        : () => nav.switchTo(AuthScreen.signIn),
                  ),
                ],
              );
            },
          ),
    );
  }
}
