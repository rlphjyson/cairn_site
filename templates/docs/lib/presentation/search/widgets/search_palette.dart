import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/navigation/docs_navigation_cubit.dart';
import '../../../domain/search/models/search_hit.dart';
import '../bloc/search_cubit.dart';

/// The keys that open the palette, as `CairnKbd` labels: `Cmd K` on Apple
/// platforms, `Ctrl K` everywhere else.
List<String> searchShortcutKeys() =>
    defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS
    ? const <String>['Cmd', 'K']
    : const <String>['Ctrl', 'K'];

/// Opens the command palette over the page.
///
/// The palette lives on the root navigator, outside the template's providers,
/// so everything it needs (the index, the navigation cubit) is read here,
/// before it opens, and captured by the item callbacks.
Future<void> openSearchPalette(BuildContext context) {
  final DocsNavigationCubit nav = context.read<DocsNavigationCubit>();
  final List<SearchHit> hits = context.read<SearchCubit>().state.hits;
  final CairnTheme theme = CairnTheme.of(context);
  return showCairnCommandPalette(
    context: context,
    placeholder: 'Search pages and headings...',
    emptyMessage: 'No results found.',
    items: <CairnCommandItem>[
      for (final SearchHit hit in hits)
        CairnCommandItem(
          label: hit.label,
          group: hit.group,
          keywords: hit.keywords,
          icon: Icon(
            hit.kind == SearchHitKind.page
                ? Icons.description_outlined
                : Icons.tag,
            size: 16,
            color: theme.mutedForeground,
          ),
          onSelected: () =>
              nav.openPage(hit.pageSlug, headingId: hit.headingId),
        ),
    ],
  );
}
