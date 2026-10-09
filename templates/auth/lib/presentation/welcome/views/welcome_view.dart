import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/auth_copy.dart';
import '../../../core/presentation/auth_scope.dart';
import '../../../core/presentation/auth_text.dart';
import '../../../core/presentation/form_status.dart';
import '../../../core/presentation/navigation/auth_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/auth_button.dart';
import '../../../core/presentation/widgets/auth_scaffold.dart';
import '../../../core/presentation/widgets/brand_mark.dart';
import '../../../core/presentation/widgets/error_alert.dart';
import '../../../core/presentation/widgets/labeled_divider.dart';
import '../../../core/presentation/widgets/legal_text.dart';
import '../../../core/presentation/widgets/prompt_row.dart';
import '../../../domain/auth/models/social_provider.dart';
import '../../session/bloc/session_cubit.dart';
import '../bloc/welcome_cubit.dart';
import '../view_models/welcome_view_model.dart';
import '../widgets/social_button.dart';

/// The first screen: the brand, social sign-in and the email entry points.
class WelcomeView extends StatelessWidget {
  /// Creates the view.
  const WelcomeView({super.key, required this.destination});

  /// The destination this screen was opened with.
  final AuthDestination destination;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final List<SocialProvider> providers = AuthScope.configOf(
      context,
    ).socialProviders;
    final AuthNavigationCubit nav = context.read<AuthNavigationCubit>();

    return ViewModelBuilder<WelcomeViewModel>(
      param: destination,
      builder: (BuildContext context, WelcomeViewModel vm) =>
          BlocConsumer<WelcomeCubit, WelcomeState>(
            bloc: vm.cubit,
            listenWhen: (WelcomeState a, WelcomeState b) =>
                a.status != b.status && b.status == FormStatus.success,
            listener: (BuildContext context, WelcomeState state) =>
                context.read<SessionCubit>().start(state.session!),
            builder: (BuildContext context, WelcomeState state) {
              final bool busy = state.status == FormStatus.submitting;
              return AuthScaffold(
                centered: true,
                spacing: 12,
                children: <Widget>[
                  const SizedBox(height: 16),
                  const Center(child: BrandMark()),
                  const SizedBox(height: 4),
                  Semantics(
                    header: true,
                    child: Text(
                      AuthCopy.brandName,
                      textAlign: TextAlign.center,
                      style: authText(
                        theme,
                        CairnTypography.xl3,
                        weight: CairnTypography.semibold,
                        letterSpacing: CairnTypography.trackingTight(30),
                      ),
                    ),
                  ),
                  Text(
                    AuthCopy.tagline,
                    textAlign: TextAlign.center,
                    style: authText(
                      theme,
                      CairnTypography.base,
                      color: theme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (state.failure != null)
                    ErrorAlert(
                      title: AuthCopy.failureTitle(state.failure!),
                      message: AuthCopy.failure(state.failure!),
                    ),
                  for (final SocialProvider provider in providers)
                    SocialButton(
                      provider: provider,
                      loading: busy && state.provider == provider,
                      onPressed: busy
                          ? null
                          : () => vm.cubit.continueWith(provider),
                    ),
                  if (providers.isNotEmpty) const LabeledDivider(AuthCopy.or),
                  AuthButton(
                    label: AuthCopy.continueWithEmail,
                    onPressed: busy ? null : () => nav.push(AuthScreen.signIn),
                  ),
                  PromptRow(
                    prompt: AuthCopy.newHere,
                    linkLabel: AuthCopy.createAccountLink,
                    onPressed: busy ? null : () => nav.push(AuthScreen.signUp),
                  ),
                  const SizedBox(height: 4),
                  const LegalText(),
                ],
              );
            },
          ),
    );
  }
}
