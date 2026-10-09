import 'package:flutter_bloc/flutter_bloc.dart';

/// The heading currently at the top of the reading area, or `null` before the
/// first one. Screen-scoped: created and closed by `DocPageViewModel`.
class TocCubit extends Cubit<String?> {
  /// Creates the cubit.
  TocCubit() : super(null);

  /// Marks [id] as the active heading.
  void setActive(String? id) {
    if (id != state) emit(id);
  }
}
