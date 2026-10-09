import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/docs_layout.dart';
import '../../../core/presentation/navigation/docs_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../domain/docs/models/doc_page.dart';
import '../../../domain/docs/models/doc_version.dart';
import '../../../domain/docs/models/docs_site.dart';
import '../bloc/docs_cubit.dart';
import '../view_models/doc_page_view_model.dart';
import '../widgets/block_column.dart';
import '../widgets/page_footer.dart';
import '../widgets/page_header.dart';
import '../widgets/page_states.dart';
import '../widgets/toc_rail.dart';

/// The article area: loading, error, not-found, or the open page.
///
/// [showToc] is decided by the shell from the template's own width (not the
/// window's), so the rail also hides when the template is mounted in a narrow
/// frame.
class DocPageView extends StatelessWidget {
  /// Creates the view.
  const DocPageView({super.key, required this.showToc});

  /// Whether to show the "On this page" rail.
  final bool showToc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocsNavigationCubit, DocsNavigationState>(
      buildWhen: (DocsNavigationState a, DocsNavigationState b) =>
          a.versionId != b.versionId || a.pageSlug != b.pageSlug,
      builder: (BuildContext context, DocsNavigationState nav) =>
          BlocBuilder<DocsCubit, DocsState>(
            builder: (BuildContext context, DocsState docs) {
              if (docs.status == DocsStatus.failure) {
                return PageMessage(
                  icon: errorIcon,
                  title: 'Could not load the documentation',
                  description: docs.error ?? 'Something went wrong.',
                  actions: <Widget>[
                    CairnButton(
                      size: CairnButtonSize.sm,
                      onPressed: () =>
                          context.read<DocsCubit>().load(nav.versionId),
                      child: const Text('Try again'),
                    ),
                  ],
                );
              }
              final DocsSite? site = docs.site;
              if (site == null || site.versionId != nav.versionId) {
                return const PageSkeleton();
              }
              final DocPage? page = site.pageFor(nav.pageSlug);
              if (page == null) {
                return _NotFound(
                  slug: nav.pageSlug,
                  site: site,
                  version: docs.version,
                );
              }
              return _PageScaffold(
                key: ValueKey<String>('${site.versionId}/${page.slug}'),
                page: page,
                site: site,
                version: docs.version,
                latest: docs.versions.where((DocVersion v) => v.isLatest),
                showToc: showToc,
              );
            },
          ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({
    required this.slug,
    required this.site,
    required this.version,
  });

  final String slug;
  final DocsSite site;
  final DocVersion? version;

  @override
  Widget build(BuildContext context) {
    final String? first = site.firstSlug;
    return PageMessage(
      icon: notFoundIcon,
      title: 'Page not found',
      description:
          '"$slug" is not part of the ${version?.label ?? site.versionId} '
          'documentation. It may have been renamed, or it may only exist in '
          'another version.',
      actions: <Widget>[
        if (first != null)
          CairnButton(
            size: CairnButtonSize.sm,
            onPressed: () =>
                context.read<DocsNavigationCubit>().openPage(first),
            child: const Text('Go to the first page'),
          ),
      ],
    );
  }
}

class _PageScaffold extends StatelessWidget {
  const _PageScaffold({
    super.key,
    required this.page,
    required this.site,
    required this.version,
    required this.latest,
    required this.showToc,
  });

  final DocPage page;
  final DocsSite site;
  final DocVersion? version;
  final Iterable<DocVersion> latest;
  final bool showToc;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DocPageViewModel>(
      onCreate: (BuildContext context, DocPageViewModel vm) {
        vm.bind(site, page);
        final String? heading = context
            .read<DocsNavigationCubit>()
            .state
            .headingId;
        if (heading != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => vm.scrollTo(heading, animate: false),
          );
        }
      },
      builder: (BuildContext context, DocPageViewModel vm) =>
          BlocListener<DocsNavigationCubit, DocsNavigationState>(
            listenWhen: (DocsNavigationState a, DocsNavigationState b) =>
                a.jump != b.jump &&
                b.headingId != null &&
                b.pageSlug == page.slug,
            listener: (BuildContext context, DocsNavigationState s) =>
                vm.scrollTo(s.headingId!),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: CairnMotion.d200,
              curve: CairnMotion.easeOut,
              builder: (BuildContext context, double t, Widget? child) =>
                  Opacity(opacity: t, child: child),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: _Article(vm: vm, scaffold: this),
                  ),
                  if (showToc) TocRail(viewModel: vm),
                ],
              ),
            ),
          ),
    );
  }
}

class _Article extends StatelessWidget {
  const _Article({required this.vm, required this.scaffold});

  final DocPageViewModel vm;
  final _PageScaffold scaffold;

  @override
  Widget build(BuildContext context) {
    final DocPage page = scaffold.page;
    final DocVersion? version = scaffold.version;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double gutter = box.maxWidth < 640
            ? 20
            : box.maxWidth < 900
            ? 32
            : 48;
        final double top = box.maxWidth < 640 ? 28 : 40;
        return SingleChildScrollView(
          key: vm.viewportKey,
          controller: vm.scroll,
          padding: EdgeInsets.fromLTRB(gutter, top, gutter, 48),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DocsLayout.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PageHeader(page: page, site: scaffold.site, version: version),
                  if (version?.notice != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: _VersionNotice(
                        version: version!,
                        latest: scaffold.latest.firstOrNull,
                      ),
                    ),
                  BlockColumn(blocks: page.blocks, keyFor: vm.keyFor),
                  PageFooter(
                    versionId: scaffold.site.versionId,
                    slug: page.slug,
                    neighbours: vm.neighbours,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VersionNotice extends StatelessWidget {
  const _VersionNotice({required this.version, required this.latest});

  final DocVersion version;
  final DocVersion? latest;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnAlert(
      icon: Icon(Icons.history, size: 16, color: theme.foreground),
      title: Text('You are reading ${version.label}'),
      description: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          Text(version.notice!),
          if (latest != null)
            CairnButton(
              size: CairnButtonSize.sm,
              variant: CairnButtonVariant.outline,
              onPressed: () =>
                  context.read<DocsNavigationCubit>().selectVersion(latest!.id),
              child: Text('Switch to ${latest!.label}'),
            ),
        ],
      ),
    );
  }
}
