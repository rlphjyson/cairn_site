import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/presentation/navigation/blog_navigation_cubit.dart';
import '../../core/presentation/widgets/blog_layout.dart';
import '../authors/views/about_view.dart';
import '../feed/bloc/posts_feed_cubit.dart';
import '../feed/views/feed_view.dart';
import '../post/views/post_detail_view.dart';
import 'blog_footer.dart';
import 'blog_navbar.dart';

/// The blog's frame: a sticky navbar above a scrolling page that ends in the
/// footer. Switches pages on [BlogNavigationCubit] and scrolls back to the top
/// whenever the page changes.
class BlogShell extends StatefulWidget {
  /// Creates the shell.
  const BlogShell({super.key});

  @override
  State<BlogShell> createState() => _BlogShellState();
}

class _BlogShellState extends State<BlogShell> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PostsFeedCubit>().ensureLoaded();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toTop({bool animate = false}) {
    if (!_scroll.hasClients) return;
    if (animate) {
      _scroll.animateTo(
        0,
        duration: CairnMotion.d300,
        curve: CairnMotion.standard,
      );
    } else {
      _scroll.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return BlogLayout(
          size: BlogSize.of(constraints.maxWidth),
          child: ColoredBox(
            color: theme.background,
            child: Column(
              children: <Widget>[
                const BlogNavbar(),
                Expanded(
                  child: BlocListener<BlogNavigationCubit, BlogRoute>(
                    listener: (BuildContext context, BlogRoute route) =>
                        _toTop(),
                    // The page is at least as tall as the viewport, so a short
                    // page pushes the footer to the bottom edge.
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints area) =>
                          SingleChildScrollView(
                            controller: _scroll,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: area.maxHeight,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const _Page(),
                                  BlogFooter(
                                    onBackToTop: () => _toTop(animate: true),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The current page, cross-faded when the route changes.
class _Page extends StatelessWidget {
  const _Page();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlogNavigationCubit, BlogRoute>(
      builder: (BuildContext context, BlogRoute route) => AnimatedSwitcher(
        duration: CairnMotion.d150,
        layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[...previous, ?current],
        ),
        child: KeyedSubtree(
          key: ValueKey<BlogRoute>(route),
          child: switch (route) {
            HomeRoute() => const FeedView(),
            PostRoute(:final String id) => PostDetailView(postId: id),
            AboutRoute() => const AboutView(),
          },
        ),
      ),
    );
  }
}
