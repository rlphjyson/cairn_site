/// The three parts of the personalise step, in order.
///
/// Each is one screenful, so a phone never has to scroll a long form. The
/// labels feed the `CairnSteps` indicator at the top.
enum PersonaliseSection {
  /// Pick at least the minimum number of interests.
  interests(
    'Interests',
    'What are you into?',
    'Pick a few; we use them to tailor what you see.',
  ),

  /// Pick one goal.
  goal(
    'Goal',
    'What is your main goal?',
    'Choose the one that matters most right now.',
  ),

  /// Pick how often to be reminded.
  reminders(
    'Reminders',
    'When should we nudge you?',
    'You can change this any time in settings.',
  );

  const PersonaliseSection(this.label, this.title, this.hint);

  /// The short label shown in the step indicator.
  final String label;

  /// The heading.
  final String title;

  /// The line under the heading.
  final String hint;
}
