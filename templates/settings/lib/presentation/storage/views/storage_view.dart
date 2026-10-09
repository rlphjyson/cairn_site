import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/byte_format.dart';
import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/load_gate.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../domain/settings/models/settings_section.dart';
import '../../../domain/settings/models/settings_snapshot.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/registry/settings_registry.dart';
import '../../settings/bloc/settings_cubit.dart';
import '../../settings/bloc/settings_state.dart';
import '../../settings/widgets/section_blocks.dart';
import '../bloc/storage_cubit.dart';
import '../view_models/storage_view_model.dart';
import '../widgets/usage_meter.dart';

/// Storage and data: a usage meter by category, clear cache (with a confirm
/// that says how much it frees), download over Wi-Fi only and auto-delete.
class StorageView extends StatelessWidget {
  /// Creates the view.
  const StorageView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<StorageViewModel>(
    onCreate: (BuildContext context, StorageViewModel vm) =>
        unawaited(vm.cubit.load()),
    builder: (BuildContext context, StorageViewModel vm) =>
        BlocProvider<StorageCubit>.value(
          value: vm.cubit,
          child: NoticeListener<StorageCubit, StorageState>(
            pick: (StorageState s) => s.notice,
            child: _Body(onBack: onBack),
          ),
        ),
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.onBack});

  final VoidCallback? onBack;

  Future<void> _clear(BuildContext context, int bytes) async {
    final StorageCubit cubit = context.read<StorageCubit>();
    final bool sure = await confirmSettingsAction(
      context,
      title: 'Clear cache?',
      description:
          'This frees about ${formatBytes(bytes)}. Nothing you saved is '
          'removed, but some screens may load more slowly once.',
      confirmLabel: 'Clear cache',
    );
    if (sure) await cubit.clearCache();
  }

  @override
  Widget build(BuildContext context) {
    final StorageState storage = context.watch<StorageCubit>().state;
    final SettingsState settings = context.watch<SettingsCubit>().state;
    final SettingsCubit cubit = context.read<SettingsCubit>();
    final SettingsRegistry registry = context.read<SettingsRegistry>();
    final SettingsSnapshot? snapshot = settings.snapshot;
    final int cache = storage.usage?.cacheBytes ?? 0;
    return PageFrame(
      title: SettingsSection.storage.title,
      onBack: onBack,
      children: <Widget>[
        LoadGate(
          status: storage.status,
          onRetry: context.read<StorageCubit>().load,
          rows: 2,
          child: storage.usage == null
              ? const SizedBox.shrink()
              : UsageMeter(usage: storage.usage!),
        ),
        if (snapshot != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final (int i, Widget w) in SectionBlocks.build(
                context,
                registry: registry,
                section: SettingsSection.storage,
                snapshot: snapshot,
                onChanged: cubit.set,
                subtitles: <String, String>{
                  if (storage.clearing) SettingIds.clearCache: 'Clearing...',
                  if (storage.status == LoadStatus.ready && cache == 0)
                    SettingIds.clearCache: 'The cache is empty.',
                  if (storage.status == LoadStatus.ready && cache > 0)
                    SettingIds.clearCache:
                        '${formatBytes(cache)} can be freed. Nothing you '
                        'saved is removed.',
                },
                actions: <String, VoidCallback>{
                  if (cache > 0 && !storage.clearing)
                    SettingIds.clearCache: () =>
                        unawaited(_clear(context, cache)),
                },
              ).indexed) ...<Widget>[if (i > 0) const SizedBox(height: 20), w],
            ],
          )
        else
          LoadGate(
            status: settings.status,
            onRetry: cubit.load,
            child: const SizedBox.shrink(),
          ),
      ],
    );
  }
}
