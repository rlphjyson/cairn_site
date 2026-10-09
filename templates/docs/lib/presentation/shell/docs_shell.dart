import 'dart:math' as math;

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../common/constants/docs_layout.dart';
import '../docs/views/doc_page_view.dart';
import '../search/widgets/search_palette.dart';
import '../sidebar/widgets/sidebar_nav.dart';
import 'top_bar.dart';

/// The page frame: top bar, sidebar (or drawer) and the article.
///
/// Layout follows the template's own width, not the window's, so it behaves
/// the same when mounted in a phone mockup or a split view:
///
/// * 900 px and up: a fixed sidebar beside the article;
/// * below 900 px: the sidebar becomes a drawer opened from the menu button;
/// * 1100 px and up: the "On this page" rail appears at the right.
///
/// `Ctrl+K`, `Cmd+K` and `/` open the search palette.
class DocsShell extends StatelessWidget {
  /// Creates the shell.
  const DocsShell({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ColoredBox(
      color: theme.background,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          final bool drawer = box.maxWidth < DocsLayout.drawerBreakpoint;
          final bool toc = box.maxWidth >= DocsLayout.tocBreakpoint;
          return CairnToaster(
            width: math.min(356, math.max(240, box.maxWidth - 32)),
            child: _SearchShortcuts(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TopBar(compact: drawer),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (!drawer)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: theme.border),
                              ),
                            ),
                            child: const SizedBox(
                              width: DocsLayout.sidebarWidth,
                              child: SidebarNav(),
                            ),
                          ),
                        Expanded(child: DocPageView(showToc: toc)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchShortcuts extends StatelessWidget {
  const _SearchShortcuts({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    void open() => openSearchPalette(context);
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): open,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): open,
        const SingleActivator(LogicalKeyboardKey.slash): open,
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
