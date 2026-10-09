import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/docs_layout.dart';
import '../../../common/utils/inline_markup.dart';
import '../../../core/presentation/docs_text.dart';
import '../../../core/presentation/navigation/docs_navigation_cubit.dart';
import '../../../core/presentation/widgets/pressable.dart';
import '../../../domain/docs/models/toc_entry.dart';
import '../bloc/toc_cubit.dart';
import '../view_models/doc_page_view_model.dart';

/// The "On this page" rail: the page's `h2` / `h3` headings, with the one at
/// the top of the reading area highlighted. Clicking one scrolls to it.
class TocRail extends StatelessWidget {
  /// Creates the rail.
  const TocRail({super.key, required this.viewModel});

  /// Supplies the entries and the scroll action.
  final DocPageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final List<TocEntry> entries = viewModel.entries;
    if (entries.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: DocsLayout.tocWidth,
      child: Semantics(
        container: true,
        label: 'On this page',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 48, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 12),
                child: Text(
                  'On this page',
                  style: docsText(
                    theme,
                    theme.textStyle(CairnTypography.sm),
                    weight: CairnTypography.semibold,
                  ),
                ),
              ),
              BlocBuilder<TocCubit, String?>(
                bloc: viewModel.toc,
                builder: (BuildContext context, String? active) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final TocEntry e in entries)
                      _TocItem(
                        entry: e,
                        active: e.id == active,
                        onTap: () {
                          viewModel.scrollTo(e.id);
                          context.read<DocsNavigationCubit>().goToHeading(e.id);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TocItem extends StatelessWidget {
  const _TocItem({
    required this.entry,
    required this.active,
    required this.onTap,
  });

  final TocEntry entry;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Pressable(
      onTap: onTap,
      selected: active,
      semanticLabel: plainText(entry.text),
      borderRadius: BorderRadius.circular(theme.radiusScale.sm),
      builder: (BuildContext context, bool hovered, bool focused) {
        final Color color = active || hovered
            ? theme.foreground
            : theme.mutedForeground;
        return Container(
          padding: EdgeInsets.fromLTRB(entry.level == 3 ? 24 : 12, 6, 8, 6),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: active ? theme.foreground : theme.border,
                width: active ? 2 : 1,
              ),
            ),
          ),
          child: Text(
            plainText(entry.text),
            style: docsText(
              theme,
              theme.textStyle(CairnTypography.sm),
              color: color,
              weight: active ? CairnTypography.medium : null,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }
}
