import '../../../core/presentation/view_model.dart';
import '../bloc/download_cubit.dart';

/// Owns the [DownloadCubit] for the life of the download section.
class DownloadViewModel implements ViewModel {
  /// Creates the view model.
  DownloadViewModel(this.cubit);

  /// The form state.
  final DownloadCubit cubit;

  @override
  void dispose() => cubit.close();
}
