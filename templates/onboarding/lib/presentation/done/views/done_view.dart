import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/lists.dart';
import '../../../core/presentation/widgets/footer_button.dart';
import '../../../core/presentation/widgets/step_layout.dart';
import '../../../core/presentation/widgets/touch_target.dart';
import '../../../domain/flow/models/onboarding_flow.dart';
import '../../../domain/flow/models/onboarding_step.dart';
import '../../../domain/permissions/models/permission_request.dart';
import '../../../domain/permissions/models/permission_status.dart';
import '../../../domain/personalise/models/interest.dart';
import '../../../domain/progress/models/account_choice.dart';
import '../../../domain/progress/models/onboarding_progress.dart';
import '../../flow/bloc/onboarding_cubit.dart';
import '../../flow/bloc/onboarding_state.dart';
import '../widgets/success_mark.dart';
import '../widgets/summary_card.dart';

/// The calm last screen: what the user chose, and a Start button that hands
/// the result to the host.
class DoneView extends StatelessWidget {
  /// Creates the view.
  const DoneView({super.key, this.showReplay = false});

  /// Whether to offer "Replay from the start", for demos.
  final bool showReplay;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (BuildContext context, OnboardingState state) {
        final OnboardingFlow? flow = state.flow;
        if (flow == null) return const SizedBox.shrink();
        final OnboardingStep? step = flow.step(OnboardingStepKind.done);
        final OnboardingCubit cubit = context.read<OnboardingCubit>();
        final bool finished = state.result != null;
        return StepLayout(
          centered: true,
          leading: const Center(child: SuccessMark()),
          title: step?.title,
          body: step?.body,
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FooterButton(
                label: 'Start',
                onPressed: finished ? null : () => unawaited(cubit.complete()),
              ),
              if (showReplay)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Center(
                    child: TouchTarget(
                      onTap: () => unawaited(cubit.restart()),
                      child: CairnLink(
                        muted: true,
                        onPressed: () => unawaited(cubit.restart()),
                        child: const Text('Replay from the start'),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          child: SummaryCard(entries: _entries(flow, state.progress)),
        );
      },
    );
  }

  List<SummaryEntry> _entries(OnboardingFlow flow, OnboardingProgress p) {
    return <SummaryEntry>[
      if (flow.contains(OnboardingStepKind.personalise)) ...<SummaryEntry>[
        SummaryEntry(
          'Interests',
          joinProse(<String>[
            for (final Interest i in flow.interests)
              if (p.interests.contains(i.id)) i.label,
          ]),
        ),
        if (flow.goal(p.goalId) != null)
          SummaryEntry('Goal', flow.goal(p.goalId)!.label),
        if (flow.reminder(p.reminderId) != null)
          SummaryEntry('Reminders', flow.reminder(p.reminderId)!.label),
      ],
      if (flow.contains(OnboardingStepKind.permissions))
        for (final PermissionRequest r in flow.permissions)
          SummaryEntry(r.title, _status(p.statusOf(r.kind))),
      if (flow.contains(OnboardingStepKind.account))
        SummaryEntry('Account', switch (p.accountChoice ??
            AccountChoice.guest) {
          AccountChoice.createAccount => 'Create an account',
          AccountChoice.signIn => 'Sign in to an existing account',
          AccountChoice.guest => 'Continue as a guest',
        }),
    ];
  }

  String _status(PermissionStatus status) => switch (status) {
    PermissionStatus.granted => 'Allowed',
    PermissionStatus.denied || PermissionStatus.permanentlyDenied =>
      'Not allowed. You can change this in settings.',
    PermissionStatus.notDetermined => 'Not asked yet',
  };
}
