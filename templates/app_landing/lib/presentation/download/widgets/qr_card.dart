import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/app_landing_text.dart';
import '../../../domain/download/models/download_content.dart';
import '../../../domain/download/models/qr_pattern.dart';

/// A card with a QR-style pattern, a caption and a note that marks it as a
/// demo.
///
/// The pattern is drawn by [QrPainter] from a [QrPattern]; it is deterministic
/// and **will not scan**. To ship a real code, replace [QrPainter] with a
/// package that renders your smart link (see the docs).
class QrCard extends StatelessWidget {
  /// Creates the card.
  const QrCard({super.key, required this.content, required this.pattern});

  /// The copy.
  final QrCardContent content;

  /// The pattern, or `null` while it is being built.
  final QrPattern? pattern;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final QrPattern? p = pattern;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl2),
        border: Border.all(color: theme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CairnSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                content.title,
                textAlign: TextAlign.center,
                style: appLandingText(
                  theme,
                  CairnTypography.lg,
                  weight: CairnTypography.semibold,
                  tight: true,
                ),
              ),
            ),
            const SizedBox(height: CairnSpacing.s4),
            Semantics(
              image: true,
              label: content.demoNote,
              child: ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.card,
                    borderRadius: BorderRadius.circular(theme.radiusScale.lg),
                    border: Border.all(color: theme.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(CairnSpacing.s3),
                    child: SizedBox.square(
                      dimension: 152,
                      child: p == null
                          ? null
                          : CustomPaint(
                              painter: QrPainter(
                                pattern: p,
                                dark: theme.foreground,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: CairnSpacing.s4),
            Text(
              content.caption,
              textAlign: TextAlign.center,
              style: appLandingText(
                theme,
                CairnTypography.sm,
                color: theme.mutedForeground,
                height: 1.5,
              ),
            ),
            const SizedBox(height: CairnSpacing.s3),
            CairnBadge(
              variant: CairnBadgeVariant.secondary,
              label: Text(content.badge),
            ),
            const SizedBox(height: CairnSpacing.s2),
            Text(
              content.demoNote,
              textAlign: TextAlign.center,
              style: appLandingText(
                theme,
                CairnTypography.xs,
                color: theme.mutedForeground,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a [QrPattern] as square modules in [dark] on a transparent
/// background.
class QrPainter extends CustomPainter {
  /// Creates a painter.
  const QrPainter({required this.pattern, required this.dark});

  /// The modules to draw.
  final QrPattern pattern;

  /// The colour of a dark module.
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    final double cell = size.shortestSide / pattern.size;
    final Paint paint = Paint()..color = dark;
    for (int y = 0; y < pattern.size; y++) {
      for (int x = 0; x < pattern.size; x++) {
        if (!pattern.isDark(x, y)) continue;
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell + 0.4, cell + 0.4),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(QrPainter oldDelegate) =>
      oldDelegate.pattern != pattern || oldDelegate.dark != dark;
}
