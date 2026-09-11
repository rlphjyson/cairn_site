import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../app/site_theme.dart';
import '../data/components_catalog.dart';
import '../widgets/code_block.dart';
import '../widgets/site_icons.dart';
import '../widgets/surfaces.dart';
import '../widgets/variant_preview_pane.dart';

/// A single component's page: live preview, code, and the measurement note
/// that explains why it is built the way it is.
class ComponentDetailPage extends StatelessWidget {
  /// Creates the page for [entry].
  const ComponentDetailPage({super.key, required this.entry});

  /// The component being documented.
  final ComponentEntry entry;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final int index = componentCatalog.indexOf(entry);
    final ComponentEntry? previous = index > 0
        ? componentCatalog[index - 1]
        : null;
    final ComponentEntry? next = index < componentCatalog.length - 1
        ? componentCatalog[index + 1]
        : null;

    return PageContainer(
      maxWidth: 980,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CairnBreadcrumb(
            crumbs: <CairnCrumb>[
              CairnCrumb(label: 'Home', onTap: () => context.go(Routes.home)),
              CairnCrumb(
                label: 'Components',
                onTap: () => context.go(Routes.components),
              ),
              CairnCrumb.current(label: entry.name),
            ],
          ),
          const SizedBox(height: CairnSpacing.s6),
          PageHeading(
            title: entry.name,
            lead: entry.description,
            trailing: Wrap(
              spacing: CairnSpacing.s2,
              children: <Widget>[
                CairnBadge(
                  variant: CairnBadgeVariant.secondary,
                  label: Text(entry.category.label),
                ),
                if (entry.livesIn != null)
                  CairnBadge(
                    variant: CairnBadgeVariant.outline,
                    label: Text(entry.livesIn!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: CairnSpacing.s8),
          VariantPreviewPane(variants: entry.preview),
          const SizedBox(height: CairnSpacing.s6),
          _QuickStart(code: entry.code),
          if (entry.note != null) ...<Widget>[
            const SizedBox(height: CairnSpacing.s8),
            _Note(text: entry.note!),
          ],
          if (entry.alsoExports.isNotEmpty) ...<Widget>[
            const SizedBox(height: CairnSpacing.s8),
            const SectionHeading('Also exported from this module', level: 3),
            const SizedBox(height: CairnSpacing.s3),
            Wrap(
              spacing: CairnSpacing.s2,
              runSpacing: CairnSpacing.s2,
              children: <Widget>[
                for (final String widgetName in entry.alsoExports)
                  CairnBadge(
                    variant: CairnBadgeVariant.outline,
                    label: Text(widgetName),
                  ),
              ],
            ),
          ],
          const SizedBox(height: CairnSpacing.s10),
          const CairnSeparator(),
          const SizedBox(height: CairnSpacing.s5),
          Row(
            children: <Widget>[
              if (previous != null)
                CairnButton(
                  variant: CairnButtonVariant.ghost,
                  onPressed: () => context.go(previous.path),
                  leading: const CairnIcon(CairnIconData.chevronLeft, size: 15),
                  child: Text(previous.name),
                ),
              const Spacer(),
              if (next != null)
                CairnButton(
                  variant: CairnButtonVariant.ghost,
                  onPressed: () => context.go(next.path),
                  trailing: const CairnIcon(
                    CairnIconData.chevronRight,
                    size: 15,
                  ),
                  child: Text(next.name),
                ),
            ],
          ),
          const SizedBox(height: CairnSpacing.s6),
          Center(
            child: CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: () => context.go(Routes.components),
              leading: const SiteIcon(SiteIconData.layers, size: 15),
              child: Text(
                'Back to all ${componentCatalog.length} components',
                style: TextStyle(color: theme.foreground),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The component's general orientation snippet, folded away by default.
///
/// The pane above it now answers "how do I reproduce *that*"; this answers
/// "what does this component look like in an app at all". Closed by default so
/// it does not compete with the per-variant code, and built from a real
/// [CairnCollapsible] rather than an `ExpansionTile`.
class _QuickStart extends StatefulWidget {
  const _QuickStart({required this.code});

  final String code;

  @override
  State<_QuickStart> createState() => _QuickStartState();
}

class _QuickStartState extends State<_QuickStart> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnCollapsible(
      open: _open,
      onToggle: () => setState(() => _open = !_open),
      trigger: Padding(
        padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s2),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Quick start snippet',
                style: theme
                    .textStyle(CairnTypography.sm)
                    .copyWith(
                      color: theme.foreground,
                      fontWeight: CairnTypography.medium,
                    ),
              ),
            ),
            CairnIcon(
              _open ? CairnIconData.chevronUp : CairnIconData.chevronDown,
              color: theme.mutedForeground,
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: CairnSpacing.s2),
        child: CodeBlock(widget.code, maxHeight: 360),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(CairnSpacing.s5),
      decoration: BoxDecoration(
        color: theme.subtleSurface,
        border: Border(left: BorderSide(color: theme.foreground, width: 2)),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(theme.radiusScale.md),
          bottomRight: Radius.circular(theme.radiusScale.md),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Why it is built this way',
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  color: theme.foreground,
                  fontWeight: CairnTypography.semibold,
                ),
          ),
          const SizedBox(height: CairnSpacing.s2),
          Text(
            text,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  color: theme.mutedForeground,
                  height: CairnTypography.leadingRelaxed,
                ),
          ),
        ],
      ),
    );
  }
}
