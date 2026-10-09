import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../auth_copy.dart';
import '../auth_scope.dart';
import '../auth_text.dart';
import 'inline_link.dart';

/// "By continuing you agree to our Terms and Privacy Policy."
///
/// The links call the host's `onLegalLink`, so the app decides whether to open
/// a web page, an in-app reader or a sheet.
class LegalText extends StatelessWidget {
  /// Creates the footnote.
  const LegalText({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final void Function(AuthLegalLink)? open = AuthScope.configOf(
      context,
    ).onLegalLink;
    final TextStyle style = authText(
      theme,
      CairnTypography.xs,
      color: theme.mutedForeground,
    );
    return Column(
      children: <Widget>[
        Text(AuthCopy.legalIntro, textAlign: TextAlign.center, style: style),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: <Widget>[
            InlineLink(
              label: AuthCopy.terms,
              small: true,
              onPressed: () => open?.call(AuthLegalLink.terms),
            ),
            Text(AuthCopy.and, style: style),
            InlineLink(
              label: AuthCopy.privacy,
              small: true,
              onPressed: () => open?.call(AuthLegalLink.privacy),
            ),
          ],
        ),
      ],
    );
  }
}
