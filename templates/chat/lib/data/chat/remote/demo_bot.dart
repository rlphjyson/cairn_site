import '../../../common/constants/demo_replies.dart';

/// What the bot decided to say.
class BotReply {
  /// Creates a reply.
  const BotReply(this.text, {this.photo});

  /// The message text, or a photo's caption.
  final String text;

  /// An asset path when the reply is a photo.
  final String? photo;
}

/// Picks a varied, believable reply to a message.
///
/// Deterministic: the same text and [turn] always give the same answer, so
/// tests can rely on it and a demo never feels random-broken.
abstract final class DemoBot {
  /// The reply to [text]; [turn] is how many replies came before it.
  static BotReply replyTo(String text, {required int turn}) {
    final String t = text.toLowerCase();
    if (RegExp(r'\b(photo|pic|picture|selfie)\b').hasMatch(t)) {
      return BotReply(
        DemoReplies.photoCaptions[turn % DemoReplies.photoCaptions.length],
        photo: DemoReplies.photos[turn % DemoReplies.photos.length],
      );
    }
    if (t.contains('thank')) return BotReply(_pick(DemoReplies.thanks, turn));
    if (RegExp(r'\b(hi|hello|hey|morning|yo)\b').hasMatch(t)) {
      return BotReply(_pick(DemoReplies.greetings, turn));
    }
    if (RegExp(r'\b(lunch|dinner|eat|food|hungry|pizza)\b').hasMatch(t)) {
      return BotReply(_pick(DemoReplies.food, turn));
    }
    if (t.contains('?')) return BotReply(_pick(DemoReplies.questions, turn));
    if (turn % 5 == 4) return BotReply(_pick(DemoReplies.emoji, turn));
    return BotReply(_pick(DemoReplies.generic, turn));
  }

  static String _pick(List<String> options, int turn) =>
      options[turn % options.length];
}
