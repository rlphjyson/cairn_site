import 'package:equatable/equatable.dart';

/// The signed-in shopper.
class Account extends Equatable {
  /// Creates an account.
  const Account({
    required this.name,
    required this.email,
    required this.reviewCount,
    required this.memberSince,
  });

  /// Full name.
  final String name;

  /// Email address.
  final String email;

  /// Reviews written.
  final int reviewCount;

  /// The year the account was opened.
  final int memberSince;

  /// The first word of [name].
  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  /// Two letters for the avatar.
  String get initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => <Object?>[name, email, reviewCount, memberSince];
}
