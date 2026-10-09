import 'package:cairn_template_blog/cairn_template_blog.dart';
import 'package:cairn_template_blog/data/newsletter/remote/newsletter_remote_data_source.dart';
import 'package:cairn_template_blog/data/posts/remote/posts_remote_data_source.dart';
import 'package:cairn_template_blog/presentation/shell/blog_footer.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The three widths the template is designed for.
const List<(String, Size)> _sizes = <(String, Size)>[
  ('phone 390', Size(390, 844)),
  ('tablet 768', Size(768, 1024)),
  ('desktop 1280', Size(1280, 900)),
];

Future<void> _mount(
  WidgetTester tester,
  Size size, {
  bool dark = false,
  PostsRemoteDataSource? posts,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CairnTheme.materialTheme(
        (dark ? CairnTheme.dark : CairnTheme.light).copyWith(
          fontFamily: 'Geist',
        ),
      ),
      home: BlogApp(
        postsDataSource: posts,
        newsletterDataSource: InMemoryNewsletterRemoteDataSource(
          latency: const Duration(milliseconds: 200),
        ),
      ),
    ),
  );
  await _settle(tester);
}

/// Pumps in small steps: a single long pump jumps the clock but leaves an
/// AnimatedSwitcher's outgoing child mounted until the next frame.
Future<void> _settle(WidgetTester tester, [int steps = 10]) async {
  for (int i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder _button(String label) => find.widgetWithText(CairnButton, label);

Finder _buttonLabelled(String label) => find.byWidgetPredicate(
  (Widget w) => w is CairnButton && w.semanticLabel == label,
);

Finder _input(String label) => find.byWidgetPredicate(
  (Widget w) => w is CairnInput && w.semanticLabel == label,
);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await _settle(tester, 2);
  await tester.tap(finder);
  await _settle(tester);
}

/// Types into the navbar search, opening it first on narrow widths.
Future<void> _search(WidgetTester tester, String text) async {
  if (_input('Search posts').evaluate().isEmpty) {
    await tester.tap(_buttonLabelled('Search posts'));
    await _settle(tester);
  }
  await tester.enterText(
    find.descendant(
      of: _input('Search posts'),
      matching: find.byType(EditableText),
    ),
    text,
  );
  await _settle(tester);
}

/// Fails with the full report (including the widget that overflowed) if the
/// framework caught anything.
void _expectClean(WidgetTester tester) {
  final Object? error = tester.takeException();
  if (error == null) return;
  final String detail = error is FlutterError
      ? error.toStringDeep()
      : error.toString();
  fail(detail.length > 1800 ? detail.substring(0, 1800) : detail);
}

class _SlowPosts implements PostsRemoteDataSource {
  @override
  Future<List<Map<String, Object?>>> fetchPosts() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const InMemoryPostsRemoteDataSource().fetchPosts();
  }
}

class _FailingPosts implements PostsRemoteDataSource {
  @override
  Future<List<Map<String, Object?>>> fetchPosts() =>
      Future<List<Map<String, Object?>>>.error(StateError('offline'));
}

