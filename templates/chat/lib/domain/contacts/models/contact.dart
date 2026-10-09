import 'package:equatable/equatable.dart';

import '../../../common/utils/initials.dart';
import 'presence.dart';

/// A person you can talk to (or you).
class Contact extends Equatable {
  /// Creates a contact.
  const Contact({
    required this.id,
    required this.name,
    this.about = '',
    this.avatar,
    this.presence = Presence.offline,
    this.lastSeen,
    this.blocked = false,
  });

  /// A stable identifier.
  final String id;

  /// The display name.
  final String name;

  /// The short status line ("Hiking this weekend").
  final String about;

  /// An asset path (`assets/images/...`) or an `http(s)` URL; `null` shows the
  /// person's initials.
  final String? avatar;

  /// Current availability.
  final Presence presence;

  /// When the person was last online; meaningful while [presence] is offline.
  final DateTime? lastSeen;

  /// Whether you blocked this person.
  final bool blocked;

  /// Up to two capital letters: `Mina Park` is `MP`.
  String get initials => initialsOf(name);

  /// A copy with some fields replaced.
  Contact copyWith({
    String? name,
    String? about,
    Presence? presence,
    DateTime? lastSeen,
    bool? blocked,
  }) => Contact(
    id: id,
    name: name ?? this.name,
    about: about ?? this.about,
    avatar: avatar,
    presence: presence ?? this.presence,
    lastSeen: lastSeen ?? this.lastSeen,
    blocked: blocked ?? this.blocked,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    about,
    avatar,
    presence,
    lastSeen,
    blocked,
  ];
}

/// A run of contacts under one initial, for the alphabetical list.
class ContactSection extends Equatable {
  /// Creates a section.
  const ContactSection(this.letter, this.contacts);

  /// `A`, `B`, ... or `#` for names that do not start with a letter.
  final String letter;

  /// The people under [letter], sorted by name.
  final List<Contact> contacts;

  @override
  List<Object?> get props => <Object?>[letter, contacts];
}
