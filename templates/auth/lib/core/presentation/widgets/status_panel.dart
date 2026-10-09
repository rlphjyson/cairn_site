import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../auth_text.dart';

/// A centred confirmation: a round glyph, a heading and a sentence.
///
/// Used for "Check your inbox" and "Password updated". It is a live region so
/// the change is announced when it replaces a form.
class StatusPanel extends StatelessWidget {
  /// Creates a panel.
  const StatusPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.tone = CairnTone.primary,
  });

  /// The glyph, drawn at 28 px.
  final IconData icon;

  /// The heading.
  final String title;

  /// The sentence under the heading.
  final String body;

  /// The tone of the glyph's disc.
  final CairnTone tone;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final CairnToneColor colors = CairnToneColors.resolve(theme, tone);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Column(
        spacing: 12,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.fill,
            ),
            child: Icon(icon, size: 28, color: colors.onFill),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: authText(
              theme,
              CairnTypography.xl2,
              weight: CairnTypography.semibold,
              letterSpacing: CairnTypography.trackingTight(24),
            ),
          ),
          Text(
            body,
            textAlign: TextAlign.center,
            style: authText(
              theme,
              CairnTypography.sm,
              color: theme.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
