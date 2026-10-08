import 'package:equatable/equatable.dart';

/// Notification preferences.
class Preferences extends Equatable {
  /// Creates preferences.
  const Preferences({this.orderUpdates = true, this.offers = false});

  /// Shipping and delivery alerts.
  final bool orderUpdates;

  /// Sales and new arrivals.
  final bool offers;

  /// A copy with the given fields replaced.
  Preferences copyWith({bool? orderUpdates, bool? offers}) => Preferences(
    orderUpdates: orderUpdates ?? this.orderUpdates,
    offers: offers ?? this.offers,
  );

  @override
  List<Object?> get props => <Object?>[orderUpdates, offers];
}
