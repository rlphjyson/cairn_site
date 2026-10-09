import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/inline_markup.dart';
import '../../../core/presentation/docs_host.dart';
import '../../../core/presentation/docs_text.dart';
import '../../../core/presentation/navigation/docs_navigation_cubit.dart';

/// Opens an inline link: an external URL through the host, or an internal
/// `slug`, `slug#heading` or `#heading` through the navigation cubit.
void openDocsLink(BuildContext context, String target) {
  if (isExternalTarget(target)) {
    DocsHost.openExternal(context, target);
    return;
  }
  final DocsNavigationCubit nav = context.read<DocsNavigationCubit>();
  final int hash = target.indexOf('#');
  final String slug = hash < 0 ? target : target.substring(0, hash);
  final String? heading = hash < 0 || hash == target.length - 1
      ? null
      : target.substring(hash + 1);
  if (slug.isEmpty || slug == nav.state.pageSlug) {
    if (heading != null) nav.goToHeading(heading);
    return;
  }
  nav.openPage(slug, headingId: heading);
}

/// Renders a string of inline markup: `**bold**`, `code` and `[links](x)`.
///
/// Links are tappable spans with a pointer cursor. They are not individually
/// keyboard-focusable (a span cannot take focus); every navigational link also
/// exists as a focusable control elsewhere on the page (sidebar, pager,
/// table of contents).
class RichInline extends StatefulWidget {
  /// Creates the text.
  const RichInline(
    this.markup, {
    super.key,
    required this.style,
    this.textAlign,
  });

  /// The markup to parse.
  final String markup;

  /// The base style; bold and code derive from it.
  final TextStyle style;

  /// Alignment of the text.
  final TextAlign? textAlign;

  @override
  State<RichInline> createState() => _RichInlineState();
}

class _RichInlineState extends State<RichInline> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final TapGestureRecognizer r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    _disposeRecognizers();
    final TextStyle base = widget.style;
    final double size = base.fontSize ?? 16;

    final List<InlineSpan> spans = <InlineSpan>[
      for (final InlineNode node in parseInline(widget.markup))
        switch (node) {
          InlineText(:final String text) => TextSpan(text: text),
          InlineBold(:final String text) => TextSpan(
            text: text,
            style: TextStyle(
              fontWeight: CairnTypography.semibold,
              color: theme.foreground,
            ),
          ),
          InlineCode(:final String text) => TextSpan(
            // Non-breaking spaces give the highlight some air without a
            // WidgetSpan, so long code still wraps with the paragraph.
            text: ' $text ',
            style: docsMono(theme, base).copyWith(
              fontSize: size * 0.88,
              color: theme.foreground,
              backgroundColor: theme.muted,
            ),
          ),
          InlineLink() => _link(context, theme, node),
        },
    ];
    return Text.rich(
      TextSpan(children: spans),
      style: base,
      textAlign: widget.textAlign,
    );
  }

  TextSpan _link(BuildContext context, CairnTheme theme, InlineLink link) {
    final TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () => openDocsLink(context, link.target);
    _recognizers.add(recognizer);
    return TextSpan(
      text: link.text,
      recognizer: recognizer,
      mouseCursor: SystemMouseCursors.click,
      semanticsLabel: link.text,
      style: TextStyle(
        color: theme.foreground,
        fontWeight: CairnTypography.medium,
        decoration: TextDecoration.underline,
        decorationColor: theme.mutedForeground,
        decorationThickness: 1,
      ),
    );
  }
}
