import '../../../core/presentation/view_model.dart';
import '../bloc/account_cubit.dart';

/// Owns the danger zone's [AccountCubit].
class AccountViewModel implements ViewModel {
  /// Creates the view model.
  AccountViewModel(this.cubit);

  /// The screen's cubit.
  final AccountCubit cubit;

  @override
  void dispose() => cubit.close();
}
