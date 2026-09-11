import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/components_catalog.dart';
import '../data/docs_catalog.dart';
import '../pages/blocks_page.dart';
import '../pages/charts_page.dart';
import '../pages/component_detail_page.dart';
import '../pages/components_page.dart';
import '../pages/directory_page.dart';
import '../pages/docs_page.dart';
import '../pages/home_page.dart';
import '../pages/not_found_page.dart';
import '../pages/typeset_page.dart';
import '../shell/site_page.dart';
import '../shell/site_shell.dart';
import 'page_title.dart';
import 'routes.dart';

/// Builds the site's router.
///
/// Every section is a real URL, so a link to `/components/switch` or
/// `/docs/theming` can be shared, bookmarked and opened cold. A [ShellRoute]
/// keeps the header mounted across navigations — the theme toggle and the
/// command palette do not rebuild when the page changes — while each route
/// supplies its own scroller through [SitePage].
GoRouter buildRouter({String initialLocation = Routes.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            SiteShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: Routes.home,
            pageBuilder: (BuildContext context, GoRouterState state) =>
                _page(state, 'Cairn UI', const SitePage(child: HomePage())),
          ),
          GoRoute(
            path: Routes.docs,
            redirect: (BuildContext context, GoRouterState state) =>
                Routes.docsIntroduction,
          ),
          GoRoute(
            path: '/docs/:slug',
            pageBuilder: (BuildContext context, GoRouterState state) {
              final String slug = state.pathParameters['slug'] ?? '';
              final DocPage? page = findDoc(slug);
              if (page == null) {
                return _page(
                  state,
                  'Not found',
                  SitePage(child: NotFoundPage(location: state.uri.path)),
                );
              }
              // The docs layout runs its own three scrollers, so it is not
              // wrapped in SitePage; it appends the footer itself.
              return _page(state, page.title, DocsPage(page: page));
            },
          ),
          GoRoute(
            path: Routes.components,
            pageBuilder: (BuildContext context, GoRouterState state) => _page(
              state,
              'Components',
              const SitePage(child: ComponentsPage()),
            ),
          ),
          GoRoute(
            path: '/components/:slug',
            pageBuilder: (BuildContext context, GoRouterState state) {
              final String slug = state.pathParameters['slug'] ?? '';
              final ComponentEntry? entry = findComponent(slug);
              if (entry == null) {
                return _page(
                  state,
                  'Not found',
                  SitePage(child: NotFoundPage(location: state.uri.path)),
                );
              }
              return _page(
                state,
                entry.name,
                SitePage(child: ComponentDetailPage(entry: entry)),
              );
            },
          ),
          GoRoute(
            path: Routes.blocks,
            pageBuilder: (BuildContext context, GoRouterState state) =>
                _page(state, 'Blocks', const SitePage(child: BlocksPage())),
          ),
          GoRoute(
            path: Routes.charts,
            pageBuilder: (BuildContext context, GoRouterState state) =>
                _page(state, 'Charts', const SitePage(child: ChartsPage())),
          ),
          GoRoute(
            path: Routes.directory,
            pageBuilder: (BuildContext context, GoRouterState state) => _page(
              state,
              'Directory',
              const SitePage(child: DirectoryPage()),
            ),
          ),
          GoRoute(
            path: Routes.typeset,
            pageBuilder: (BuildContext context, GoRouterState state) =>
                _page(state, 'Typeset', const SitePage(child: TypesetPage())),
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => SiteShell(
      child: SitePage(child: NotFoundPage(location: state.uri.path)),
    ),
  );
}

/// Wraps a route's body in its browser title and the shared page transition.
///
/// The transition is deliberately small: 16ms of nothing would feel broken, a
/// slide-across would feel like a phone app. A 300ms fade with a 1.2% rise, on
/// Tailwind's `ease-out`, reads as a page settling into place — and the values
/// come from [CairnMotion] rather than being picked by eye.
CustomTransitionPage<void> _page(
  GoRouterState state,
  String title,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: CairnMotion.d300,
    reverseTransitionDuration: CairnMotion.d150,
    child: PageTitle(title: title, child: child),
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final Animation<double> curved = CurvedAnimation(
            parent: animation,
            curve: CairnMotion.easeOut,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.012),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
  );
}
