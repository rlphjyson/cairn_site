import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Opens a URL outside the documentation (`http`, `https`, `mailto`).
typedef OpenExternalLink = void Function(String url);

/// What the host app configured on `DocsApp`, made available to every view.
///
/// The template has no `url_launcher` dependency, so by default an external
/// link is copied to the clipboard with a toast. Pass `onOpenExternal` to
/// `DocsApp` to open it for real.
class DocsHost extends InheritedWidget {
  /// Creates the host configuration.
  const DocsHost({super.key, this.onOpenExternal, required super.child});

  /// Opens an external URL, or `null` for the copy-to-clipboard fallback.
  final OpenExternalLink? onOpenExternal;

  /// Opens [url] with the host's handler, or copies it with a toast.
  static void openExternal(BuildContext context, String url) {
    final DocsHost? host = context.getInheritedWidgetOfExactType<DocsHost>();
    final OpenExternalLink? handler = host?.onOpenExternal;
    if (handler != null) {
      handler(url);
      return;
    }
    Clipboard.setData(ClipboardData(text: url));
    CairnToast.show(
      context,
      CairnToast(
        title: 'Link copied',
        description: url,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  bool updateShouldNotify(DocsHost oldWidget) =>
      onOpenExternal != oldWidget.onOpenExternal;
}
