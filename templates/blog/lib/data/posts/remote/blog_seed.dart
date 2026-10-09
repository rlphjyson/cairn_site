// The template's content: authors and posts as the decoded JSON a CMS or API
// would return. Replace the in-memory data sources that read this file with
// your own (see PostsRemoteDataSource) and delete it.
//
// Author:  id, name, role, bio, avatar
// Post:    id, title, excerpt, category, tags[], author (an author id),
//          publishedAt (ISO 8601), cover, coverAlt, featured?, readingMinutes?,
//          body[]  (heading | paragraph | quote | list | code | image blocks,
//          see ContentBlockMapper)
//
// `cover`, `avatar` and image `src` are either a bundled asset path
// ("assets/images/x.jpg") or an http(s) URL.

/// The seed authors.
const List<Map<String, Object?>> seedAuthors = <Map<String, Object?>>[
  <String, Object?>{
    'id': 'marisol-reyes',
    'name': 'Marisol Reyes',
    'role': 'Head of Design Systems',
    'bio':
        'Marisol leads the design system team. She writes about tokens, '
        'accessibility and how to make a component library people actually '
        'want to use.',
    'avatar': 'assets/images/author-marisol.jpg',
  },
  <String, Object?>{
    'id': 'daniel-haddad',
    'name': 'Daniel Haddad',
    'role': 'Staff Engineer, Flutter',
    'bio':
        'Daniel has shipped Flutter apps to mobile, desktop and the web. He '
        'writes about architecture, state management and performance.',
    'avatar': 'assets/images/author-daniel.jpg',
  },
  <String, Object?>{
    'id': 'priya-nair',
    'name': 'Priya Nair',
    'role': 'Senior Product Manager',
    'bio':
        'Priya turns fuzzy problems into small, testable bets. She writes '
        'about discovery, roadmaps and the craft of saying no.',
    'avatar': 'assets/images/author-priya.jpg',
  },
  <String, Object?>{
    'id': 'theo-lambert',
    'name': 'Theo Lambert',
    'role': 'Engineering Manager',
    'bio':
        'Theo manages the platform team. He writes about code review, '
        'incident culture and keeping a team healthy while it ships.',
    'avatar': 'assets/images/author-theo.jpg',
  },
];

