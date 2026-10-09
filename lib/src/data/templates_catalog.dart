import 'package:cairn_template_app_landing/cairn_template_app_landing.dart';
import 'package:cairn_template_auth/cairn_template_auth.dart';
import 'package:cairn_template_blog/cairn_template_blog.dart';
import 'package:cairn_template_chat/cairn_template_chat.dart';
import 'package:cairn_template_dashboard/cairn_template_dashboard.dart';
import 'package:cairn_template_docs/cairn_template_docs.dart';
import 'package:cairn_template_landing/cairn_template_landing.dart';
import 'package:cairn_template_onboarding/cairn_template_onboarding.dart';
import 'package:cairn_template_shop/cairn_template_shop.dart';
import 'package:flutter/widgets.dart';

/// What a template targets.
enum TemplateKind {
  /// A phone app, shown in a phone frame.
  mobile('Mobile'),

  /// A browser app, shown in a browser frame.
  web('Web');

  const TemplateKind(this.label);

  /// Shown in badges.
  final String label;
}

/// One captured screen, shown in the gallery.
@immutable
class TemplateShot {
  /// Creates a shot. The files are
  /// `assets/screenshots/<slug>-<file>-<light|dark>.png`.
  const TemplateShot(this.file, this.caption);

  /// The middle part of the file name, e.g. `1-shop`.
  final String file;

  /// The caption under the image.
  final String caption;
}

/// One template in the catalogue.
@immutable
class TemplateEntry {
  /// Creates an entry.
  const TemplateEntry({
    required this.slug,
    required this.name,
    required this.kind,
    required this.summary,
    required this.description,
    required this.screens,
    required this.uses,
    required this.shots,
    this.preview,
    this.shotExt = 'png',
    this.serverRendered = false,
    this.runCommands,
  });

  /// The URL segment and the package folder, e.g. `shop`.
  final String slug;

  /// The display name.
  final String name;

  /// Mobile or web.
  final TemplateKind kind;

  /// A line for the picker.
  final String summary;

  /// A paragraph for the detail view.
  final String description;

  /// `(name, what it does)` for each screen or section.
  final List<(String, String)> screens;

  /// Catalogue component names the template is built from.
  final List<String> uses;

  /// The screenshot gallery.
  final List<TemplateShot> shots;

  /// Builds the live template, or `null` for a template that cannot run
  /// inside this Flutter page (a server-rendered one).
  final WidgetBuilder? preview;

  /// The screenshot file extension.
  final String shotExt;

  /// Whether it is a server-rendered Jaspr app rather than a Flutter package.
  final bool serverRendered;

  /// How to run a server-rendered template locally.
  final String? runCommands;

  /// The package folder inside the repository.
  String get packagePath => 'templates/$slug';
}

