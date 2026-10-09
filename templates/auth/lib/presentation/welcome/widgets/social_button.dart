import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../core/presentation/auth_copy.dart';
import '../../../core/presentation/widgets/auth_button.dart';
import '../../../domain/auth/models/social_provider.dart';

/// "Continue with Google" or "Continue with Apple".
///
/// The glyphs are generic Material icons, not the providers' logos: the
/// providers' brand guidelines require their official buttons, which you add
/// when you wire the real SDKs (see `doc/index.html`).
class SocialButton extends StatelessWidget {
  /// Creates a button.
  const SocialButton({
    super.key,
    required this.provider,
    required this.loading,
    required this.onPressed,
  });

  /// Which provider this button is for.
  final SocialProvider provider;

  /// Whether this button's request is in flight.
  final bool loading;

  /// Called on press, or `null` while another request is running.
  final VoidCallback? onPressed;

  IconData get _glyph => switch (provider) {
    SocialProvider.google => Icons.language,
    SocialProvider.apple => Icons.phone_iphone,
  };

  @override
  Widget build(BuildContext context) => AuthButton(
    label: AuthCopy.continueWith(provider.label),
    loadingLabel: AuthCopy.connectingTo(provider.label),
    variant: CairnButtonVariant.outline,
    loading: loading,
    leading: Icon(_glyph),
    onPressed: onPressed,
  );
}
