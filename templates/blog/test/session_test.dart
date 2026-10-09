import 'package:cairn_template_blog/core/infrastructure/di/blog_injection.dart';
import 'package:cairn_template_blog/core/presentation/navigation/blog_navigation_cubit.dart';
import 'package:cairn_template_blog/data/newsletter/remote/newsletter_remote_data_source.dart';
import 'package:cairn_template_blog/data/posts/remote/posts_remote_data_source.dart';
import 'package:cairn_template_blog/domain/newsletter/models/subscribe_result.dart';
import 'package:cairn_template_blog/presentation/authors/bloc/authors_cubit.dart';
import 'package:cairn_template_blog/presentation/authors/view_models/authors_view_model.dart';
import 'package:cairn_template_blog/presentation/feed/bloc/posts_feed_cubit.dart';
import 'package:cairn_template_blog/presentation/newsletter/bloc/newsletter_cubit.dart';
import 'package:cairn_template_blog/presentation/newsletter/view_models/newsletter_view_model.dart';
import 'package:cairn_template_blog/presentation/post/bloc/post_detail_cubit.dart';
import 'package:cairn_template_blog/presentation/post/view_models/post_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The cubits wired through the real container, with no widgets: the point
/// of the layering is that all of this runs without a UI.
void main() {
  late GetIt locator;

  setUp(
    () => locator = createBlogLocator(
      newsletterDataSource: InMemoryNewsletterRemoteDataSource(
        latency: Duration.zero,
      ),
    ),
  );
  tearDown(() => locator.reset());

  group('container', () {
    test('each container is independent', () {
      final GetIt other = createBlogLocator();
      expect(
        identical(locator<BlogNavigationCubit>(), other<BlogNavigationCubit>()),
        isFalse,
      );
      other.reset();
    });

    test('session cubits are singletons; screen cubits are not', () {
      expect(
        identical(locator<PostsFeedCubit>(), locator<PostsFeedCubit>()),
        isTrue,
      );
      expect(
        identical(
          locator<BlogNavigationCubit>(),
          locator<BlogNavigationCubit>(),
        ),
        isTrue,
      );
      expect(
        identical(
          locator<PostDetailViewModel>().cubit,
          locator<PostDetailViewModel>().cubit,
        ),
        isFalse,
      );
    });

    test('view models close their cubit when disposed', () async {
      final PostDetailViewModel vm = locator<PostDetailViewModel>();
      vm.dispose();
      expect(vm.cubit.isClosed, isTrue);
    });
  });

  group('BlogNavigationCubit', () {
    test('starts at home, remembers where you came from', () {
      final BlogNavigationCubit nav = locator<BlogNavigationCubit>();
      expect(nav.state, const HomeRoute());

      nav.openPost('a');
      nav.openPost('b');
      expect(nav.state, const PostRoute('b'));

      nav.back();
      expect(nav.state, const PostRoute('a'));
      nav.back();
      expect(nav.state, const HomeRoute());
      nav.back();
      expect(nav.state, const HomeRoute(), reason: 'nothing to go back to');
    });

    test('opening the same page twice does not stack it', () {
      final BlogNavigationCubit nav = locator<BlogNavigationCubit>();
      nav.openAbout();
      nav.openAbout();
      nav.back();
      expect(nav.state, const HomeRoute());
    });

    test('openHome forgets the history', () {
      final BlogNavigationCubit nav = locator<BlogNavigationCubit>();
      nav
        ..openPost('a')
        ..openAbout()
        ..openHome()
        ..back();
      expect(nav.state, const HomeRoute());
    });
  });

  group('PostsFeedCubit', () {
    test(
      'loads, features the newest featured post and pages the rest',
      () async {
        final PostsFeedCubit feed = locator<PostsFeedCubit>();
        expect(feed.state.status, FeedStatus.initial);

        await feed.ensureLoaded();
        expect(feed.state.status, FeedStatus.ready);
        expect(feed.state.featured?.id, 'design-tokens-are-a-contract');
        expect(feed.state.showFeatured, isTrue);
        expect(feed.state.page.total, 14);
        expect(feed.state.page.items, hasLength(6));
        expect(feed.state.categories, hasLength(4));
        expect(
          feed.state.page.items.map((p) => p.id),
          isNot(contains('design-tokens-are-a-contract')),
        );
      },
    );

    test('paginates and clamps', () async {
      final PostsFeedCubit feed = locator<PostsFeedCubit>();
      await feed.load();
      feed.goToPage(3);
      expect(feed.state.page.items, hasLength(2));
      expect(feed.state.showFeatured, isFalse, reason: 'only on page 1');
      feed.goToPage(9);
      expect(feed.state.page.page, 3);
    });

    test('a category narrows the list and returns to page 1', () async {
      final PostsFeedCubit feed = locator<PostsFeedCubit>();
      await feed.load();
      feed.goToPage(2);
      feed.selectCategory('Flutter');
      expect(feed.state.query.page, 1);
      expect(feed.state.page.total, 4);
      expect(feed.state.showFeatured, isFalse);
      expect(
        feed.state.page.items.every((p) => p.category == 'Flutter'),
        isTrue,
      );

      feed.selectCategory(null);
      expect(feed.state.page.total, 14);
      expect(feed.state.showFeatured, isTrue);
    });

    test(
      'search matches live, and a filtered list includes the featured',
      () async {
        final PostsFeedCubit feed = locator<PostsFeedCubit>();
        await feed.load();
        feed.search('tokens');
        expect(feed.state.page.total, 2);
        expect(
          feed.state.page.items.map((p) => p.id),
          contains('design-tokens-are-a-contract'),
        );
        feed.search('zzzz');
        expect(feed.state.page.items, isEmpty);

        feed.clearFilters();
        expect(feed.state.query.isFiltered, isFalse);
        expect(feed.state.page.total, 14);
      },
    );

    test('a query set before loading is applied once posts arrive', () async {
      final PostsFeedCubit feed = locator<PostsFeedCubit>();
      feed.search('roadmaps');
      await feed.load();
      expect(feed.state.query.search, 'roadmaps');
      expect(feed.state.page.total, 1);
    });

    test('reports a failing data source and can retry', () async {
      final _FlakyPosts flaky = _FlakyPosts();
      final GetIt g = createBlogLocator(postsDataSource: flaky);
      final PostsFeedCubit feed = g<PostsFeedCubit>();

      await feed.load();
      expect(feed.state.status, FeedStatus.failure);

      flaky.fail = false;
      await feed.ensureLoaded();
      expect(feed.state.status, FeedStatus.ready);
      await g.reset();
    });
  });

  group('PostDetailCubit', () {
    test('loads a post with related posts', () async {
      final PostDetailCubit cubit = locator<PostDetailViewModel>().cubit;
      await cubit.load('dark-mode-without-pain');
      expect(cubit.state.status, PostDetailStatus.ready);
      expect(cubit.state.post?.title, contains('Dark mode'));
      expect(cubit.state.related, hasLength(3));
      expect(
        cubit.state.related.map((p) => p.id),
        isNot(contains('dark-mode-without-pain')),
      );
      await cubit.close();
    });

    test('reports a missing post', () async {
      final PostDetailCubit cubit = locator<PostDetailViewModel>().cubit;
      await cubit.load('missing');
      expect(cubit.state.status, PostDetailStatus.notFound);
      await cubit.close();
    });

    test('reports a failing data source', () async {
      final GetIt g = createBlogLocator(postsDataSource: _FlakyPosts());
      final PostDetailCubit cubit = g<PostDetailViewModel>().cubit;
      await cubit.load('anything');
      expect(cubit.state.status, PostDetailStatus.failure);
      await cubit.close();
      await g.reset();
    });
  });

  group('AuthorsCubit', () {
    test('loads the profiles and totals their posts', () async {
      final AuthorsCubit cubit = locator<AuthorsViewModel>().cubit;
      await cubit.load();
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.profiles, hasLength(4));
      expect(cubit.state.totalPosts, 15);
      await cubit.close();
    });
  });

  group('NewsletterCubit', () {
    test('rejects a bad address without a request', () async {
      final NewsletterCubit cubit = locator<NewsletterViewModel>().cubit;
      await cubit.submit('not an email');
      expect(cubit.state.status, NewsletterStatus.failure);
      expect(cubit.state.hasError, isTrue);

      cubit.edit();
      expect(cubit.state.status, NewsletterStatus.idle);
      expect(cubit.state.hasError, isFalse);
      await cubit.close();
    });

    test('subscribes, then reports a repeat', () async {
      final NewsletterCubit cubit = locator<NewsletterViewModel>().cubit;
      await cubit.submit('reader@example.com');
      expect(cubit.state.status, NewsletterStatus.success);
      expect(cubit.state.result, SubscribeResult.subscribed);

      cubit.reset();
      await cubit.submit('Reader@Example.com');
      expect(cubit.state.result, SubscribeResult.alreadySubscribed);
      await cubit.close();
    });

    test('shows the submitting state while the request is in flight', () async {
      final GetIt g = createBlogLocator(); // 600 ms latency
      final NewsletterCubit cubit = g<NewsletterViewModel>().cubit;
      final List<NewsletterStatus> seen = <NewsletterStatus>[];
      cubit.stream.listen((NewsletterState s) => seen.add(s.status));
      await cubit.submit('slow@example.com');
      await pumpEventQueue();
      expect(seen, <NewsletterStatus>[
        NewsletterStatus.submitting,
        NewsletterStatus.success,
      ]);
      await cubit.close();
      await g.reset();
    });

    test('surfaces a service error', () async {
      final NewsletterCubit cubit = locator<NewsletterViewModel>().cubit;
      await cubit.submit('reader@error.test');
      expect(cubit.state.status, NewsletterStatus.failure);
      expect(cubit.state.error, contains('could not reach'));
      await cubit.close();
    });
  });
}

class _FlakyPosts implements PostsRemoteDataSource {
  bool fail = true;

  @override
  Future<List<Map<String, Object?>>> fetchPosts() async {
    if (fail) throw StateError('offline');
    return const InMemoryPostsRemoteDataSource().fetchPosts();
  }
}
