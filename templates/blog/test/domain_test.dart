import 'package:cairn_template_blog/common/utils/format.dart';
import 'package:cairn_template_blog/core/infrastructure/di/blog_injection.dart';
import 'package:cairn_template_blog/domain/authors/mappers/author_mapper.dart';
import 'package:cairn_template_blog/domain/authors/models/author.dart';
import 'package:cairn_template_blog/domain/authors/use_cases/get_author_profiles.dart';
import 'package:cairn_template_blog/domain/newsletter/mappers/subscribe_result_mapper.dart';
import 'package:cairn_template_blog/domain/newsletter/models/subscribe_result.dart';
import 'package:cairn_template_blog/domain/newsletter/use_cases/subscribe_to_newsletter.dart';
import 'package:cairn_template_blog/domain/newsletter/use_cases/validate_email.dart';
import 'package:cairn_template_blog/domain/posts/mappers/content_block_mapper.dart';
import 'package:cairn_template_blog/domain/posts/mappers/post_mapper.dart';
import 'package:cairn_template_blog/domain/posts/models/content_block.dart';
import 'package:cairn_template_blog/domain/posts/models/post.dart';
import 'package:cairn_template_blog/domain/posts/models/post_page.dart';
import 'package:cairn_template_blog/domain/posts/models/post_query.dart';
import 'package:cairn_template_blog/domain/posts/use_cases/get_categories.dart';
import 'package:cairn_template_blog/domain/posts/use_cases/get_featured_post.dart';
import 'package:cairn_template_blog/domain/posts/use_cases/get_post.dart';
import 'package:cairn_template_blog/domain/posts/use_cases/get_posts.dart';
import 'package:cairn_template_blog/domain/posts/use_cases/get_related_posts.dart';
import 'package:cairn_template_blog/domain/posts/use_cases/query_posts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The domain layer through the real container, with no widgets.
void main() {
  late GetIt locator;
  late List<Post> posts;

  setUp(() async {
    locator = createBlogLocator();
    posts = await locator<GetPosts>()();
  });
  tearDown(() => locator.reset());

  group('seed content', () {
    test('has 15 posts, newest first, by 4 authors', () {
      expect(posts, hasLength(15));
      for (int i = 1; i < posts.length; i++) {
        expect(
          posts[i - 1].publishedAt.isAfter(posts[i].publishedAt),
          isTrue,
          reason: '${posts[i - 1].id} should be newer than ${posts[i].id}',
        );
      }
      expect(posts.map((Post p) => p.author.id).toSet(), hasLength(4));
      expect(posts.map((Post p) => p.id).toSet(), hasLength(15));
    });

    test('every post has a cover, tags and a body', () {
      for (final Post p in posts) {
        expect(p.cover, startsWith('assets/images/'));
        expect(p.tags, isNotEmpty, reason: p.id);
        expect(p.body, isNotEmpty, reason: p.id);
        expect(p.readingMinutes, greaterThan(0));
      }
    });

    test('every block type appears in the seed', () {
      final Set<Type> types = <Type>{
        for (final Post p in posts)
          for (final ContentBlock b in p.body) b.runtimeType,
      };
      expect(types, <Type>{
        HeadingBlock,
        ParagraphBlock,
        QuoteBlock,
        BulletListBlock,
        CodeBlock,
        ImageBlock,
      });
    });
  });

  group('GetPost', () {
    test('finds a post by id and returns null otherwise', () async {
      final GetPost getPost = locator<GetPost>();
      expect((await getPost('roadmaps-are-bets'))?.title, contains('Roadmaps'));
      expect(await getPost('nope'), isNull);
    });
  });

  group('GetCategories', () {
    test('orders by how many posts each has, then alphabetically', () {
      expect(const GetCategories()(posts), <String>[
        'Design Systems',
        'Engineering Culture',
        'Flutter',
        'Product',
      ]);
    });

    test('is empty for no posts', () {
      expect(const GetCategories()(<Post>[]), isEmpty);
    });
  });

  group('GetFeaturedPost', () {
    test('prefers the newest post flagged featured', () {
      expect(
        const GetFeaturedPost()(posts)?.id,
        'design-tokens-are-a-contract',
      );
    });

    test('falls back to the newest post', () {
      final List<Post> none = <Post>[
        for (final Post p in posts) _copy(p, featured: false),
      ];
      expect(const GetFeaturedPost()(none)?.id, posts.first.id);
      expect(const GetFeaturedPost()(<Post>[]), isNull);
    });
  });

  group('QueryPosts', () {
    const QueryPosts query = QueryPosts();

    test('paginates by the page size and clamps the page', () {
      final PostPage first = query(posts, const PostQuery());
      expect(first.items, hasLength(6));
      expect(first.total, 15);
      expect(first.pageCount, 3);

      final PostPage last = query(posts, const PostQuery(page: 3));
      expect(last.items, hasLength(3));

      expect(query(posts, const PostQuery(page: 99)).page, 3);
      expect(query(posts, const PostQuery(page: -4)).page, 1);
    });

    test('can leave out the featured post', () {
      final PostPage page = query(
        posts,
        const PostQuery(),
        excludeId: 'design-tokens-are-a-contract',
      );
      expect(page.total, 14);
      expect(page.pageCount, 3);
      expect(
        page.items.map((Post p) => p.id),
        isNot(contains('design-tokens-are-a-contract')),
      );
    });

    test('filters by category', () {
      final PostPage page = query(posts, const PostQuery(category: 'Product'));
      expect(page.total, 3);
      expect(page.items.every((Post p) => p.category == 'Product'), isTrue);
    });

    test('searches title, excerpt, tags, category and author, any case', () {
      expect(query(posts, const PostQuery(search: 'TOKENS')).total, 2);
      expect(query(posts, const PostQuery(search: 'daniel haddad')).total, 4);
      expect(query(posts, const PostQuery(search: 'code review')).total, 1);
      expect(query(posts, const PostQuery(search: 'engineering')).total, 4);
    });

    test('every search term must match', () {
      expect(query(posts, const PostQuery(search: 'tokens flutter')).total, 0);
    });

    test('combines category and search', () {
      final PostPage page = query(
        posts,
        const PostQuery(category: 'Design Systems', search: 'tokens'),
      );
      expect(page.total, 2);
      expect(
        query(
          posts,
          const PostQuery(category: 'Flutter', search: 'tokens'),
        ).total,
        0,
      );
    });

    test('an empty result is one empty page', () {
      final PostPage page = query(posts, const PostQuery(search: 'zzzz'));
      expect(page.items, isEmpty);
      expect(page.page, 1);
      expect(page.pageCount, 1);
    });

    test('a blank search does not filter', () {
      const PostQuery blank = PostQuery(search: '   ');
      expect(blank.isFiltered, isFalse);
      expect(query(posts, blank).total, 15);
    });
  });

  group('GetRelatedPosts', () {
    test('ranks by category, shared tags and author', () async {
      final Post source = (await locator<GetPost>()(
        'design-tokens-are-a-contract',
      ))!;
      final List<Post> related = await locator<GetRelatedPosts>()(source);
      expect(related.map((Post p) => p.id), <String>[
        'dark-mode-without-pain',
        'documenting-components-people-use',
        'accessible-components-from-day-one',
      ]);
    });

    test('never includes the post itself and respects the limit', () async {
      final Post source = posts.first;
      final GetRelatedPosts use = locator<GetRelatedPosts>();
      final List<Post> one = await use(source, limit: 1);
      expect(one, hasLength(1));
      expect(one.single.id, isNot(source.id));
      expect(
        use.rank(source, posts).map((Post p) => p.id),
        isNot(contains(source.id)),
      );
    });

    test('returns nothing when nothing is alike', () {
      final Post lonely = _copy(
        posts.first,
        tags: <String>['x'],
        category: 'X',
        author: _author('me'),
      );
      final List<Post> others = <Post>[
        for (final Post p in posts.skip(1))
          _copy(
            p,
            tags: <String>['y'],
            category: 'Y',
            author: _author('someone-else'),
          ),
      ];
      expect(locator<GetRelatedPosts>().rank(lonely, others), isEmpty);
    });
  });

  group('GetAuthorProfiles', () {
    test('counts posts per author, busiest first', () async {
      final List<AuthorProfile> profiles = await locator<GetAuthorProfiles>()();
      expect(profiles, hasLength(4));
      expect(
        profiles.fold<int>(0, (int s, AuthorProfile p) => s + p.postCount),
        15,
      );
      expect(profiles.last.author.id, 'priya-nair');
      expect(profiles.last.postCount, 3);
    });
  });

  group('mappers', () {
    final Author author = _author('a');

    Map<String, Object?> json({Map<String, Object?>? overrides}) =>
        <String, Object?>{
          'id': 'p',
          'title': 'T',
          'excerpt': 'E',
          'category': 'C',
          'author': 'a',
          'publishedAt': '2026-01-02T03:04:05',
          'cover': 'assets/images/x.jpg',
          'body': <Object?>[
            <String, Object?>{'type': 'paragraph', 'text': 'one two three'},
          ],
          ...?overrides,
        };

    test('maps a post and resolves its author', () {
      final Post post = PostMapper.fromJson(
        json(
          overrides: <String, Object?>{
            'tags': <Object?>['x', 'y'],
            'featured': true,
          },
        ),
        <String, Author>{'a': author},
      );
      expect(post.author, author);
      expect(post.tags, <String>['x', 'y']);
      expect(post.featured, isTrue);
      expect(post.publishedAt, DateTime(2026, 1, 2, 3, 4, 5));
      expect(post.coverAlt, 'T', reason: 'falls back to the title');
    });

    test('computes the reading time, at least one minute', () {
      final Post short = PostMapper.fromJson(json(), <String, Author>{
        'a': author,
      });
      expect(short.readingMinutes, 1);

      final String words = List<String>.filled(450, 'word').join(' ');
      final Post long = PostMapper.fromJson(
        json(
          overrides: <String, Object?>{
            'body': <Object?>[
              <String, Object?>{'type': 'paragraph', 'text': words},
            ],
          },
        ),
        <String, Author>{'a': author},
      );
      expect(long.readingMinutes, 3);
    });

    test('an explicit readingMinutes wins', () {
      final Post post = PostMapper.fromJson(
        json(overrides: <String, Object?>{'readingMinutes': 12}),
        <String, Author>{'a': author},
      );
      expect(post.readingMinutes, 12);
    });

    test('rejects unknown authors and missing fields', () {
      expect(
        () => PostMapper.fromJson(json(), <String, Author>{}),
        throwsFormatException,
      );
      expect(
        () => PostMapper.fromJson(
          json(overrides: <String, Object?>{'title': null}),
          <String, Author>{'a': author},
        ),
        throwsFormatException,
      );
      expect(
        () => PostMapper.fromJson(
          json(overrides: <String, Object?>{'body': 'nope'}),
          <String, Author>{'a': author},
        ),
        throwsFormatException,
      );
    });

    test('maps every block type', () {
      ContentBlock map(Map<String, Object?> j) =>
          ContentBlockMapper.fromJson(j);
      expect(
        map(<String, Object?>{'type': 'heading', 'text': 'H', 'level': 3}),
        const HeadingBlock('H', level: 3),
      );
      expect(
        map(<String, Object?>{'type': 'heading', 'text': 'H'}),
        const HeadingBlock('H'),
      );
      expect(
        map(<String, Object?>{'type': 'quote', 'text': 'Q', 'cite': 'C'}),
        const QuoteBlock('Q', cite: 'C'),
      );
      expect(
        map(<String, Object?>{
          'type': 'list',
          'items': <Object?>['a', 'b'],
        }),
        const BulletListBlock(<String>['a', 'b']),
      );
      expect(
        map(<String, Object?>{'type': 'code', 'code': 'x', 'language': 'dart'}),
        const CodeBlock('x', language: 'dart'),
      );
      expect(
        map(<String, Object?>{'type': 'image', 'src': 's', 'caption': 'c'}),
        const ImageBlock('s', caption: 'c'),
      );
    });

    test('rejects unknown and empty blocks', () {
      expect(
        () => ContentBlockMapper.fromJson(<String, Object?>{'type': 'video'}),
        throwsFormatException,
      );
      expect(
        () => ContentBlockMapper.fromJson(<String, Object?>{
          'type': 'list',
          'items': <Object?>[],
        }),
        throwsFormatException,
      );
    });

    test('maps an author and rejects an incomplete one', () {
      final Author mapped = AuthorMapper.fromJson(<String, Object?>{
        'id': 'i',
        'name': 'N',
        'role': 'R',
        'bio': 'B',
        'avatar': 'A',
      });
      expect(mapped.name, 'N');
      expect(
        () => AuthorMapper.fromJson(<String, Object?>{'id': 'i'}),
        throwsFormatException,
      );
    });

    test('maps newsletter responses', () {
      expect(
        SubscribeResultMapper.fromJson(<String, Object?>{
          'status': 'subscribed',
        }),
        SubscribeResult.subscribed,
      );
      expect(
        SubscribeResultMapper.fromJson(<String, Object?>{
          'status': 'already_subscribed',
        }),
        SubscribeResult.alreadySubscribed,
      );
      expect(
        () => SubscribeResultMapper.fromJson(<String, Object?>{'error': 'no'}),
        throwsA(isA<NewsletterException>()),
      );
      expect(
        () => SubscribeResultMapper.fromJson(<String, Object?>{}),
        throwsA(isA<NewsletterException>()),
      );
    });
  });

  group('ValidateEmail', () {
    const ValidateEmail validate = ValidateEmail();

    test('accepts ordinary addresses', () {
      for (final String ok in <String>[
        'a@b.co',
        'first.last+tag@sub.example.com',
        '  padded@example.org  ',
        'x_y@my-domain.io',
      ]) {
        expect(validate(ok), isNull, reason: ok);
      }
    });

    test('rejects the usual mistakes', () {
      for (final String bad in <String>[
        '',
        '   ',
        'plain',
        'no@tld',
        '@example.com',
        'a@@b.com',
        'a b@c.com',
        'a@b..com',
        'a@-b.com',
        'a@b.com.',
      ]) {
        expect(validate(bad), isNotNull, reason: '"$bad"');
      }
    });

    test('asks for an address when empty and explains when malformed', () {
      expect(validate(''), contains('Enter'));
      expect(validate('nope'), contains('does not look like'));
    });

    test('rejects addresses over 254 characters', () {
      expect(validate('${'a' * 250}@b.co'), isNotNull);
    });
  });

  group('SubscribeToNewsletter', () {
    test('refuses an invalid address before any request', () {
      expect(
        () => locator<SubscribeToNewsletter>()('nope'),
        throwsA(isA<InvalidEmailException>()),
      );
    });
  });

  group('format helpers', () {
    test('formatDate', () {
      expect(formatDate(DateTime(2026, 9, 18)), 'Sep 18, 2026');
      expect(formatDate(DateTime(2026, 1, 2)), 'Jan 2, 2026');
    });

    test('initials, truncate and wordCount', () {
      expect(initials('Marisol Reyes'), 'MR');
      expect(initials('Cher'), 'C');
      expect(initials('  '), '');
      expect(truncate('short', 10), 'short');
      expect(truncate('a long title here', 8), 'a long…');
      expect(wordCount('  one  two\nthree '), 3);
      expect(wordCount(''), 0);
    });
  });
}

Author _author(String id) =>
    Author(id: id, name: id, role: '', bio: '', avatar: '');

Post _copy(
  Post p, {
  bool? featured,
  List<String>? tags,
  String? category,
  Author? author,
}) => Post(
  id: p.id,
  title: p.title,
  excerpt: p.excerpt,
  category: category ?? p.category,
  tags: tags ?? p.tags,
  author: author ?? p.author,
  publishedAt: p.publishedAt,
  cover: p.cover,
  coverAlt: p.coverAlt,
  body: p.body,
  readingMinutes: p.readingMinutes,
  featured: featured ?? p.featured,
);
