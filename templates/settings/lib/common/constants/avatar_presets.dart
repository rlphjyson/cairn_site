/// The avatars a person can pick on the Edit profile screen.
///
/// The domain only stores the id. How each one looks (gradients built from the
/// theme's tokens) is decided in
/// `presentation/profile/widgets/profile_avatar.dart`.
abstract final class AvatarPresets {
  /// Initials on a muted circle. The default.
  static const String initials = 'initials';

  /// Every preset: id and the name a screen reader announces.
  static const List<({String id, String label})> all =
      <({String id, String label})>[
        (id: initials, label: 'Initials'),
        (id: 'ink', label: 'Ink'),
        (id: 'dusk', label: 'Dusk'),
        (id: 'ember', label: 'Ember'),
        (id: 'moss', label: 'Moss'),
      ];

  /// Whether [id] is a known preset.
  static bool isValid(String id) =>
      all.any((({String id, String label}) p) => p.id == id);
}
