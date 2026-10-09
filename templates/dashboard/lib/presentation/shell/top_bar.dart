import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/presentation/dashboard_text.dart';
import '../../core/presentation/navigation/dashboard_navigation_cubit.dart';
import '../../domain/filters/models/period.dart';
import '../filters/bloc/period_cubit.dart';

/// The page title, the period picker and account actions.
class TopBar extends StatelessWidget {
  /// Creates the bar.
  const TopBar({super.key, this.compact = false});

  /// Whether to drop secondary controls to fit a narrow frame.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            spacing: 12,
            children: <Widget>[
              Expanded(
                child: BlocBuilder<DashboardNavigationCubit, DashboardPage>(
                  builder: (BuildContext context, DashboardPage page) => Text(
                    page.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: dashText(
                      theme,
                      theme.textStyle(CairnTypography.lg),
                      weight: CairnTypography.semibold,
                    ),
                  ),
                ),
              ),
              BlocBuilder<PeriodCubit, Period>(
                builder: (BuildContext context, Period period) =>
                    CairnToggleGroup<Period>(
                      type: CairnToggleGroupType.single,
                      variant: CairnToggleVariant.outline,
                      size: CairnToggleSize.sm,
                      semanticLabel: 'Period',
                      values: <Period>{period},
                      onChanged: (Set<Period> v) {
                        if (v.isNotEmpty) {
                          context.read<PeriodCubit>().select(v.first);
                        }
                      },
                      items: <CairnToggleGroupItem<Period>>[
                        for (final Period p in Period.values)
                          CairnToggleGroupItem<Period>(
                            value: p,
                            child: Text(p.label),
                          ),
                      ],
                    ),
              ),
              if (!compact)
                const CairnIndicator(
                  indicator: CairnStatus(tone: CairnTone.destructive, size: 8),
                  child: Icon(Icons.notifications_none, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
