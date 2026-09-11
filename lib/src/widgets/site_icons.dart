import 'package:flutter/widgets.dart';

/// Glyphs the site needs that the library does not ship.
///
/// Cairn draws the handful of icons its components need with a [CustomPainter]
/// rather than bundling an icon font, so that the package stays pure Dart with
/// no assets. The site follows the same rule for the same reason — a marketing
/// page that pulls in a 300 KB icon font to draw six glyphs is exactly the kind
/// of thing this project is arguing against.
///
/// Geometry follows Lucide's own conventions: a 24 x 24 view box, 2px stroke,
/// round caps and round joins, scaled to the requested size so a 16px icon
/// draws a 1.33px stroke exactly as a browser would.
enum SiteIconData {
  /// Two stacked sheets — the code block's copy affordance.
  copy,

  /// A sun. Shown when the dark theme is active.
  sun,

  /// A crescent moon. Shown when the light theme is active.
  moon,

  /// A rightward arrow, for call-to-action buttons.
  arrowRight,

  /// A box with an arrow leaving it, for off-site links.
  externalLink,

  /// A hamburger, for the narrow-layout nav trigger.
  menu,

  /// A shell prompt, for install instructions.
  terminal,

  /// Angle brackets, for the "view code" toggle.
  code,

  /// Stacked planes, for Blocks.
  layers,

  /// A serif capital, for Typeset.
  type,

  /// An axis with bars, for Charts.
  barChart,

  /// A ruler, for the measurement story.
  ruler,

  /// A half-filled circle, for theming.
  contrast,

  /// A shield with a tick, for accessibility.
  shieldCheck,

  /// A crate, for the zero-dependency story.
  package,
}

/// Draws a [SiteIconData] glyph.
class SiteIcon extends StatelessWidget {
  /// Creates an icon.
  const SiteIcon(this.icon, {super.key, this.size = 16.0, this.color});

  /// Which glyph to draw.
  final SiteIconData icon;

  /// The width and height, in logical pixels.
  final double size;

  /// The stroke colour. Falls back to the ambient [IconTheme].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color resolved =
        color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SiteIconPainter(icon: icon, color: resolved),
      ),
    );
  }
}

class _SiteIconPainter extends CustomPainter {
  const _SiteIconPainter({required this.icon, required this.color});

  final SiteIconData icon;
  final Color color;

