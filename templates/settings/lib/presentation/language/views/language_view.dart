import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/format_preview.dart';
import '../../../core/presentation/widgets/load_gate.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/setting_rows.dart';
import '../../../domain/settings/models/settings_section.dart';
import '../../../domain/settings/models/settings_snapshot.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/registry/settings_registry.dart';
import '../../settings/bloc/settings_cubit.dart';
import '../../settings/bloc/settings_state.dart';
import '../../settings/widgets/section_blocks.dart';

/// Language and region: language, region, date and time formats and units,
/// with a preview that follows the choices.
class LanguageView extends StatelessWidget {
  /// Creates the view.
  const LanguageView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final SettingsState state = context.watch<SettingsCubit>().state;
    final SettingsCubit cubit = context.read<SettingsCubit>();
    final SettingsRegistry registry = context.read<SettingsRegistry>();
    final SettingsSnapshot? snapshot = state.snapshot;
    return PageFrame(
      title: SettingsSection.language.title,
      onBack: onBack,
      children: <Widget>[
        LoadGate(
          status: state.status,
          onRetry: cubit.load,
          rows: 4,
          child: snapshot == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final (int i, Widget w) in SectionBlocks.build(
                      context,
                      registry: registry,
                      section: SettingsSection.language,
                      snapshot: snapshot,
                      onChanged: cubit.set,
                    ).indexed) ...<Widget>[
                      if (i > 0) const SizedBox(height: 20),
                      w,
                    ],
                    const SizedBox(height: 20),
                    _Preview(snapshot: snapshot),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.snapshot});

  final SettingsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final String date = FormatPreview.date(
      snapshot.choice(SettingIds.dateFormat),
    );
    final String time = FormatPreview.time(
      snapshot.choice(SettingIds.timeFormat),
    );
    final String units = snapshot.choice(SettingIds.units);
    return SettingsGroup(
      title: 'Preview',
      footer: 'How dates, times and distances look with these choices.',
      children: <Widget>[
        _line('Date', date),
        _line('Time', time),
        _line('Distance', FormatPreview.distance(units)),
        _line('Temperature', FormatPreview.temperature(units)),
      ],
    );
  }

  Widget _line(String title, String value) => Semantics(
    label: '$title, $value',
    excludeSemantics: true,
    child: CairnListItem(title: Text(title), trailing: Text(value)),
  );
}
