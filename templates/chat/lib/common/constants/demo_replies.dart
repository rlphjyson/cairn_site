/// What the demo bot says back, and when. Used only by the in-memory data
/// source; a real backend has people on the other end.
abstract final class DemoReplies {
  /// Answers to a question.
  static const List<String> questions = <String>[
    'Good question. Let me think about it.',
    'Probably yes! Want me to check?',
    'Hmm, not sure yet. What do you think?',
    'I was just about to ask you the same.',
  ];

  /// Answers to thanks.
  static const List<String> thanks = <String>[
    'Anytime!',
    'No problem at all.',
    'Happy to help.',
  ];

  /// Answers to a greeting.
  static const List<String> greetings = <String>[
    'Hey! How is your day going?',
    'Hi there! Good to hear from you.',
    'Morning! Coffee in hand.',
  ];

  /// Answers that mention food.
  static const List<String> food = <String>[
    'I could go for something spicy.',
    'Noodles. It is always noodles.',
    'Whatever you pick, I am in.',
  ];

  /// The caption on a photo the bot sends.
  static const List<String> photoCaptions = <String>[
    'Here you go.',
    'Took this earlier.',
    'Look at this light.',
  ];

  /// Everything else, in rotation.
  static const List<String> generic = <String>[
    'Haha, love that.',
    'Makes sense to me.',
    'Let me get back to you on this one.',
    'Nice! Tell me more.',
    'Sounds like a plan.',
    'Ha, same.',
    'Ok, noted. Talk soon?',
    'Can we do that a bit later?',
  ];

  /// An occasional emoji-only reply.
  static const List<String> emoji = <String>[
    '\u{1F602}',
    '\u{1F64C}\u{1F64C}',
    '\u{1F44D}',
  ];

  /// Photos the bot can send, as asset paths.
  static const List<String> photos = <String>[
    'assets/images/photo-lake.jpg',
    'assets/images/photo-lighthouse.jpg',
    'assets/images/photo-waterfall.jpg',
    'assets/images/photo-dog.jpg',
  ];
}
