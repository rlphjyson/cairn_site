import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../app/site_theme.dart';
import '../widgets/site_icons.dart';

/// Whole screens assembled out of Cairn components.
///
/// The point of a block is that nothing in it is a new widget. Every one of
/// these is Card + Button + Input + Tabs + Table + Select composed the way an
/// application would compose them — which is the only honest way to show that a
/// component library actually holds together at screen scale.
abstract final class BlockPreviews {
  /// A centred sign-in card.
  static Widget login(BuildContext context) => const _LoginBlock();

  /// A full application shell: sidebar, topbar, stat row, table.
  static Widget dashboard(BuildContext context) => const _DashboardBlock();

  /// A tabbed settings screen.
  static Widget settings(BuildContext context) => const _SettingsBlock();

  /// A three-tier pricing section.
  static Widget pricing(BuildContext context) => const _PricingBlock();

  /// A team roster with per-row role selects.
  static Widget team(BuildContext context) => const _TeamBlock();
}

// ---------------------------------------------------------------------------
// Login
// ---------------------------------------------------------------------------

class _LoginBlock extends StatelessWidget {
  const _LoginBlock();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: 400,
      child: CairnCard(
        children: <Widget>[
          const CairnCardHeader(
            title: Text('Login to your account'),
            description: Text(
              'Enter your email below to sign in to your workspace.',
            ),
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
                    onPressed: () {},
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
                      onPressed: () {},
                      child: const Text('Login'),
                    ),
                    CairnButton(
                      variant: CairnButtonVariant.outline,
                      expand: true,
                      onPressed: () {},
                      leading: const SiteIcon(SiteIconData.code, size: 15),
                      child: const Text('Login with GitHub'),
                    ),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Don\'t have an account?',
                            style: theme
                                .textStyle(CairnTypography.sm)
                                .copyWith(color: theme.mutedForeground),
                          ),
                          CairnButton(
                            variant: CairnButtonVariant.link,
                            size: CairnButtonSize.sm,
                            onPressed: () {},
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------

class _DashboardBlock extends StatefulWidget {
  const _DashboardBlock();

  @override
  State<_DashboardBlock> createState() => _DashboardBlockState();
}

class _DashboardBlockState extends State<_DashboardBlock> {
  String _nav = 'overview';
  String _range = '30d';

  static const List<_Order> _orders = <_Order>[
    _Order('#3210', 'Olivia Martin', 'Fulfilled', 1999.00),
    _Order('#3209', 'Jackson Lee', 'Processing', 39.00),
    _Order('#3208', 'Isabella Nguyen', 'Fulfilled', 299.00),
    _Order('#3207', 'William Kim', 'Cancelled', 99.00),
    _Order('#3206', 'Sofia Davis', 'Fulfilled', 39.00),
    _Order('#3205', 'Liam Johnson', 'Processing', 450.00),
  ];

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Container(
      width: 1000,
      height: 620,
      decoration: BoxDecoration(
        color: theme.background,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: <Widget>[
          // Sidebar.
          Container(
            width: 228,
            decoration: BoxDecoration(
              color: theme.subtleSurface,
              border: Border(right: BorderSide(color: theme.border)),
            ),
            padding: const EdgeInsets.all(CairnSpacing.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(CairnSpacing.s2),
                  child: Row(
                    children: <Widget>[
                      const CairnAvatar(
                        size: CairnAvatarSize.sm,
                        fallback: Text('AC'),
                      ),
                      const SizedBox(width: CairnSpacing.s2p5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Acme Inc.',
                              style: theme
                                  .textStyle(CairnTypography.sm)
                                  .copyWith(
                                    fontWeight: CairnTypography.medium,
                                    color: theme.foreground,
                                  ),
                            ),
                            Text(
                              'Enterprise',
                              style: theme
                                  .textStyle(CairnTypography.xs)
                                  .copyWith(color: theme.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: CairnSpacing.s2),
                const CairnSeparator(),
                const SizedBox(height: CairnSpacing.s3),
                const CairnMenuLabel('Workspace'),
                for (final (String value, String label) in <(String, String)>[
                  ('overview', 'Overview'),
                  ('orders', 'Orders'),
                  ('products', 'Products'),
                  ('customers', 'Customers'),
                ])
                  CairnMenuItem(
                    onPressed: () => setState(() => _nav = value),
                    trailing: _nav == value
                        ? const CairnIcon(CairnIconData.check, size: 14)
                        : null,
                    child: Text(label),
                  ),
                const SizedBox(height: CairnSpacing.s3),
                const CairnMenuLabel('Settings'),
                CairnMenuItem(
                  onPressed: () => setState(() => _nav = 'billing'),
                  trailing: _nav == 'billing'
                      ? const CairnIcon(CairnIconData.check, size: 14)
                      : null,
                  child: const Text('Billing'),
                ),
                const Spacer(),
                const CairnSeparator(),
                const SizedBox(height: CairnSpacing.s3),
                // The avatar goes in the child, not the `leading` slot:
                // CairnMenuItem sizes leading to a 16px icon box, and a small
                // avatar is 32.
                CairnMenuItem(
                  onPressed: () {},
                  child: const Row(
                    children: <Widget>[
                      CairnAvatar(
                        size: CairnAvatarSize.sm,
                        fallback: Text('RJ'),
                      ),
                      SizedBox(width: CairnSpacing.s2p5),
                      Text('rlphjyson'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main column.
          Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: CairnSpacing.s5,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: theme.border)),
                  ),
                  child: Row(
                    children: <Widget>[
                      CairnBreadcrumb(
                        crumbs: <CairnCrumb>[
                          CairnCrumb(label: 'Acme Inc.', onTap: () {}),
                          const CairnCrumb.current(label: 'Overview'),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 200,
                        child: CairnInput(
                          placeholder: 'Search orders...',
                          leading: CairnIcon(
                            CairnIconData.search,
                            color: theme.mutedForeground,
                          ),
                        ),
                      ),
                      const SizedBox(width: CairnSpacing.s3),
                      CairnSelect<String>(
                        value: _range,
                        width: 140,
                        size: CairnSelectSize.sm,
                        options: const <CairnSelectOption<String>>[
                          CairnSelectOption<String>(
                            value: '7d',
                            label: 'Last 7 days',
                          ),
                          CairnSelectOption<String>(
                            value: '30d',
                            label: 'Last 30 days',
                          ),
                          CairnSelectOption<String>(
                            value: '12m',
                            label: 'Last 12 months',
                          ),
                        ],
                        onChanged: (String v) => setState(() => _range = v),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CairnScrollArea(
                    padding: const EdgeInsets.all(CairnSpacing.s5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: CairnSpacing.s5,
                      children: <Widget>[
                        const Row(
                          spacing: CairnSpacing.s4,
                          children: <Widget>[
                            Expanded(
                              child: _StatCard(
                                label: 'Total revenue',
                                value: r'$45,231.89',
                                delta: '+20.1%',
                                progress: 0.78,
                              ),
                            ),
                            Expanded(
                              child: _StatCard(
                                label: 'Subscriptions',
                                value: '+2,350',
                                delta: '+180.1%',
                                progress: 0.62,
                              ),
                            ),
                            Expanded(
                              child: _StatCard(
                                label: 'Sales',
                                value: '+12,234',
                                delta: '+19%',
                                progress: 0.44,
                              ),
                            ),
                            Expanded(
                              child: _StatCard(
                                label: 'Active now',
                                value: '+573',
                                delta: '+201',
                                progress: 0.31,
                              ),
                            ),
                          ],
                        ),
                        CairnCard(
                          children: <Widget>[
                            const CairnCardHeader(
                              title: Text('Recent orders'),
                              description: Text(
                                'Sorted by most recent. Click a header to '
                                're-sort.',
                              ),
                            ),
                            CairnCardContent(
                              child: CairnDataTable<_Order>(
                                rows: _orders,
                                pageSize: 4,
                                searchBy: (_Order o) => o.customer,
                                searchPlaceholder: 'Filter customers...',
                                columns: <CairnColumn<_Order>>[
                                  CairnColumn<_Order>(
                                    label: 'Order',
                                    cell: (_Order o) => Text(o.id),
                                    sortKey: (_Order o) => o.id,
                                  ),
                                  CairnColumn<_Order>(
                                    label: 'Customer',
                                    flex: 2,
                                    cell: (_Order o) => Text(o.customer),
                                    sortKey: (_Order o) => o.customer,
                                  ),
                                  CairnColumn<_Order>(
                                    label: 'Status',
                                    cell: (_Order o) => CairnBadge(
                                      variant: switch (o.status) {
                                        'Fulfilled' =>
                                          CairnBadgeVariant.primary,
                                        'Cancelled' =>
                                          CairnBadgeVariant.destructive,
                                        _ => CairnBadgeVariant.secondary,
                                      },
                                      label: Text(o.status),
                                    ),
                                    sortKey: (_Order o) => o.status,
                                  ),
                                  CairnColumn<_Order>(
                                    label: 'Amount',
                                    alignment: Alignment.centerRight,
                                    cell: (_Order o) => Text(
                                      '\$${o.amount.toStringAsFixed(2)}',
                                    ),
                                    sortKey: (_Order o) => o.amount,
                                  ),
                                ],
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
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.progress,
  });

  final String label;
  final String value;
  final String delta;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnCard(
      gap: CairnSpacing.s3,
      children: <Widget>[
        CairnCardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s2,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme
                          .textStyle(CairnTypography.sm)
                          .copyWith(color: theme.mutedForeground),
                    ),
                  ),
                  CairnBadge(
                    variant: CairnBadgeVariant.outline,
                    label: Text(delta),
                  ),
                ],
              ),
              Text(
                value,
                style: theme
                    .textStyle(CairnTypography.xl2)
                    .copyWith(
                      color: theme.foreground,
                      fontWeight: CairnTypography.semibold,
                      letterSpacing: CairnTypography.trackingTight(24),
                    ),
              ),
              CairnProgress(value: progress, height: 6, semanticLabel: label),
            ],
          ),
        ),
      ],
    );
  }
}

class _Order {
  const _Order(this.id, this.customer, this.status, this.amount);

  final String id;
  final String customer;
  final String status;
  final double amount;
}

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

class _SettingsBlock extends StatefulWidget {
  const _SettingsBlock();

  @override
  State<_SettingsBlock> createState() => _SettingsBlockState();
}

class _SettingsBlockState extends State<_SettingsBlock> {
  String _tab = 'profile';
  bool _marketing = false;
  bool _security = true;
  bool _digest = true;
  String _theme = 'dark';

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return SizedBox(
      width: 620,
      child: CairnCard(
        children: <Widget>[
          const CairnCardHeader(
            title: Text('Settings'),
            description: Text('Manage your account preferences.'),
          ),
          CairnCardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: CairnSpacing.s6,
              children: <Widget>[
                CairnTabs<String>(
                  value: _tab,
                  expand: true,
                  onChanged: (String v) => setState(() => _tab = v),
                  tabs: const <CairnTab<String>>[
                    CairnTab<String>(value: 'profile', label: Text('Profile')),
                    CairnTab<String>(
                      value: 'appearance',
                      label: Text('Appearance'),
                    ),
                    CairnTab<String>(
                      value: 'notifications',
                      label: Text('Notifications'),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: CairnMotion.d200,
                  curve: CairnMotion.standard,
                  alignment: Alignment.topCenter,
                  child: switch (_tab) {
                    'profile' => const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: CairnSpacing.s4,
                      children: <Widget>[
                        CairnFormField(
                          label: 'Display name',
                          description: 'Shown on your public profile.',
                          child: CairnInput(placeholder: 'Ralph Jayson'),
                        ),
                        CairnFormField(
                          label: 'Bio',
                          child: CairnTextarea(
                            placeholder: 'Tell us a little about yourself...',
                          ),
                        ),
                      ],
                    ),
                    'appearance' => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: CairnSpacing.s4,
                      children: <Widget>[
                        Text(
                          'Theme',
                          style: theme
                              .textStyle(CairnTypography.sm)
                              .copyWith(
                                color: theme.foreground,
                                fontWeight: CairnTypography.medium,
                              ),
                        ),
                        CairnRadioGroup<String>(
                          value: _theme,
                          onChanged: (String v) => setState(() => _theme = v),
                          children: const <Widget>[
                            CairnRadioItem<String>(
                              value: 'light',
                              label: Text('Light'),
                            ),
                            CairnRadioItem<String>(
                              value: 'dark',
                              label: Text('Dark'),
                            ),
                            CairnRadioItem<String>(
                              value: 'system',
                              label: Text('Follow the system'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _ => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: CairnSpacing.s1,
                      children: <Widget>[
                        _SettingRow(
                          title: 'Marketing emails',
                          description: 'Product news and occasional offers.',
                          value: _marketing,
                          onChanged: (bool v) => setState(() => _marketing = v),
                        ),
                        const CairnSeparator(),
                        _SettingRow(
                          title: 'Security alerts',
                          description: 'Sign-ins from a new device.',
                          value: _security,
                          onChanged: (bool v) => setState(() => _security = v),
                        ),
                        const CairnSeparator(),
                        _SettingRow(
                          title: 'Weekly digest',
                          description: 'A Monday summary of your workspace.',
                          value: _digest,
                          onChanged: (bool v) => setState(() => _digest = v),
                        ),
                      ],
                    ),
                  },
                ),
              ],
            ),
          ),
          CairnCardFooter(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              CairnButton(
                variant: CairnButtonVariant.ghost,
                onPressed: () {},
                child: const Text('Cancel'),
              ),
              CairnButton(onPressed: () {}, child: const Text('Save changes')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CairnLabel(title),
                const SizedBox(height: CairnSpacing.s1),
                Text(
                  description,
                  style: theme
                      .textStyle(CairnTypography.sm)
                      .copyWith(color: theme.mutedForeground),
                ),
              ],
            ),
          ),
          const SizedBox(width: CairnSpacing.s4),
          CairnSwitch(value: value, semanticLabel: title, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pricing
// ---------------------------------------------------------------------------

class _PricingBlock extends StatelessWidget {
  const _PricingBlock();

  static const List<_Tier> _tiers = <_Tier>[
    _Tier(
      name: 'Hobby',
      price: r'$0',
      cadence: 'forever',
      blurb: 'Everything you need to ship a side project.',
      features: <String>[
        'All 45 components',
        'Light and dark themes',
        'MIT licensed',
        'Community support',
      ],
      featured: false,
    ),
    _Tier(
      name: 'Team',
      price: r'$29',
      cadence: 'per editor / month',
      blurb: 'For product teams who need a shared source of truth.',
      features: <String>[
        'Everything in Hobby',
        'Shared token presets',
        'Figma library sync',
        'Golden-test CI templates',
        'Priority support',
      ],
      featured: true,
    ),
    _Tier(
      name: 'Enterprise',
      price: 'Custom',
      cadence: 'talk to us',
      blurb: 'Governance, audit trails and a named engineer.',
      features: <String>[
        'Everything in Team',
        'SSO and SCIM',
        'Accessibility audit',
        'SLA and onboarding',
      ],
      featured: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Sized from the space actually available rather than from the window
    // width: this block is rendered inside a preview pane on /blocks and
    // inside a page band on /, and those give it very different room.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double card = 300;
        const double gap = CairnSpacing.s5;
        final double available = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 960;
        final int columns = ((available + gap) / (card + gap)).floor().clamp(
          1,
          3,
        );
        return SizedBox(
          width: card * columns + gap * (columns - 1),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            alignment: WrapAlignment.center,
            children: <Widget>[
              for (final _Tier tier in _tiers)
                SizedBox(
                  width: card,
                  child: _TierCard(tier: tier),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Tier {
  const _Tier({
    required this.name,
    required this.price,
    required this.cadence,
    required this.blurb,
    required this.features,
    required this.featured,
  });

  final String name;
  final String price;
  final String cadence;
  final String blurb;
  final List<String> features;
  final bool featured;
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier});

  final _Tier tier;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Widget card = CairnCard(
      children: <Widget>[
        CairnCardHeader(
          title: Text(tier.name),
          description: Text(tier.blurb),
          action: tier.featured
              ? const CairnBadge(label: Text('Popular'))
              : null,
        ),
        CairnCardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s4,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    tier.price,
                    style: theme
                        .textStyle(CairnTypography.xl3)
                        .copyWith(
                          color: theme.foreground,
                          fontWeight: CairnTypography.semibold,
                          letterSpacing: CairnTypography.trackingTight(30),
                        ),
                  ),
                  const SizedBox(width: CairnSpacing.s2),
                  Text(
                    tier.cadence,
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(color: theme.mutedForeground),
                  ),
                ],
              ),
              const CairnSeparator(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: CairnSpacing.s2p5,
                children: <Widget>[
                  for (final String feature in tier.features)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: CairnIcon(
                            CairnIconData.check,
                            size: 14,
                            color: theme.foreground,
                          ),
                        ),
                        const SizedBox(width: CairnSpacing.s2p5),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme
                                .textStyle(CairnTypography.sm)
                                .copyWith(color: theme.mutedForeground),
                          ),
                        ),
                      ],
                    ),
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
                onPressed: () {},
                child: Text(
                  tier.price == 'Custom' ? 'Contact sales' : 'Get started',
                ),
              ),
            ),
          ],
        ),
      ],
    );

    if (!tier.featured) return card;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        boxShadow: <BoxShadow>[
          BoxShadow(color: theme.ring.withValues(alpha: 0.35), spreadRadius: 2),
        ],
      ),
      child: card,
    );
  }
}

// ---------------------------------------------------------------------------
// Team
// ---------------------------------------------------------------------------

class _TeamBlock extends StatefulWidget {
  const _TeamBlock();

  @override
  State<_TeamBlock> createState() => _TeamBlockState();
}

class _TeamBlockState extends State<_TeamBlock> {
  final Map<String, String> _roles = <String, String>{
    'Sofia Davis': 'owner',
    'Jackson Lee': 'member',
    'Isabella Nguyen': 'member',
    'William Kim': 'viewer',
  };

  static const List<CairnSelectOption<String>> _roleOptions =
      <CairnSelectOption<String>>[
        CairnSelectOption<String>(value: 'owner', label: 'Owner'),
        CairnSelectOption<String>(value: 'member', label: 'Member'),
        CairnSelectOption<String>(value: 'viewer', label: 'Viewer'),
      ];

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final List<String> names = _roles.keys.toList();

    return SizedBox(
      width: 560,
      child: CairnCard(
        children: <Widget>[
          CairnCardHeader(
            title: const Text('Team members'),
            description: const Text(
              'Invite collaborators and manage their access.',
            ),
            action: CairnButton(
              variant: CairnButtonVariant.outline,
              size: CairnButtonSize.sm,
              onPressed: () {},
              child: const Text('Invite'),
            ),
          ),
          CairnCardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < names.length; i++) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: CairnSpacing.s3,
                    ),
                    child: Row(
                      children: <Widget>[
                        CairnAvatar(
                          fallback: Text(_initials(names[i])),
                          semanticLabel: names[i],
                        ),
                        const SizedBox(width: CairnSpacing.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                names[i],
                                style: theme
                                    .textStyle(CairnTypography.sm)
                                    .copyWith(
                                      color: theme.foreground,
                                      fontWeight: CairnTypography.medium,
                                    ),
                              ),
                              Text(
                                '${names[i].split(' ').first.toLowerCase()}'
                                '@example.com',
                                style: theme
                                    .textStyle(CairnTypography.sm)
                                    .copyWith(color: theme.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: CairnSpacing.s3),
                        CairnSelect<String>(
                          value: _roles[names[i]],
                          width: 130,
                          size: CairnSelectSize.sm,
                          options: _roleOptions,
                          onChanged: (String v) =>
                              setState(() => _roles[names[i]] = v),
                        ),
                      ],
                    ),
                  ),
                  if (i != names.length - 1) const CairnSeparator(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) => name
      .split(' ')
      .map((String part) => part.isEmpty ? '' : part[0])
      .take(2)
      .join();
}
