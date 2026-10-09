import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/filters/models/period.dart';

/// The selected time range, shared by every page.
///
/// A session cubit: a lazy singleton provided once and read from context.
class PeriodCubit extends Cubit<Period> {
  /// Creates the cubit.
  PeriodCubit() : super(Period.week);

  /// Picks a period.
  void select(Period period) => emit(period);
}
