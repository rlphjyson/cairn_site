import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/constants/docs_brand.dart';
import '../../common/constants/docs_layout.dart';
import '../../core/presentation/docs_text.dart';
import '../../core/presentation/navigation/docs_navigation_cubit.dart';
import '../../core/presentation/widgets/brand_mark.dart';
import '../../core/presentation/widgets/pressable.dart';
import '../../domain/docs/models/doc_version.dart';
import '../docs/bloc/docs_cubit.dart';
import '../search/widgets/search_palette.dart';
import '../sidebar/bloc/sidebar_cubit.dart';
import '../sidebar/widgets/sidebar_nav.dart';

/// The top bar: menu (on narrow layouts), brand, version selector and search.
class TopBar extends StatelessWidget {
  /// Creates the bar.
  const TopBar({super.key, required this.compact});

  /// Whether the sidebar is a drawer, which adds the menu button.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: SizedBox(
        height: DocsLayout.topBarHeight,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            final bool phone = box.maxWidth < 480;
            final bool showPill = box.maxWidth >= 680;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: phone ? 8 : 16),
              child: Row(
                spacing: phone ? 4 : 12,
                children: <Widget>[
                  if (compact)
                    CairnButton.icon(
                      icon: const Icon(Icons.menu, size: 20),
                      semanticLabel: 'Open navigation menu',
                      variant: CairnButtonVariant.ghost,
                      onPressed: () => _openDrawer(context),
                    ),
                  Padding(
                    padding: EdgeInsets.only(left: compact ? 0 : 8),
                    child: Pressable(
                      onTap: () => context.read<DocsNavigationCubit>().openPage(
                        DocsBrand.homeSlug,
                      ),
                      semanticLabel: '${DocsBrand.name} documentation home',
                      builder:
                          (BuildContext context, bool hovered, bool focused) =>
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: BrandMark(showName: !phone),
                              ),
                    ),
                  ),
                  const _VersionSelect(),
                  const Spacer(),
                  if (showPill)
                    const _SearchPill()
                  else
                    CairnButton.icon(
                      icon: const CairnIcon(CairnIconData.search, size: 18),
                      semanticLabel: 'Search documentation',
                      variant: CairnButtonVariant.ghost,
                      onPressed: () => openSearchPalette(context),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openDrawer(BuildContext context) {
    final DocsNavigationCubit nav = context.read<DocsNavigationCubit>();
    final DocsCubit docs = context.read<DocsCubit>();
    final SidebarCubit sidebar = context.read<SidebarCubit>();
    showCairnSheet<void>(
      context: context,
      side: CairnSheetSide.left,
      builder: (BuildContext sheet) => MultiBlocProvider(
        // The sheet is a route on the root navigator, outside the template's
        // providers, so the cubits it needs are handed in again.
        providers: <BlocProvider<dynamic>>[
          BlocProvider<DocsNavigationCubit>.value(value: nav),
          BlocProvider<DocsCubit>.value(value: docs),
          BlocProvider<SidebarCubit>.value(value: sidebar),
        ],
        child: CairnSheet(
          side: CairnSheetSide.left,
          title: const BrandMark(),
          description: const Text(DocsBrand.tagline),
          content: SidebarNav(
            scrollable: false,
            onNavigate: () => Navigator.of(sheet).maybePop(),
          ),
        ),
      ),
    );
  }
}

class _VersionSelect extends StatelessWidget {
  const _VersionSelect();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocsNavigationCubit, DocsNavigationState>(
      buildWhen: (DocsNavigationState a, DocsNavigationState b) =>
          a.versionId != b.versionId,
      builder: (BuildContext context, DocsNavigationState nav) =>
          BlocBuilder<DocsCubit, DocsState>(
            buildWhen: (DocsState a, DocsState b) => a.versions != b.versions,
            builder: (BuildContext context, DocsState docs) {
              final List<CairnSelectOption<String>> options =
                  <CairnSelectOption<String>>[
                    for (final DocVersion v in docs.versions)
                      CairnSelectOption<String>(
                        value: v.id,
                        label: v.isLatest ? '${v.label} (latest)' : v.label,
                      ),
                  ];
              if (options.every(
                (CairnSelectOption<String> o) => o.value != nav.versionId,
              )) {
                options.add(
                  CairnSelectOption<String>(
                    value: nav.versionId,
                    label: nav.versionId,
                  ),
                );
              }
              return CairnSelect<String>(
                size: CairnSelectSize.sm,
                width: 128,
                semanticLabel: 'Documentation version',
                value: nav.versionId,
                options: options,
                onChanged: context.read<DocsNavigationCubit>().selectVersion,
              );
            },
          ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: 280,
      child: Pressable(
        onTap: () => openSearchPalette(context),
        semanticLabel: 'Search documentation',
        builder: (BuildContext context, bool hovered, bool focused) =>
            AnimatedContainer(
              duration: CairnMotion.d150,
              height: 36,
              padding: const EdgeInsets.only(left: 12, right: 8),
              decoration: BoxDecoration(
                color: hovered
                    ? theme.muted.withValues(alpha: 0.6)
                    : theme.background,
                border: Border.all(color: theme.border),
                borderRadius: BorderRadius.circular(theme.radiusScale.md),
              ),
              child: Row(
                spacing: 8,
                children: <Widget>[
                  CairnIcon(
                    CairnIconData.search,
                    size: 16,
                    color: theme.mutedForeground,
                  ),
                  Expanded(
                    child: Text(
                      'Search docs...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: docsText(
                        theme,
                        theme.textStyle(CairnTypography.sm),
                        color: theme.mutedForeground,
                      ),
                    ),
                  ),
                  CairnKbdGroup(keys: searchShortcutKeys()),
                ],
              ),
            ),
      ),
    );
  }
}
