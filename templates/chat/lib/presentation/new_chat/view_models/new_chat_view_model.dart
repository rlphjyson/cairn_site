import '../../../core/presentation/view_model.dart';
import '../bloc/new_chat_cubit.dart';

/// Owns the [NewChatCubit] of one visit to the new chat screen.
class NewChatViewModel implements ViewModel {
  /// Creates the view model.
  NewChatViewModel(this.cubit);

  /// The screen's state.
  final NewChatCubit cubit;

  @override
  void dispose() => cubit.close();
}
