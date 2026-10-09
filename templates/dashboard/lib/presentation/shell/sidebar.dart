import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/constants/dashboard_brand.dart';
import '../../core/presentation/dashboard_text.dart';
import '../../core/presentation/navigation/dashboard_navigation_cubit.dart';

/// The left navigation: brand, pages and the signed-in user.
class Sidebar extends StatelessWidget {
  /// Creates the sidebar.
  const Sidebar({super.key});

  static const Map<DashboardPage, IconData> _icons = <DashboardPage, IconData>{
    DashboardPage.overview: Icons.space_dashboard_outlined,
    DashboardPage.analytics: Icons.insights_outlined,
    DashboardPage.orders: Icons.receipt_long_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.card,
        border: Border(right: BorderSide(color: theme.border)),
      ),
      child: SizedBox(
        width: 224,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
                child: Row(
                  spacing: 10,
                  children: <Widget>[
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(
                          theme.radiusScale.md,
                        ),
                      ),
                      child: Icon(
                        Icons.bar_chart_rounded,
                        size: 18,
                        color: theme.primaryForeground,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        DashboardBrand.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: dashText(
                          theme,
                          theme.textStyle(CairnTypography.sm),
                          weight: CairnTypography.semibold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<DashboardNavigationCubit, DashboardPage>(
                builder: (BuildContext context, DashboardPage page) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 4,
                  children: <Widget>[
                    for (final DashboardPage p in DashboardPage.values)
                      CairnButton(
                        variant: p == page
                            ? CairnButtonVariant.secondary
                            : CairnButtonVariant.ghost,
                        leading: Icon(_icons[p], size: 16),
                        onPressed: () =>
                            context.read<DashboardNavigationCubit>().select(p),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(p.label),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              const CairnSeparator(),
              const SizedBox(height: 12),
              Row(
                spacing: 10,
                children: <Widget>[
                  const CairnAvatar(
                    fallback: Text(DashboardBrand.userInitials),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          DashboardBrand.userName,
                          style: dashText(
                            theme,
                            theme.textStyle(CairnTypography.sm),
                            weight: CairnTypography.medium,
                          ),
                        ),
                        Text(
                          DashboardBrand.userRole,
                          style: dashText(
                            theme,
                            theme.textStyle(CairnTypography.xs),
                            color: theme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
