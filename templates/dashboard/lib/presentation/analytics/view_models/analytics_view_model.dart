import '../../../core/presentation/view_model.dart';
import '../bloc/analytics_cubit.dart';

/// Owns the analytics page's [AnalyticsCubit] for the life of the screen.
class AnalyticsViewModel implements ViewModel {
  /// Creates the view model.
  AnalyticsViewModel(this.cubit);

  /// The analytics page state.
  final AnalyticsCubit cubit;

  @override
  void dispose() => cubit.close();
}
