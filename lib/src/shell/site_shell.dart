import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../app/links.dart';
import '../app/routes.dart';
import '../app/site_theme.dart';
import '../data/blocks_catalog.dart';
import '../data/components_catalog.dart';
import '../widgets/site_icons.dart';

/// The persistent chrome around every route: sticky header, scrolling body,
/// footer, and the Ctrl+K command palette.
///
/// Almost everything visible here is a Cairn widget doing the site's own job
/// rather than being demonstrated in isolation — the nav items are
/// [CairnButton]s, the search trigger is a [CairnButton] with a [CairnKbdGroup]
/// inside it, the mobile nav is a real [CairnSheet] full of [CairnMenuItem]s,
/// and Ctrl+K opens the library's own command palette wired to the real routes.
class SiteShell extends StatelessWidget {
  /// Wraps [child] in the site chrome.
  const SiteShell({super.key, required this.child});

  /// The current route's page.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            openCommandPalette(context),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            openCommandPalette(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: theme.background,
          body: Column(
            children: <Widget>[
              const _SiteHeader(),
              // Each route owns its own scroller — see SitePage.
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens Cairn's own command palette, populated with the site's routes.
void openCommandPalette(BuildContext context) {
  final GoRouter router = GoRouter.of(context);
  unawaited(
    showCairnCommandPalette(
      context: context,
      placeholder: 'Search pages and components...',
      items: <CairnCommandItem>[
        for (final NavDestination destination in siteNav)
          CairnCommandItem(
            label: destination.label,
            group: 'Pages',
            keywords: <String>[destination.description],
            onSelected: () => router.go(destination.path),
          ),
        for (final BlockEntry block in blockCatalog)
          CairnCommandItem(
            label: block.name,
            group: 'Blocks',
            keywords: <String>[block.description],
            onSelected: () => router.go(Routes.blocks),
          ),
        for (final ComponentEntry entry in componentCatalog)
          CairnCommandItem(
            label: entry.name,
            group: 'Components',
            keywords: <String>[entry.description, ...entry.alsoExports],
            onSelected: () => router.go(entry.path),
          ),
      ],
    ),
  );
}

class _SiteHeader extends StatelessWidget {
  const _SiteHeader();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= SiteTokens.desktopBreakpoint;
    // Eight nav items plus a wordmark leave very little room at 1024. The
    // search trigger and the GitHub link earn their place back as the viewport
    // grows, rather than being squeezed until the row overflows.
    final bool showSearch = width >= 1300 || (!wide && width >= 700);
    final bool showGitHub = width >= 1200 || (!wide && width >= 480);

    return ClipRect(
      child: BackdropFilter(
        // A translucent `--background` with a backdrop blur, so content scrolls
        // under the header rather than behind an opaque bar. Flutter's
        // BackdropFilter needs the ClipRect above it or it samples the whole
        // layer tree and the blur bleeds down the page.
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: SiteTokens.headerHeight,
          decoration: BoxDecoration(
            color: theme.background.withValues(alpha: 0.82),
            border: Border(bottom: BorderSide(color: theme.border)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: SiteTokens.contentMaxWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? CairnSpacing.s10 : CairnSpacing.s4,
                ),
                child: Row(
                  children: <Widget>[
                    if (!wide) ...<Widget>[
                      const _MobileNavTrigger(),
                      const SizedBox(width: CairnSpacing.s2),
                    ],
                    const _Wordmark(),
                    if (wide) ...<Widget>[
                      const SizedBox(width: CairnSpacing.s6),
                      const _DesktopNav(),
                    ],
                    const Spacer(),
                    if (showSearch) ...<Widget>[
                      const _SearchTrigger(),
                      const SizedBox(width: CairnSpacing.s2),
                    ],
                    if (showGitHub) ...<Widget>[
                      const _GitHubLink(),
                      const SizedBox(width: CairnSpacing.s1),
                    ],
                    const ThemeToggle(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(Routes.home),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CairnMark(size: 18),
            const SizedBox(width: CairnSpacing.s2p5),
            Text(
              'Cairn',
              style: theme
                  .textStyle(CairnTypography.base)
                  .copyWith(
                    color: theme.foreground,
                    fontWeight: CairnTypography.semibold,
                    letterSpacing: CairnTypography.trackingTight(16),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The wordmark glyph: three stacked stones, narrowing upwards.
///
/// A cairn is a stack of stones that marks a route — which is what a design
/// system is. Drawn rather than imported so the site ships no image assets.
class CairnMark extends StatelessWidget {
  /// Creates the mark.
  const CairnMark({super.key, this.size = 20.0, this.color});

  /// The height and width in logical pixels.
  final double size;

  /// Overrides the foreground colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CairnMarkPainter(color: color ?? theme.foreground),
      ),
    );
  }
}

class _CairnMarkPainter extends CustomPainter {
  const _CairnMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.width / 24.0;
    final Paint fill = Paint()..color = color;
    void stone(double x, double y, double w, double h, double r) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * unit, y * unit, w * unit, h * unit),
          Radius.circular(r * unit),
        ),
        fill,
      );
    }

    stone(3, 16, 18, 5, 2.5);
    stone(5.5, 9.5, 13, 5, 2.5);
    stone(8.5, 3, 7, 5, 2.5);
  }

  @override
  bool shouldRepaint(_CairnMarkPainter old) => old.color != color;
}

/// The active path, readable from anywhere under the router.
///
/// `GoRouterState.of(context)` only works inside a `RouteBase.builder`, and the
/// shell is also mounted by `errorBuilder` — which is not one. Asking the
/// delegate for its current configuration works in both places, so a 404 still
/// gets the real header instead of throwing.
String currentLocation(BuildContext context) =>
    GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

class _DesktopNav extends StatelessWidget {
  const _DesktopNav();

  @override
  Widget build(BuildContext context) {
    final String location = currentLocation(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final NavDestination destination in siteNav)
          if (destination.primary)
            _NavLink(
              destination: destination,
              active: destination.matches(location),
            ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.destination, required this.active});

  final NavDestination destination;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CairnSpacing.s0p5),
      child: CairnButton(
        variant: CairnButtonVariant.ghost,
        size: CairnButtonSize.sm,
        onPressed: () => context.go(destination.path),
        child: Text(
          destination.label,
          style: TextStyle(
            color: active ? theme.foreground : theme.mutedForeground,
            fontWeight: active
                ? CairnTypography.medium
                : CairnTypography.normal,
          ),
        ),
      ),
    );
  }
}

class _SearchTrigger extends StatelessWidget {
  const _SearchTrigger();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    // The Kbd hint deliberately does *not* go in the button's `trailing` slot.
    // CairnButton wraps leading/trailing in `SizedBox.square(iconSize)` so that
    // icons are uniform whatever their intrinsic size — anything that is not an
    // icon
    // — a two-key Kbd group is about 54 logical pixels wide — overflows a 16px
    // box. The slot is for icons; everything else belongs in the child.
    return SizedBox(
      width: 240,
      child: CairnButton(
        variant: CairnButtonVariant.outline,
        size: CairnButtonSize.sm,
        expand: true,
        onPressed: () => openCommandPalette(context),
        child: Row(
          children: <Widget>[
            CairnIcon(
              CairnIconData.search,
              size: 14,
              color: theme.mutedForeground,
            ),
            const SizedBox(width: CairnSpacing.s2),
            Expanded(
              child: Text(
                'Search...',
                style: TextStyle(color: theme.mutedForeground),
              ),
            ),
            const CairnKbdGroup(keys: <String>['Ctrl', 'K']),
          ],
        ),
      ),
    );
  }
}

