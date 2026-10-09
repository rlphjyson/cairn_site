import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/auth_copy.dart';
import '../../../core/presentation/auth_text.dart';
import '../../../core/presentation/widgets/auth_button.dart';
import '../../../core/presentation/widgets/auth_scaffold.dart';
import '../../../core/presentation/widgets/error_alert.dart';
import '../../../domain/auth/models/account.dart';
import '../bloc/session_cubit.dart';

/// A placeholder for the signed-in app: the person's avatar and name, a note
/// about the `onAuthenticated` hook, and a sign-out button.
///
/// In your app this screen is never reached: `onAuthenticated` runs first, and
/// you navigate to your own home there.
class SignedInView extends StatelessWidget {
  /// Creates the view.
  const SignedInView({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final SessionState session = context.watch<SessionCubit>().state;
    final Account? account = session.session?.account;

    return AuthScaffold(
      centered: true,
      spacing: 16,
      children: <Widget>[
        const SizedBox(height: 16),
        if (account != null) ...<Widget>[
          Center(
            child: SizedBox.square(
              dimension: 64,
              child: FittedBox(
                child: CairnAvatar(
                  size: CairnAvatarSize.lg,
                  semanticLabel: account.name,
                  fallback: Text(account.initials),
                ),
              ),
            ),
          ),
          Semantics(
            header: true,
            child: Text(
              AuthCopy.welcomeName(account.firstName),
              textAlign: TextAlign.center,
              style: authText(
                theme,
                CairnTypography.xl2,
                weight: CairnTypography.semibold,
                letterSpacing: CairnTypography.trackingTight(24),
              ),
            ),
          ),
          Text(
            account.email,
            textAlign: TextAlign.center,
            style: authText(
              theme,
              CairnTypography.sm,
              color: theme.mutedForeground,
            ),
          ),
        ],
        const SizedBox(height: 8),
        const InfoAlert(title: AuthCopy.hookTitle, message: AuthCopy.hookBody),
        AuthButton(
          label: AuthCopy.signOut,
          loadingLabel: AuthCopy.signingOut,
          variant: CairnButtonVariant.outline,
          loading: session.signingOut,
          onPressed: context.read<SessionCubit>().signOut,
        ),
        Text(
          AuthCopy.sessionNote,
          textAlign: TextAlign.center,
          style: authText(
            theme,
            CairnTypography.xs,
            color: theme.mutedForeground,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
