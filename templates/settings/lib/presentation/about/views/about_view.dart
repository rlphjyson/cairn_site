import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/infrastructure/settings_hooks.dart';
import '../../../core/presentation/notice.dart';
import '../../../core/presentation/settings_text.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/setting_rows.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../domain/settings/models/app_info.dart';
import '../../../domain/settings/models/setting_definition.dart';
import '../../../domain/settings/models/settings_link.dart';
import '../../../domain/settings/models/settings_section.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/registry/settings_registry.dart';
import '../../settings/bloc/settings_cubit.dart';
import '../widgets/rate_dialog.dart';

/// About: the app's version, open-source licences, legal links and a way to
/// rate it.
class AboutView extends StatefulWidget {
  /// Creates the view.
  const AboutView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  bool _licences = false;

  void _link(SettingDefinition d) {
    final SettingsHooks hooks = context.read<SettingsHooks>();
    final void Function(SettingsLink)? onTap = hooks.onLinkTap;
    if (d is LinkSetting && onTap != null) {
      onTap(d.link);
    } else {
      showSettingsToast(
        context,
        Notice(
          d.title,
          description: 'Pass onLinkTap to SettingsApp to open this.',
        ),
      );
    }
  }

  Future<void> _rate() async {
    final int? stars = await showSettingsDialog<int>(
      context,
      (BuildContext _) => const RateDialog(),
    );
    if (stars == null || !mounted) return;
    context.read<SettingsHooks>().onRateApp?.call(stars);
    showSettingsToast(
      context,
      Notice('Thanks for rating', description: 'You gave us $stars of 5.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final SettingsRegistry registry = context.read<SettingsRegistry>();
    final AppInfo? info = context.watch<SettingsCubit>().state.appInfo;
    final List<SettingDefinition> rows = registry.inSection(
      SettingsSection.about,
    );
    return PageFrame(
      title: SettingsSection.about.title,
      onBack: widget.onBack,
      children: <Widget>[
        if (info != null)
          Semantics(
            container: true,
            label: '${info.name}, version ${info.versionLabel}',
            excludeSemantics: true,
            child: Column(
              children: <Widget>[
                Text(
                  info.name,
                  textAlign: TextAlign.center,
                  style: settingsText(
                    theme,
                    CairnTypography.xl,
                    weight: CairnTypography.semibold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${info.versionLabel}',
                  textAlign: TextAlign.center,
                  style: settingsText(
                    theme,
                    CairnTypography.sm,
                    color: theme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        SettingsGroup(
          children: <Widget>[
            for (final SettingDefinition d in rows)
              if (d.id == SettingIds.licences)
                NavRow(
                  title: d.title,
                  value: _licences ? 'Hide' : 'Show',
                  onTap: () => setState(() => _licences = !_licences),
                )
              else if (d.id == SettingIds.rate)
                NavRow(title: d.title, onTap: () => unawaited(_rate()))
              else
                NavRow(
                  title: d.title,
                  subtitle: d.description,
                  external: d is LinkSetting,
                  onTap: () => _link(d),
                ),
          ],
        ),
        if (_licences && info != null)
          SettingsGroup(
            title: 'Open-source licences',
            children: <Widget>[
              for (final LicenceEntry e in info.licences)
                Semantics(
                  container: true,
                  label: '${e.name}, ${e.licence}. ${e.summary}',
                  excludeSemantics: true,
                  child: CairnListItem(
                    title: Text(e.name),
                    subtitle: e.summary.isEmpty ? null : Text(e.summary),
                    trailing: CairnBadge(
                      variant: CairnBadgeVariant.outline,
                      label: Text(e.licence),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