void main() {
  for (final (String name, Size size) in _sizes) {
    group(name, () {
      testWidgets('renders the home page without overflow', (
        WidgetTester tester,
      ) async {
        await _mount(tester, size);
        expect(
          find.text('Notes on building interfaces that last'),
          findsOneWidget,
        );
        expect(
          find.text('Design tokens are a contract, not a colour palette'),
          findsOneWidget,
        );
        expect(find.text('Latest posts'), findsOneWidget);
        expect(find.byType(CairnPagination), findsOneWidget);
        _expectClean(tester);
      });

      testWidgets('searches, shows results and clears', (
        WidgetTester tester,
      ) async {
        await _mount(tester, size);
        await _search(tester, 'tokens');

        expect(find.text('Results for “tokens”'), findsOneWidget);
        expect(find.text('2 posts'), findsOneWidget);
        expect(find.text('Dark mode without the pain'), findsOneWidget);
        expect(
          find.text('Flutter state management without the drama'),
          findsNothing,
        );
        expect(find.byType(CairnPagination), findsNothing);

        await _search(tester, 'zzzz');
        expect(find.text('No posts match your search'), findsOneWidget);

        await _tap(tester, _button('Clear filters'));
        expect(find.text('Latest posts'), findsOneWidget);
        expect(find.text('No posts match your search'), findsNothing);
        _expectClean(tester);
      });

      testWidgets('filters by category', (WidgetTester tester) async {
        await _mount(tester, size);
        await _tap(tester, _button('Product'));

        expect(find.text('Roadmaps are bets, not promises'), findsOneWidget);
        expect(
          find.text('Flutter state management without the drama'),
          findsNothing,
        );
        expect(find.text('3 posts'), findsOneWidget);
        // The featured hero gives way to the filtered list.
        expect(find.text('Featured'), findsNothing);

        await _tap(tester, _button('All'));
        expect(find.text('Featured'), findsOneWidget);
        _expectClean(tester);
      });

      testWidgets('paginates', (WidgetTester tester) async {
        await _mount(tester, size);
        expect(
          find.text('Flutter state management without the drama'),
          findsOneWidget,
        );

        await _tap(
          tester,
          find.descendant(
            of: find.byType(CairnPagination),
            matching: find.text('2'),
          ),
        );
        expect(
          find.text('Flutter state management without the drama'),
          findsNothing,
        );
        expect(find.text('Featured'), findsNothing);
        expect(find.text('Dark mode without the pain'), findsOneWidget);

        await _tap(
          tester,
          find.descendant(
            of: find.byType(CairnPagination),
            matching: find.text('3'),
          ),
        );
        expect(
          find.text('The quiet value of writing things down'),
          findsOneWidget,
        );
        _expectClean(tester);
      });

      testWidgets('opens a post, copies its link and goes back', (
        WidgetTester tester,
      ) async {
        await _mount(tester, size);
        await _tap(
          tester,
          find.text(
            'Writing product requirement docs that people actually read',
          ),
        );

        // The article page: breadcrumb, body, author card, related posts.
        expect(find.byType(CairnBreadcrumb), findsOneWidget);
        expect(
          find.text('Start with the problem, in one paragraph'),
          findsOneWidget,
        );
        expect(find.text('WRITTEN BY'), findsOneWidget);
        expect(find.text('Related posts'), findsOneWidget);
        expect(find.text('Priya Nair'), findsWidgets);
        expect(find.text('#writing'), findsOneWidget);

        await _tap(tester, _buttonLabelled('Copy link to this article'));
        expect(find.text('Link copied'), findsOneWidget);

        await _tap(tester, _button('Back to blog'));
        expect(find.text('Latest posts'), findsOneWidget);
        expect(find.text('Related posts'), findsNothing);
        _expectClean(tester);
      });

      testWidgets('keeps the search when you come back from a post', (
        WidgetTester tester,
      ) async {
        await _mount(tester, size);
        await _search(tester, 'roadmaps');
        await _tap(tester, find.text('Roadmaps are bets, not promises').first);
        expect(find.text('Related posts'), findsOneWidget);

        await _tap(tester, _button('Back to blog'));
        expect(find.text('Results for “roadmaps”'), findsOneWidget);
        _expectClean(tester);
      });

      testWidgets('shows the About page and filters to an author', (
        WidgetTester tester,
      ) async {
        await _mount(tester, size);
        await _tap(tester, _buttonLabelled('About').first);

        expect(find.text('About Fieldnotes'), findsOneWidget);
        expect(find.text('Marisol Reyes'), findsOneWidget);
        expect(find.text('Head of Design Systems'), findsOneWidget);
        expect(find.text('4 posts'), findsWidgets);
        expect(find.text('3 posts'), findsOneWidget);

        await _tap(tester, _buttonLabelled('Read posts by Daniel Haddad'));
        expect(find.text('Results for “Daniel Haddad”'), findsOneWidget);
        expect(find.text('4 posts'), findsOneWidget);
        _expectClean(tester);
      });

      testWidgets('subscribes to the newsletter', (WidgetTester tester) async {
        await _mount(tester, size);
        final Finder field = find.descendant(
          of: _input('Email address for the newsletter'),
          matching: find.byType(EditableText),
        );
        await tester.ensureVisible(field);
        await _settle(tester, 2);

        // An invalid address is explained, not submitted.
        await tester.enterText(field, 'not-an-email');
        await tester.tap(_button('Subscribe').first);
        await _settle(tester);
        expect(
          find.text('That does not look like an email address.'),
          findsOneWidget,
        );

        // Typing again clears the error.
        await tester.enterText(field, 'reader@example.com');
        await _settle(tester);
        expect(
          find.text('That does not look like an email address.'),
          findsNothing,
        );

        await tester.tap(_button('Subscribe').first);
        await tester.pump();
        expect(find.text('Subscribing'), findsOneWidget);
        await _settle(tester);

        expect(find.text('You are on the list.'), findsOneWidget);
        expect(find.text('You are subscribed'), findsOneWidget);
        _expectClean(tester);
      });
    });
  }

  group('states', () {
    testWidgets('shows an error with a retry when posts fail to load', (
      WidgetTester tester,
    ) async {
      await _mount(tester, _sizes[0].$2, posts: _FailingPosts());
      expect(find.text('We could not load the posts'), findsOneWidget);
      expect(_button('Try again'), findsOneWidget);
      _expectClean(tester);
    });

    testWidgets('keeps the footer at the bottom of a short page', (
      WidgetTester tester,
    ) async {
      await _mount(tester, const Size(1280, 1400), posts: _FailingPosts());
      expect(
        tester.getBottomLeft(find.byType(BlogFooter)).dy,
        closeTo(1400, 0.5),
      );
      _expectClean(tester);
    });

    testWidgets('shows skeletons while loading', (WidgetTester tester) async {
      tester.view.physicalSize = _sizes[2].$2;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: CairnTheme.materialTheme(
            CairnTheme.light.copyWith(fontFamily: 'Geist'),
          ),
          home: BlogApp(postsDataSource: _SlowPosts()),
        ),
      );
      await tester.pump();
      expect(find.byType(CairnSkeleton), findsWidgets);
      await _settle(tester);
      expect(find.byType(CairnSkeleton), findsNothing);
      _expectClean(tester);
    });

    testWidgets('renders in dark mode', (WidgetTester tester) async {
      await _mount(tester, _sizes[0].$2, dark: true);
      expect(find.text('Latest posts'), findsOneWidget);
      _expectClean(tester);
    });

    testWidgets('icon-only controls have semantic labels', (
      WidgetTester tester,
    ) async {
      await _mount(tester, _sizes[0].$2);
      expect(_buttonLabelled('Search posts'), findsOneWidget);
    });
  });
}
