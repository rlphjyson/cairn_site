import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sets the browser tab title while its subtree is mounted.
///
/// This is about as far as a client-rendered Flutter web app can honestly go on
/// SEO. There is no server-rendered HTML for a crawler to read, so `<title>`,
/// `<meta name="description">` and Open Graph tags in `web/index.html` are what
/// a link preview or a first crawl actually sees. What this widget adds is the
/// thing a *human* notices: the tab and the browser history entry say which
/// page they are on, and a bookmark saves a useful name.
///
/// [SystemChrome.setApplicationSwitcherDescription] is the cross-platform API
/// that Flutter web implements as a `document.title` write, so no `dart:html`
/// import — and therefore no web-only compilation — is needed. On the VM
/// (widget tests) it is a no-op message to a platform channel nobody answers,
/// which is exactly the behaviour we want in tests.
class PageTitle extends StatefulWidget {
  /// Titles [child] with "[title] — Cairn UI".
  const PageTitle({super.key, required this.title, required this.child});

  /// The page-specific part of the title.
  final String title;

  /// The page.
  final Widget child;

  /// The full document title for a page-specific [title].
  static String format(String title) =>
      title == 'Cairn UI' ? title : '$title — Cairn UI';

  @override
  State<PageTitle> createState() => _PageTitleState();
}

class _PageTitleState extends State<PageTitle> {
  @override
  void initState() {
    super.initState();
    _apply();
  }

  @override
  void didUpdateWidget(PageTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) _apply();
  }

  void _apply() {
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: PageTitle.format(widget.title),
        primaryColor: 0xFF0A0A0A,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
