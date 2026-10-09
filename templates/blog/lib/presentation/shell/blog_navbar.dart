import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/constants/blog_brand.dart';
import '../../core/presentation/blog_text.dart';
import '../../core/presentation/navigation/blog_navigation_cubit.dart';
import '../../core/presentation/widgets/blog_layout.dart';
import '../../core/presentation/widgets/pressable.dart';
import '../feed/bloc/posts_feed_cubit.dart';

/// The sticky top bar: brand, page links and search.
///
/// On compact widths the search field folds behind an icon and opens in a
/// row under the bar.
class BlogNavbar extends StatefulWidget {
  /// Creates the navbar.
  const BlogNavbar({super.key});

  @override
  State<BlogNavbar> createState() => _BlogNavbarState();
}

class _BlogNavbarState extends State<BlogNavbar> {
  bool _searchOpen = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final BlogSize size = BlogLayout.sizeOf(context);
    final bool compact = size == BlogSize.compact;
    final double gutter = BlogLayout.gutterFor(size);
    final BlogNavigationCubit nav = context.read<BlogNavigationCubit>();
    final bool hasQuery = context.select(
      (PostsFeedCubit c) => c.state.query.search.isNotEmpty,
    );
    final bool searchVisible = _searchOpen || hasQuery;

    final Widget links = BlocBuilder<BlogNavigationCubit, BlogRoute>(
      builder: (BuildContext context, BlogRoute route) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s1,
        children: <Widget>[
          _NavLink(
            label: 'Blog',
            active: route is! AboutRoute,
            onPressed: nav.openHome,
          ),
          _NavLink(
            label: 'About',
            active: route is AboutRoute,
            onPressed: nav.openAbout,
          ),
        ],
      ),
    );

    final Widget bar = CairnNavbar(
      bordered: false,
      color: const Color(0x00000000),
      start: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const _Brand(),
          if (!compact) ...<Widget>[const SizedBox(width: 28), links],
        ],
      ),
      end: compact
          ? Row(
              mainAxisSize: MainAxisSize.min,
              spacing: CairnSpacing.s1,
              children: <Widget>[
                links,
                CairnButton.icon(
                  icon: const CairnIcon(CairnIconData.search),
                  semanticLabel: searchVisible ? 'Hide search' : 'Search posts',
                  variant: CairnButtonVariant.ghost,
                  size: CairnButtonSize.iconSm,
                  onPressed: () => setState(() => _searchOpen = !searchVisible),
                ),
              ],
            )
          : SizedBox(
              width: size == BlogSize.medium ? 210 : 280,
              child: const SearchField(),
            ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1264),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: gutter > 16 ? gutter - 16 : 0,
                ),
                child: bar,
              ),
            ),
          ),
          AnimatedSize(
            duration: CairnMotion.d200,
            curve: CairnMotion.standard,
            alignment: Alignment.topCenter,
            child: compact && searchVisible
                ? Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 12),
                    child: const SearchField(autofocus: true),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Pressable(
      semanticLabel: '${BlogBrand.name}, go to the blog',
      onTap: () => context.read<BlogNavigationCubit>().openHome(),
      builder: (BuildContext context, PressState state) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: CairnSpacing.s2p5,
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(theme.radiusScale.md),
              ),
              child: Text(
                BlogBrand.mark,
                style: blogText(
                  theme,
                  CairnTypography.sm,
                  color: theme.primaryForeground,
                  weight: CairnTypography.bold,
                ),
              ),
            ),
            Text(
              BlogBrand.name,
              style: blogText(
                theme,
                CairnTypography.base,
                weight: CairnTypography.semibold,
                tight: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => CairnButton(
    size: CairnButtonSize.sm,
    variant: active ? CairnButtonVariant.secondary : CairnButtonVariant.ghost,
    semanticLabel: active ? '$label, current page' : label,
    onPressed: onPressed,
    child: Text(label),
  );
}

/// The search box. Typing filters the post list live and, from any other
/// page, takes you back to it.
class SearchField extends StatefulWidget {
  /// Creates the field.
  const SearchField({super.key, this.autofocus = false});

  /// Whether to take focus when it first appears.
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: context.read<PostsFeedCubit>().state.query.search,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _change(String value) {
    context.read<PostsFeedCubit>().search(value);
    context.read<BlogNavigationCubit>().openHome();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostsFeedCubit, PostsFeedState>(
      listenWhen: (PostsFeedState a, PostsFeedState b) =>
          a.query.search != b.query.search,
      // Filters can be cleared from elsewhere (the results header, the empty
      // state); keep the box in step.
      listener: (BuildContext context, PostsFeedState state) {
        if (_controller.text != state.query.search) {
          _controller.text = state.query.search;
          setState(() {});
        }
      },
      child: CairnInput(
        controller: _controller,
        autofocus: widget.autofocus,
        placeholder: 'Search posts',
        semanticLabel: 'Search posts',
        textInputAction: TextInputAction.search,
        leading: const CairnIcon(CairnIconData.search),
        trailing: _controller.text.isEmpty
            ? null
            : CairnButton.icon(
                icon: const CairnIcon(CairnIconData.close, size: 12),
                semanticLabel: 'Clear search',
                variant: CairnButtonVariant.ghost,
                size: CairnButtonSize.iconXs,
                onPressed: () {
                  _controller.clear();
                  _change('');
                },
              ),
        onChanged: _change,
      ),
    );
  }
}
