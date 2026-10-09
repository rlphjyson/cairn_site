import '../models/contact.dart';

/// Filters contacts by name or status line.
class SearchContacts {
  /// Creates the use case.
  const SearchContacts();

  /// The contacts matching [query] (case-insensitive); all of them when the
  /// query is blank.
  List<Contact> call(List<Contact> contacts, String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return contacts;
    return contacts
        .where(
          (Contact c) =>
              c.name.toLowerCase().contains(q) ||
              c.about.toLowerCase().contains(q),
        )
        .toList();
  }
}
