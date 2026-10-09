import '../../../core/presentation/view_model.dart';
import '../bloc/storage_cubit.dart';

/// Owns the Storage and data screen's [StorageCubit].
class StorageViewModel implements ViewModel {
  /// Creates the view model.
  StorageViewModel(this.cubit);

  /// The screen's cubit.
  final StorageCubit cubit;

  @override
  void dispose() => cubit.close();
}
