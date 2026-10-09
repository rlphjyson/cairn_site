import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/confirmation_phrases.dart';
import '../../../core/presentation/settings_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/labeled_field.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../bloc/two_factor_cubit.dart';
import '../view_models/privacy_view_models.dart';

/// The two-factor setup sheet: add the key to an authenticator app, then type
/// the 6-digit code it shows.
///
/// Pops with `true` once the code is verified and the person taps Done. The demo
/// data source accepts the code `123456`.
class TwoFactorSheet extends StatelessWidget {
  /// Creates the sheet.
  const TwoFactorSheet({super.key});

  @override
  Widget build(BuildContext context) => ViewModelBuilder<TwoFactorViewModel>(
    onCreate: (BuildContext context, TwoFactorViewModel vm) =>
        unawaited(vm.cubit.begin()),
    builder: (BuildContext context, TwoFactorViewModel vm) =>
        BlocProvider<TwoFactorCubit>.value(
          value: vm.cubit,
          child: const _Sheet(),
        ),
  );
}

class _Sheet extends StatefulWidget {
  const _Sheet();

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  final TextEditingController _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TwoFactorCubit cubit = context.read<TwoFactorCubit>();
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final double maxContent = MediaQuery.sizeOf(context).height * 0.45;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: BlocBuilder<TwoFactorCubit, TwoFactorState>(
        builder: (BuildContext context, TwoFactorState state) {
          final bool done = state.step == TwoFactorStep.done;
          return CairnDrawer(
            title: Text(
              done
                  ? 'Two-factor authentication is on'
                  : 'Set up two-factor authentication',
            ),
            description: Text(switch (state.step) {
              TwoFactorStep.key =>
                'Step 1 of 2. Add this key to an authenticator app.',
              TwoFactorStep.code =>
                'Step 2 of 2. Enter the code the app shows.',
              TwoFactorStep.done =>
                'You will be asked for a code when you sign in.',
            }),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxContent),
              child: SingleChildScrollView(
                child: switch (state.step) {
                  TwoFactorStep.key => _KeyStep(state: state),
                  TwoFactorStep.code => _CodeStep(
                    state: state,
                    controller: _code,
                    onSubmit: () => unawaited(cubit.verify(_code.text)),
                  ),
                  TwoFactorStep.done => const _DoneStep(),
                },
              ),
            ),
            footer: <Widget>[
              switch (state.step) {
                TwoFactorStep.key => DialogButton(
                  label: 'Next',
                  onPressed: state.setup == null ? null : cubit.next,
                ),
                TwoFactorStep.code => DialogButton(
                  label: state.verifying ? 'Checking...' : 'Verify',
                  busy: state.verifying,
                  onPressed: state.verifying
                      ? null
                      : () => unawaited(cubit.verify(_code.text)),
                ),
                TwoFactorStep.done => DialogButton(
                  label: 'Done',
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              },
              if (!done)
                DialogButton(
                  label: state.step == TwoFactorStep.code ? 'Back' : 'Cancel',
                  variant: CairnButtonVariant.outline,
                  onPressed: state.step == TwoFactorStep.code
                      ? cubit.back
                      : () => Navigator.of(context).pop(false),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _KeyStep extends StatefulWidget {
  const _KeyStep({required this.state});

  final TwoFactorState state;

  @override
  State<_KeyStep> createState() => _KeyStepState();
}

class _KeyStepState extends State<_KeyStep> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final TwoFactorState state = widget.state;
    final CairnTheme theme = CairnTheme.of(context);
    if (state.loading) return const CairnSkeleton(height: 56);
    if (state.setup == null) {
      return CairnAlert(
        variant: CairnAlertVariant.destructive,
        icon: const CairnIcon(CairnIconData.alert),
        title: Text(state.error ?? 'Could not start setup'),
      );
    }
    final String secret = state.setup!.secret;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.muted,
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  label: 'Setup key: ${secret.split('').join(' ')}',
                  excludeSemantics: true,
                  child: Text(
                    secret,
                    style: settingsText(
                      theme,
                      CairnTypography.base,
                      weight: CairnTypography.medium,
                    ).copyWith(letterSpacing: 1.5),
                  ),
                ),
              ),
              CairnButton.icon(
                variant: CairnButtonVariant.ghost,
                size: CairnButtonSize.iconMd,
                semanticLabel: _copied ? 'Setup key copied' : 'Copy setup key',
                icon: Icon(
                  _copied ? Icons.check : Icons.copy_outlined,
                  size: 16,
                ),
                onPressed: () {
                  unawaited(
                    Clipboard.setData(
                      ClipboardData(text: secret.replaceAll(' ', '')),
                    ),
                  );
                  setState(() => _copied = true);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const HelpText(
          'Choose "Enter a setup key" in your authenticator app and paste or '
          'type this key.',
        ),
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.state,
    required this.controller,
    required this.onSubmit,
  });

  final TwoFactorState state;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => LabeledField(
    label: '6-digit code',
    error: state.error,
    description: 'In this demo the code is $demoTwoFactorCode.',
    child: CairnInput(
      controller: controller,
      semanticLabel: '6-digit code',
      placeholder: '123456',
      keyboardType: TextInputType.number,
      hasError: state.error != null,
      maxLength: 6,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      onSubmitted: (_) => onSubmit(),
    ),
  );
}

class _DoneStep extends StatelessWidget {
  const _DoneStep();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      children: <Widget>[
        CairnIcon(CairnIconData.circleCheck, size: 24, color: theme.primary),
        const SizedBox(width: 12),
        const Expanded(
          child: HelpText('Keep your authenticator app. You will need it.'),
        ),
      ],
    );
  }
}
