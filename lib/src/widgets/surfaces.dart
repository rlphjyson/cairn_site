import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../app/site_theme.dart';

/// Lifts its child on hover.
///
/// A 2px rise, a brighter border and a shadow, animated over Tailwind's default
/// 150ms / `cubic-bezier(0.4, 0, 0.2, 1)` — the same duration and curve every
/// Cairn component transitions on, read from [CairnMotion] rather than
/// reinvented here.
class HoverLift extends StatefulWidget {
  /// Wraps [child].
  const HoverLift({
    super.key,
    required this.child,
    this.onTap,
    this.lift = 2.0,
    this.borderRadius,
    this.enabled = true,
  });

  /// The content.
  final Widget child;

  /// Called on tap. When null the widget is decorative and shows no pointer.
  final VoidCallback? onTap;

  /// How far to rise, in logical pixels.
  final double lift;

  /// Corner radius for the hover shadow. Defaults to `rounded-xl`.
  final BorderRadius? borderRadius;

  /// Set false to disable the effect without restructuring the tree.
  final bool enabled;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool active = _hovered && widget.enabled;

    final Widget content = AnimatedContainer(
      duration: CairnMotion.d150,
      curve: CairnMotion.standard,
      transform: Matrix4.translationValues(0, active ? -widget.lift : 0, 0),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? CairnRadius.brXl,
        boxShadow: active ? CairnShadows.lg : CairnShadows.none,
        color: active ? theme.hoverTint : const Color(0x00000000),
      ),
      child: widget.child,
    );

    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.onTap == null
          ? content
          : GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: content,
            ),
    );
  }
}

/// A faint dot grid, used behind live previews.
///
/// Gives a preview surface a sense of being a canvas rather than a card, and
/// makes transparent components (ghost buttons, `bg-transparent` inputs) read
/// as deliberately transparent rather than broken.
class DotGrid extends StatelessWidget {
  /// Paints a grid behind [child].
  const DotGrid({super.key, required this.child, this.spacing = 16.0});

  /// The content painted over the grid.
  final Widget child;

  /// The distance between dots.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CustomPaint(
      painter: _DotGridPainter(
        color: theme.brightness == Brightness.dark
            ? theme.foreground.withValues(alpha: 0.055)
            : theme.foreground.withValues(alpha: 0.06),
        spacing: spacing,
      ),
      child: child,
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color, required this.spacing});

  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) =>
      old.color != color || old.spacing != spacing;
}

/// Guarantees [minWidth] to its child, scrolling horizontally below that.
///
/// Live previews are the one place on this site with a genuine layout
/// conflict. A dashboard block wants 1000 logical pixels and a phone has 360.
/// Shrinking it with a `FittedBox` would make its data table unreadable — and
/// `FittedBox` lays its child out unbounded, which breaks anything containing
/// an `Expanded`. Letting it overflow paints Flutter's yellow-and-black
/// stripes. So: hand the child a *bounded* width of at least [minWidth], and
/// install a scroller only when the viewport is actually narrower than that.
///
/// Two consequences worth stating, because both were bugs before this existed:
///
/// * The child always gets bounded width, so a `Wrap` inside a preview really
///   wraps instead of laying every chip out on one infinite line.
/// * At desktop width there is no `Scrollable` in the tree at all, so nothing
///   competes in the gesture arena with a preview's own horizontal drags —
///   which is what a Slider and a Carousel both use.
class MinWidthScroller extends StatelessWidget {
  /// Wraps [child].
  const MinWidthScroller({
    super.key,
    required this.child,
    this.minWidth = 640.0,
    this.alignment = Alignment.center,
  });

  /// The content.
  final Widget child;

  /// The narrowest the child is ever laid out at.
  final double minWidth;

  /// Where the content sits once it has room.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget aligned = Align(alignment: alignment, child: child);
        if (constraints.hasBoundedWidth && constraints.maxWidth >= minWidth) {
          return aligned;
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: aligned),
        );
      },
    );
  }
}

/// A page-level heading with an optional eyebrow and lead paragraph.
class PageHeading extends StatelessWidget {
  /// Creates a heading.
  const PageHeading({
    super.key,
    required this.title,
    this.eyebrow,
    this.lead,
    this.trailing,
  });

  /// The `h1`.
  final String title;

  /// A small uppercase label above the title.
  final String? eyebrow;

  /// The paragraph under the title.
  final String? lead;

  /// Placed opposite the title on wide layouts.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (eyebrow != null) ...<Widget>[
          Text(
            eyebrow!.toUpperCase(),
            style: theme
                .textStyle(CairnTypography.xs)
                .copyWith(
                  color: theme.mutedForeground,
                  fontWeight: CairnTypography.medium,
                  letterSpacing: CairnTypography.trackingWidest(12) / 2,
                ),
          ),
          const SizedBox(height: CairnSpacing.s3),
        ],
        Text(
          title,
          style: theme
              .textStyle(CairnTypography.xl4)
              .copyWith(
                color: theme.foreground,
                fontWeight: CairnTypography.semibold,
                letterSpacing: CairnTypography.trackingTight(36),
              ),
        ),
        if (lead != null) ...<Widget>[
          const SizedBox(height: CairnSpacing.s4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              lead!,
              style: theme
                  .textStyle(CairnTypography.lg)
                  .copyWith(color: theme.mutedForeground),
            ),
          ),
        ],
      ],
    );

    if (trailing == null) return text;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < SiteTokens.tabletBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s6,
            children: <Widget>[text, trailing!],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(child: text),
            const SizedBox(width: CairnSpacing.s8),
            trailing!,
          ],
        );
      },
    );
  }
}

/// A section heading inside a page, with an anchor id for deep links.
class SectionHeading extends StatelessWidget {
  /// Creates a section heading.
  const SectionHeading(this.title, {super.key, this.subtitle, this.level = 2});

  /// The heading text.
  final String title;

  /// An optional paragraph under it.
  final String? subtitle;

  /// 2 for `h2`, 3 for `h3`.
  final int level;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle base = level == 2
        ? CairnTypography.xl2
        : CairnTypography.lg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme
              .textStyle(base)
              .copyWith(
                color: theme.foreground,
                fontWeight: CairnTypography.semibold,
                letterSpacing: CairnTypography.trackingTight(
                  base.fontSize ?? 24,
                ),
              ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: CairnSpacing.s2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              subtitle!,
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(color: theme.mutedForeground),
            ),
          ),
        ],
      ],
    );
  }
}

/// Body copy, at the size Cairn's components use for everything else.
class Prose extends StatelessWidget {
  /// Creates a paragraph.
  const Prose(this.text, {super.key, this.maxWidth = 680});

  /// The paragraph.
  final String text;

  /// The reading measure.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        text,
        style: theme
            .textStyle(CairnTypography.sm)
            .copyWith(
              color: theme.mutedForeground,
              height: CairnTypography.leadingRelaxed,
            ),
      ),
    );
  }
}

/// Constrains a page body to the site's reading width and gutters.
class PageContainer extends StatelessWidget {
  /// Wraps [child].
  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = SiteTokens.contentMaxWidth,
    this.padding,
  });

  /// The content.
  final Widget child;

  /// The maximum width of the content column.
  final double maxWidth;

  /// Overrides the default gutters.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double gutter = width < SiteTokens.tabletBreakpoint
        ? CairnSpacing.s5
        : CairnSpacing.s10;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: gutter,
                vertical: CairnSpacing.s10,
              ),
          child: child,
        ),
      ),
    );
  }
}
