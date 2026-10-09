import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, IconData, Icons;
import 'package:flutter/widgets.dart';

import '../../../domain/settings/models/setting_definition.dart';
import '../settings_text.dart';
import 'control_scale.dart';

/// A small rounded square holding an icon, the leading mark of a row.
class IconBadge extends StatelessWidget {
  /// Creates a badge.
  const IconBadge({super.key, required this.icon, this.destructive = false});

  /// The glyph.
  final IconData icon;

  /// Whether it is drawn as dangerous.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ExcludeSemantics(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: destructive
              ? theme.destructive.withValues(alpha: 0.12)
              : theme.muted,
          borderRadius: BorderRadius.circular(theme.radiusScale.md),
        ),
        child: Icon(
          icon,
          size: 18,
          color: destructive ? theme.destructive : theme.foreground,
        ),
      ),
    );
  }
}

/// A heading and a card of rows.
class SettingsGroup extends StatelessWidget {
  /// Creates a group.
  const SettingsGroup({
    super.key,
    this.title,
    this.footer,
    required this.children,
  });

  /// The heading above the card.
  final String? title;

  /// A line of help under the card.
  final String? footer;

  /// The rows.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Semantics(
              header: true,
              child: Text(
                title!,
                style: settingsText(
                  theme,
                  CairnTypography.sm,
                  color: theme.mutedForeground,
                  weight: CairnTypography.medium,
                ),
              ),
            ),
          ),
        CairnList(bordered: true, children: children),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: Text(
              footer!,
              style: settingsText(
                theme,
                CairnTypography.xs,
                color: theme.mutedForeground,
              ),
            ),
          ),
      ],
    );
  }
}

/// A row that opens something: a chevron, an optional current value.
class NavRow extends StatelessWidget {
  /// Creates a row.
  const NavRow({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.icon,
    this.trailing,
    this.selected = false,
    this.destructive = false,
    this.external = false,
    this.onTap,
  });

  /// The label.
  final String title;

  /// A line under the label.
  final String? subtitle;

  /// The current value, shown before the chevron.
  final String? value;

  /// A leading glyph.
  final IconData? icon;

  /// Replaces the value and chevron.
  final Widget? trailing;

  /// Whether the row is the chosen one (the tablet list).
  final bool selected;

  /// Whether the row is drawn as dangerous.
  final bool destructive;

  /// Whether it opens something outside the app.
  final bool external;

  /// Called on tap. `null` makes the row static.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool stacked = isLargeText(context);
    final String label = <String>[title, ?subtitle, ?value].join('. ');
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: CairnListItem(
        selected: selected,
        onTap: onTap,
        leading: icon == null
            ? null
            : IconBadge(icon: icon!, destructive: destructive),
        title: Text(
          title,
          style: destructive ? TextStyle(color: theme.destructive) : null,
        ),
        subtitle: subtitle == null && !(stacked && value != null)
            ? null
            : Text(<String>[?subtitle, if (stacked) ?value].join('\n')),
        trailing:
            trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (value != null && !stacked)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 112),
                    child: Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (value != null && !stacked) const SizedBox(width: 8),
                if (onTap != null)
                  external
                      ? Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: theme.mutedForeground,
                        )
                      : CairnIcon(
                          CairnIconData.chevronRight,
                          color: theme.mutedForeground,
                        ),
              ],
            ),
      ),
    );
  }
}

/// A row with a switch. The whole row toggles it, so the target is as tall as
/// the row; the switch itself only shows the state.
class ToggleRow extends StatelessWidget {
  /// Creates a row.
  const ToggleRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  /// The label.
  final String title;

  /// A line under the label.
  final String? subtitle;

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value. `null` disables the row.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final VoidCallback? tap = onChanged == null
        ? null
        : () => onChanged!(!value);
    return Semantics(
      label: title,
      hint: subtitle,
      toggled: value,
      enabled: onChanged != null,
      onTap: tap,
      excludeSemantics: true,
      child: CairnListItem(
        onTap: tap,
        title: Text(
          title,
          style: onChanged == null
              ? TextStyle(color: theme.mutedForeground)
              : null,
        ),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: ExcludeFocus(
          child: IgnorePointer(
            child: CairnSwitch(
              value: value,
              onChanged: onChanged == null ? null : (_) {},
            ),
          ),
        ),
      ),
    );
  }
}

/// The label and help of a row that holds a control underneath or beside it.
class RowLabel extends StatelessWidget {
  /// Creates a label.
  const RowLabel({
    super.key,
    required this.title,
    this.subtitle,
    this.enabled = true,
    this.trailing,
  });

  /// The label.
  final String title;

  /// A line under the label.
  final String? subtitle;

  /// Whether the label is drawn at full strength.
  final bool enabled;

