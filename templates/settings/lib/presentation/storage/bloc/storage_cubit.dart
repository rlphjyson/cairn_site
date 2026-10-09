import 'package:equatable/equatable.dart';

import '../../../common/utils/byte_format.dart';
import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/notice.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/storage/models/storage_usage.dart';
import '../../../domain/storage/use_cases/storage_use_cases.dart';

/// What the app stores, and whether the cache is being cleared.
class StorageState extends Equatable {
  /// Creates a state.
  const StorageState({
    this.status = LoadStatus.loading,
    this.usage,
    this.clearing = false,
    this.notice,
  });

  /// Whether the usage has loaded.
  final LoadStatus status;

  /// The usage. `null` until loaded.
  final StorageUsage? usage;

  /// Whether the cache is being cleared.
  final bool clearing;

  /// A message to show as a toast.
  final Notice? notice;

  @override
  List<Object?> get props => <Object?>[status, usage, clearing, notice];
}

/// The storage screen. Screen-scoped.
class StorageCubit extends SafeCubit<StorageState> {
  /// Creates the cubit.
  StorageCubit(this._getUsage, this._clearCache) : super(const StorageState());

  final GetStorageUsage _getUsage;
  final ClearCache _clearCache;

  /// Loads the usage.
  Future<void> load() async {
    emit(const StorageState());
    try {
      emit(StorageState(status: LoadStatus.ready, usage: await _getUsage()));
    } on Object {
      emit(const StorageState(status: LoadStatus.failure));
    }
  }

  /// Empties the cache and reports how much was freed.
  Future<void> clearCache() async {
    final StorageUsage? before = state.usage;
    if (before == null || state.clearing) return;
    emit(StorageState(status: LoadStatus.ready, usage: before, clearing: true));
    try {
      final int reclaimed = await _clearCache();
      emit(
        StorageState(
          status: LoadStatus.ready,
          usage: before.withoutCache(),
          notice: Notice(
            'Cache cleared',
            description: '${formatBytes(reclaimed)} reclaimed.',
          ),
        ),
      );
    } on Object {
      emit(
        StorageState(
          status: LoadStatus.ready,
          usage: before,
          notice: Notice('Could not clear the cache', isError: true),
        ),
      );
    }
  }
}
