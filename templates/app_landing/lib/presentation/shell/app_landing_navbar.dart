import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/constants/section_ids.dart';
import '../../core/presentation/app_landing_actions.dart';
import '../../core/presentation/app_landing_icons.dart';
import '../../core/presentation/app_landing_text.dart';
import '../../core/presentation/content_cubit.dart';
import '../../core/presentation/layout.dart';
import '../../core/presentation/navigation/app_landing_navigation_cubit.dart';
import '../../domain/shared/models/link.dart';
import '../../domain/site/models/site_info.dart';

/// The sticky navbar: brand, section links with the active one highlighted,
/// and the call-to-action button. Below [AppLandingLayout.navCollapseWidth] the
/// links move into a menu sheet.
class AppLandingNavbar extends StatelessWidget {
  /// Creates the navbar.
  const AppLandingNavbar({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ContentCubit<SiteInfo>, ContentState<SiteInfo>>(
    builder: (BuildContext context, ContentState<SiteInfo> state) {
      final SiteInfo? site = state.data;
      if (site == null) {
        return const CairnNavbar(height: AppLandingLayout.navHeight);
      }
      return BlocBuilder<AppLandingNavigationCubit, AppLandingNavigationState>(
        buildWhen: (AppLandingNavigationState a, AppLandingNavigationState b) =>
            a.activeId != b.activeId,
        builder: (BuildContext context, AppLandingNavigationState nav) =>
            _NavbarBody(site: site, activeId: nav.activeId),
      );
    },
  );
}

class _NavbarBody extends StatelessWidget {
  const _NavbarBody({required this.site, required this.activeId});

  final SiteInfo site;
  final String activeId;

  bool _isActive(Link link) =>
      link.href.startsWith('#') && link.href.substring(1) == activeId;

  void _openMenu(BuildContext context) {
    final ValueChanged<String> open = AppLandingActions.of(context).open;
    showCairnSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        void go(String href) {
          Navigator.of(sheetContext).pop();
          open(href);
        }

        return CairnSheet(
          title: Text(site.brandName),
          description: Text(site.tagline),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: CairnSpacing.s1,
            children: <Widget>[
              for (final Link link in site.navLinks)
                CairnButton(
                  variant: _isActive(link)
                      ? CairnButtonVariant.secondary
                      : CairnButtonVariant.ghost,
                  expand: true,
                  onPressed: () => go(link.href),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(link.label),
                  ),
                ),
            ],
          ),
          footer: <Widget>[
            CairnButton(
              expand: true,
              onPressed: () => go(site.cta.href),
              child: Text(site.cta.label),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final AppLandingViewport viewport = AppLandingViewport.of(context);
    final ValueChanged<String> open = AppLandingActions.of(context).open;
    final bool collapsed = viewport.collapsesNav;

    final Widget brand = CairnLink(
      onPressed: () => open('#${SectionIds.hero}'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s2p5,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(theme.radiusScale.lg),
            ),
            child: SizedBox.square(
              dimension: 32,
              child: Icon(
                AppLandingIcons.byName(site.brandIcon),
                size: 18,
                color: theme.primaryForeground,
              ),
            ),
          ),
          Text(
            site.brandName,
            style: appLandingText(
              theme,
              CairnTypography.lg,
              weight: CairnTypography.semibold,
              tight: true,
            ).copyWith(decoration: TextDecoration.none),
          ),
        ],
      ),
    );

    return CairnNavbar(
      height: AppLandingLayout.navHeight,
      start: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          brand,
          if (!collapsed) ...<Widget>[
            const SizedBox(width: CairnSpacing.s8),
            for (final Link link in site.navLinks)
              Padding(
                padding: const EdgeInsets.only(right: CairnSpacing.s1),
                child: Semantics(
                  selected: _isActive(link),
                  child: CairnButton(
                    size: CairnButtonSize.sm,
                    variant: _isActive(link)
                        ? CairnButtonVariant.secondary
                        : CairnButtonVariant.ghost,
                    onPressed: () => open(link.href),
                    child: Text(link.label),
                  ),
                ),
              ),
          ],
        ],
      ),
      end: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s2,
        children: <Widget>[
          CairnButton(
            size: CairnButtonSize.sm,
            onPressed: () => open(site.cta.href),
            child: Text(site.cta.label),
          ),
          if (collapsed)
            CairnButton.icon(
              variant: CairnButtonVariant.outline,
              size: CairnButtonSize.iconSm,
              semanticLabel: 'Open menu',
              icon: const Icon(Icons.menu, size: 18),
              onPressed: () => _openMenu(context),
            ),
        ],
      ),
    );
  }
}
