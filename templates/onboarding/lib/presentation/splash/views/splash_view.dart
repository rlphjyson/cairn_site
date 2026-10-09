import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/onboarding_brand.dart';
import '../../../common/constants/onboarding_layout.dart';
import '../../../core/presentation/motion.dart';
import '../../../core/presentation/onboarding_text.dart';
import '../../../core/presentation/widgets/brand_mark.dart';
import '../../../core/presentation/widgets/footer_button.dart';
import '../../flow/bloc/onboarding_cubit.dart';
import '../../flow/bloc/onboarding_state.dart';

/// The splash screen: the brand mark fades in once, holds for a moment, and
/// the flow moves on as soon as its content has loaded.
///
/// Nothing here repeats. With reduced motion there is no fade and a shorter
/// hold. If the content fails to load, a retry is offered.
class SplashView extends StatefulWidget {
  /// Creates the view.
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  static const Duration _hold = Duration(milliseconds: 1400);
  static const Duration _holdReduced = Duration(milliseconds: 400);

  Timer? _timer;
  bool _held = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer ??= Timer(
      OnboardingMotion.reduced(context) ? _holdReduced : _hold,
      () {
        _held = true;
        _continue();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _continue() {
    if (!mounted || !_held) return;
    context.read<OnboardingCubit>().begin();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (OnboardingState a, OnboardingState b) =>
          a.status != b.status,
      listener: (BuildContext context, OnboardingState state) => _continue(),
      builder: (BuildContext context, OnboardingState state) {
        final bool failed = state.status == OnboardingStatus.failure;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OnboardingLayout.gutter,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: OnboardingMotion.of(context, CairnMotion.d500),
                    curve: CairnMotion.easeOut,
                    builder: (BuildContext context, double t, Widget? child) =>
                        Opacity(opacity: t, child: child),
                    child: Semantics(
                      container: true,
                      label:
                          '${OnboardingBrand.name}. ${OnboardingBrand.tagline}',
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const BrandMark(),
                            const SizedBox(height: 24),
                            Text(
                              OnboardingBrand.name,
                              style: onboardingText(
                                theme,
                                theme.textStyle(CairnTypography.xl3),
                                weight: CairnTypography.semibold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              OnboardingBrand.tagline,
                              textAlign: TextAlign.center,
                              style: onboardingText(
                                theme,
                                theme.textStyle(CairnTypography.base),
                                color: theme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (failed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const CairnAlert(
                        variant: CairnAlertVariant.destructive,
                        icon: CairnIcon(CairnIconData.alert),
                        title: Text('We could not load the welcome'),
                        description: Text('Check your connection and retry.'),
                      ),
                      const SizedBox(height: 12),
                      FooterButton(
                        label: 'Try again',
                        onPressed: () =>
                            unawaited(context.read<OnboardingCubit>().load()),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 64),
            ],
          ),
        );
      },
    );
  }
}
