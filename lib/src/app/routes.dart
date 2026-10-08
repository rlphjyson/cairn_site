/// Every path the site serves, in one place.
///
/// Kept as constants rather than string literals scattered through the widget
/// tree so the nav, the footer, the in-page cross links and the router cannot
/// drift apart — a dead link on a documentation site is the most embarrassing
/// possible bug.
abstract final class Routes {
  /// The landing page.
  static const String home = '/';

  /// The docs index, which redirects to [docsIntroduction].
  static const String docs = '/docs';

  /// The first docs page.
  static const String docsIntroduction = '/docs/introduction';

  /// The component catalogue.
  static const String components = '/components';

  /// Pre-composed screens.
  static const String blocks = '/blocks';

  /// The charts showcase.
  static const String charts = '/charts';

  /// The full index of components and blocks.
  static const String directory = '/directory';

  /// The typography style guide.
  static const String typeset = '/typeset';

  /// The project starter/configurator.
  static const String create = '/create';

  /// The detail page for a single component.
  static String component(String slug) => '/components/$slug';

  /// A single docs page.
  static String doc(String slug) => '/docs/$slug';
}

/// One entry in the site's primary navigation.
class NavDestination {
  /// Creates a destination.
  const NavDestination({
    required this.label,
    required this.path,
    required this.description,
  });

  /// The nav label.
  final String label;

  /// Where it points.
  final String path;

  /// Used by the mobile nav sheet and the command palette.
  final String description;

  /// Whether [location] is inside this destination's subtree.
  bool matches(String location) {
    if (path == Routes.home) return location == Routes.home;
    return location == path || location.startsWith('$path/');
  }
}

/// The primary navigation, ordered from "what is this" through to the
/// reference material.
const List<NavDestination> siteNav = <NavDestination>[
  NavDestination(
    label: 'Home',
    path: Routes.home,
    description: 'What Cairn is and why it exists',
  ),
  NavDestination(
    label: 'Docs',
    path: Routes.docs,
    description: 'Install, theme and use the library',
  ),
  NavDestination(
    label: 'Components',
    path: Routes.components,
    description: 'All 65 components, live',
  ),
  NavDestination(
    label: 'Blocks',
    path: Routes.blocks,
    description: 'Whole screens, composed from components',
  ),
  NavDestination(
    label: 'Charts',
    path: Routes.charts,
    description: 'Data visualisation on Cairn tokens',
  ),
  NavDestination(
    label: 'Directory',
    path: Routes.directory,
    description: 'The searchable index of everything',
  ),
  NavDestination(
    label: 'Typeset',
    path: Routes.typeset,
    description: 'The type scale as a style guide',
  ),
  NavDestination(
    label: 'Create',
    path: Routes.create,
    description: 'Configure a starter project and copy the code',
  ),
];
