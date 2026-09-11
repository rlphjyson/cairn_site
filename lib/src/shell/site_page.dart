import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import 'site_footer.dart';

/// The default page wrapper: one scroller holding the page and the footer.
///
/// Scrolling lives in the page rather than in the shell so that a route which
/// needs a different layout — the docs section, with its sticky sidebar and
/// "On this page" rail — can opt out and run three independent scrollers side
/// by side. It also means each route gets a fresh scroll offset for free, since
/// navigating replaces the widget that owns the controller.
class SitePage extends StatelessWidget {
  /// Wraps [child].
  const SitePage({super.key, required this.child, this.footer = true});

  /// The page body.
  final Widget child;

  /// Whether to append the site footer.
  final bool footer;

  @override
  Widget build(BuildContext context) {
    return CairnScrollArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[child, if (footer) const SiteFooter()],
      ),
    );
  }
}
