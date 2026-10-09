import 'package:flutter/widgets.dart';

import '../../../common/constants/blog_config.dart';

/// How much room the blog has, measured on the blog itself rather than the
/// screen, so it behaves inside a narrow panel on a wide desktop.
enum BlogSize {
  /// Under 640: phones. One column.
  compact,

  /// 640 to 1023: tablets. Two columns.
  medium,

  /// 1024 and up: desktops. Three columns.
  expanded;

  /// The size for a given available [width].
  static BlogSize of(double width) => width < 640
      ? BlogSize.compact
      : width < 1024
      ? BlogSize.medium
      : BlogSize.expanded;
}

/// Provides the blog's [BlogSize] to everything below the shell.
class BlogLayout extends InheritedWidget {
  /// Creates the layout.
  const BlogLayout({super.key, required this.size, required super.child});

  /// The current size class.
  final BlogSize size;

  /// The nearest layout.
  static BlogSize sizeOf(BuildContext context) {
    final BlogLayout? layout = context
        .dependOnInheritedWidgetOfExactType<BlogLayout>();
    return layout?.size ?? BlogSize.expanded;
  }

  /// Horizontal page padding for [size].
  static double gutterFor(BlogSize size) => switch (size) {
    BlogSize.compact => 16,
    BlogSize.medium => 24,
    BlogSize.expanded => 32,
  };

  /// Posts per row in the grid for [size].
  static int columnsFor(BlogSize size) => switch (size) {
    BlogSize.compact => 1,
    BlogSize.medium => 2,
    BlogSize.expanded => 3,
  };

  @override
  bool updateShouldNotify(BlogLayout oldWidget) => size != oldWidget.size;
}

/// Centres [child] in a column no wider than [maxWidth], with the page's
/// side gutters.
class PageContainer extends StatelessWidget {
  /// Creates a container.
  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = BlogConfig.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  /// The content.
  final Widget child;

  /// The widest the column grows, gutters included.
  final double maxWidth;

  /// Extra padding inside the gutters.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final double gutter = BlogLayout.gutterFor(BlogLayout.sizeOf(context));
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter).add(padding),
          child: child,
        ),
      ),
    );
  }
}
