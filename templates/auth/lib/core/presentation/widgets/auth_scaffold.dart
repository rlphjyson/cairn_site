import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../auth_copy.dart';
import 'touch_target.dart';

/// The widest the content gets, however wide the space it is given.
const double authMaxWidth = 440;

/// Space reserved above the content for a phone frame's notch. On a real
/// device the safe area already covers this.
const double notchInset = 22;

/// The page chrome every screen shares.
///
/// A scrolling column of [children], centred in a [authMaxWidth] column on
/// wide screens, with the safe area and room for the on-screen keyboard. An
/// optional back button stays pinned above the scrolling content. When the
/// content is shorter than the screen and [centered] is set, it sits in the
/// vertical middle (the welcome screen); otherwise it starts at the top.
class AuthScaffold extends StatelessWidget {
  /// Creates a scaffold.
  const AuthScaffold({
    super.key,
    required this.children,
    this.onBack,
    this.centered = false,
    this.spacing = 0,
  });

  /// The screen's content, top to bottom.
  final List<Widget> children;

  /// Shows a back button that calls this, or none when `null`.
  final VoidCallback? onBack;

  /// Whether short content is centred vertically.
  final bool centered;

  /// Gap between [children].
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ColoredBox(
      color: theme.background,
      child: SafeArea(
        minimum: const EdgeInsets.only(top: notchInset),
        child: Column(
          children: <Widget>[
            if (onBack != null)
              _Column(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 14, top: 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TouchTarget(
                      onTap: onBack,
                      child: CairnButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        semanticLabel: AuthCopy.back,
                        variant: CairnButtonVariant.ghost,
                        onPressed: onBack,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints box) =>
                    SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: box.maxHeight),
                        child: Align(
                          alignment: centered
                              ? Alignment.center
                              : Alignment.topCenter,
                          child: _Column(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                24,
                                onBack == null ? 24 : 4,
                                24,
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: spacing,
                                children: children,
                              ),
                            ),
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
  }
}

/// Centres [child] in a column no wider than [authMaxWidth].
class _Column extends StatelessWidget {
  const _Column({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: authMaxWidth),
      child: child,
    ),
  );
}
