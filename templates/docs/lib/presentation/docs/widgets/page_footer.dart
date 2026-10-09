import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/docs_layout.dart';
import '../../../common/constants/docs_links.dart';
import '../../../core/presentation/docs_host.dart';
import '../../../core/presentation/docs_text.dart';
import '../../../core/presentation/navigation/docs_navigation_cubit.dart';
import '../../../core/presentation/widgets/pressable.dart';
import '../../../domain/docs/models/docs_site.dart';
import '../../../domain/docs/use_cases/get_page_neighbours.dart';

/// "Edit this page" and the previous / next links at the foot of an article.
class PageFooter extends StatelessWidget {
  /// Creates the footer.
  const PageFooter({
    super.key,
    required this.versionId,
    required this.slug,
    required this.neighbours,
  });

  /// The open version, for the edit link.
  final String versionId;

  /// The open page, for the edit link.
  final String slug;

  /// The pages either side.
  final PageNeighbours neighbours;

  @override
  Widget build(BuildContext context) {
    final DocsNavigationCubit nav = context.read<DocsNavigationCubit>();

    Widget card(SidebarItem? item, {required bool isNext}) {
      if (item == null) return const SizedBox.shrink();
      return _PagerCard(
        label: isNext ? 'Next' : 'Previous',
        title: item.title,
        alignEnd: isNext,
        onTap: () => nav.openPage(item.slug),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 64),
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: <Widget>[
            Pressable(
              onTap: () => DocsHost.openExternal(
                context,
                DocsLinks.editUrl(versionId, slug),
              ),
              semanticLabel: 'Edit this page',
              builder: (BuildContext context, bool hovered, bool focused) =>
                  _FooterLink(
                    icon: Icons.edit_outlined,
                    label: 'Edit this page',
                    highlighted: hovered || focused,
                  ),
            ),
            Pressable(
              onTap: () => DocsHost.openExternal(context, DocsLinks.issues),
              semanticLabel: 'Report an issue',
              builder: (BuildContext context, bool hovered, bool focused) =>
                  _FooterLink(
                    icon: Icons.bug_report_outlined,
                    label: 'Report an issue',
                    highlighted: hovered || focused,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const CairnSeparator(),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            final bool stacked = box.maxWidth < DocsLayout.pagerBreakpoint;
            final Widget previous = card(neighbours.previous, isNext: false);
            final Widget next = card(neighbours.next, isNext: true);
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: <Widget>[
                  if (neighbours.next != null) next,
                  if (neighbours.previous != null) previous,
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: <Widget>[
                  Expanded(child: previous),
                  Expanded(child: next),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.icon,
    required this.label,
    required this.highlighted,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color color = highlighted ? theme.foreground : theme.mutedForeground;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          Text(
            label,
            style: docsText(
              theme,
              theme.textStyle(CairnTypography.sm),
              color: color,
              weight: CairnTypography.medium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PagerCard extends StatelessWidget {
  const _PagerCard({
    required this.label,
    required this.title,
    required this.alignEnd,
    required this.onTap,
  });

  final String label;
  final String title;
  final bool alignEnd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: '$label: $title',
      borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      builder: (BuildContext context, bool hovered, bool focused) {
        final Widget chevron = Icon(
          alignEnd ? Icons.arrow_forward : Icons.arrow_back,
          size: 16,
          color: hovered ? theme.foreground : theme.mutedForeground,
        );
        return AnimatedContainer(
          duration: CairnMotion.d150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hovered ? theme.muted.withValues(alpha: 0.6) : theme.card,
            border: Border.all(
              color: hovered ? theme.mutedForeground : theme.border,
            ),
            borderRadius: BorderRadius.circular(theme.radiusScale.lg),
          ),
          child: Column(
            crossAxisAlignment: alignEnd
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                style: docsText(
                  theme,
                  theme.textStyle(CairnTypography.xs),
                  color: theme.mutedForeground,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: <Widget>[
                  if (!alignEnd) chevron,
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: docsText(
                        theme,
                        theme.textStyle(CairnTypography.base),
                        weight: CairnTypography.medium,
                      ),
                    ),
                  ),
                  if (alignEnd) chevron,
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
