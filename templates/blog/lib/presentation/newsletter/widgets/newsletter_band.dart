import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/blog_text.dart';
import '../../../core/presentation/widgets/blog_layout.dart';
import 'newsletter_form.dart';

/// The home page's sign-up call to action: a tinted panel with a pitch on one
/// side and the form on the other (stacked on narrow widths).
class NewsletterBand extends StatelessWidget {
  /// Creates the band.
  const NewsletterBand({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final BlogSize size = BlogLayout.sizeOf(context);
    final bool wide = size == BlogSize.expanded;
    final double pad = size == BlogSize.compact ? CairnSpacing.s6 : 48;

    final Widget pitch = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s2,
      children: <Widget>[
        Text(
          'One email a month. No noise.',
          style: blogText(
            theme,
            CairnTypography.xl2,
            weight: CairnTypography.semibold,
            tight: true,
            height: 1.25,
          ),
        ),
        Text(
          'The best of what we wrote, and a few links we found useful. '
          'Unsubscribe whenever you like.',
          style: blogText(
            theme,
            CairnTypography.base,
            muted: true,
            height: 1.6,
          ),
        ),
      ],
    );
    const Widget form = NewsletterForm(
      fieldLabel: 'Email address for the newsletter',
    );

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: theme.muted.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(theme.radiusScale.xl2),
        border: Border.all(color: theme.border),
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 64,
              children: <Widget>[
                Expanded(child: pitch),
                const Expanded(child: form),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: CairnSpacing.s6,
              children: <Widget>[pitch, form],
            ),
    );
  }
}