/// Every template, in the order the picker shows them.
final List<TemplateEntry> templateCatalog = <TemplateEntry>[
  TemplateEntry(
    slug: 'shop',
    name: 'E-commerce',
    kind: TemplateKind.mobile,
    summary: 'A storefront with cart and checkout',
    description:
        'A storefront in a phone frame, and it is live: search, filter, '
        'sort, save, pick a variant, add to cart, apply the promo code '
        'CAIRN10 and check out through a four-step flow with validated '
        'shipping and payment forms. Orders land in your history. A bottom '
        'Dock replaces the navbar a web store would have.',
    screens: <(String, String)>[
      ('Shop', 'Swipeable promo banner, search, categories, sorting, grid.'),
      ('Product', 'Reviews, variants, quantity, stock and a sticky buy bar.'),
      ('Cart', 'Promo codes, free-shipping progress and a summary.'),
      ('Checkout', 'Shipping, payment and review, then order tracking.'),
      ('Profile', 'Order history, saved addresses and preferences.'),
    ],
    uses: <String>[
      'Dock',
      'Input',
      'Select',
      'Button',
      'Badge',
      'Avatar',
      'Indicator',
      'Skeleton',
      'Accordion',
      'Toggle Group',
      'Radio Group',
      'Rating',
      'List',
      'Steps',
      'Progress',
      'Timeline',
      'Stat',
      'Switch',
      'Mockup',
    ],
    shots: <TemplateShot>[
      const TemplateShot('1-shop', 'Shop'),
      const TemplateShot('2-shop-grid', 'Product grid'),
      const TemplateShot('3-product', 'Product'),
      const TemplateShot('4-cart', 'Cart'),
      const TemplateShot('5-checkout', 'Shipping'),
      const TemplateShot('6-payment', 'Payment'),
      const TemplateShot('7-confirmation', 'Order placed'),
      const TemplateShot('8-profile', 'Profile'),
    ],
    preview: (BuildContext context) => const ShopApp(),
  ),
  TemplateEntry(
    slug: 'dashboard',
    name: 'Dashboard',
    kind: TemplateKind.web,
    summary: 'KPIs, charts and an orders table',
    description:
        'An analytics dashboard with a sidebar, a period picker and three '
        'pages: an overview with KPI cards and a revenue chart, an '
        'analytics page with traffic, device, visitor and conversion charts, '
        'and a sortable, searchable, paged orders table. Every chart is '
        'fl_chart restyled through Cairn tokens, and the layout collapses '
        'to a phone below 760 pixels.',
    screens: <(String, String)>[
      ('Overview', 'Four KPIs with trends, revenue against last period.'),
      ('Analytics', 'Traffic donut, device bars, visitor lines, conversion.'),
      ('Orders', 'Status filters, search, sorting and pagination.'),
      (
        'Period picker',
        '7 days, 30 days or 12 months, applied to every chart.',
      ),
    ],
    uses: <String>[
      'Card',
      'Badge',
      'Button',
      'Toggle Group',
      'Data Table',
      'Alert',
      'List',
      'Avatar',
      'Indicator',
      'Status',
      'Separator',
      'Spinner',
    ],
    shots: <TemplateShot>[
      const TemplateShot('1-overview', 'Overview'),
      const TemplateShot('2-analytics', 'Analytics'),
      const TemplateShot('3-orders', 'Orders'),
      const TemplateShot('4-overview-year', 'Twelve-month view'),
    ],
    preview: (BuildContext context) => const DashboardApp(),
  ),
  TemplateEntry(
    slug: 'blog',
    name: 'Blog',
    kind: TemplateKind.web,
    summary: 'Posts, search, authors and a newsletter',
    description:
        'A responsive blog: a featured post, a filterable and searchable '
        'grid with pagination, rich post pages built from typed content '
        'blocks, an authors page and a newsletter form with validation. '
        'Fifteen seed posts and their photographs are bundled; the data '
        'source is the one place to swap in a CMS.',
    screens: <(String, String)>[
      ('Home', 'Featured post, category chips, search, grid, pagination.'),
      ('Post', 'Headings, quotes, code, images, tags, related posts.'),
      ('About', 'The team, post counts and a shortcut to their posts.'),
      ('Newsletter', 'Validated sign-up with success and error states.'),
    ],
    uses: <String>[
      'Navbar',
      'Input',
      'Button',
      'Badge',
      'Avatar',
      'Card',
      'Pagination',
      'Breadcrumb',
      'Skeleton',
      'Empty',
      'Alert',
      'Toast',
      'Separator',
    ],
    shots: <TemplateShot>[
      const TemplateShot('1-home', 'Home'),
      const TemplateShot('2-home-grid', 'Post grid'),
      const TemplateShot('3-post', 'Post'),
      const TemplateShot('4-about', 'About'),
    ],
    preview: (BuildContext context) => const BlogApp(),
  ),
  TemplateEntry(
    slug: 'docs',
    name: 'Documentation',
    kind: TemplateKind.web,
    summary: 'Sidebar, search palette and content blocks',
    description:
        'A documentation site with a collapsible sidebar, a version '
        'selector, a command palette (Ctrl or Cmd K), an on-this-page rail '
        'that follows the scroll, and pages built from typed blocks: code '
        'with copy, tabs, steps, callouts and tables. On a phone the sidebar '
        'becomes a drawer.',
    screens: <(String, String)>[
      ('Pages', 'Thirteen pages across four sections, with previous and next.'),
      ('Search', 'A command palette over titles and headings.'),
      ('Versions', 'Switch between v2.0 and v1.x content sets.'),
      ('On this page', 'A scroll-following rail of headings.'),
    ],
    uses: <String>[
      'Navbar',
      'Select',
      'Command',
      'Sheet',
      'Breadcrumb',
      'Tabs',
      'Table',
      'Alert',
      'Button',
      'Badge',
      'Kbd',
      'Skeleton',
      'Tooltip',
      'Toast',
    ],
    shots: <TemplateShot>[
      const TemplateShot('1-introduction', 'Introduction'),
      const TemplateShot('2-installation', 'Installation'),
      const TemplateShot('3-api', 'API reference'),
    ],
    preview: (BuildContext context) => const DocsApp(),
  ),
  TemplateEntry(
    slug: 'landing',
    name: 'SaaS landing',
    kind: TemplateKind.web,
    summary: 'Hero, pricing, testimonials and a waitlist',
    description:
        'A one-page product site: a sticky navbar with smooth-scrolling '
        'links, a hero with a product mockup, bento features, numbers, '
        'testimonials, monthly and yearly pricing, an FAQ and a waitlist '
        'form. All copy is JSON in one place, and every section reveals as '
        'you scroll.',
    screens: <(String, String)>[
      ('Hero', 'Headline, calls to action, social proof and a mockup.'),
      ('Features', 'A bento grid and alternating spotlights.'),
      ('Pricing', 'A monthly and yearly toggle over three plans.'),
      ('FAQ', 'An accordion, then a validated waitlist form.'),
    ],
    uses: <String>[
      'Navbar',
      'Button',
      'Badge',
      'Card',
      'Avatar',
      'Rating',
      'Stat',
      'Switch',
      'Accordion',
      'Input',
      'Sheet',
      'Mockup',
      'Toast',
    ],
    shots: <TemplateShot>[
      const TemplateShot('1-hero', 'Hero'),
      const TemplateShot('2-features', 'Features'),
      const TemplateShot('3-pricing', 'Pricing'),
      const TemplateShot('4-faq', 'FAQ'),
    ],
    preview: (BuildContext context) => const LandingApp(),
  ),
  const TemplateEntry(
    slug: 'jaspr_store',
    name: 'Online store (SEO)',
    kind: TemplateKind.web,
    summary: 'Server-rendered, with full SEO',
    serverRendered: true,
    description:
        'A web store rendered on the server with Jaspr, built for search: '
        'every page has its own title, description, canonical, Open Graph '
        'and JSON-LD (Product, Offer, Review, Breadcrumb, ItemList), a '
        'dynamic sitemap and robots.txt, correct redirects and real 404s. '
        'Cart, promo codes and checkout are plain forms that work with '
        'JavaScript off; three small islands add instant feedback. The '
        'tokens come across as CSS variables, in light and dark.',
    screens: <(String, String)>[
      ('Home', 'Hero, categories, featured products, newsletter.'),
      ('Listing', 'Filters, search, sorting and pagination by URL.'),
      ('Product', 'Responsive images, variants, reviews and structured data.'),
      ('Cart', 'A signed, HttpOnly cookie; promo code; free-shipping bar.'),
      ('Checkout', 'Server-side validation with inline errors.'),
    ],
    uses: <String>[],
    shots: <TemplateShot>[
      TemplateShot('1-home', 'Home'),
      TemplateShot('2-listing', 'Listing'),
      TemplateShot('3-product', 'Product'),
      TemplateShot('4-cart', 'Cart'),
      TemplateShot('5-checkout', 'Checkout'),
    ],
    shotExt: 'webp',
    runCommands: '''
cd templates/jaspr_store
dart pub get
dart pub global activate jaspr_cli
jaspr serve        # http://localhost:8080
dart run tool/seo_audit.dart''',
  ),
  TemplateEntry(
    slug: 'onboarding',
    name: 'Onboarding',
    kind: TemplateKind.mobile,
    summary: 'Swipeable intro, permissions, personalise',
    description:
        'A resumable first-run flow: a splash, four swipeable value pages '
        'with photographs, notification and location permission cards with '
        'allowed, denied and settings states, personalisation (interests, '
        'goal, reminder) with validation, an account choice and a '
        'summary. Progress is saved after every change, and the host '
        'receives the result through a callback.',
    screens: <(String, String)>[
      ('Value pages', 'Swipe, dots, skip and back, with photographs.'),
      ('Permissions', 'Explain the benefit, ask, handle denial.'),
      ('Personalise', 'Interests, a goal and reminders, in steps.'),
      ('Account', 'Create, sign in or continue as a guest.'),
      ('Done', 'A summary and the hand-off to your app.'),
    ],
    uses: <String>[
      'Button',
      'Progress',
      'Steps',
      'Toggle',
      'Radio Group',
      'Select',
      'Card',
      'Badge',
      'Alert',
      'Link',
      'Separator',
    ],
    shots: <TemplateShot>[
      const TemplateShot('1-welcome', 'Welcome'),
      const TemplateShot('2-value', 'Value page'),
      const TemplateShot('3-permissions', 'Permissions'),
      const TemplateShot('4-interests', 'Interests'),
      const TemplateShot('5-done', 'Done'),
    ],
    preview: (BuildContext context) => const OnboardingApp(),
  ),
  TemplateEntry(
    slug: 'auth',
    name: 'Authentication',
    kind: TemplateKind.mobile,
    summary: 'Sign in, sign up and recovery',
    description:
        'Seven calm screens for getting into an app: welcome, sign in, sign '
        'up with a live password-strength meter, forgot password, a six-digit '
        'code with paste and a resend countdown, reset, and signed in. '
        'Validation, rate limiting and lockout are pure, tested logic; the '
        'server is an in-memory stand-in you replace. Try ada@example.com with '
        'Cairn-demo-1, and the code 123456.',
    screens: <(String, String)>[
      ('Welcome', 'Social buttons, email entry and legal links.'),
      ('Sign in', 'Show/hide password, remember me, lockout messaging.'),
      ('Sign up', 'Strength meter, rule checklist, terms.'),
      ('Verify', 'Six-digit code, paste, resend cooldown, attempts.'),
      ('Reset', 'A new password, then back to sign in.'),
    ],
    uses: <String>[
      'Input',
      'Input OTP',
      'Button',
      'Checkbox',
      'Alert',
      'Progress',
      'Status',
      'Link',
      'Separator',
      'Avatar',
      'Spinner',
    ],
    shots: <TemplateShot>[
      const TemplateShot('1-welcome', 'Welcome'),
      const TemplateShot('2-signin', 'Sign in'),
      const TemplateShot('3-signed-in', 'Signed in'),
      const TemplateShot('4-signup', 'Sign up'),
    ],
    preview: (BuildContext context) => const AuthApp(showDemoHint: true),
  ),
  TemplateEntry(
    slug: 'chat',
    name: 'Chat',
    kind: TemplateKind.mobile,
    summary: 'Conversations, threads and groups',
    description:
        'A messaging app that behaves like one: a searchable conversation '
        'list with pinned and archived chats, threads with grouped bubbles, '
        'date separators, delivery ticks, replies, reactions, photos and '
        'typing, new one-to-one and group chats, and contact and group '
        'info. A demo contact answers after a short delay. On a tablet it '
        'becomes two panes.',
    screens: <(String, String)>[
      ('Chats', 'Search, pinned, unread badges, archive, mute, delete.'),
      ('Thread', 'Bubbles, replies, reactions, photos, history paging.'),
      ('New chat', 'Pick a contact or build a group.'),
      ('Info', 'Contact or group details, members, block and leave.'),
      ('Profile', 'Your status, availability and settings.'),
    ],
    uses: <String>[
      'Chat Bubble',
      'Avatar',
      'Indicator',
      'Status',
      'Badge',
      'Textarea',
      'Button',
      'Dock',
      'List',
      'Dropdown Menu',
      'Context Menu',
      'Sheet',
      'Alert Dialog',
      'Skeleton',
      'Empty',
      'Switch',
    ],
    shots: <TemplateShot>[
      const TemplateShot('1-chats', 'Chats'),
      const TemplateShot('2-contacts', 'Contacts'),
      const TemplateShot('3-profile', 'Profile'),
      const TemplateShot('4-thread', 'Thread'),
    ],
    preview: (BuildContext context) => const ChatApp(),
  ),
  TemplateEntry(
    slug: 'app_landing',
    name: 'App landing',
    kind: TemplateKind.web,
    summary: 'A page that sells a phone app',
    description:
        'A landing page for a mobile app: a hero with two live, overlapping '
        'phones, feature tabs that switch the screen beside them, a '
        'screenshot carousel, store-style reviews with a rating '
        'distribution, free and premium pricing, an FAQ, and a "send me the '
        'link" form with a QR card. The phone screens are real Cairn UIs, '
        'not images, and all copy lives in one JSON document.',
    screens: <(String, String)>[
      ('Hero', 'Store buttons, rating line and two live phone screens.'),
      ('Features', 'Tabs that swap the phone screen next to the copy.'),
      ('Gallery', 'A carousel of five phones with captions.'),
      ('Reviews', 'Store-style cards and a rating distribution.'),
      ('Download', 'A validated send-me-the-link form and a QR card.'),
    ],
    uses: <String>[
      'Mockup',
      'Navbar',
      'Button',
      'Badge',
      'Card',
      'Avatar',
      'Rating',
      'Tabs',
      'Carousel',
      'Accordion',
      'Input',
      'Stat',
      'Switch',
      'Sheet',
      'Progress',
      'Radial Progress',
    ],
    shots: <TemplateShot>[
      const TemplateShot('1-hero', 'Hero'),
      const TemplateShot('2-features', 'Features'),
      const TemplateShot('3-reviews', 'Reviews'),
      const TemplateShot('4-pricing', 'Pricing'),
    ],
    preview: (BuildContext context) => const AppLandingApp(),
  ),
];

/// Looks up a template by slug.
TemplateEntry? findTemplate(String slug) {
  for (final TemplateEntry t in templateCatalog) {
    if (t.slug == slug) return t;
  }
  return null;
}
