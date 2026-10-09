/// How available a person is.
enum Presence {
  /// Active now.
  online('online', 'Online'),

  /// Signed in but not paying attention.
  away('away', 'Away'),

  /// Does not want to be disturbed.
  doNotDisturb('dnd', 'Do not disturb'),

  /// Not signed in.
  offline('offline', 'Offline');

  const Presence(this.wire, this.label);

  /// The value used in JSON.
  final String wire;

  /// The text shown to people.
  final String label;

  /// Reads the JSON value, treating anything unknown as [offline].
  static Presence fromWire(Object? value) => Presence.values.firstWhere(
    (Presence p) => p.wire == value,
    orElse: () => Presence.offline,
  );
}
