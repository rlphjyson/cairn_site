import 'package:cairn_template_blog/cairn_template_blog.dart';
import 'package:cairn_template_dashboard/cairn_template_dashboard.dart';
import 'package:cairn_template_docs/cairn_template_docs.dart';
import 'package:cairn_template_landing/cairn_template_landing.dart';
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
    required this.preview,
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

  /// Builds the live template.
  final WidgetBuilder preview;

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
];

/// Looks up a template by slug.
TemplateEntry? findTemplate(String slug) {
  for (final TemplateEntry t in templateCatalog) {
    if (t.slug == slug) return t;
  }
  return null;
}
