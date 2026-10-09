import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/di/docs_injection.dart';
import 'core/presentation/docs_host.dart';
import 'core/presentation/navigation/docs_navigation_cubit.dart';
import 'core/presentation/view_model.dart';
import 'data/docs/remote/docs_remote_data_source.dart';
import 'presentation/docs/bloc/docs_cubit.dart';
import 'presentation/shell/docs_providers.dart';
import 'presentation/shell/docs_shell.dart';

export 'core/presentation/docs_host.dart' show OpenExternalLink;
export 'core/presentation/navigation/docs_navigation_cubit.dart'
    show DocsLocation;
export 'data/docs/remote/docs_remote_data_source.dart'
    show DocsRemoteDataSource, InMemoryDocsRemoteDataSource;

/// A documentation site built only from `cairn_ui` and Cairn tokens.
///
/// A top bar with a version selector and a command-palette search, a
/// collapsible sidebar that becomes a drawer on narrow layouts, an article
/// view that renders typed content blocks (headings, paragraphs with inline
/// markup, code with a copy button, callouts, tabs, steps, tables, lists), an
/// "On this page" rail that follows the scroll, and previous / next links.
///
/// It fills whatever space its parent gives it, takes its colours from the
/// ambient [CairnTheme], and keeps its own navigation, so it runs inside any
/// host. To drive the URL from your own router, pass [initialLocation] and
/// [onLocationChanged]; to open external links, pass [onOpenExternal]; to load
/// your own content, pass [remote].
///
/// Organised as clean architecture, by layer and then by feature; see the
/// README next to this file.
class DocsApp extends StatefulWidget {
  /// Creates the app.
  const DocsApp({
    super.key,
    this.initialLocation = const DocsLocation(),
    this.onLocationChanged,
    this.onOpenExternal,
    this.remote,
  });

  /// Where to start. Changing it later navigates there, which is how a router
  /// drives the template (back button, a pasted deep link).
  final DocsLocation initialLocation;

  /// Called when the reader changes version, page or heading.
  final ValueChanged<DocsLocation>? onLocationChanged;

  /// Opens an external URL. When null, the URL is copied with a toast.
  final OpenExternalLink? onOpenExternal;

  /// Where content comes from. When null, the in-memory Acme SDK content.
  final DocsRemoteDataSource? remote;

  @override
  State<DocsApp> createState() => _DocsAppState();
}

class _DocsAppState extends State<DocsApp> {
  late final GetIt _locator = createDocsLocator(
    initialLocation: widget.initialLocation,
    remote: widget.remote,
  );

  @override
  void initState() {
    super.initState();
    // Content is requested once, up front; the providers reload it whenever
    // the version in navigation changes.
    unawaited(
      _locator<DocsCubit>().load(
        _locator<DocsNavigationCubit>().state.versionId,
      ),
    );
  }

  @override
  void didUpdateWidget(DocsApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocation != oldWidget.initialLocation) {
      _locator<DocsNavigationCubit>().go(widget.initialLocation);
    }
  }

  @override
  void dispose() {
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DocsScope(
      locator: _locator,
      child: DocsHost(
        onOpenExternal: widget.onOpenExternal,
        // Material supplies the ancestor some Cairn parts (text fields in the
        // palette) need, and the default text style stops a bare Text from
        // falling back to Flutter's debug style in a host without a Scaffold.
        child: Material(
          type: MaterialType.transparency,
          child: DefaultTextStyle(
            style: theme.defaultTextStyle,
            child: DocsProviders(
              locator: _locator,
              onLocationChanged: widget.onLocationChanged,
              child: const DocsShell(),
            ),
          ),
        ),
      ),
    );
  }
}
