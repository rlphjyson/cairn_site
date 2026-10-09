import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/widgets/footer_button.dart';
import '../../../core/presentation/widgets/step_layout.dart';
import '../../../domain/flow/models/onboarding_flow.dart';
import '../../../domain/flow/models/onboarding_step.dart';
import '../../../domain/permissions/models/permission_request.dart';
import '../../flow/bloc/onboarding_cubit.dart';
import '../../flow/bloc/onboarding_state.dart';
import '../widgets/permission_card.dart';

/// The permission cards. Allowing is optional: Continue is always available.
class PermissionsView extends StatelessWidget {
  /// Creates the view.
  const PermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (BuildContext context, OnboardingState state) {
        final OnboardingFlow? flow = state.flow;
        if (flow == null) return const SizedBox.shrink();
        final OnboardingStep? step = flow.step(OnboardingStepKind.permissions);
        final OnboardingCubit cubit = context.read<OnboardingCubit>();
        return StepLayout(
          title: step?.title,
          body: step?.body,
          footer: FooterButton(
            label: 'Continue',
            onPressed: () => unawaited(cubit.next()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final PermissionRequest request in flow.permissions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PermissionCard(
                    request: request,
                    status: state.progress.statusOf(request.kind),
                    busy: state.pendingPermission == request.kind,
                    onAllow: () =>
                        unawaited(cubit.requestPermission(request.kind)),
                    onOpenSettings: () => unawaited(cubit.openSettings()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
