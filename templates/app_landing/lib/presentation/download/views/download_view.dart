import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/app_landing_image.dart';
import '../../../core/presentation/app_landing_text.dart';
import '../../../core/presentation/content_cubit.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../core/presentation/widgets/store_buttons.dart';
import '../../../domain/download/models/download_content.dart';
import '../../../domain/download/models/send_outcome.dart';
import '../bloc/download_cubit.dart';
import '../view_models/download_view_model.dart';
import '../widgets/download_form.dart';
import '../widgets/qr_card.dart';

/// The closing call to action: a send-me-the-link form (email or phone), a QR
/// card and the two store buttons.
class DownloadView extends StatelessWidget {
  /// Creates the view.
  const DownloadView({super.key});

  /// The photo shown beside the content on desktop.
  static const String photo = 'assets/images/lifestyle-park.jpg';

  @override
  Widget build(BuildContext context) => ViewModelBuilder<DownloadViewModel>(
    onCreate: (BuildContext _, DownloadViewModel vm) => vm.cubit.load(),
    builder: (BuildContext context, DownloadViewModel vm) =>
        BlocConsumer<DownloadCubit, DownloadState>(
          bloc: vm.cubit,
          listenWhen: (DownloadState a, DownloadState b) =>
              a.attempts != b.attempts,
          listener: (BuildContext context, DownloadState state) {
            final DownloadContent? content = state.content;
            if (state.status == DownloadStatus.sent && content != null) {
              final Contact? contact = state.contact;
              CairnToast.show(
                context,
                CairnToast(
                  title: content.successTitle,
                  description: contact == null
                      ? content.successMessage
                      : '${content.successMessage} (${contact.value})',
                  variant: CairnToastVariant.success,
                ),
              );
            } else if (state.status == DownloadStatus.failure) {
              CairnToast.show(
                context,
                CairnToast(
                  title: 'Could not send the link',
                  description: state.message,
                  variant: CairnToastVariant.error,
                ),
              );
            }
          },
          builder: (BuildContext context, DownloadState state) {
            final DownloadContent? content = state.content;
            if (content == null || state.load != ContentStatus.loaded) {
              return const SizedBox(height: 760);
            }
            return _Download(content: content, state: state, cubit: vm.cubit);
          },
        ),
  );
}

class _Download extends StatelessWidget {
  const _Download({
    required this.content,
    required this.state,
    required this.cubit,
  });

  final DownloadContent content;
  final DownloadState state;
  final DownloadCubit cubit;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final AppLandingViewport viewport = AppLandingViewport.of(context);
    final bool compact = viewport.isCompact;
    final bool wide = viewport.isExpanded;
    final CrossAxisAlignment align = wide
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final TextAlign textAlign = wide ? TextAlign.start : TextAlign.center;

    final Widget header = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
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
            textAlign: textAlign,
            style: appLandingText(
              theme,
              CairnTypography.xl4,
              size: compact ? 30 : 40,
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
            textAlign: textAlign,
            style: appLandingText(
              theme,
              compact ? CairnTypography.base : CairnTypography.lg,
              color: theme.mutedForeground,
              height: 1.6,
            ),
          ),
        ),
      ],
    );

    final Widget stores = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s3,
      children: <Widget>[
        Text(
          content.storesHeading,
          style: appLandingText(
            theme,
            CairnTypography.sm,
            color: theme.mutedForeground,
            weight: CairnTypography.medium,
          ),
        ),
        const StoreButtons(alignment: WrapAlignment.start),
      ],
    );

    final Widget form = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl2),
        border: Border.all(color: theme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CairnSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DownloadForm(
              content: content,
              state: state,
              onSubmit: cubit.submit,
              onEdited: cubit.clearError,
              onReset: cubit.reset,
            ),
            const SizedBox(height: CairnSpacing.s5),
            const CairnSeparator(),
            const SizedBox(height: CairnSpacing.s5),
            stores,
          ],
        ),
      ),
    );

    final QrCard qr = QrCard(content: content.qr, pattern: state.qr);

    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: wide ? Alignment.centerLeft : Alignment.center,
          child: header,
        ),
        SizedBox(height: compact ? CairnSpacing.s8 : CairnSpacing.s10),
        if (viewport.width >= 760)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: CairnSpacing.s5,
              children: <Widget>[
                Expanded(flex: 6, child: form),
                Expanded(flex: 4, child: qr),
              ],
            ),
          )
        else ...<Widget>[form, const SizedBox(height: CairnSpacing.s5), qr],
      ],
    );

    return SectionFrame(
      verticalPadding: compact ? 48 : 96,
      child: Reveal(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusScale.xl3),
            border: Border.all(color: theme.border),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[theme.muted.withValues(alpha: 0.8), theme.card],
            ),
            boxShadow: CairnShadows.sm,
          ),
          child: Padding(
            padding: EdgeInsets.all(
              compact
                  ? CairnSpacing.s5
                  : (wide ? CairnSpacing.s12 : CairnSpacing.s10),
            ),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: CairnSpacing.s12,
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: AspectRatio(
                          aspectRatio: 0.78,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              theme.radiusScale.xl2,
                            ),
                            child: const AppLandingPhoto(
                              DownloadView.photo,
                              semanticLabel:
                                  'A woman checking her phone in a sunny park',
                              alignment: Alignment(0, -0.3),
                            ),
                          ),
                        ),
                      ),
                      Expanded(flex: 7, child: body),
                    ],
                  )
                : body,
          ),
        ),
      ),
    );
  }
}
