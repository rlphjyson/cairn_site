import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../common/utils/format.dart';
import '../../../core/presentation/dashboard_text.dart';
import '../../../domain/overview/models/kpi.dart';

/// One headline figure with its change since the previous period.
class KpiCard extends StatelessWidget {
  /// Creates a card.
  const KpiCard({super.key, required this.kpi});

  /// What to show.
  final Kpi kpi;

  String get _value => switch (kpi.unit) {
    KpiUnit.currency => DashboardFormat.currency(kpi.value),
    KpiUnit.count => DashboardFormat.number(kpi.value),
    KpiUnit.percent => DashboardFormat.percent(kpi.value),
  };

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final CairnToneColor tone = CairnToneColors.resolve(
      theme,
      kpi.improving ? CairnTone.success : CairnTone.destructive,
    );
    return CairnCard(
      children: <Widget>[
        CairnCardHeader(
          title: Text(kpi.label),
          action: CairnBadge(
            variant: CairnBadgeVariant.outline,
            leading: Icon(
              kpi.delta >= 0 ? Icons.trending_up : Icons.trending_down,
              size: 12,
              color: tone.fill,
            ),
            label: Text(DashboardFormat.signedPercent(kpi.delta)),
          ),
        ),
        CairnCardContent(
          child: Text(
            _value,
            style: dashText(
              theme,
              theme.textStyle(CairnTypography.xl3),
              weight: CairnTypography.semibold,
            ).copyWith(letterSpacing: CairnTypography.trackingTight(30)),
          ),
        ),
      ],
    );
  }
}
