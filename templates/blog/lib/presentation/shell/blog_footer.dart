import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/constants/blog_brand.dart';
import '../../core/presentation/blog_text.dart';
import '../../core/presentation/navigation/blog_navigation_cubit.dart';
import '../../core/presentation/widgets/blog_layout.dart';
import '../feed/bloc/posts_feed_cubit.dart';
import '../newsletter/widgets/newsletter_form.dart';

/// The page footer: brand, a compact sign-up form, links and the copyright.
class BlogFooter extends StatelessWidget {
  /// Creates the footer.
  const BlogFooter({super.key, required this.onBackToTop});

  /// Scrolls the page back to the top.
  final VoidCallback onBackToTop;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final BlogSize size = BlogLayout.sizeOf(context);
    final bool expanded = size == BlogSize.expanded;
    final bool compact = size == BlogSize.compact;
    final BlogNavigationCubit nav = context.read<BlogNavigationCubit>();
    final PostsFeedCubit feed = context.read<PostsFeedCubit>();
    final List<String> categories = context.select(
      (PostsFeedCubit c) => c.state.categories,
    );

    final Widget brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s3,
      children: <Widget>[
        Text(
          BlogBrand.name,
          style: blogText(
            theme,
            CairnTypography.lg,
            weight: CairnTypography.semibold,
            tight: true,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Text(
            BlogBrand.tagline,
            style: blogText(
              theme,
              CairnTypography.sm,
              muted: true,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: CairnSpacing.s2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: const NewsletterForm(
            fieldLabel: 'Email address for the footer newsletter',
          ),
        ),
      ],
    );

    final Widget explore = _LinkColumn(
      title: 'Explore',
      links: <_FooterLink>[
        _FooterLink('All posts', () {
          feed.clearFilters();
          nav.openHome();
        }),
        _FooterLink('About', nav.openAbout),
        _FooterLink('Back to top', onBackToTop),
      ],
    );

    final Widget topics = _LinkColumn(
      title: 'Topics',
      links: <_FooterLink>[
        for (final String c in categories)
          _FooterLink(c, () {
            feed.clearFilters();
            feed.selectCategory(c);
            nav.openHome();
          }),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.muted.withValues(alpha: 0.35),
        border: Border(top: BorderSide(color: theme.border)),
      ),
      child: PageContainer(
        padding: EdgeInsets.only(top: compact ? 40 : 64, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (expanded)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 5, child: brand),
                  const SizedBox(width: 64),
                  Expanded(flex: 2, child: explore),
                  Expanded(flex: 2, child: topics),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: CairnSpacing.s8,
                children: <Widget>[
                  brand,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: explore),
                      Expanded(child: topics),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: CairnSpacing.s10),
            const CairnSeparator(),
            const SizedBox(height: CairnSpacing.s6),
            Text(
              '© ${DateTime.now().year} ${BlogBrand.copyright}',
              style: blogText(theme, CairnTypography.xs, muted: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink {
  const _FooterLink(this.label, this.onPressed);

  final String label;
  final VoidCallback onPressed;
}

class _LinkColumn extends StatelessWidget {
  const _LinkColumn({required this.title, required this.links});

  final String title;
  final List<_FooterLink> links;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s3,
      children: <Widget>[
        Text(
          title,
          style: blogText(
            theme,
            CairnTypography.sm,
            weight: CairnTypography.semibold,
          ),
        ),
        for (final _FooterLink l in links)
          CairnLink(muted: true, onPressed: l.onPressed, child: Text(l.label)),
      ],
    );
  }
}