  static const double _viewBox = 24.0;
  static const double _strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / _viewBox;
    canvas.save();
    canvas.scale(scale);

    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (icon) {
      case SiteIconData.copy:
        canvas.drawRRect(
          RRect.fromLTRBR(8, 8, 22, 22, const Radius.circular(2)),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(4, 16)
            ..cubicTo(2.9, 16, 2, 15.1, 2, 14)
            ..lineTo(2, 4)
            ..cubicTo(2, 2.9, 2.9, 2, 4, 2)
            ..lineTo(14, 2)
            ..cubicTo(15.1, 2, 16, 2.9, 16, 4),
          stroke,
        );
      case SiteIconData.sun:
        canvas.drawCircle(const Offset(12, 12), 4, stroke);
        const List<List<double>> rays = <List<double>>[
          <double>[12, 2, 12, 4],
          <double>[12, 20, 12, 22],
          <double>[4.93, 4.93, 6.34, 6.34],
          <double>[17.66, 17.66, 19.07, 19.07],
          <double>[2, 12, 4, 12],
          <double>[20, 12, 22, 12],
          <double>[6.34, 17.66, 4.93, 19.07],
          <double>[19.07, 4.93, 17.66, 6.34],
        ];
        for (final List<double> r in rays) {
          canvas.drawLine(Offset(r[0], r[1]), Offset(r[2], r[3]), stroke);
        }
      case SiteIconData.moon:
        canvas.drawPath(
          Path()
            ..moveTo(12, 3)
            ..arcToPoint(
              const Offset(21, 12),
              radius: const Radius.circular(6),
              clockwise: false,
            )
            ..arcToPoint(
              const Offset(12, 3),
              radius: const Radius.circular(9),
              largeArc: true,
            )
            ..close(),
          stroke,
        );
      case SiteIconData.arrowRight:
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);
        canvas.drawPath(
          Path()
            ..moveTo(12, 5)
            ..lineTo(19, 12)
            ..lineTo(12, 19),
          stroke,
        );
      case SiteIconData.externalLink:
        canvas.drawPath(
          Path()
            ..moveTo(15, 3)
            ..lineTo(21, 3)
            ..lineTo(21, 9),
          stroke,
        );
        canvas.drawLine(const Offset(10, 14), const Offset(21, 3), stroke);
        canvas.drawPath(
          Path()
            ..moveTo(18, 13)
            ..lineTo(18, 19)
            ..cubicTo(18, 20.1, 17.1, 21, 16, 21)
            ..lineTo(5, 21)
            ..cubicTo(3.9, 21, 3, 20.1, 3, 19)
            ..lineTo(3, 8)
            ..cubicTo(3, 6.9, 3.9, 6, 5, 6)
            ..lineTo(11, 6),
          stroke,
        );
      case SiteIconData.menu:
        for (final double y in <double>[6, 12, 18]) {
          canvas.drawLine(Offset(4, y), Offset(20, y), stroke);
        }
      case SiteIconData.terminal:
        canvas.drawPath(
          Path()
            ..moveTo(4, 17)
            ..lineTo(10, 11)
            ..lineTo(4, 5),
          stroke,
        );
        canvas.drawLine(const Offset(12, 19), const Offset(20, 19), stroke);
      case SiteIconData.code:
        canvas.drawPath(
          Path()
            ..moveTo(16, 18)
            ..lineTo(22, 12)
            ..lineTo(16, 6),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(8, 6)
            ..lineTo(2, 12)
            ..lineTo(8, 18),
          stroke,
        );
      case SiteIconData.layers:
        canvas.drawPath(
          Path()
            ..moveTo(12, 2)
            ..lineTo(22, 7)
            ..lineTo(12, 12)
            ..lineTo(2, 7)
            ..close(),
          stroke,
        );
        for (final double dy in <double>[5, 10]) {
          canvas.drawPath(
            Path()
              ..moveTo(2, 7 + dy)
              ..lineTo(12, 12 + dy)
              ..lineTo(22, 7 + dy),
            stroke,
          );
        }
      case SiteIconData.type:
        canvas.drawPath(
          Path()
            ..moveTo(4, 7)
            ..lineTo(4, 4)
            ..lineTo(20, 4)
            ..lineTo(20, 7),
          stroke,
        );
        canvas.drawLine(const Offset(12, 4), const Offset(12, 20), stroke);
        canvas.drawLine(const Offset(9, 20), const Offset(15, 20), stroke);
      case SiteIconData.barChart:
        canvas.drawPath(
          Path()
            ..moveTo(3, 3)
            ..lineTo(3, 21)
            ..lineTo(21, 21),
          stroke,
        );
        canvas.drawLine(const Offset(8, 17), const Offset(8, 14), stroke);
        canvas.drawLine(const Offset(13, 17), const Offset(13, 5), stroke);
        canvas.drawLine(const Offset(18, 17), const Offset(18, 9), stroke);
      case SiteIconData.ruler:
        canvas.drawRRect(
          RRect.fromLTRBR(2, 8, 22, 16, const Radius.circular(2)),
          stroke,
        );
        for (final double x in <double>[7, 12, 17]) {
          canvas.drawLine(Offset(x, 8), Offset(x, 12), stroke);
        }
      case SiteIconData.contrast:
        canvas.drawCircle(const Offset(12, 12), 9.5, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(12, 2.5)
            ..arcToPoint(
              const Offset(12, 21.5),
              radius: const Radius.circular(9.5),
            )
            ..close(),
          Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );
      case SiteIconData.shieldCheck:
        canvas.drawPath(
          Path()
            ..moveTo(12, 2)
            ..lineTo(20, 5)
            ..lineTo(20, 12)
            ..cubicTo(20, 17.5, 16, 20.5, 12, 22)
            ..cubicTo(8, 20.5, 4, 17.5, 4, 12)
            ..lineTo(4, 5)
            ..close(),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(9, 12)
            ..lineTo(11, 14)
            ..lineTo(15, 10),
          stroke,
        );
      case SiteIconData.package:
        canvas.drawPath(
          Path()
            ..moveTo(12, 2)
            ..lineTo(21, 7)
            ..lineTo(21, 17)
            ..lineTo(12, 22)
            ..lineTo(3, 17)
            ..lineTo(3, 7)
            ..close(),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(3, 7)
            ..lineTo(12, 12)
            ..lineTo(21, 7),
          stroke,
        );
        canvas.drawLine(const Offset(12, 12), const Offset(12, 22), stroke);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SiteIconPainter old) =>
      old.icon != icon || old.color != color;
}
