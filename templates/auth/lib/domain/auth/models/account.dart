import 'package:equatable/equatable.dart';

/// The person who signed in.
class Account extends Equatable {
  /// Creates an account.
  const Account({required this.id, required this.name, required this.email});

  /// The server's stable identifier for the account.
  final String id;

  /// The display name.
  final String name;

  /// The email address.
  final String email;

  /// The first name, for greetings.
  String get firstName {
    final List<String> parts = _words;
    return parts.isEmpty ? email : parts.first;
  }

  /// Up to two capital letters for an avatar: "Ada Lovelace" is "AL". Falls
  /// back to the email's first letter when there is no name.
  String get initials {
    final List<String> parts = _words;
    if (parts.isEmpty) {
      return email.isEmpty ? '?' : email.substring(0, 1).toUpperCase();
    }
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  List<String> get _words => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String w) => w.isNotEmpty)
      .toList();

  @override
  List<Object?> get props => <Object?>[id, name, email];
}
