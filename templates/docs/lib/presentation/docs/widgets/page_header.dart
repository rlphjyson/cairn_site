import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/docs_brand.dart';
import '../../../common/utils/dates.dart';
import '../../../core/presentation/docs_text.dart';
import '../../../core/presentation/navigation/docs_navigation_cubit.dart';
import '../../../domain/docs/models/doc_page.dart';
import '../../../domain/docs/models/doc_version.dart';
import '../../../domain/docs/models/docs_site.dart';

/// Breadcrumb, title, description and the last-updated / version badges.
class PageHeader extends StatelessWidget {
  /// Creates the header.
  const PageHeader({
    super.key,
    required this.page,
    required this.site,
    this.version,
  });

  /// The page being shown.
  final DocPage page;

  /// The site the page belongs to (for the breadcrumb's section).
  final DocsSite site;

  /// The version, for its badge, once the version list has loaded.
  final DocVersion? version;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final DocsNavigationCubit nav = context.read<DocsNavigationCubit>();
    final SidebarSection? section = site.sectionOf(page.slug);
    final bool compact = MediaQuery.sizeOf(context).width < 640;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CairnBreadcrumb(
          crumbs: <CairnCrumb>[
            CairnCrumb(
              label: 'Docs',
              onTap: () => nav.openPage(site.firstSlug ?? DocsBrand.homeSlug),
            ),
            if (section != null)
              CairnCrumb(
                label: section.title,
                onTap: section.items.isEmpty
                    ? null
                    : () => nav.openPage(section.items.first.slug),
              ),
            CairnCrumb.current(label: page.title),
          ],
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            page.title,
            style: docsText(
              theme,
              theme.textStyle(
                compact ? CairnTypography.xl3 : CairnTypography.xl4,
              ),
              weight: CairnTypography.bold,
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
        ),
        if (page.description.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            page.description,
            style: docsText(
              theme,
              theme.textStyle(CairnTypography.lg),
              color: theme.mutedForeground,
              height: 1.55,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            CairnBadge(
              variant: CairnBadgeVariant.outline,
              leading: const Icon(Icons.schedule, size: 12),
              label: Text('Updated ${formatDate(page.updated)}'),
            ),
            if (version != null)
              CairnBadge(
                variant: CairnBadgeVariant.secondary,
                label: Text(version!.label),
              ),
          ],
        ),
        const SizedBox(height: 32),
        const CairnSeparator(),
        const SizedBox(height: 40),
      ],
    );
  }
}
