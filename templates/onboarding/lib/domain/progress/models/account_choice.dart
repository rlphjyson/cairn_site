/// What the user chose on the account step.
///
/// The template builds no sign-in forms. The choice is handed to the host in
/// `OnboardingResult.accountChoice`, which routes to its own auth flow.
enum AccountChoice {
  /// "Create account".
  createAccount,

  /// "I already have an account".
  signIn,

  /// "Continue as guest".
  guest;

  /// The choice stored under [key], or `null` when it is unknown.
  static AccountChoice? fromKey(String? key) {
    for (final AccountChoice choice in values) {
      if (choice.name == key) return choice;
    }
    return null;
  }
}
