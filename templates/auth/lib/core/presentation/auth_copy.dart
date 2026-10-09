import '../../common/constants/auth_policy.dart';
import '../../common/constants/demo_account.dart';
import '../../domain/auth/models/auth_failure.dart';
import '../../domain/validation/models/password_assessment.dart';
import '../../domain/validation/models/validation_issue.dart';

/// Every word the screens show, in one place.
///
/// Edit the strings to change the voice, or replace the statics with lookups
/// into your localisation system (`AppLocalizations.of(context)...`): views
/// only ever call these members, so nothing else needs to change. Messages
/// about sign-in never say whether the email or the password was wrong, and
/// messages about password reset never say whether an account exists.
abstract final class AuthCopy {
  // Brand.

  /// The product name shown on the welcome screen and in legal copy.
  static const String brandName = 'Cairn';

  /// The line under the name on the welcome screen.
  static const String tagline = 'A calm place for your work.';

  // Welcome.

  /// The primary welcome button.
  static const String continueWithEmail = 'Sign in with email';

  /// The divider between social and email sign-in.
  static const String or = 'or';

  /// The prompt before the create-account link.
  static const String newHere = 'New to $brandName?';

  /// The create-account link.
  static const String createAccountLink = 'Create an account';

  /// A social button's label.
  static String continueWith(String provider) => 'Continue with $provider';

  /// A social button's label while its request runs.
  static String connectingTo(String provider) => 'Connecting to $provider';

  /// The legal footnote, before the links.
  static const String legalIntro = 'By continuing you agree to our';

  /// The terms link.
  static const String terms = 'Terms';

  /// The privacy link.
  static const String privacy = 'Privacy Policy';

  /// Joins the two legal links.
  static const String and = 'and';

  // Common.

  /// The back button's label.
  static const String back = 'Back';

  /// The email field's label.
  static const String emailLabel = 'Email';

  /// The email field's placeholder.
  static const String emailPlaceholder = 'you@example.com';

  /// The password field's label.
  static const String passwordLabel = 'Password';

  /// The shown-password toggle's label.
  static const String showPassword = 'Show password';

  /// The hidden-password toggle's label.
  static const String hidePassword = 'Hide password';

  // Sign in.

  /// The sign-in heading.
  static const String signInTitle = 'Welcome back';

  /// The sign-in subheading.
  static const String signInSubtitle = 'Sign in to pick up where you left off.';

  /// The remember-me checkbox.
  static const String rememberMe = 'Remember me';

  /// The forgot-password link.
  static const String forgotPasswordLink = 'Forgot password?';

  /// The sign-in button.
  static const String signInButton = 'Sign in';

  /// The sign-in button while the request is in flight.
  static const String signingIn = 'Signing in';

  /// The prompt before the sign-up link.
  static const String noAccount = 'No account yet?';

  /// The sign-up link on the sign-in screen.
  static const String signUpLink = 'Create one';

  /// The button label while sign-in is locked.
  static String tryAgainIn(int seconds) => 'Try again in ${seconds}s';

  // Sign up.

  /// The sign-up heading.
  static const String signUpTitle = 'Create your account';

  /// The sign-up subheading.
  static const String signUpSubtitle = 'It takes less than a minute.';

  /// The name field's label.
  static const String nameLabel = 'Full name';

  /// The name field's placeholder.
  static const String namePlaceholder = 'Ada Lovelace';

  /// The new-password field's label.
  static const String newPasswordLabel = 'Password';

  /// The confirm field's label.
  static const String confirmLabel = 'Confirm password';

  /// The terms checkbox, before the links.
  static const String agreeTo = 'I agree to the';

  /// The terms checkbox's accessible label.
  static const String agreeSemantics =
      'I agree to the Terms and the Privacy Policy';

  /// The sign-up button.
  static const String signUpButton = 'Create account';

  /// The sign-up button while the request is in flight.
  static const String signingUp = 'Creating your account';

  /// The prompt before the sign-in link.
  static const String haveAccount = 'Already have an account?';

  /// The sign-in link on the sign-up screen.
  static const String signInLink = 'Sign in';

