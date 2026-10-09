import '../models/account.dart';
import '../models/preferences.dart';

/// Converts the account and preferences to and from JSON.
abstract final class ProfileMapper {
  /// Maps [json] to an [Account].
  static Account accountFromJson(Map<String, Object?> json) => Account(
    name: json['name']! as String,
    email: json['email']! as String,
    reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    memberSince: (json['memberSince'] as num?)?.toInt() ?? 2024,
  );

  /// Maps [json] to [Preferences].
  static Preferences preferencesFromJson(Map<String, Object?> json) =>
      Preferences(
        orderUpdates: json['orderUpdates'] as bool? ?? true,
        offers: json['offers'] as bool? ?? false,
      );

  /// The JSON for [preferences].
  static Map<String, Object?> preferencesToJson(Preferences preferences) =>
      <String, Object?>{
        'orderUpdates': preferences.orderUpdates,
        'offers': preferences.offers,
      };
}
