/// Where one of your own messages is on its way.
enum MessageStatus {
  /// Handed to the app, not yet confirmed by the server.
  sending('sending'),

  /// The server has it.
  sent('sent'),

  /// The other person has read it.
  read('read'),

  /// The server rejected it or the network failed.
  failed('failed');

  const MessageStatus(this.wire);

  /// The value used in JSON.
  final String wire;

  /// Reads the JSON value, treating anything unknown as [sent].
  static MessageStatus fromWire(Object? value) =>
      MessageStatus.values.firstWhere(
        (MessageStatus s) => s.wire == value,
        orElse: () => MessageStatus.sent,
      );
}
