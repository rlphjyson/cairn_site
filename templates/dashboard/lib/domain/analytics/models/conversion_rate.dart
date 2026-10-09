import 'package:equatable/equatable.dart';

/// The conversion rate against its target.
class ConversionRate extends Equatable {
  /// Creates a rate.
  const ConversionRate({required this.rate, required this.target});

  /// Current rate, in percent.
  final double rate;

  /// Target rate, in percent.
  final double target;

  /// 0 to 1, how close the rate is to the target.
  double get progress => (rate / target).clamp(0.0, 1.0);

  @override
  List<Object?> get props => <Object?>[rate, target];
}
