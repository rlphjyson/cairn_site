import 'package:flutter/widgets.dart';

import 'block_previews.dart';

/// A pre-composed screen built from several Cairn components.
///
/// A block is a whole screen rather than a primitive — a login page, a
/// dashboard shell, a settings screen — assembled entirely from catalogue
/// components. The point of shipping them is that a design system either holds
/// together at screen scale or it does not, and nothing here is allowed to
/// invent a widget to make a layout work. There is no CLI and nothing to
/// install: a block is exactly what it looks like, a widget tree to read and
/// adapt.
@immutable
class BlockEntry {
  /// Creates a block.
  const BlockEntry({
    required this.name,
    required this.slug,
    required this.description,
    required this.uses,
    required this.builder,
    required this.code,
    this.wide = false,
  });

  /// The block's name.
  final String name;

  /// A stable id, used for anchors and the directory.
  final String slug;

  /// One line about what it is.
  final String description;

  /// Which Cairn components it composes, for the "built from" chip row.
  final List<String> uses;

  /// Builds the live block.
  final WidgetBuilder builder;

  /// The abridged source, shown on the Code tab.
  final String code;

  /// Whether the block needs a desktop-width canvas and should scroll
  /// horizontally on narrow screens rather than reflow.
  final bool wide;
}

/// Every block on the site.
const List<BlockEntry> blockCatalog = <BlockEntry>[
  BlockEntry(
    name: 'Login',
    slug: 'login',
    description:
        'A centred authentication card with an email/password form, a social '
        'provider button and a sign-up link.',
    uses: <String>['Card', 'Form Field', 'Input', 'Button', 'Label'],
    builder: BlockPreviews.login,
    code: '''
SizedBox(
  width: 400,
  child: CairnCard(
    children: <Widget>[
      const CairnCardHeader(
        title: Text('Login to your account'),
        description: Text('Enter your email below to sign in.'),
      ),
      CairnCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: CairnSpacing.s4,
          children: <Widget>[
            const CairnFormField(
              label: 'Email',
              child: CairnInput(placeholder: 'name@example.com'),
            ),
            const CairnFormField(
              label: 'Password',
              child: CairnInput(obscureText: true),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CairnButton(
                variant: CairnButtonVariant.link,
                size: CairnButtonSize.sm,
                onPressed: _recover,
                child: const Text('Forgot your password?'),
              ),
            ),
          ],
        ),
      ),
      CairnCardFooter(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: CairnSpacing.s3,
              children: <Widget>[
                CairnButton(
                  expand: true,
                  onPressed: _signIn,
                  child: const Text('Login'),
                ),
                CairnButton(
                  variant: CairnButtonVariant.outline,
                  expand: true,
                  onPressed: _signInWithGitHub,
                  child: const Text('Login with GitHub'),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
)''',
  ),
  BlockEntry(
    name: 'Dashboard shell',
    slug: 'dashboard',
    description:
        'A complete application frame: a sidebar with grouped navigation, a '
        'top bar with breadcrumbs and a range filter, a row of stat cards and '
        'a sortable, filterable, paginated table.',
    uses: <String>[
      'Menu',
      'Avatar',
      'Separator',
      'Breadcrumb',
      'Input',
      'Select',
      'Card',
      'Badge',
      'Progress',
      'Data Table',
      'Scroll Area',
    ],
    builder: BlockPreviews.dashboard,
    wide: true,
    code: '''
Row(
  children: <Widget>[
    // Sidebar — menu primitives, not a bespoke nav widget.
    Container(
      width: 228,
      decoration: BoxDecoration(
        color: theme.subtleSurface,
        border: Border(right: BorderSide(color: theme.border)),
      ),
      child: Column(
        children: <Widget>[
          const CairnMenuLabel('Workspace'),
          for (final NavItem item in items)
            CairnMenuItem(
              onPressed: () => setState(() => _nav = item.value),
              trailing: _nav == item.value
                  ? const CairnIcon(CairnIconData.check, size: 14)
                  : null,
              child: Text(item.label),
            ),
        ],
      ),
    ),
    Expanded(
      child: Column(
        children: <Widget>[
          _TopBar(range: _range, onRangeChanged: _setRange),
          Expanded(
            child: CairnScrollArea(
              padding: const EdgeInsets.all(CairnSpacing.s5),
              child: Column(
                spacing: CairnSpacing.s5,
                children: <Widget>[
                  const Row(
                    spacing: CairnSpacing.s4,
                    children: <Widget>[
                      Expanded(child: StatCard(label: 'Total revenue')),
                      Expanded(child: StatCard(label: 'Subscriptions')),
                    ],
                  ),
                  CairnCard(
                    children: <Widget>[
                      const CairnCardHeader(title: Text('Recent orders')),
                      CairnCardContent(
                        child: CairnDataTable<Order>(
                          rows: orders,
                          pageSize: 4,
                          searchBy: (Order o) => o.customer,
                          columns: columns,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ],
)''',
  ),
  BlockEntry(
    name: 'Settings',
    slug: 'settings',
    description:
        'A tabbed preferences panel: profile fields, a theme radio group and '
        'a list of notification switches, with the body height animating '
        'between tabs.',
    uses: <String>[
      'Card',
      'Tabs',
      'Form Field',
      'Input',
      'Textarea',
      'Radio Group',
      'Switch',
      'Separator',
      'Button',
    ],
    builder: BlockPreviews.settings,
    code: '''
CairnCard(
  children: <Widget>[
    const CairnCardHeader(
      title: Text('Settings'),
      description: Text('Manage your account preferences.'),
    ),
    CairnCardContent(
      child: Column(
        spacing: CairnSpacing.s6,
        children: <Widget>[
          CairnTabs<String>(
            value: _tab,
            expand: true,
            onChanged: (String v) => setState(() => _tab = v),
            tabs: const <CairnTab<String>>[
              CairnTab<String>(value: 'profile', label: Text('Profile')),
              CairnTab<String>(value: 'appearance', label: Text('Appearance')),
              CairnTab<String>(
                value: 'notifications',
                label: Text('Notifications'),
              ),
            ],
          ),
          // AnimatedSize keeps the card from snapping when the taller
          // notifications panel replaces the shorter profile one.
          AnimatedSize(
            duration: CairnMotion.d200,
            curve: CairnMotion.standard,
            alignment: Alignment.topCenter,
            child: switch (_tab) {
              'profile' => const _ProfilePanel(),
              'appearance' => _AppearancePanel(value: _theme),
              _ => _NotificationsPanel(values: _switches),
            },
          ),
        ],
      ),
    ),
    CairnCardFooter(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        CairnButton(onPressed: _save, child: const Text('Save changes')),
      ],
    ),
  ],
)''',
  ),
  BlockEntry(
    name: 'Pricing',
    slug: 'pricing',
    description:
        'Three tier cards with a highlighted plan. The emphasis on the middle '
        'card is drawn with the theme\'s focus-ring token rather than an '
        'invented accent colour.',
    uses: <String>['Card', 'Badge', 'Separator', 'Button', 'Icon'],
    builder: BlockPreviews.pricing,
    code: '''
CairnCard(
  children: <Widget>[
    CairnCardHeader(
      title: Text(tier.name),
      description: Text(tier.blurb),
      action: tier.featured ? const CairnBadge(label: Text('Popular')) : null,
    ),
    CairnCardContent(
      child: Column(
        spacing: CairnSpacing.s4,
        children: <Widget>[
          _PriceRow(price: tier.price, cadence: tier.cadence),
          const CairnSeparator(),
          for (final String feature in tier.features)
            Row(
              children: <Widget>[
                const CairnIcon(CairnIconData.check, size: 14),
                const SizedBox(width: CairnSpacing.s2p5),
                Expanded(child: Text(feature)),
              ],
            ),
        ],
      ),
    ),
    CairnCardFooter(
      children: <Widget>[
        Expanded(
          child: CairnButton(
            variant: tier.featured
                ? CairnButtonVariant.primary
                : CairnButtonVariant.outline,
            expand: true,
            onPressed: _subscribe,
            child: const Text('Get started'),
          ),
        ),
      ],
    ),
  ],
)''',
  ),
  BlockEntry(
    name: 'Team roster',
    slug: 'team',
    description:
        'A member list with avatars and a per-row role select — the pattern '
        'every settings screen eventually needs.',
    uses: <String>['Card', 'Avatar', 'Select', 'Separator', 'Button'],
    builder: BlockPreviews.team,
    code: '''
CairnCard(
  children: <Widget>[
    CairnCardHeader(
      title: const Text('Team members'),
      description: const Text('Invite collaborators and manage access.'),
      action: CairnButton(
        variant: CairnButtonVariant.outline,
        size: CairnButtonSize.sm,
        onPressed: _invite,
        child: const Text('Invite'),
      ),
    ),
    CairnCardContent(
      child: Column(
        children: <Widget>[
          for (final Member member in members)
            Row(
              children: <Widget>[
                CairnAvatar(fallback: Text(member.initials)),
                const SizedBox(width: CairnSpacing.s3),
                Expanded(child: _MemberIdentity(member: member)),
                CairnSelect<String>(
                  value: member.role,
                  width: 130,
                  size: CairnSelectSize.sm,
                  options: roleOptions,
                  onChanged: (String v) => _setRole(member, v),
                ),
              ],
            ),
        ],
      ),
    ),
  ],
)''',
  ),
];
