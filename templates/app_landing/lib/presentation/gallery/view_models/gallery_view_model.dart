import '../../../core/presentation/view_model.dart';
import '../bloc/gallery_cubit.dart';

/// Owns the [GalleryCubit] for the life of the gallery section.
class GalleryViewModel implements ViewModel {
  /// Creates the view model.
  GalleryViewModel(this.cubit);

  /// The gallery state.
  final GalleryCubit cubit;

  @override
  void dispose() => cubit.close();
}
