import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/account_benefits.dart';
import '../../../core/presentation/widgets/footer_button.dart';
import '../../../core/presentation/widgets/step_layout.dart';
import '../../../domain/flow/models/onboarding_flow.dart';
import '../../../domain/flow/models/onboarding_step.dart';
import '../../../domain/progress/models/account_choice.dart';
import '../../flow/bloc/onboarding_cubit.dart';
import '../../flow/bloc/onboarding_state.dart';
import '../widgets/benefit_list.dart';

/// Create an account, sign in, or carry on as a guest.
///
/// The template builds no sign-in forms. Each choice is recorded and the flow
/// moves to the summary; when the user presses Start, the host receives the
/// choice in `OnboardingResult.accountChoice` and routes to its own auth
/// screens (see the authentication template).
class AccountView extends StatelessWidget {
  /// Creates the view.
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (BuildContext context, OnboardingState state) {
        final OnboardingFlow? flow = state.flow;
        if (flow == null) return const SizedBox.shrink();
        final OnboardingStep? step = flow.step(OnboardingStepKind.account);
        final OnboardingCubit cubit = context.read<OnboardingCubit>();
        void choose(AccountChoice choice) =>
            unawaited(cubit.chooseAccount(choice));
        return StepLayout(
          title: step?.title,
          body: step?.body,
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FooterButton(
                label: 'Create account',
                onPressed: () => choose(AccountChoice.createAccount),
              ),
              const SizedBox(height: 8),
              FooterButton(
                label: 'I already have an account',
                variant: CairnButtonVariant.outline,
                onPressed: () => choose(AccountChoice.signIn),
              ),
              const SizedBox(height: 4),
              FooterButton(
                label: 'Continue as guest',
                variant: CairnButtonVariant.ghost,
                onPressed: () => choose(AccountChoice.guest),
              ),
            ],
          ),
          child: const BenefitList(items: AccountBenefits.values),
        );
      },
    );
  }
}
