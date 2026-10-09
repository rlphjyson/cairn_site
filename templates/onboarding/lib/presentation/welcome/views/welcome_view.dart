import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/onboarding_layout.dart';
import '../../../core/presentation/motion.dart';
import '../../../core/presentation/widgets/footer_button.dart';
import '../../../domain/flow/models/onboarding_flow.dart';
import '../../flow/bloc/onboarding_cubit.dart';
import '../../flow/bloc/onboarding_state.dart';
import '../widgets/page_dots.dart';
import '../widgets/value_page_view.dart';

/// The swipeable value pages.
///
/// The session cubit holds the page the user reached (so it is saved and
/// resumed); the [PageController] follows it, and swiping reports back to it.
class WelcomeView extends StatefulWidget {
  /// Creates the view.
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  late final PageController _controller = PageController(
    initialPage: context.read<OnboardingCubit>().state.progress.pageIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _follow(int index) {
    if (!_controller.hasClients) return;
    final int shown = (_controller.page ?? index.toDouble()).round();
    if (shown == index) return;
    if (OnboardingMotion.reduced(context)) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(
        index,
        duration: CairnMotion.d300,
        curve: CairnMotion.standard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (OnboardingState a, OnboardingState b) =>
          a.progress.pageIndex != b.progress.pageIndex,
      listener: (BuildContext context, OnboardingState state) =>
          _follow(state.progress.pageIndex),
      builder: (BuildContext context, OnboardingState state) {
        final OnboardingFlow? flow = state.flow;
        if (flow == null) return const SizedBox.shrink();
        final int index = state.progress.pageIndex;
        final bool last = index >= flow.pages.length - 1;
        final OnboardingCubit cubit = context.read<OnboardingCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: flow.pages.length,
                onPageChanged: (int i) => cubit.setPage(i),
                itemBuilder: (BuildContext context, int i) =>
                    ValuePageView(page: flow.pages[i]),
              ),
            ),
            const SizedBox(height: 12),
            PageDots(count: flow.pages.length, index: index),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OnboardingLayout.gutter,
                8,
                OnboardingLayout.gutter,
                16,
              ),
              child: FooterButton(
                label: last ? 'Get started' : 'Next',
                trailing: last
                    ? null
                    : const CairnIcon(CairnIconData.chevronRight),
                onPressed: () {
                  if (last) {
                    cubit.next();
                  } else {
                    cubit.setPage(index + 1);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
