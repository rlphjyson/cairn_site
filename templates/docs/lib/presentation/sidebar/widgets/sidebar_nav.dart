import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/docs_text.dart';
import '../../../core/presentation/navigation/docs_navigation_cubit.dart';
import '../../../core/presentation/widgets/pressable.dart';
import '../../../domain/docs/models/docs_site.dart';
import '../../docs/bloc/docs_cubit.dart';
import '../bloc/sidebar_cubit.dart';

/// The page tree: collapsible sections of pages, the open page highlighted.
///
/// Used by the desktop sidebar (where it scrolls itself) and by the mobile
/// drawer (where the sheet scrolls it, so [scrollable] is false). [onNavigate]
/// runs after a page is chosen; the drawer uses it to close itself.
class SidebarNav extends StatelessWidget {
  /// Creates the navigation.
  const SidebarNav({super.key, this.scrollable = true, this.onNavigate});

  /// Whether the list scrolls on its own.
  final bool scrollable;

  /// Called after the reader picks a page.
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocsNavigationCubit, DocsNavigationState>(
      listenWhen: (DocsNavigationState a, DocsNavigationState b) =>
          a.pageSlug != b.pageSlug,
      listener: (BuildContext context, DocsNavigationState nav) {
        // Navigating into a collapsed section (a link, the palette) opens it.
        final DocsSite? site = context.read<DocsCubit>().state.site;
        final SidebarSection? section = site?.sectionOf(nav.pageSlug);
        if (section != null) context.read<SidebarCubit>().reveal(section.id);
      },
      child: BlocBuilder<DocsCubit, DocsState>(
        builder: (BuildContext context, DocsState docs) {
          final DocsSite? site = docs.site;
          final Widget body = site == null
              ? const _SidebarSkeleton()
              : BlocBuilder<DocsNavigationCubit, DocsNavigationState>(
                  buildWhen: (DocsNavigationState a, DocsNavigationState b) =>
                      a.pageSlug != b.pageSlug,
                  builder: (BuildContext context, DocsNavigationState nav) =>
                      BlocBuilder<SidebarCubit, SidebarState>(
                        builder: (BuildContext context, SidebarState sidebar) =>
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 8,
                              children: <Widget>[
                                for (final SidebarSection s in site.sidebar)
                                  _Section(
                                    section: s,
                                    open: sidebar.isOpen(s.id),
                                    activeSlug: nav.pageSlug,
                                    onNavigate: onNavigate,
                                  ),
                              ],
                            ),
                      ),
                );
          return Semantics(
            container: true,
            label: 'Documentation navigation',
            child: scrollable
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                    child: body,
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: body,
                  ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.section,
    required this.open,
    required this.activeSlug,
    required this.onNavigate,
  });

  final SidebarSection section;
  final bool open;
  final String activeSlug;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Pressable(
          onTap: () => context.read<SidebarCubit>().toggle(section.id),
          semanticLabel: '${section.title}, ${open ? 'expanded' : 'collapsed'}',
          builder: (BuildContext context, bool hovered, bool focused) =>
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        section.title,
                        style: docsText(
                          theme,
                          theme.textStyle(CairnTypography.sm),
                          weight: CairnTypography.semibold,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: open ? 0 : -0.25,
                      duration: CairnMotion.d150,
                      child: CairnIcon(
                        CairnIconData.chevronDown,
                        size: 14,
                        color: hovered || focused
                            ? theme.foreground
                            : theme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: CairnMotion.d150,
            curve: CairnMotion.standard,
            alignment: Alignment.topCenter,
            child: open
                ? Container(
                    margin: const EdgeInsets.only(left: 12, top: 2),
                    padding: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: theme.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 2,
                      children: <Widget>[
                        for (final SidebarItem item in section.items)
                          _Item(
                            item: item,
                            active: item.slug == activeSlug,
                            onNavigate: onNavigate,
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.item,
    required this.active,
    required this.onNavigate,
  });

  final SidebarItem item;
  final bool active;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Pressable(
      selected: active,
      semanticLabel: item.title,
      onTap: () {
        context.read<DocsNavigationCubit>().openPage(item.slug);
        onNavigate?.call();
      },
      builder: (BuildContext context, bool hovered, bool focused) =>
          AnimatedContainer(
            duration: CairnMotion.d100,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: active
                  ? theme.accent
                  : hovered
                  ? theme.muted.withValues(alpha: 0.6)
                  : const Color(0x00000000),
              borderRadius: BorderRadius.circular(theme.radiusScale.md),
            ),
            child: Text(
              item.title,
              style: docsText(
                theme,
                theme.textStyle(CairnTypography.sm),
                color: active
                    ? theme.accentForeground
                    : hovered
                    ? theme.foreground
                    : theme.mutedForeground,
                weight: active ? CairnTypography.medium : null,
              ),
            ),
          ),
    );
  }
}

class _SidebarSkeleton extends StatelessWidget {
  const _SidebarSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: <Widget>[
        CairnSkeleton(width: 96, height: 14),
        CairnSkeleton(height: 12),
        CairnSkeleton(width: 140, height: 12),
        CairnSkeleton(height: 12),
        SizedBox(height: 8),
        CairnSkeleton(width: 72, height: 14),
        CairnSkeleton(width: 150, height: 12),
        CairnSkeleton(height: 12),
      ],
    );
  }
}
