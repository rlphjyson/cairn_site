import '../../../core/presentation/view_model.dart';
import '../bloc/features_cubit.dart';

/// Owns the [FeaturesCubit] for the life of the features section.
class FeaturesViewModel implements ViewModel {
  /// Creates the view model.
  FeaturesViewModel(this.cubit);

  /// The features state.
  final FeaturesCubit cubit;

  @override
  void dispose() => cubit.close();
}
