import 'dart:async';

import 'package:cairn_template_docs/core/infrastructure/di/docs_injection.dart';
import 'package:cairn_template_docs/core/presentation/navigation/docs_navigation_cubit.dart';
import 'package:cairn_template_docs/data/docs/remote/docs_remote_data_source.dart';
import 'package:cairn_template_docs/presentation/docs/bloc/docs_cubit.dart';
import 'package:cairn_template_docs/presentation/docs/bloc/toc_cubit.dart';
import 'package:cairn_template_docs/presentation/docs/view_models/doc_page_view_model.dart';
import 'package:cairn_template_docs/presentation/search/bloc/search_cubit.dart';
import 'package:cairn_template_docs/presentation/sidebar/bloc/sidebar_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FailingRemote implements DocsRemoteDataSource {
  @override
  Future<Map<String, dynamic>> fetchManifest() async =>
      throw StateError('offline');

  @override
  Future<Map<String, dynamic>> fetchSite(String versionId) async =>
      throw StateError('offline');
}

/// The session cubits wired through the real container, with no widgets.
void main() {
  late GetIt locator;

  setUp(
    () => locator = createDocsLocator(
      remote: const InMemoryDocsRemoteDataSource(latency: Duration.zero),
    ),
  );
  tearDown(() => locator.reset());

  test('each container is independent', () {
    final GetIt other = createDocsLocator();
    expect(identical(locator<DocsCubit>(), other<DocsCubit>()), isFalse);
    other.reset();
  });

  test('session cubits are singletons; the page view model is not', () {
    expect(
      identical(locator<DocsNavigationCubit>(), locator<DocsNavigationCubit>()),
      isTrue,
    );
    final DocPageViewModel a = locator<DocPageViewModel>();
    final DocPageViewModel b = locator<DocPageViewModel>();
    expect(identical(a, b), isFalse);
    expect(identical(a.toc, b.toc), isFalse);
    a.dispose();
    expect(a.toc.isClosed, isTrue);
    expect(b.toc.isClosed, isFalse);
    b.dispose();
  });

  group('navigation', () {
    test('starts at the default location', () {
      expect(
        locator<DocsNavigationCubit>().state.location,
        const DocsLocation(),
      );
    });

    test('a deep link sets the heading and a scroll request', () async {
      final GetIt g = createDocsLocator(
        initialLocation: const DocsLocation(
          pageSlug: 'configuration',
          headingId: 'environments',
        ),
      );
      final DocsNavigationState s = g<DocsNavigationCubit>().state;
      expect(s.pageSlug, 'configuration');
      expect(s.headingId, 'environments');
      expect(s.jump, 1);
      await g.reset();
    });

    test('asking for the same heading twice is a new state', () {
      final DocsNavigationCubit nav = locator<DocsNavigationCubit>()
        ..goToHeading('a');
      final int first = nav.state.jump;
      nav.goToHeading('a');
      expect(nav.state.jump, first + 1);
    });

    test('opening a page clears the heading; version keeps the page', () {
      final DocsNavigationCubit nav = locator<DocsNavigationCubit>()
        ..openPage('configuration', headingId: 'environments')
        ..openPage('faq');
      expect(nav.state.headingId, isNull);
      nav.selectVersion('v1.x');
      expect(nav.state.versionId, 'v1.x');
      expect(nav.state.pageSlug, 'faq');
    });

    test('go() ignores the location it is already at', () async {
      final DocsNavigationCubit nav = locator<DocsNavigationCubit>();
      final List<DocsNavigationState> seen = <DocsNavigationState>[];
      final StreamSubscription<DocsNavigationState> sub = nav.stream.listen(
        seen.add,
      );
      nav
        ..go(nav.state.location)
        ..go(const DocsLocation(pageSlug: 'faq'));
      await Future<void>.delayed(Duration.zero);
      expect(seen, hasLength(1));
      await sub.cancel();
    });
  });

  group('docs cubit', () {
    test('loads versions and the requested site', () async {
      final DocsCubit docs = locator<DocsCubit>();
      expect(docs.state.status, DocsStatus.loading);
      await docs.load('v2.0');
      expect(docs.state.status, DocsStatus.ready);
      expect(docs.state.versions, hasLength(2));
      expect(docs.state.site!.versionId, 'v2.0');
      expect(docs.state.version!.isLatest, isTrue);
    });

    test('switching version swaps the site', () async {
      final DocsCubit docs = locator<DocsCubit>();
      await docs.load('v2.0');
      final int v2Pages = docs.state.site!.pages.length;
      await docs.load('v1.x');
      expect(docs.state.site!.versionId, 'v1.x');
      expect(docs.state.site!.pages.length, lessThan(v2Pages));
      await docs.load('v2.0');
      expect(docs.state.status, DocsStatus.ready);
      expect(docs.state.site!.pages.length, v2Pages);
    });

    test('an unknown version fails with a message', () async {
      final DocsCubit docs = locator<DocsCubit>();
      await docs.load('v9');
      expect(docs.state.status, DocsStatus.failure);
      expect(docs.state.error, contains('Unknown version'));
    });

    test('a failing data source is reported', () async {
      final GetIt g = createDocsLocator(remote: _FailingRemote());
      final DocsCubit docs = g<DocsCubit>();
      await docs.load('v2.0');
      expect(docs.state.status, DocsStatus.failure);
      expect(docs.state.error, contains('offline'));
      await g.reset();
    });

    test('an older, slower request never overwrites a newer one', () async {
      final GetIt g = createDocsLocator(
        remote: const InMemoryDocsRemoteDataSource(
          latency: Duration(milliseconds: 5),
        ),
      );
      final DocsCubit docs = g<DocsCubit>();
      final Future<void> first = docs.load('v2.0');
      final Future<void> second = docs.load('v1.x');
      await Future.wait(<Future<void>>[first, second]);
      expect(docs.state.versionId, 'v1.x');
      expect(docs.state.site!.versionId, 'v1.x');
      await g.reset();
    });
  });

  test('search cubit indexes the loaded site', () async {
    final DocsCubit docs = locator<DocsCubit>();
    final SearchCubit search = locator<SearchCubit>();
    expect(search.state.hits, isEmpty);
    await docs.load('v2.0');
    search.index(docs.state.site!);
    expect(search.state.hits, isNotEmpty);
    expect(
      search.search(docs.state.site!, 'authentication').first.pageSlug,
      'authentication',
    );
  });

  test('sidebar cubit collapses and reveals sections', () {
    final SidebarCubit sidebar = locator<SidebarCubit>();
    expect(sidebar.state.isOpen('guides'), isTrue);
    sidebar.toggle('guides');
    expect(sidebar.state.isOpen('guides'), isFalse);
    sidebar.reveal('guides');
    expect(sidebar.state.isOpen('guides'), isTrue);
  });

  test('toc cubit only emits changes', () async {
    final TocCubit toc = TocCubit();
    final List<String?> seen = <String?>[];
    final StreamSubscription<String?> sub = toc.stream.listen(seen.add);
    toc
      ..setActive('a')
      ..setActive('a')
      ..setActive('b');
    await Future<void>.delayed(Duration.zero);
    expect(seen, <String?>['a', 'b']);
    await sub.cancel();
    await toc.close();
  });
}
