/// The subjects offered on the contact support form.
abstract final class SupportSubjects {
  /// Subject id and label.
  static const List<({String id, String label})> all =
      <({String id, String label})>[
        (id: 'bug', label: 'Something is not working'),
        (id: 'account', label: 'My account'),
        (id: 'billing', label: 'Billing'),
        (id: 'feedback', label: 'Feedback or an idea'),
        (id: 'other', label: 'Something else'),
      ];

  /// Whether [id] is a known subject.
  static bool isValid(String id) =>
      all.any((({String id, String label}) s) => s.id == id);
}
