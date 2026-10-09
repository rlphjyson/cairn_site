import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../app_landing_text.dart';
import '../layout.dart';

/// The eyebrow, title and subtitle that open most sections.
class SectionHeader extends StatelessWidget {
  /// Creates a header.
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.centered = true,
  });

  /// The eyebrow label above the title.
  final String? eyebrow;

  /// The section title.
  final String title;

  /// The supporting copy.
  final String? subtitle;

  /// Whether to centre the text (otherwise it starts at the leading edge).
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool compact = AppLandingViewport.of(context).isCompact;
    final TextAlign align = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (eyebrow != null) ...<Widget>[
          CairnBadge(variant: CairnBadgeVariant.outline, label: Text(eyebrow!)),
          const SizedBox(height: CairnSpacing.s4),
        ],
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: align,
            style: appLandingText(
              theme,
              CairnTypography.xl4,
              size: compact ? 30 : 40,
              height: 1.15,
              weight: CairnTypography.semibold,
              tight: true,
            ),
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: CairnSpacing.s4),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLandingLayout.maxCopyWidth,
            ),
            child: Text(
              subtitle!,
              textAlign: align,
              style: appLandingText(
                theme,
                compact ? CairnTypography.base : CairnTypography.lg,
                color: theme.mutedForeground,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