  // Password strength.

  /// The meter's accessible name.
  static const String strengthLabel = 'Password strength';

  /// The meter text before anything is typed.
  static const String strengthIdle = 'Choose a strong password';

  /// The label for a strength [level].
  static String strength(PasswordStrengthLevel level) => switch (level) {
    PasswordStrengthLevel.tooShort => 'Too short',
    PasswordStrengthLevel.weak => 'Weak',
    PasswordStrengthLevel.fair => 'Fair',
    PasswordStrengthLevel.strong => 'Strong',
  };

  /// The checklist line for [rule].
  static String rule(PasswordRule rule) => switch (rule) {
    PasswordRule.minLength =>
      'At least ${AuthPolicy.minPasswordLength} characters',
    PasswordRule.mixedCase => 'Upper and lower case letters',
    PasswordRule.number => 'A number',
    PasswordRule.symbol => 'A symbol (recommended)',
  };

  /// Spoken after a checklist line: met.
  static const String ruleMet = 'met';

  /// Spoken after a checklist line: not met.
  static const String ruleUnmet = 'not met';

  // Forgot password.

  /// The forgot-password heading.
  static const String forgotTitle = 'Forgot your password?';

  /// The forgot-password subheading.
  static const String forgotSubtitle =
      'Enter your email and we will send you a code to reset it.';

  /// The send-code button.
  static const String sendCode = 'Send code';

  /// The send-code button while the request is in flight.
  static const String sendingCode = 'Sending code';

  /// The confirmation heading. Shown whether or not the account exists.
  static const String checkInboxTitle = 'Check your inbox';

  /// The confirmation body. It never says whether the account exists.
  static String checkInboxBody(String email) =>
      'If an account exists for $email, a ${AuthPolicy.codeLength}-digit code '
      'is on its way. It stays valid for '
      '${AuthPolicy.codeLifetime.inMinutes} minutes.';

  /// The confirmation body when recovery emails a link, not a code.
  static String checkInboxLinkBody(String email) =>
      'If an account exists for $email, we have emailed a link to reset the '
      'password. Open it on this device.';

  /// The button that moves on to the code screen.
  static const String enterCode = 'Enter code';

  /// The link that returns to the email form.
  static const String useDifferentEmail = 'Use a different email';

  /// The link that returns to sign in.
  static const String backToSignIn = 'Back to sign in';

  // Verify code.

  /// The verify-code heading.
  static const String verifyTitle = 'Enter the code';

  /// The verify-code subheading.
  static String verifySubtitle(String email) =>
      'We sent a ${AuthPolicy.codeLength}-digit code to $email.';

  /// The OTP field's accessible name.
  static const String codeSemantics = 'Verification code';

  /// The paste button.
  static const String pasteCode = 'Paste code';

  /// The verify button.
  static const String verifyButton = 'Verify code';

  /// The verify button while the request is in flight.
  static const String verifying = 'Verifying';

  /// Before the resend countdown.
  static const String resendPrompt = 'Did not get it?';

  /// The resend countdown, formatted `m:ss`.
  static String resendIn(String time) => 'Resend code in $time';

  /// The resend link once the cooldown is over.
  static const String resend = 'Resend code';

  /// Shown while a resend is in flight.
  static const String resending = 'Sending a new code';

  /// Shown after a code was resent.
  static String resent(String email) => 'We sent a new code to $email.';

  // Reset password.

  /// The reset heading.
  static const String resetTitle = 'Choose a new password';

  /// The reset subheading.
  static const String resetSubtitle =
      'Pick something you do not use anywhere else.';

  /// The reset button.
  static const String resetButton = 'Update password';

  /// The reset button while the request is in flight.
  static const String resetting = 'Updating your password';

  /// The reset success heading.
  static const String resetDoneTitle = 'Password updated';

  /// The reset success body.
  static const String resetDoneBody =
      'You can now sign in with your new password.';

  /// The button after a successful reset.
  static const String continueToSignIn = 'Continue to sign in';

  /// The link when the reset session ran out.
  static const String startOver = 'Start over';

