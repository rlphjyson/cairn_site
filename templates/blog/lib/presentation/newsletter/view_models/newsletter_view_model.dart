import '../../../core/presentation/view_model.dart';
import '../bloc/newsletter_cubit.dart';

/// Owns one sign-up form's [NewsletterCubit].
class NewsletterViewModel implements ViewModel {
  /// Creates the view model.
  NewsletterViewModel(this.cubit);

  /// The form state.
  final NewsletterCubit cubit;

  @override
  void dispose() => cubit.close();
}
