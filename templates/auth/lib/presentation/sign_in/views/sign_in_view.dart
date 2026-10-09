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
import '../../../core/presentation/widgets/auth_link.dart';
import '../../../core/presentation/widgets/auth_scaffold.dart';
import '../../../core/presentation/widgets/check_row.dart';
import '../../../core/presentation/widgets/error_alert.dart';
import '../../../core/presentation/widgets/labeled_input.dart';
import '../../../core/presentation/widgets/password_field.dart';
import '../../../core/presentation/widgets/prompt_row.dart';
import '../../../core/presentation/widgets/screen_header.dart';
import '../../../domain/validation/models/auth_field.dart';
import '../../../domain/validation/models/validation_issue.dart';
import '../../session/bloc/session_cubit.dart';
import '../bloc/sign_in_cubit.dart';
import '../view_models/sign_in_view_model.dart';

/// Email and password sign-in.
class SignInView extends StatefulWidget {
  /// Creates the view.
  const SignInView({
    super.key,
    required this.destination,
    required this.showBack,
  });

  /// The destination this screen was opened with. Its email prefills the form.
  final AuthDestination destination;

  /// Whether to show a back button.
  final bool showBack;

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  late final TextEditingController _email = TextEditingController(
    text: widget.destination.email,
  );
  final TextEditingController _password = TextEditingController();
  bool _remember = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(SignInCubit cubit) => cubit.submit(
    email: _email.text,
    password: _password.text,
    remember: _remember,
  );

  String? _error(SignInState state, AuthField field) {
    final ValidationIssue? issue = state.issues[field];
    return issue == null ? null : AuthCopy.issue(issue);
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final AuthNavigationCubit nav = context.read<AuthNavigationCubit>();

    return ViewModelBuilder<SignInViewModel>(
      param: widget.destination,
      builder: (BuildContext context, SignInViewModel vm) =>
          BlocConsumer<SignInCubit, SignInState>(
            bloc: vm.cubit,
            listenWhen: (SignInState a, SignInState b) =>
                a.status != b.status && b.status == FormStatus.success,
            listener: (BuildContext context, SignInState state) {
              // The password never outlives the form.
              _password.clear();
              context.read<SessionCubit>().start(state.session!);
            },
            builder: (BuildContext context, SignInState state) {
              final bool busy = state.status == FormStatus.submitting;
              return AuthScaffold(
                onBack: widget.showBack ? nav.back : null,
                spacing: 16,
                children: <Widget>[
                  const ScreenHeader(
                    title: AuthCopy.signInTitle,
                    subtitle: AuthCopy.signInSubtitle,
                  ),
                  if (state.failure != null)
                    ErrorAlert(
                      title: AuthCopy.failureTitle(state.failure!),
                      message: AuthCopy.failure(state.failure!),
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
                  PasswordField(
                    label: AuthCopy.passwordLabel,
                    controller: _password,
                    enabled: !busy,
                    textInputAction: TextInputAction.done,
                    error: _error(state, AuthField.password),
                    onChanged: (_) => vm.cubit.edited(AuthField.password),
                    onSubmitted: (_) => _submit(vm.cubit),
                  ),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: <Widget>[
                      CheckRow(
                        value: _remember,
                        semanticLabel: AuthCopy.rememberMe,
                        onChanged: (bool v) => setState(() => _remember = v),
                        label: ExcludeSemantics(
                          child: Text(
                            AuthCopy.rememberMe,
                            style: authText(theme, CairnTypography.sm),
                          ),
                        ),
                      ),
                      AuthLink(
                        label: AuthCopy.forgotPasswordLink,
                        onPressed: () => nav.push(
                          AuthScreen.forgotPassword,
                          email: _email.text.trim(),
                        ),
                      ),
                    ],
                  ),
                  AuthButton(
                    label: state.locked
                        ? AuthCopy.tryAgainIn(state.lockedSeconds)
                        : AuthCopy.signInButton,
                    loadingLabel: AuthCopy.signingIn,
                    loading: busy,
                    onPressed: state.locked ? null : () => _submit(vm.cubit),
                  ),
                  PromptRow(
                    prompt: AuthCopy.noAccount,
                    linkLabel: AuthCopy.signUpLink,
                    onPressed: busy ? null : () => nav.push(AuthScreen.signUp),
                  ),
                  if (AuthScope.configOf(context).showDemoHint)
                    Text(
                      AuthCopy.demoSignIn,
                      textAlign: TextAlign.center,
                      style: authText(
                        theme,
                        CairnTypography.xs,
                        color: theme.mutedForeground,
                      ),
                    ),
                ],
              );
            },
          ),
    );
  }
}
