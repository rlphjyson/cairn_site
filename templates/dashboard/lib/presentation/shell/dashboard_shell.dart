import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/presentation/dashboard_text.dart';
import '../../core/presentation/navigation/dashboard_navigation_cubit.dart';
import '../analytics/views/analytics_view.dart';
import '../orders/views/orders_view.dart';
import '../overview/views/overview_view.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// The page frame: sidebar, top bar and the current page.
///
/// Below 760 logical pixels the sidebar gives way to a row of page buttons
/// under the top bar.
class DashboardShell extends StatelessWidget {
  /// Creates the shell.
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ColoredBox(
      color: theme.background,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          final bool compact = box.maxWidth < 760;
          return Row(
            children: <Widget>[
              if (!compact) const Sidebar(),
              Expanded(
                child: Column(
                  children: <Widget>[
                    TopBar(compact: compact),
                    if (compact) const _PageSwitcher(),
                    Expanded(
                      child:
                          BlocBuilder<DashboardNavigationCubit, DashboardPage>(
                            builder:
                                (BuildContext context, DashboardPage page) =>
                                    AnimatedSwitcher(
                                      duration: CairnMotion.d150,
                                      child: KeyedSubtree(
                                        key: ValueKey<DashboardPage>(page),
                                        child: switch (page) {
                                          DashboardPage.overview =>
                                            const OverviewView(),
                                          DashboardPage.analytics =>
                                            const AnalyticsView(),
                                          DashboardPage.orders =>
                                            const OrdersView(),
                                        },
                                      ),
                                    ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PageSwitcher extends StatelessWidget {
  const _PageSwitcher();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: BlocBuilder<DashboardNavigationCubit, DashboardPage>(
          builder: (BuildContext context, DashboardPage page) => Row(
            spacing: 8,
            children: <Widget>[
              for (final DashboardPage p in DashboardPage.values)
                CairnButton(
                  size: CairnButtonSize.sm,
                  variant: p == page
                      ? CairnButtonVariant.secondary
                      : CairnButtonVariant.ghost,
                  onPressed: () =>
                      context.read<DashboardNavigationCubit>().select(p),
                  child: Text(
                    p.label,
                    style: dashText(theme, theme.textStyle(CairnTypography.sm)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
