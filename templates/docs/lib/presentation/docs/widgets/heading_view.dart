import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/docs_text.dart';
import '../../../core/presentation/navigation/docs_navigation_cubit.dart';
import '../../../domain/docs/models/doc_block.dart';

/// An `h2` / `h3` with an anchor.
///
/// The heading carries [anchorKey] so the page's view model can find it for
/// scrolling and for the active highlight in the table of contents. Hovering
/// or focusing it reveals a `#` that jumps to the heading (and, in a host that
/// mirrors the location into the URL, makes the heading linkable).
class HeadingView extends StatefulWidget {
  /// Creates a heading.
  const HeadingView({
    super.key,
    required this.block,
    required this.anchorKey,
    required this.isFirst,
  });

  /// The heading to show.
  final HeadingBlock block;

  /// Attached to the heading text, for measuring.
  final GlobalKey anchorKey;

  /// Whether it is the first block (no top margin then).
  final bool isFirst;

  @override
  State<HeadingView> createState() => _HeadingViewState();
}

class _HeadingViewState extends State<HeadingView> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool h2 = widget.block.level == 2;
    final TextStyle style = docsText(
      theme,
      theme.textStyle(h2 ? CairnTypography.xl2 : CairnTypography.lg),
      weight: CairnTypography.semibold,
      height: h2 ? 1.25 : 1.35,
      letterSpacing: h2 ? -0.4 : -0.2,
    );
    return Padding(
      padding: EdgeInsets.only(
        top: widget.isFirst ? 0 : (h2 ? 48 : 32),
        bottom: h2 ? 16 : 12,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Semantics(
          header: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Flexible(
                child: Text(
                  widget.block.text,
                  key: widget.anchorKey,
                  style: style,
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'Link to ${widget.block.text}',
                child: GestureDetector(
                  onTap: () => context.read<DocsNavigationCubit>().goToHeading(
                    widget.block.id,
                  ),
                  child: AnimatedOpacity(
                    duration: CairnMotion.d150,
                    opacity: _hovered ? 1 : 0,
                    child: Text(
                      '#',
                      style: style.copyWith(
                        color: theme.mutedForeground,
                        fontWeight: CairnTypography.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
