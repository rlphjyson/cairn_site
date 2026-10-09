import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/auth_policy.dart';
import '../../../core/presentation/auth_copy.dart';
import '../../../core/presentation/auth_scope.dart';
import '../../../core/presentation/auth_text.dart';
import '../../../core/presentation/form_status.dart';
import '../../../core/presentation/navigation/auth_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/auth_button.dart';
import '../../../core/presentation/widgets/auth_link.dart';
import '../../../core/presentation/widgets/auth_scaffold.dart';
import '../../../core/presentation/widgets/error_alert.dart';
import '../../../core/presentation/widgets/screen_header.dart';
import '../../../core/presentation/widgets/touch_target.dart';
import '../../../domain/auth/models/auth_failure.dart';
import '../bloc/verify_code_cubit.dart';
import '../view_models/verify_code_view_model.dart';

/// Step two of recovery: the six-digit code from the email.
///
/// Supports typing, pasting (the keyboard's clipboard suggestion, or the Paste
/// button), automatic submission when the sixth digit lands, a wrong-code
/// message with the attempts left, and a resend link behind a counting-down
/// cooldown.
class VerifyCodeView extends StatefulWidget {
  /// Creates the view.
  const VerifyCodeView({
    super.key,
    required this.destination,
    required this.showBack,
  });

  /// The destination this screen was opened with; its email is where the code
  /// went.
  final AuthDestination destination;

  /// Whether to show a back button.
  final bool showBack;

  @override
  State<VerifyCodeView> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<VerifyCodeView> {
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _code.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _code
      ..removeListener(_rebuild)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _complete => _code.text.length == AuthPolicy.codeLength;

  Future<void> _paste() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String digits = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (!mounted || digits.isEmpty) return;
    _code.text = digits.length > AuthPolicy.codeLength
        ? digits.substring(0, AuthPolicy.codeLength)
        : digits;
    _code.selection = TextSelection.collapsed(offset: _code.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final AuthNavigationCubit nav = context.read<AuthNavigationCubit>();

    return ViewModelBuilder<VerifyCodeViewModel>(
      param: widget.destination,
      builder: (BuildContext context, VerifyCodeViewModel vm) =>
          BlocConsumer<VerifyCodeCubit, VerifyCodeState>(
            bloc: vm.cubit,
            listenWhen: (VerifyCodeState a, VerifyCodeState b) =>
                a.status != b.status ||
                a.failure != b.failure ||
                a.resent != b.resent,
            listener: (BuildContext context, VerifyCodeState state) {
              if (state.status == FormStatus.success) {
                nav.replaceTrailing(
                  const <AuthScreen>{
                    AuthScreen.verifyCode,
                    AuthScreen.forgotPassword,
                  },
                  AuthScreen.resetPassword,
                  email: vm.cubit.email,
                  grant: state.grant,
                );
              } else if (state.status == FormStatus.failure || state.resent) {
                // Start the next attempt from an empty field.
                _code.clear();
                if (!state.locked) _focus.requestFocus();
              }
            },
            builder: (BuildContext context, VerifyCodeState state) {
              final bool busy = state.status == FormStatus.submitting;
              final bool locked = state.locked;
              return AuthScaffold(
                onBack: widget.showBack ? nav.back : null,
                spacing: 16,
                children: <Widget>[
                  ScreenHeader(
                    title: AuthCopy.verifyTitle,
                    subtitle: AuthCopy.verifySubtitle(vm.cubit.email),
                  ),
                  if (state.failure != null)
                    ErrorAlert(
                      title: AuthCopy.failureTitle(state.failure!),
                      message: AuthCopy.failure(
                        state.failure!,
                        attemptsRemaining: state.attemptsRemaining,
                      ),
                    ),
                  Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      excludeFromSemantics: true,
                      onTap: locked ? null : _focus.requestFocus,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: CairnInputOtp(
                          length: AuthPolicy.codeLength,
                          groupSizes: const <int>[3, 3],
                          controller: _code,
                          focusNode: _focus,
                          autofocus: true,
                          enabled: !locked && !busy,
                          hasError:
                              state.failure == AuthFailure.invalidCode ||
                              locked,
                          onChanged: vm.cubit.edited,
                          onCompleted: vm.cubit.submit,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: TouchTarget(
                      onTap: locked || busy ? null : _paste,
                      child: CairnButton(
                        size: CairnButtonSize.sm,
                        variant: CairnButtonVariant.ghost,
                        leading: const Icon(Icons.content_paste),
                        onPressed: locked || busy ? null : _paste,
                        child: const Text(AuthCopy.pasteCode),
                      ),
                    ),
                  ),
                  AuthButton(
                    label: AuthCopy.verifyButton,
                    loadingLabel: AuthCopy.verifying,
                    loading: busy,
                    onPressed: locked || !_complete
                        ? null
                        : () => vm.cubit.submit(_code.text),
                  ),
                  _ResendRow(state: state, onResend: vm.cubit.resend),
                  if (state.resent)
                    Semantics(
                      liveRegion: true,
                      container: true,
                      child: Text(
                        AuthCopy.resent(vm.cubit.email),
                        textAlign: TextAlign.center,
                        style: authText(
                          theme,
                          CairnTypography.xs,
                          color: theme.mutedForeground,
                        ),
                      ),
                    ),
                  if (AuthScope.configOf(context).showDemoHint)
                    Text(
                      AuthCopy.demoCode,
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

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.state, required this.onResend});

  final VerifyCodeState state;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle style = authText(
      theme,
      CairnTypography.sm,
      color: theme.mutedForeground,
    );
    if (state.resending) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: <Widget>[
          CairnSpinner(
            size: 14,
            color: theme.mutedForeground,
            semanticLabel: AuthCopy.resending,
          ),
          Text(AuthCopy.resending, style: style),
        ],
      );
    }
    if (state.resendSeconds > 0) {
      // A plain, finite countdown: no animation, and not a live region, so a
      // screen reader is not interrupted every second.
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        children: <Widget>[
          Text(AuthCopy.resendPrompt, style: style),
          Text(
            AuthCopy.resendIn(AuthCopy.clock(state.resendSeconds)),
            style: style.copyWith(
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: <Widget>[
        Text(AuthCopy.resendPrompt, style: style),
        AuthLink(label: AuthCopy.resend, onPressed: onResend),
      ],
    );
  }
}
