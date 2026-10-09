import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/content_cubit.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../domain/waitlist/models/waitlist_content.dart';
import '../bloc/waitlist_cubit.dart';
import '../view_models/waitlist_view_model.dart';
import '../widgets/waitlist_form.dart';

/// The closing call to action: an email field that joins the waitlist, with
/// validation, a submitting state, a success panel and a toast.
class WaitlistView extends StatelessWidget {
  /// Creates the view.
  const WaitlistView({super.key});

  @override
  Widget build(BuildContext context) => ViewModelBuilder<WaitlistViewModel>(
    onCreate: (BuildContext _, WaitlistViewModel vm) => vm.cubit.load(),
    builder: (BuildContext context, WaitlistViewModel vm) =>
        BlocConsumer<WaitlistCubit, WaitlistState>(
          bloc: vm.cubit,
          listenWhen: (WaitlistState a, WaitlistState b) =>
              a.submissions != b.submissions,
          listener: (BuildContext context, WaitlistState state) {
            final WaitlistContent? content = state.content;
            if (state.status == WaitlistStatus.success && content != null) {
              CairnToast.show(
                context,
                CairnToast(
                  title: content.successTitle,
                  description: content.successMessage,
                  variant: CairnToastVariant.success,
                ),
              );
            } else if (state.status == WaitlistStatus.failure) {
              CairnToast.show(
                context,
                CairnToast(
                  title: 'Could not join the waitlist',
                  description: state.message,
                  variant: CairnToastVariant.error,
                ),
              );
            }
          },
          builder: (BuildContext context, WaitlistState state) {
            final WaitlistContent? content = state.content;
            if (content == null || state.load != ContentStatus.loaded) {
              return const SizedBox(height: 520);
            }
            return _Waitlist(content: content, state: state, cubit: vm.cubit);
          },
        ),
  );
}

class _Waitlist extends StatelessWidget {
  const _Waitlist({
    required this.content,
    required this.state,
    required this.cubit,
  });

  final WaitlistContent content;
  final WaitlistState state;
  final WaitlistCubit cubit;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool compact = LandingViewport.of(context).isCompact;

    return SectionFrame(
      verticalPadding: compact ? 48 : 96,
      child: Reveal(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusScale.xl3),
            border: Border.all(color: theme.border),
            color: theme.card,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[theme.muted.withValues(alpha: 0.8), theme.card],
            ),
            boxShadow: CairnShadows.sm,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? CairnSpacing.s5 : CairnSpacing.s16,
              vertical: compact ? CairnSpacing.s10 : CairnSpacing.s20,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CairnBadge(
                    variant: CairnBadgeVariant.outline,
                    label: Text(content.eyebrow),
                  ),
                  const SizedBox(height: CairnSpacing.s4),
                  Semantics(
                    header: true,
                    child: Text(
                      content.title,
                      textAlign: TextAlign.center,
                      style: landingText(
                        theme,
                        CairnTypography.xl4,
                        size: compact ? 30 : 44,
                        height: 1.12,
                        weight: CairnTypography.semibold,
                        tight: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: CairnSpacing.s4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(
                      content.subtitle,
                      textAlign: TextAlign.center,
                      style: landingText(
                        theme,
                        compact ? CairnTypography.base : CairnTypography.lg,
                        color: theme.mutedForeground,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: CairnSpacing.s8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: WaitlistForm(
                      content: content,
                      state: state,
                      onSubmit: cubit.submit,
                      onEdited: cubit.clearError,
                      onReset: cubit.reset,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