  /// Text at the end of the title line, such as the current step.
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: settingsText(
                  theme,
                  CairnTypography.sm,
                  color: enabled ? theme.foreground : theme.mutedForeground,
                  weight: CairnTypography.medium,
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  trailing!,
                  style: settingsText(
                    theme,
                    CairnTypography.sm,
                    color: theme.mutedForeground,
                  ),
                ),
              ),
          ],
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: settingsText(
              theme,
              CairnTypography.xs,
              color: theme.mutedForeground,
            ),
          ),
      ],
    );
  }
}

/// A row with a select: beside the label when there is room, under it
/// otherwise.
class SelectRow extends StatelessWidget {
  /// Creates a row.
  const SelectRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    required this.value,
    required this.onChanged,
    this.inline = false,
  });

  /// The label, also the select's accessible name.
  final String title;

  /// A line under the label.
  final String? subtitle;

  /// The choices.
  final List<ChoiceOption> options;

  /// The chosen value.
  final String value;

  /// Called with the new value. `null` disables the select.
  final ValueChanged<String>? onChanged;

  /// Whether the select sits beside the label.
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final Widget select = ControlScale(
      child: CairnSelect<String>(
        semanticLabel: title,
        value: value,
        width: inline ? null : double.infinity,
        onChanged: onChanged,
        options: <CairnSelectOption<String>>[
          for (final ChoiceOption o in options)
            CairnSelectOption<String>(value: o.value, label: o.label),
        ],
      ),
    );
    final RowLabel label = RowLabel(
      title: title,
      subtitle: subtitle,
      enabled: onChanged != null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: inline
          ? Row(
              children: <Widget>[
                Expanded(child: label),
                const SizedBox(width: 12),
                SizedBox(width: 136, child: select),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[label, const SizedBox(height: 8), select],
            ),
    );
  }
}

/// A row with a group of radio options under its label. Every option is as wide
/// as the row and 44 px tall.
class RadioRow extends StatelessWidget {
  /// Creates a row.
  const RadioRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  /// The label, also the group's accessible name.
  final String title;

  /// A line under the label.
  final String? subtitle;

  /// The choices.
  final List<ChoiceOption> options;

  /// The chosen value.
  final String value;

  /// Called with the new value. `null` disables the group.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RowLabel(
            title: title,
            subtitle: subtitle,
            enabled: onChanged != null,
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) =>
                CairnRadioGroup<String>(
                  value: value,
                  onChanged: onChanged,
                  spacing: 0,
                  semanticLabel: title,
                  children: <Widget>[
                    for (final ChoiceOption o in options)
                      CairnRadioItem<String>(
                        value: o.value,
                        semanticLabel: o.description == null
                            ? o.label
                            : '${o.label}. ${o.description}',
                        label: ExcludeSemantics(
                          child: SizedBox(
                            width: box.maxWidth - 24,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    o.label,
                                    style: settingsText(
                                      theme,
                                      CairnTypography.sm,
                                      color: onChanged == null
                                          ? theme.mutedForeground
                                          : theme.foreground,
                                    ),
                                  ),
                                  if (o.description != null)
                                    Text(
                                      o.description!,
                                      style: settingsText(
                                        theme,
                                        CairnTypography.xs,
                                        color: theme.mutedForeground,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

/// A [CairnSlider] on a short scale, with a 44 px tall touch area.
///
/// Taps and drags in the margin above and below the track move the thumb too,
/// so the slider is as easy to hit as any other control.
class StepSlider extends StatelessWidget {
  /// Creates a slider with [steps] positions.
  const StepSlider({
    super.key,
    required this.value,
    required this.steps,
    required this.onChanged,
    required this.semanticLabel,
  });

  /// The current step, 0-based.
  final int value;

  /// How many positions there are.
  final int steps;

  /// Called with the new step.
  final ValueChanged<int>? onChanged;

  /// The accessible name.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints box) {
      void move(double dx) {
        final double usable = box.maxWidth - CairnSlider.thumbSize;
        if (usable <= 0 || onChanged == null) return;
        final double fraction = ((dx - CairnSlider.thumbSize / 2) / usable)
            .clamp(0.0, 1.0);
        final int next = (fraction * (steps - 1)).round();
        if (next != value) onChanged!(next);
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTapDown: (TapDownDetails d) => move(d.localPosition.dx),
        onHorizontalDragUpdate: (DragUpdateDetails d) =>
            move(d.localPosition.dx),
        child: SizedBox(
          height: 44,
          child: Center(
            child: CairnSlider(
              value: value.toDouble(),
              min: 0,
              max: (steps - 1).toDouble(),
              step: 1,
              semanticLabel: semanticLabel,
              onChanged: onChanged == null
                  ? null
                  : (double v) => onChanged!(v.round()),
            ),
          ),
        ),
      );
    },
  );
}
