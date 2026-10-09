import '../../../core/presentation/view_model.dart';
import '../bloc/post_detail_cubit.dart';

/// Owns the article page's [PostDetailCubit] for the life of the screen.
class PostDetailViewModel implements ViewModel {
  /// Creates the view model.
  PostDetailViewModel(this.cubit);

  /// The article state.
  final PostDetailCubit cubit;

  @override
  void dispose() => cubit.close();
}
