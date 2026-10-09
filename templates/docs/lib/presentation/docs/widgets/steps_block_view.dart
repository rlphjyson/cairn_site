import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/docs_text.dart';
import '../../../domain/docs/models/doc_block.dart';
import 'block_column.dart';

/// A numbered procedure: a marker per step joined by a hairline, with the
/// step's own blocks beside it.
class StepsBlockView extends StatelessWidget {
  /// Creates a steps block.
  const StepsBlockView({super.key, required this.block});

  /// The steps to show.
  final StepsBlock block;

  static const double _marker = 28;
  static const double _gutter = 44;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final List<StepItem> steps = block.steps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          Stack(
            children: <Widget>[
              if (i < steps.length - 1)
                Positioned(
                  left: _marker / 2 - 0.5,
                  top: _marker + 6,
                  bottom: 6,
                  width: 1,
                  child: ColoredBox(color: theme.border),
                ),
              Padding(
                padding: EdgeInsets.only(
                  left: _gutter,
                  bottom: i < steps.length - 1 ? 28 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: _marker),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          steps[i].title,
                          style: docsText(
                            theme,
                            theme.textStyle(CairnTypography.base),
                            weight: CairnTypography.semibold,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlockColumn(blocks: steps[i].blocks),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.muted,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.border),
                  ),
                  child: SizedBox.square(
                    dimension: _marker,
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: docsText(
                          theme,
                          theme.textStyle(CairnTypography.sm),
                          weight: CairnTypography.medium,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