  // Signed in.

  /// The greeting on the signed-in screen.
  static String welcomeName(String firstName) => 'Welcome, $firstName';

  /// The line under the greeting.
  static const String signedInSubtitle = 'You are signed in.';

  /// The placeholder alert's title.
  static const String hookTitle = 'This screen is a placeholder';

  /// The placeholder alert's body.
  static const String hookBody =
      'AuthApp calls onAuthenticated with the session as soon as sign-in '
      'succeeds. Navigate to your own home screen there and this one is never '
      'shown.';

  /// The sign-out button.
  static const String signOut = 'Sign out';

  /// The sign-out button while the request is in flight.
  static const String signingOut = 'Signing out';

  /// A note about where the session lives.
  static const String sessionNote =
      'The session is held in memory only. Persist the token in secure '
      'storage to keep people signed in.';

  // Demo hints.

  /// The sign-in demo hint.
  static const String demoSignIn =
      'Demo account\n${DemoAccount.email} · ${DemoAccount.password}';

  /// The verify-code demo hint.
  static const String demoCode = 'Demo code: ${DemoAccount.code}';

  // Errors.

  /// The one-line heading of the alert for a [failure].
  static String failureTitle(AuthFailure failure) => switch (failure) {
    AuthFailure.invalidCredentials => 'Could not sign you in',
    AuthFailure.rateLimited => 'Too many attempts',
    AuthFailure.invalidCode => 'Wrong code',
    AuthFailure.codeExpired => 'Code expired',
    AuthFailure.tooManyAttempts => 'Too many wrong codes',
    AuthFailure.network => 'You seem to be offline',
    _ => 'Something went wrong',
  };

  /// The words for a field [issue].
  static String issue(ValidationIssue issue) => switch (issue) {
    ValidationIssue.nameRequired => 'Enter your name.',
    ValidationIssue.nameTooShort => 'Your name is too short.',
    ValidationIssue.emailRequired => 'Enter your email address.',
    ValidationIssue.emailInvalid => 'Enter a valid email address.',
    ValidationIssue.emailTaken =>
      'An account with this email already exists. Try signing in.',
    ValidationIssue.passwordRequired => 'Enter your password.',
    ValidationIssue.passwordTooShort =>
      'Use at least ${AuthPolicy.minPasswordLength} characters.',
    ValidationIssue.passwordTooWeak =>
      'Add upper and lower case letters and a number.',
    ValidationIssue.passwordTooCommon =>
      'That password is too common. Pick another.',
    ValidationIssue.confirmationRequired => 'Repeat your password.',
    ValidationIssue.confirmationMismatch => 'The passwords do not match.',
    ValidationIssue.termsRequired => 'Accept the terms to create your account.',
    ValidationIssue.codeIncomplete =>
      'Enter all ${AuthPolicy.codeLength} digits.',
  };

  /// The words for a [failure]. [attemptsRemaining] adds "n attempts left" to
  /// a wrong code.
  static String failure(AuthFailure failure, {int? attemptsRemaining}) =>
      switch (failure) {
        AuthFailure.invalidCredentials =>
          'The email or password is not right. Check them and try again.',
        AuthFailure.emailTaken =>
          'An account with this email already exists. Try signing in.',
        AuthFailure.rateLimited =>
          'You have tried too many times. Wait a moment, then try again.',
        AuthFailure.invalidCode =>
          attemptsRemaining == null
              ? 'That code is not right. Check it and try again.'
              : 'That code is not right. $attemptsRemaining '
                    '${attemptsRemaining == 1 ? 'attempt' : 'attempts'} left.',
        AuthFailure.codeExpired =>
          'That code has expired. Request a new one to continue.',
        AuthFailure.tooManyAttempts =>
          'Too many wrong codes. Request a new code to continue.',
        AuthFailure.invalidInput => 'Check the highlighted fields.',
        AuthFailure.network =>
          'We could not reach the server. Check your connection and try again.',
        AuthFailure.unknown => 'Something went wrong. Please try again.',
      };

  /// Formats a countdown as `m:ss`.
  static String clock(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
