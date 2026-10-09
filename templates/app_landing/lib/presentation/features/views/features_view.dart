import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/app_landing_icons.dart';
import '../../../core/presentation/app_landing_text.dart';
import '../../../core/presentation/content_cubit.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/mock/mock_phone.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/features/models/features_content.dart';
import '../bloc/features_cubit.dart';
import '../view_models/features_view_model.dart';

/// The feature showcase: tabs switch the live phone screen beside the copy.
class FeaturesView extends StatelessWidget {
  /// Creates the view.
  const FeaturesView({super.key});

  @override
  Widget build(BuildContext context) => ViewModelBuilder<FeaturesViewModel>(
    onCreate: (BuildContext _, FeaturesViewModel vm) => vm.cubit.load(),
    builder: (BuildContext context, FeaturesViewModel vm) =>
        BlocBuilder<FeaturesCubit, FeaturesState>(
          bloc: vm.cubit,
          builder: (BuildContext context, FeaturesState state) {
            final FeaturesContent? content = state.content;
            final Feature? selected = state.selected;
            if (content == null ||
                selected == null ||
                state.status != ContentStatus.loaded) {
              return const SizedBox(height: 900);
            }
            return _Features(
              content: content,
              selected: selected,
              onSelect: vm.cubit.select,
            );
          },
        ),
  );
}

class _Features extends StatelessWidget {
  const _Features({
    required this.content,
    required this.selected,
    required this.onSelect,
  });

  final FeaturesContent content;
  final Feature selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final AppLandingViewport viewport = AppLandingViewport.of(context);
    final bool wide = viewport.isExpanded;
    final bool compact = viewport.isCompact;

    final Widget tabs = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: CairnTabs<String>(
        value: selected.id,
        onChanged: onSelect,
        tabs: <CairnTab<String>>[
          for (final Feature f in content.items)
            CairnTab<String>(
              value: f.id,
              label: Text(f.tabLabel),
              icon: compact ? null : Icon(AppLandingIcons.byName(f.icon)),
            ),
        ],
      ),
    );

    final Widget copy = AnimatedSwitcher(
      duration: CairnMotion.d200,
      child: _FeatureCopy(
        key: ValueKey<String>('copy-${selected.id}'),
        feature: selected,
        centered: !wide,
      ),
    );

    final double phoneWidth = wide ? 270 : (compact ? 230 : 250);
    final Widget stage = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.muted.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(theme.radiusScale.xl3),
        border: Border.all(color: theme.border),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: compact ? CairnSpacing.s8 : CairnSpacing.s10,
          horizontal: CairnSpacing.s5,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: CairnMotion.d200,
            child: DecoratedBox(
              key: ValueKey<String>('phone-${selected.id}'),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                boxShadow: CairnShadows.lg,
              ),
              child: MockPhone(screen: selected.screen, width: phoneWidth),
            ),
          ),
        ),
      ),
    );

    return SectionFrame(
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
            child: Center(child: tabs),
          ),
          SizedBox(height: compact ? CairnSpacing.s8 : CairnSpacing.s12),
          Reveal(
            delay: const Duration(milliseconds: 100),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: CairnSpacing.s12,
                    children: <Widget>[
                      Expanded(flex: 5, child: copy),
                      Expanded(flex: 6, child: stage),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: CairnSpacing.s8,
                    children: <Widget>[copy, stage],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCopy extends StatelessWidget {
  const _FeatureCopy({
    super.key,
    required this.feature,
    required this.centered,
  });

  final Feature feature;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool compact = AppLandingViewport.of(context).isCompact;
    final CrossAxisAlignment align = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(theme.radiusScale.xl),
            ),
            child: SizedBox.square(
              dimension: 48,
              child: Icon(
                AppLandingIcons.byName(feature.icon),
                size: 24,
                color: theme.primaryForeground,
              ),
            ),
          ),
          const SizedBox(height: CairnSpacing.s5),
          Text(
            feature.title,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: appLandingText(
              theme,
              CairnTypography.xl3,
              size: compact ? 26 : 32,
              weight: CairnTypography.semibold,
              height: 1.2,
              tight: true,
            ),
          ),
          const SizedBox(height: CairnSpacing.s4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              feature.body,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: appLandingText(
                theme,
                CairnTypography.base,
                color: theme.mutedForeground,
                height: 1.65,
              ),
            ),
          ),
          const SizedBox(height: CairnSpacing.s6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CairnSpacing.s3,
              children: <Widget>[
                for (final String bullet in feature.bullets)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: CairnSpacing.s3,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: CairnIcon(
                          CairnIconData.circleCheck,
                          size: 18,
                          color: theme.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          bullet,
                          style: appLandingText(
                            theme,
                            CairnTypography.sm,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
