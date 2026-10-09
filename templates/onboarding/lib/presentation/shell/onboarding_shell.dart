import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/presentation/motion.dart';
import '../../core/presentation/navigation/onboarding_navigation_cubit.dart';
import '../../core/presentation/widgets/touch_target.dart';
import '../../domain/flow/models/onboarding_step.dart';
import '../account/views/account_view.dart';
import '../done/views/done_view.dart';
import '../flow/bloc/onboarding_cubit.dart';
import '../flow/bloc/onboarding_state.dart';
import '../permissions/views/permissions_view.dart';
import '../personalise/views/personalise_view.dart';
import '../splash/views/splash_view.dart';
import '../welcome/views/welcome_view.dart';

/// The phone screen: a progress bar with back and skip controls above the
/// current step, which fades and slides in from the side it came from.
class OnboardingShell extends StatelessWidget {
  /// Creates the shell.
  const OnboardingShell({super.key, this.showReplay = false});

  /// Whether the last step offers "Replay from the start".
  final bool showReplay;

  @override
  Widget build(BuildContext context) {
    final OnboardingNavigationState nav = context
        .watch<OnboardingNavigationCubit>()
        .state;
    final OnboardingCubit cubit = context.read<OnboardingCubit>();
    // Watching the session state keeps `canGoBack` current.
    context.watch<OnboardingCubit>();
    final OnboardingStepKind? step = nav.step;
    return PopScope(
      canPop: !cubit.canGoBack,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) cubit.back();
      },
      child: Column(
        children: <Widget>[
          if (step != null) const _TopBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: OnboardingMotion.of(context, CairnMotion.d300),
              switchInCurve: CairnMotion.easeOut,
              switchOutCurve: CairnMotion.easeIn,
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(nav.forward ? 0.06 : -0.06, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
              child: KeyedSubtree(
                key: ValueKey<Object>(step ?? 'splash'),
                child: _body(step),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(OnboardingStepKind? step) => switch (step) {
    null => const SplashView(),
    OnboardingStepKind.welcome => const WelcomeView(),
    OnboardingStepKind.permissions => const PermissionsView(),
    OnboardingStepKind.personalise => const PersonaliseView(),
    OnboardingStepKind.account => const AccountView(),
    OnboardingStepKind.done => DoneView(showReplay: showReplay),
  };
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  static const double _side = 64;

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = context.watch<OnboardingCubit>().state;
    final OnboardingCubit cubit = context.read<OnboardingCubit>();
    final bool canSkip = state.currentStep?.canSkip ?? false;
    final double value = state.fraction.clamp(0.0, 1.0);
    final int total = state.flow?.steps.length ?? 1;
    final int index = (state.flow?.indexOf(state.progress.step) ?? 0) + 1;
    final bool reduced = OnboardingMotion.reduced(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: _side,
            child: Align(
              alignment: Alignment.centerLeft,
              child: cubit.canGoBack
                  ? TouchTarget(
                      onTap: cubit.back,
                      child: CairnButton.icon(
                        variant: CairnButtonVariant.ghost,
                        size: CairnButtonSize.iconLg,
                        semanticLabel: 'Back',
                        icon: const CairnIcon(CairnIconData.chevronLeft),
                        onPressed: cubit.back,
                      ),
                    )
                  : null,
            ),
          ),
          Expanded(
            child: CairnProgress(
              // Without animation the bar jumps: a new key makes it start at
              // its new value instead of tweening there.
              key: reduced ? ValueKey<double>(value) : null,
              value: value,
              height: 6,
              semanticLabel: 'Onboarding progress, step $index of $total',
            ),
          ),
          SizedBox(
            width: _side,
            child: Align(
              alignment: Alignment.centerRight,
              child: canSkip
                  ? TouchTarget(
                      onTap: cubit.skip,
                      child: CairnButton(
                        variant: CairnButtonVariant.ghost,
                        size: CairnButtonSize.sm,
                        semanticLabel: 'Skip this step',
                        onPressed: cubit.skip,
                        child: const Text('Skip'),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
