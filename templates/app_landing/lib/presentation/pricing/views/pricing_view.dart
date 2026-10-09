import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/app_landing_actions.dart';
import '../../../core/presentation/app_landing_text.dart';
import '../../../core/presentation/content_cubit.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/equal_height_grid.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/pricing/models/pricing_content.dart';
import '../bloc/pricing_cubit.dart';
import '../view_models/pricing_view_model.dart';
import '../widgets/plan_card.dart';

/// Plans and prices, with a monthly/yearly toggle that re-prices every plan.
class PricingView extends StatelessWidget {
  /// Creates the view.
  const PricingView({super.key});

  @override
  Widget build(BuildContext context) => ViewModelBuilder<PricingViewModel>(
    onCreate: (BuildContext _, PricingViewModel vm) => vm.cubit.load(),
    builder: (BuildContext context, PricingViewModel vm) =>
        BlocBuilder<PricingCubit, PricingState>(
          bloc: vm.cubit,
          builder: (BuildContext context, PricingState state) {
            final PricingContent? content = state.content;
            if (content == null || state.status != ContentStatus.loaded) {
              return const SizedBox(height: 900);
            }
            return _Pricing(content: content, state: state, cubit: vm.cubit);
          },
        ),
  );
}

class _Pricing extends StatelessWidget {
  const _Pricing({
    required this.content,
    required this.state,
    required this.cubit,
  });

  final PricingContent content;
  final PricingState state;
  final PricingCubit cubit;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final AppLandingViewport viewport = AppLandingViewport.of(context);
    final ValueChanged<String> open = AppLandingActions.of(context).open;
    final bool twoUp = viewport.width >= 760;

    return SectionFrame(
      tinted: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Reveal(
            child: SectionHeader(
              eyebrow: content.eyebrow,
              title: content.title,
              subtitle: content.subtitle,
            ),
          ),
          const SizedBox(height: CairnSpacing.s8),
          Reveal(
            delay: const Duration(milliseconds: 60),
            child: _PeriodToggle(content: content, state: state, cubit: cubit),
          ),
          SizedBox(height: viewport.isCompact ? 36 : 56),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: twoUp ? 880 : 520),
              child: EqualHeightGrid(
                columnsFor: (double w) =>
                    twoUp ? content.plans.length.clamp(1, 2) : 1,
                children: <Widget>[
                  for (int i = 0; i < content.plans.length; i++)
                    Reveal(
                      delay: Duration(milliseconds: 80 * i),
                      child: PlanCard(
                        plan: content.plans[i],
                        quote: state.quoteFor(content.plans[i]),
                        currency: content.currency,
                        onSelected: (String href) => open(
                          href.replaceAll('{period}', state.period.name),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: CairnSpacing.s10),
          Reveal(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: CairnSpacing.s1p5,
              children: <Widget>[
                Text(
                  content.compareNote,
                  textAlign: TextAlign.center,
                  style: appLandingText(
                    theme,
                    CairnTypography.sm,
                    color: theme.mutedForeground,
                  ),
                ),
                CairnLink(
                  onPressed: () => open(content.compare.href),
                  child: Text(content.compare.label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.content,
    required this.state,
    required this.cubit,
  });

  final PricingContent content;
  final PricingState state;
  final PricingCubit cubit;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool yearly = state.period == BillingPeriod.yearly;

    Widget label(String text, BillingPeriod period) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => cubit.setPeriod(period),
      child: Text(
        text,
        style: appLandingText(
          theme,
          CairnTypography.sm,
          weight: CairnTypography.medium,
          color: state.period == period
              ? theme.foreground
              : theme.mutedForeground,
        ),
      ),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: CairnSpacing.s3,
      runSpacing: CairnSpacing.s2,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: CairnSpacing.s3,
          children: <Widget>[
            label(content.monthlyLabel, BillingPeriod.monthly),
            CairnSwitch(
              value: yearly,
              semanticLabel: 'Bill ${content.yearlyLabel.toLowerCase()}',
              onChanged: (bool v) => cubit.setPeriod(
                v ? BillingPeriod.yearly : BillingPeriod.monthly,
              ),
            ),
            label(content.yearlyLabel, BillingPeriod.yearly),
          ],
        ),
        if (content.yearlyDiscountPercent > 0)
          CairnBadge(
            variant: CairnBadgeVariant.secondary,
            label: Text('Save ${content.yearlyDiscountPercent}%'),
          ),
      ],
    );
  }
}