/// The seed posts.
const List<Map<String, Object?>> seedPosts = <Map<String, Object?>>[
  <String, Object?>{
    'id': 'design-tokens-are-a-contract',
    'title': 'Design tokens are a contract, not a colour palette',
    'excerpt':
        'Tokens only pay off when designers, engineers and the product agree '
        'on what each one promises. Here is how we write those promises down.',
    'category': 'Design Systems',
    'tags': <String>['tokens', 'theming', 'process'],
    'author': 'marisol-reyes',
    'publishedAt': '2026-09-18T09:00:00',
    'cover': 'assets/images/cover-team-room.jpg',
    'coverAlt': 'A product team gathered around a wooden table in a studio',
    'featured': true,
    'readingMinutes': 6,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'When we started our design system, the first thing we shipped '
            'was a list of colours. It looked like progress. Six months '
            'later we had four slightly different greys in production and '
            'an argument about which one "muted" meant.',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'The list was not the problem. The missing contract was. A '
            'token is a promise: "use me when you need text that supports '
            'the main content, and I will stay readable in every theme." '
            'Without the promise, a token is just a nickname for a hex code.',
      },
      <String, Object?>{'type': 'heading', 'level': 2, 'text': 'Name the job'},
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'We stopped naming tokens after what they look like and started '
            'naming them after what they do. foreground, mutedForeground, '
            'border and ring say where a colour belongs. blue500 says '
            'nothing, and it breaks the day the brand turns green.',
      },
      <String, Object?>{
        'type': 'quote',
        'text':
            'If a token needs a paragraph of explanation, it is two tokens '
            'wearing one name.',
        'cite': 'Our design review checklist',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'Write the promise next to the value',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'What it is for, in one sentence.',
          'Where it must not be used.',
          'The contrast ratio it guarantees against its pair.',
          'Which components consume it today.',
        ],
      },
      <String, Object?>{
        'type': 'code',
        'language': 'dart',
        'code':
            '/// Text that supports the main content. Guaranteed 4.5:1 on\n'
            '/// [background] and [card] in both themes.\n'
            'final Color mutedForeground;',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Once the promise lives beside the value, a pull request that '
            'breaks it is easy to spot, and a designer can change a value '
            'without a meeting. That, more than any palette, is what made '
            'our theming cheap.',
      },
    ],
  },
  <String, Object?>{
    'id': 'flutter-state-without-the-drama',
    'title': 'Flutter state management without the drama',
    'excerpt':
        'Pick the boring option, keep widgets dumb, and put one object in '
        'charge of each screen. A calm approach to state that scales.',
    'category': 'Flutter',
    'tags': <String>['state', 'bloc', 'architecture'],
    'author': 'daniel-haddad',
    'publishedAt': '2026-09-09T10:30:00',
    'cover': 'assets/images/cover-laptop-code.jpg',
    'coverAlt': 'A laptop on a wooden desk showing code in an editor',
    'readingMinutes': 8,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Every Flutter team eventually has the state management '
            'conversation, and it is rarely about state. It is about '
            'whether we trust each other to follow a pattern.',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Our answer is deliberately unexciting: a cubit per screen, '
            'immutable states, and widgets that only read and call. Nothing '
            'in a widget decides anything.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'One owner per screen',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'A screen gets a small object that creates its cubit, hands it '
            'to the view and closes it when the screen leaves. Views never '
            'look anything up themselves, so a test can mount a screen '
            'with a fake and nothing else.',
      },
      <String, Object?>{
        'type': 'code',
        'language': 'dart',
        'code':
            'class PostsCubit extends Cubit<PostsState> {\n'
            '  PostsCubit(this._getPosts) : super(const PostsState());\n'
            '\n'
            '  final GetPosts _getPosts;\n'
            '\n'
            '  Future<void> load() async {\n'
            '    emit(state.copyWith(loading: true));\n'
            '    emit(PostsState(posts: await _getPosts()));\n'
            '  }\n'
            '}',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 3,
        'text': 'What we leave out',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'Global singletons that hold UI state.',
          'Cubits that call other cubits.',
          'Business rules inside build methods.',
        ],
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'None of this is clever. That is the point: a new teammate can '
            'read one screen and predict the next twenty.',
      },
    ],
  },
  <String, Object?>{
    'id': 'writing-prds-people-read',
    'title': 'Writing product requirement docs that people actually read',
    'excerpt':
        'A good PRD is short, opinionated and honest about what it does not '
        'know. A template and a few rules for keeping it that way.',
    'category': 'Product',
    'tags': <String>['writing', 'process', 'planning'],
    'author': 'priya-nair',
    'publishedAt': '2026-08-27T08:45:00',
    'cover': 'assets/images/cover-sticky-notes.jpg',
    'coverAlt': 'Colourful sticky notes on a whiteboard',
    'readingMinutes': 5,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'The test of a product requirement doc is simple: two weeks '
            'after you wrote it, does an engineer open it before asking you '
            'a question? Most of mine failed that test for years.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'Start with the problem, in one paragraph',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'If you cannot describe who is stuck, what they are trying to '
            'do and what happens today, the rest of the document is '
            'decoration. Everything else is allowed to be a bullet list.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'Say what you are not doing',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'Non-goals, so nobody builds them by accident.',
          'Open questions, with an owner and a date.',
          'The metric that will tell us we were wrong.',
        ],
      },
      <String, Object?>{
        'type': 'quote',
        'text':
            'A requirement nobody can disagree with is not a requirement, '
            'it is a wish.',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'We keep the whole thing to two pages and link out for '
            'everything else. When a PRD grows past that, it is usually '
            'hiding a decision nobody has made yet.',
      },
    ],
  },
  <String, Object?>{
    'id': 'the-case-for-boring-architecture',
    'title': 'The case for boring architecture',
    'excerpt':
        'Clever systems are expensive to join. Why we choose layers, '
        'interfaces and plain names, and how it keeps a team fast in year '
        'three.',
    'category': 'Engineering Culture',
    'tags': <String>['architecture', 'teams', 'maintenance'],
    'author': 'theo-lambert',
    'publishedAt': '2026-08-14T11:00:00',
    'cover': 'assets/images/cover-top-down.jpg',
    'coverAlt': 'A team working together at a table, seen from above',
    'readingMinutes': 7,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Every codebase has a moment when a new engineer asks where '
            'something lives and the honest answer is "it depends". That is '
            'the day architecture stopped being a diagram and became a '
            'tax.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'Optimise for the second month',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'The first week of a project rewards cleverness. The second '
            'month rewards predictability. We pick structures a stranger '
            'can navigate by guessing: layers at the top, features inside '
            'them, one job per class.',
      },
      <String, Object?>{
        'type': 'image',
        'src': 'assets/images/cover-sketches.jpg',
        'caption': 'Sketching boundaries before drawing a single class.',
        'alt': 'Architectural sketches and blueprints on a desk',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'Dependencies point inwards, never sideways.',
          'Interfaces live where they are used.',
          'If a rule is not enforced by the folder structure, it is a rumour.',
        ],
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Boring does not mean slow. It means the cost of the next '
            'feature is the cost of the feature, not of understanding the '
            'last three.',
      },
    ],
  },
  <String, Object?>{
    'id': 'accessible-components-from-day-one',
    'title': 'Accessible components from day one',
    'excerpt':
        'Retrofitting accessibility is slow and expensive. Four habits that '
        'make every new component keyboard-friendly and screen-reader '
        'ready from the first commit.',
    'category': 'Design Systems',
    'tags': <String>['accessibility', 'components', 'quality'],
    'author': 'marisol-reyes',
    'publishedAt': '2026-08-02T09:15:00',
    'cover': 'assets/images/cover-wireframes.jpg',
    'coverAlt': 'A notebook with hand-drawn wireframes next to a phone',
    'readingMinutes': 4,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Accessibility feels like a separate project until you ship a '
            'component that cannot be reached with a keyboard. Then it '
            'feels like a bug, and bugs are just work.',
      },
      <String, Object?>{'type': 'heading', 'level': 2, 'text': 'Four habits'},
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'Every interactive element is focusable and shows a visible ring.',
          'Every icon-only control has a semantic label.',
          'Text meets 4.5:1 contrast in both themes, checked in review.',
          'The tab order follows the reading order.',
        ],
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'We write them into the component template, so the checklist is '
            'part of the pull request rather than a lecture afterwards.',
      },
      <String, Object?>{
        'type': 'code',
        'language': 'dart',
        'code':
            'CairnButton.icon(\n'
            '  icon: const Icon(Icons.link, size: 16),\n'
            "  semanticLabel: 'Copy link',\n"
            '  onPressed: copy,\n'
            ');',
      },
      <String, Object?>{
        'type': 'quote',
        'text': 'Accessible by default is cheaper than accessible by audit.',
        'cite': 'Marisol Reyes',
      },
    ],
  },
  <String, Object?>{
    'id': 'flutter-web-performance-checklist',
    'title': 'A Flutter web performance checklist',
    'excerpt':
        'Bundle size, first paint and scroll jank are all fixable. The '
        'checklist we run before every release of our Flutter web apps.',
    'category': 'Flutter',
    'tags': <String>['web', 'performance', 'release'],
    'author': 'daniel-haddad',
    'publishedAt': '2026-07-21T14:00:00',
    'cover': 'assets/images/cover-monitor.jpg',
    'coverAlt': 'A monitor showing source code beside a desk lamp',
    'readingMinutes': 9,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Flutter on the web can feel fast or heavy, and the difference '
            'is mostly decisions you make before the first widget. We keep '
            'a short list and treat any regression as a release blocker.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'Before you ship',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'Build with the release flag and check the bundle size.',
          'Ship only the fonts and icons the app uses.',
          'Decode images at the size you display them.',
          'Lazy-load heavy routes behind deferred imports.',
          'Profile scrolling on a mid-range laptop, not your own.',
        ],
      },
      <String, Object?>{
        'type': 'code',
        'language': 'bash',
        'code':
            'flutter build web --release --tree-shake-icons\n'
            'ls -lh build/web/main.dart.js',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'The last item matters most. Performance is a property of the '
            'slowest machine your users own, and that is rarely yours.',
      },
    ],
  },
  <String, Object?>{
    'id': 'roadmaps-are-bets',
    'title': 'Roadmaps are bets, not promises',
    'excerpt':
        'How we changed our roadmap from a list of dates to a set of '
        'bets with a stated confidence, and what it did to our meetings.',
    'category': 'Product',
    'tags': <String>['roadmap', 'planning', 'strategy'],
    'author': 'priya-nair',
    'publishedAt': '2026-07-09T10:00:00',
    'cover': 'assets/images/cover-meeting.jpg',
    'coverAlt': 'Colleagues discussing a plan around a table',
    'readingMinutes': 5,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'A date on a roadmap is read as a promise, however many '
            'disclaimers surround it. After a year of apologising for '
            'slipped dates we stopped publishing them.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'What we publish instead',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'The problem each bet addresses.',
          'How confident we are, from "hunch" to "proven".',
          'What we would have to learn to stop.',
        ],
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'The first quarter was uncomfortable. Stakeholders wanted '
            'certainty and we offered honesty. By the second, the '
            'conversations had moved from "when" to "why", which is where '
            'a product team earns its keep.',
      },
      <String, Object?>{
        'type': 'quote',
        'text': 'Confidence is information. Hiding it helps nobody.',
      },
    ],
  },
  <String, Object?>{
    'id': 'code-review-as-conversation',
    'title': 'Code review as a conversation',
    'excerpt':
        'Reviews work best when they teach both sides. Our guidelines for '
        'comments that unblock people instead of slowing them down.',
    'category': 'Engineering Culture',
    'tags': <String>['code review', 'teams', 'communication'],
    'author': 'theo-lambert',
    'publishedAt': '2026-06-26T09:30:00',
    'cover': 'assets/images/cover-programmer.jpg',
    'coverAlt': 'A developer working at a desk with two screens',
    'readingMinutes': 4,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'A review comment lands differently at the end of a long day. '
            'We wrote down a few norms so the tone does not depend on '
            'anyone\'s mood.',
      },
      <String, Object?>{'type': 'heading', 'level': 2, 'text': 'Our norms'},
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'Ask a question before making a demand.',
          'Mark nitpicks as nitpicks, and never block on them.',
          'Praise what is good; it tells the author what to repeat.',
          'If a thread goes past three replies, talk instead.',
        ],
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'The measure we watch is time to first review, not number of '
            'comments. A fast, kind review beats a thorough, late one.',
      },
      <String, Object?>{
        'type': 'quote',
        'text': 'We review the code, not the person, and we review it soon.',
        'cite': 'Platform team handbook',
      },
    ],
  },
  <String, Object?>{
    'id': 'dark-mode-without-pain',
    'title': 'Dark mode without the pain',
    'excerpt':
        'If your colours are tokens, dark mode is a second set of values, '
        'not a second design. What we learned shipping both themes at once.',
    'category': 'Design Systems',
    'tags': <String>['theming', 'tokens', 'accessibility'],
    'author': 'marisol-reyes',
    'publishedAt': '2026-06-12T13:00:00',
    'cover': 'assets/images/cover-swatches.jpg',
    'coverAlt': 'A fan of paint colour swatches',
    'readingMinutes': 6,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Teams that bolt dark mode on at the end rediscover every '
            'hard-coded colour at once. Teams that start with tokens '
            'finish in an afternoon.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'Three rules that saved us',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'No colour literals in widgets; read them from the theme.',
          'Photos get an overlay, never a tint, so they stay honest.',
          'Elevation in dark mode is lightness, not shadow.',
        ],
      },
      <String, Object?>{
        'type': 'code',
        'language': 'dart',
        'code':
            'final CairnTheme theme = CairnTheme.of(context);\n'
            'return ColoredBox(color: theme.card);',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'We check every screen in both themes in the same pull '
            'request. The bugs we find that way are small; the ones we '
            'would find after release are not.',
      },
    ],
  },
  <String, Object?>{
    'id': 'clean-architecture-in-flutter',
    'title': 'Clean architecture in Flutter, without the ceremony',
    'excerpt':
        'Layers, use cases and repositories can feel heavy. A practical '
        'cut of the pattern that keeps the benefits and drops the '
        'boilerplate.',
    'category': 'Flutter',
    'tags': <String>['architecture', 'testing', 'dependency injection'],
    'author': 'daniel-haddad',
    'publishedAt': '2026-05-29T10:00:00',
    'cover': 'assets/images/cover-laptop-plant.jpg',
    'coverAlt': 'A laptop with code beside a plant and a coffee cup',
    'readingMinutes': 8,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Clean architecture has a reputation for folders full of '
            'one-line classes. The reputation is earned when the pattern '
            'is applied everywhere without asking what it buys.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'Keep what pays for itself',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'Repository interfaces, so data sources can be swapped.',
          'Use cases that hold a rule worth testing.',
          'Mappers at the boundary, so JSON never leaks inwards.',
        ],
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'We skip entities that duplicate models, abstract factories, '
            'and any layer that only forwards a call. If a class has no '
            'logic and no seam, it does not get to exist.',
      },
      <String, Object?>{
        'type': 'code',
        'language': 'dart',
        'code':
            'g.registerLazySingleton<PostRepository>(\n'
            '  () => PostRepositoryImpl(g(), g()),\n'
            ');',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Registration is written out by hand. It is twelve lines '
            'longer than code generation and infinitely easier to debug.',
      },
    ],
  },
  <String, Object?>{
    'id': 'discovery-on-a-budget',
    'title': 'Product discovery on a small budget',
    'excerpt':
        'You do not need a research team to learn what customers want. Five '
        'conversations a week and a shared notes doc go a long way.',
    'category': 'Product',
    'tags': <String>['research', 'discovery', 'process'],
    'author': 'priya-nair',
    'publishedAt': '2026-05-15T09:00:00',
    'cover': 'assets/images/cover-coffee-notebook.jpg',
    'coverAlt': 'A cup of coffee beside a notepad and pen on a wooden desk',
    'readingMinutes': 5,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Discovery is a habit before it is a methodology. The teams I '
            'have seen do it well talk to a customer every week and write '
            'down what they heard, in the customer\'s words.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'A weekly rhythm',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'Five conversations, thirty minutes each, any role can join.',
          'One shared doc where quotes go in verbatim.',
          'A Friday ten minutes to cluster what we heard.',
        ],
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'None of it needs a budget. It needs a calendar and the '
            'discipline to keep the slots when delivery pressure rises, '
            'which is exactly when discovery matters most.',
      },
    ],
  },
  <String, Object?>{
    'id': 'incident-reviews-without-blame',
    'title': 'Incident reviews without blame',
    'excerpt':
        'The goal of an incident review is a safer system, not a guilty '
        'person. A format that gets honest answers and real follow-ups.',
    'category': 'Engineering Culture',
    'tags': <String>['incidents', 'teams', 'reliability'],
    'author': 'theo-lambert',
    'publishedAt': '2026-04-30T15:00:00',
    'cover': 'assets/images/cover-team-table.jpg',
    'coverAlt': 'Three colleagues reviewing documents around a table',
    'readingMinutes': 6,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'After an outage, everyone wants to know who pushed the '
            'button. The more useful question is why the button was '
            'allowed to do that.',
      },
      <String, Object?>{'type': 'heading', 'level': 2, 'text': 'The format'},
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'A timeline built from logs, not memory.',
          'What surprised us, written by whoever was surprised.',
          'Two or three follow-ups, each with an owner and a date.',
        ],
      },
      <String, Object?>{
        'type': 'quote',
        'text':
            'People do not cause incidents. Systems let mistakes become '
            'incidents.',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'We publish every review internally. The first few felt '
            'exposing; now new joiners read them as a tour of how the '
            'system really works.',
      },
    ],
  },
  <String, Object?>{
    'id': 'documenting-components-people-use',
    'title': 'Documenting components people actually use',
    'excerpt':
        'Documentation fails when it is a museum. How we write component '
        'docs around tasks, with live examples and honest limits.',
    'category': 'Design Systems',
    'tags': <String>['documentation', 'components', 'process'],
    'author': 'marisol-reyes',
    'publishedAt': '2026-04-16T10:00:00',
    'cover': 'assets/images/cover-sketches.jpg',
    'coverAlt': 'Sketches and blueprints spread across a desk',
    'readingMinutes': 5,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Component docs usually list every prop alphabetically and '
            'stop. That is a reference, and a reference is not a guide. '
            'People arrive with a task, not a prop name.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'Structure around the task',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'When to use it, and when to reach for something else.',
          'The smallest working example, ready to paste.',
          'Variants shown side by side.',
          'Accessibility notes: keyboard, labels, contrast.',
        ],
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'We also write down limits. A component that says "not for '
            'lists longer than a hundred rows" saves more support tickets '
            'than any amount of cheerful prose.',
      },
    ],
  },
  <String, Object?>{
    'id': 'testing-flutter-widgets-that-matter',
    'title': 'Testing Flutter widgets that matter',
    'excerpt':
        'You do not need a test per widget. Where widget tests earn their '
        'keep, and how to keep them fast and unflaky.',
    'category': 'Flutter',
    'tags': <String>['testing', 'quality', 'ci'],
    'author': 'daniel-haddad',
    'publishedAt': '2026-03-31T11:30:00',
    'cover': 'assets/images/cover-laptop-mug.jpg',
    'coverAlt': 'A laptop displaying code next to a coffee mug',
    'readingMinutes': 7,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Coverage numbers tempt teams into testing everything and '
            'trusting nothing. We test behaviour at the seams instead: the '
            'use cases below the UI and a handful of flows above it.',
      },
      <String, Object?>{
        'type': 'heading',
        'level': 2,
        'text': 'What a widget test is good for',
      },
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'A user flow: search, open, go back.',
          'Layout at the widths you support.',
          'States that are hard to reach by hand, like errors.',
        ],
      },
      <String, Object?>{
        'type': 'code',
        'language': 'dart',
        'code':
            'await tester.enterText(find.byType(EditableText), \'flutter\');\n'
            'await tester.pump(const Duration(milliseconds: 100));\n'
            'expect(find.text(\'Flutter\'), findsWidgets);',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'Pump in small steps instead of settling. Animations that '
            'repeat forever never settle, and a test that waits for them '
            'is a test that hangs.',
      },
    ],
  },
  <String, Object?>{
    'id': 'the-quiet-value-of-writing-things-down',
    'title': 'The quiet value of writing things down',
    'excerpt':
        'Decisions made in a call disappear. Why our team writes a short '
        'note for almost everything, and how it keeps us honest.',
    'category': 'Engineering Culture',
    'tags': <String>['writing', 'documentation', 'teams'],
    'author': 'theo-lambert',
    'publishedAt': '2026-03-12T09:00:00',
    'cover': 'assets/images/cover-desk-moody.jpg',
    'coverAlt': 'A quiet desk by a window with a cup, a notebook and a pen',
    'readingMinutes': 3,
    'body': <Map<String, Object?>>[
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'The most useful habit on our team costs five minutes: after '
            'a decision, someone writes three sentences saying what was '
            'decided, why, and what would change our mind.',
      },
      <String, Object?>{'type': 'heading', 'level': 2, 'text': 'Why it works'},
      <String, Object?>{
        'type': 'list',
        'items': <String>[
          'People who were not there can catch up.',
          'The reasoning outlives the people who had it.',
          'Writing exposes decisions that were never really made.',
        ],
      },
      <String, Object?>{
        'type': 'quote',
        'text': 'If it is not written down, we only think we agree.',
        'cite': 'Theo Lambert',
      },
      <String, Object?>{
        'type': 'paragraph',
        'text':
            'None of these notes is polished. They only have to be '
            'findable, and honest about what was uncertain at the time.',
      },
    ],
  },
];
