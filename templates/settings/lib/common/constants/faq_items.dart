/// The questions on the Help screen.
///
/// Replace these with your own, or load them from your backend and build the
/// same records.
abstract final class FaqItems {
  /// Id, question and answer.
  static const List<({String id, String question, String answer})> all =
      <({String id, String question, String answer})>[
        (
          id: 'sync',
          question: 'How do I sync my data across devices?',
          answer:
              'Sign in with the same account on each device. Your settings '
              'sync in the background whenever you are online.',
        ),
        (
          id: 'password',
          question: 'I forgot my password',
          answer:
              'Sign out, choose "Forgot password" on the sign-in screen and '
              'follow the link we email you. The link works once and expires '
              'in an hour.',
        ),
        (
          id: 'notifications',
          question: 'Why am I not getting notifications?',
          answer:
              'Check Notifications in settings, make sure quiet hours are off, '
              'and that notifications are allowed for this app in your phone '
              'settings.',
        ),
        (
          id: 'storage',
          question: 'How do I free up space?',
          answer:
              'Open Storage and data and clear the cache. Downloads can be '
              'removed automatically after a period you choose.',
        ),
        (
          id: 'delete',
          question: 'Can I get my data back after deleting my account?',
          answer:
              'No. Deleting is permanent. Deactivating hides your account and '
              'keeps your data, so you can come back any time.',
        ),
      ];
}
