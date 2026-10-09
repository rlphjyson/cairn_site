import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/content_cubit.dart';
import '../../../core/presentation/landing_actions.dart';
import '../../../core/presentation/landing_icons.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../domain/footer/models/footer_content.dart';
import '../../../domain/shared/models/link.dart';
import '../../../domain/site/models/site_info.dart';

/// The footer: brand and blurb, link columns, social icons and legal links.
class FooterView extends StatelessWidget {
  /// Creates the view.
  const FooterView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<FooterContent>(
    loadingHeight: 420,
    builder: (BuildContext context, FooterContent footer) => _Footer(
      footer: footer,
      site: context.watch<ContentCubit<SiteInfo>>().state.data,
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer({required this.footer, required this.site});

  final FooterContent footer;
  final SiteInfo? site;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final LandingViewport viewport = LandingViewport.of(context);
    final ValueChanged<String> open = LandingActions.of(context).open;
    final bool wide = viewport.isExpanded;

    final Widget brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: CairnSpacing.s2p5,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(theme.radiusScale.md),
              ),
              child: SizedBox.square(
                dimension: 32,
                child: Icon(
                  LandingIcons.byName(site?.brandIcon ?? 'explore'),
                  size: 18,
                  color: theme.primaryForeground,
                ),
              ),
            ),
            Text(
              site?.brandName ?? '',
              style: landingText(
                theme,
                CairnTypography.lg,
                weight: CairnTypography.semibold,
                tight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: CairnSpacing.s4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            footer.description,
            style: landingText(
              theme,
              CairnTypography.sm,
              color: theme.mutedForeground,
              height: 1.6,
            ),
          ),
        ),
      ],
    );

    Widget column(FooterColumn c) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            c.title,
            style: landingText(
              theme,
              CairnTypography.sm,
              weight: CairnTypography.semibold,
            ),
          ),
        ),
        const SizedBox(height: CairnSpacing.s3),
        for (final Link l in c.links)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s1p5),
            child: CairnLink(
              muted: true,
              onPressed: () => open(l.href),
              child: Text(l.label),
            ),
          ),
      ],
    );

    final Widget columns = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final FooterColumn c in footer.columns)
                Expanded(child: column(c)),
            ],
          )
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const double gap = CairnSpacing.s8;
              final double cell = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: CairnSpacing.s8,
                children: <Widget>[
                  for (final FooterColumn c in footer.columns)
                    SizedBox(width: cell, child: column(c)),
                ],
              );
            },
          );

    final Widget social = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: CairnSpacing.s1,
      children: <Widget>[
        for (final SocialLink s in footer.social)
          CairnButton.icon(
            variant: CairnButtonVariant.ghost,
            size: CairnButtonSize.iconSm,
            semanticLabel: s.label,
            icon: Icon(LandingIcons.byName(s.icon), size: 18),
            onPressed: () => open(s.href),
          ),
      ],
    );

    final Widget legalLinks = Wrap(
      spacing: CairnSpacing.s4,
      runSpacing: CairnSpacing.s2,
      children: <Widget>[
        for (final Link l in footer.legal)
          CairnLink(
            muted: true,
            onPressed: () => open(l.href),
            child: Text(l.label),
          ),
      ],
    );
    final Widget copyright = Text(
      footer.copyright,
      style: landingText(
        theme,
        CairnTypography.xs,
        color: theme.mutedForeground,
      ),
    );
    final Widget legal = wide
        ? Row(
            spacing: CairnSpacing.s6,
            children: <Widget>[copyright, legalLinks],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s3,
            children: <Widget>[legalLinks, copyright],
          );

    return SectionFrame(
      tinted: true,
      verticalPadding: viewport.isCompact ? 48 : 72,
      child: Reveal(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 2, child: brand),
                  Expanded(flex: 3, child: columns),
                ],
              )
            else ...<Widget>[
              brand,
              const SizedBox(height: CairnSpacing.s10),
              columns,
            ],
            const SizedBox(height: CairnSpacing.s12),
            const CairnSeparator(),
            const SizedBox(height: CairnSpacing.s6),
            if (wide)
              Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: legal,
                    ),
                  ),
                  social,
                ],
              )
            else ...<Widget>[
              legal,
              const SizedBox(height: CairnSpacing.s4),
              Align(alignment: AlignmentDirectional.centerStart, child: social),
            ],
          ],
        ),
      ),
    );
  }
}
