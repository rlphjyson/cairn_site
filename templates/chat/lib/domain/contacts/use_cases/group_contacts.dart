import '../models/contact.dart';

/// Splits contacts into alphabetical sections (`A`, `B`, ..., `#`).
class GroupContacts {
  /// Creates the use case.
  const GroupContacts();

  /// Sections in alphabetical order, `#` last; people inside are sorted by
  /// name.
  List<ContactSection> call(List<Contact> contacts) {
    final Map<String, List<Contact>> byLetter = <String, List<Contact>>{};
    for (final Contact c in contacts) {
      final String name = c.name.trim();
      final String first = name.isEmpty ? '#' : name[0].toUpperCase();
      final String letter = RegExp('[A-Z]').hasMatch(first) ? first : '#';
      byLetter.putIfAbsent(letter, () => <Contact>[]).add(c);
    }
    final List<String> letters = byLetter.keys.toList()
      ..sort((String a, String b) {
        if (a == '#') return 1;
        if (b == '#') return -1;
        return a.compareTo(b);
      });
    return <ContactSection>[
      for (final String l in letters)
        ContactSection(
          l,
          byLetter[l]!..sort(
            (Contact a, Contact b) =>
                a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          ),
        ),
    ];
  }
}
