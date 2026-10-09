import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/onboarding_layout.dart';
import '../../../common/constants/personalise_sections.dart';
import '../../../core/presentation/motion.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/footer_button.dart';
import '../../../core/presentation/widgets/step_layout.dart';
import '../../../domain/flow/models/onboarding_flow.dart';
import '../../flow/bloc/onboarding_cubit.dart';
import '../../flow/bloc/onboarding_state.dart';
import '../bloc/personalise_cubit.dart';
import '../bloc/personalise_state.dart';
import '../view_models/personalise_view_model.dart';
import '../widgets/goal_picker.dart';
import '../widgets/interests_picker.dart';
import '../widgets/reminder_picker.dart';

/// Interests, a goal and a reminder, one screenful at a time, with a
/// `CairnSteps` indicator showing where the user is.
///
/// The draft answers live in a screen-scoped [PersonaliseCubit]; every change
/// is copied to the session cubit, which saves it. The part the user is on is
/// kept by the session cubit too, so back (including the system back) and
/// resuming both land on the right part.
class PersonaliseView extends StatelessWidget {
  /// Creates the view.
  const PersonaliseView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PersonaliseViewModel>(
      onCreate: (BuildContext context, PersonaliseViewModel vm) {
        final OnboardingState state = context.read<OnboardingCubit>().state;
        final OnboardingFlow? flow = state.flow;
        if (flow != null) vm.cubit.start(flow, state.progress);
      },
      builder: (BuildContext context, PersonaliseViewModel vm) =>
          BlocProvider<PersonaliseCubit>.value(
            value: vm.cubit,
            child: const _PersonaliseBody(),
          ),
    );
  }
}

class _PersonaliseBody extends StatelessWidget {
  const _PersonaliseBody();

  @override
  Widget build(BuildContext context) {
    final OnboardingFlow? flow = context.select(
      (OnboardingCubit c) => c.state.flow,
    );
    final int section = context.select(
      (OnboardingCubit c) => c.state.progress.section,
    );
    if (flow == null) return const SizedBox.shrink();
    final PersonaliseSection current = PersonaliseSection
        .values[section.clamp(0, PersonaliseSection.values.length - 1)];
    final bool reduced = OnboardingMotion.reduced(context);
    // Three labels do not fit side by side at very large text sizes; the
    // numbered markers and the heading below still say where the user is.
    final bool compact = MediaQuery.textScalerOf(context).scale(14) > 14 * 1.5;
    return BlocListener<PersonaliseCubit, PersonaliseState>(
      // Every change is saved as it is made.
      listener: (BuildContext context, PersonaliseState s) => unawaited(
        context.read<OnboardingCubit>().savePersonalisation(
          interests: s.interests,
          goalId: s.goalId,
          reminderId: s.reminderId,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              OnboardingLayout.gutter,
              12,
              OnboardingLayout.gutter,
              4,
            ),
            child: CairnSteps(
              // Without animation the markers jump to their new state.
              key: reduced ? ValueKey<int>(section) : null,
              current: section,
              steps: <CairnStep>[
                for (final PersonaliseSection s in PersonaliseSection.values)
                  CairnStep(label: compact ? '' : s.label),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: OnboardingMotion.of(context, CairnMotion.d200),
              child: KeyedSubtree(
                key: ValueKey<PersonaliseSection>(current),
                child: _SectionView(section: current, flow: flow),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section, required this.flow});

  final PersonaliseSection section;
  final OnboardingFlow flow;

  @override
  Widget build(BuildContext context) {
    final PersonaliseCubit cubit = context.read<PersonaliseCubit>();
    return BlocBuilder<PersonaliseCubit, PersonaliseState>(
      builder: (BuildContext context, PersonaliseState state) {
        final bool canContinue =
            section != PersonaliseSection.reminders || cubit.canFinish;
        return StepLayout(
          title: section.title,
          body: section.hint,
          footer: FooterButton(
            label: 'Continue',
            onPressed: canContinue
                ? () => unawaited(_continue(context, cubit))
                : null,
          ),
          child: switch (section) {
            PersonaliseSection.interests => InterestsPicker(
              interests: flow.interests,
              selected: state.interests,
              validation: state.validation,
              showError: state.showInterestsError,
              onToggle: cubit.toggleInterest,
            ),
            PersonaliseSection.goal => GoalPicker(
              goals: flow.goals,
              selectedId: state.goalId,
              showError: state.showGoalError,
              onSelect: cubit.selectGoal,
            ),
            PersonaliseSection.reminders => ReminderPicker(
              options: flow.reminders,
              selectedId: state.reminderId,
              onSelect: cubit.selectReminder,
            ),
          },
        );
      },
    );
  }

  Future<void> _continue(BuildContext context, PersonaliseCubit cubit) async {
    if (!cubit.validate(section)) return;
    final OnboardingCubit session = context.read<OnboardingCubit>();
    // Save first, so the progress rules see this screen's answers.
    await session.savePersonalisation(
      interests: cubit.state.interests,
      goalId: cubit.state.goalId,
      reminderId: cubit.state.reminderId,
    );
    await session.next();
  }
}