class _GitHubLink extends StatelessWidget {
  const _GitHubLink();

  @override
  Widget build(BuildContext context) {
    return CairnTooltip(
      message: 'View the source on GitHub',
      openDelay: const Duration(milliseconds: 400),
      child: CairnButton(
        variant: CairnButtonVariant.ghost,
        size: CairnButtonSize.sm,
        onPressed: () => openExternal(SiteLinks.libraryRepo),
        trailing: const SiteIcon(SiteIconData.externalLink, size: 14),
        child: const Text('GitHub'),
      ),
    );
  }
}

/// The light/dark switch.
///
/// Dark is the default the site boots into; this only ever moves between the
/// two explicit themes, so the control is never a no-op.
class ThemeToggle extends StatelessWidget {
  /// Creates the toggle.
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final SiteThemeController controller = SiteTheme.of(context);
    return CairnTooltip(
      message: controller.isDark ? 'Switch to light' : 'Switch to dark',
      openDelay: const Duration(milliseconds: 400),
      child: CairnButton.icon(
        icon: AnimatedSwitcher(
          duration: CairnMotion.d200,
          switchInCurve: CairnMotion.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              RotationTransition(
                turns: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
          child: SiteIcon(
            controller.isDark ? SiteIconData.sun : SiteIconData.moon,
            key: ValueKey<bool>(controller.isDark),
            size: 16,
          ),
        ),
        semanticLabel: controller.isDark
            ? 'Switch to the light theme'
            : 'Switch to the dark theme',
        variant: CairnButtonVariant.ghost,
        size: CairnButtonSize.iconSm,
        onPressed: controller.toggle,
      ),
    );
  }
}

class _MobileNavTrigger extends StatelessWidget {
  const _MobileNavTrigger();

  @override
  Widget build(BuildContext context) {
    return CairnButton.icon(
      icon: const SiteIcon(SiteIconData.menu),
      semanticLabel: 'Open navigation',
      variant: CairnButtonVariant.ghost,
      size: CairnButtonSize.iconSm,
      onPressed: () => unawaited(_openNavSheet(context)),
    );
  }
}

Future<void> _openNavSheet(BuildContext context) {
  final GoRouter router = GoRouter.of(context);
  final String location = currentLocation(context);
  return showCairnSheet<void>(
    context: context,
    side: CairnSheetSide.left,
    builder: (BuildContext sheetContext) => CairnSheet(
      side: CairnSheetSide.left,
      title: const Text('Cairn UI'),
      description: const Text(
        'A modern, accessible component library for Flutter.',
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final NavDestination destination in siteNav)
            CairnMenuItem(
              onPressed: () {
                Navigator.pop(sheetContext);
                router.go(destination.path);
              },
              trailing: destination.matches(location)
                  ? const CairnIcon(CairnIconData.check, size: 14)
                  : null,
              child: Text(destination.label),
            ),
          const CairnMenuSeparator(),
          CairnMenuItem(
            onPressed: () => openExternal(SiteLinks.libraryRepo),
            trailing: const SiteIcon(SiteIconData.externalLink, size: 14),
            child: const Text('GitHub'),
          ),
        ],
      ),
    ),
  );
}
