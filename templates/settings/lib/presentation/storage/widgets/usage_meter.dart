import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

import '../../../common/utils/byte_format.dart';
import '../../../core/presentation/settings_appearance.dart';
import '../../../core/presentation/settings_text.dart';
import '../../../core/presentation/widgets/control_scale.dart';
import '../../../domain/storage/models/storage_usage.dart';

/// A segmented bar showing how much storage each category uses, with a legend.
///
/// Each segment is a [CairnProgress] filled to the brim and tinted through the
/// theme's primary colour; the free space is an empty one. The bar is
/// decorative: the legend and the summary line carry the same numbers as text.
class UsageMeter extends StatelessWidget {
  /// Creates the meter.
  const UsageMeter({super.key, required this.usage});

  /// The figures to draw.
  final StorageUsage usage;

  /// The colour of the [index]th category.
  static Color colorOf(CairnTheme theme, int index) => switch (index) {
    0 => theme.primary,
    1 => theme.primary.withValues(alpha: 0.6),
    2 => theme.primary.withValues(alpha: 0.3),
    _ =>
      theme.brightness == Brightness.dark
          ? Oklch.toColor(0.78, 0.13, 75)
          : Oklch.toColor(0.72, 0.14, 70),
  };

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final int capacity = usage.capacityBytes <= 0 ? 1 : usage.capacityBytes;
    final String summary =
        '${formatBytes(usage.usedBytes)} of ${formatBytes(usage.capacityBytes)} used';
    final String detail = <String>[
      for (final StorageCategory c in usage.categories)
        '${c.label} ${formatBytes(c.bytes)}',
      'Free ${formatBytes(usage.freeBytes)}',
    ].join(', ');
    int flex(int bytes) => (bytes * 1000 / capacity).round().clamp(0, 1000);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            label: 'Storage. $summary. $detail',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  summary,
                  style: settingsText(
                    theme,
                    CairnTypography.lg,
                    weight: CairnTypography.semibold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  spacing: 2,
                  children: <Widget>[
                    for (int i = 0; i < usage.categories.length; i++)
                      if (flex(usage.categories[i].bytes) > 0)
                        Expanded(
                          flex: flex(usage.categories[i].bytes).clamp(8, 1000),
                          child: Theme(
                            data: SettingsAppearance.tinted(
                              context,
                              colorOf(theme, i),
                            ),
                            child: const CairnProgress(value: 1, height: 12),
                          ),
                        ),
                    Expanded(
                      flex: flex(usage.freeBytes).clamp(1, 1000),
                      child: Theme(
                        data: SettingsAppearance.tinted(
                          context,
                          theme.mutedForeground,
                        ),
                        child: const CairnProgress(value: 0, height: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < usage.categories.length; i++)
                  _LegendRow(
                    color: colorOf(theme, i),
                    label: usage.categories[i].label,
                    value: formatBytes(usage.categories[i].bytes),
                  ),
                _LegendRow(
                  color: theme.mutedForeground.withValues(alpha: 0.2),
                  label: 'Free',
                  value: formatBytes(usage.freeBytes),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool stacked = isLargeText(context);
    final Widget dot = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    final Text name = Text(
      label,
      style: settingsText(theme, CairnTypography.sm),
    );
    final Text amount = Text(
      value,
      style: settingsText(
        theme,
        CairnTypography.sm,
        color: theme.mutedForeground,
      ),
    );
    if (stacked) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(top: 9), child: dot),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[name, amount],
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: settingsText(theme, CairnTypography.sm)),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: settingsText(
              theme,
              CairnTypography.sm,
              color: theme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
