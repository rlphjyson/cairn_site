import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../domain/waitlist/models/waitlist_content.dart';
import '../bloc/waitlist_cubit.dart';

/// The email form and, once the visitor has joined, the success panel.
///
/// Presentational: it reports what the visitor does through callbacks and
/// draws whatever [state] says.
class WaitlistForm extends StatefulWidget {
  /// Creates the form.
  const WaitlistForm({
    super.key,
    required this.content,
    required this.state,
    required this.onSubmit,
    required this.onEdited,
    required this.onReset,
  });

  /// The copy.
  final WaitlistContent content;

  /// The form state.
  final WaitlistState state;

  /// Called with the typed email when the visitor submits.
  final ValueChanged<String> onSubmit;

  /// Called when the visitor edits the field, to clear an error.
  final VoidCallback onEdited;

  /// Called when the visitor asks to sign up another address.
  final VoidCallback onReset;

  @override
  State<WaitlistForm> createState() => _WaitlistFormState();
}

class _WaitlistFormState extends State<WaitlistForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => widget.onSubmit(_controller.text);

  @override
  void didUpdateWidget(WaitlistForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.status != WaitlistStatus.success &&
        widget.state.status == WaitlistStatus.success) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool done = widget.state.status == WaitlistStatus.success;
    return AnimatedSwitcher(
      duration: CairnMotion.d200,
      child: done
          ? _Success(
              key: const ValueKey<String>('success'),
              content: widget.content,
              state: widget.state,
              onReset: widget.onReset,
            )
          : _Fields(
              key: const ValueKey<String>('fields'),
              content: widget.content,
              state: widget.state,
              controller: _controller,
              onSubmit: _submit,
              onEdited: widget.onEdited,
            ),
    );
  }
}

class _Fields extends StatelessWidget {
  const _Fields({
    super.key,
    required this.content,
    required this.state,
    required this.controller,
    required this.onSubmit,
    required this.onEdited,
  });

  final WaitlistContent content;
  final WaitlistState state;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onEdited;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool compact = LandingViewport.of(context).isCompact;
    final bool submitting = state.status == WaitlistStatus.submitting;
    final bool invalid = state.status == WaitlistStatus.invalid;
    final bool failed = state.status == WaitlistStatus.failure;

    final Widget input = CairnInput(
      controller: controller,
      placeholder: content.placeholder,
      semanticLabel: 'Email address',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      enabled: !submitting,
      hasError: invalid,
      leading: Icon(Icons.mail_outline, size: 16, color: theme.mutedForeground),
      onChanged: (_) => onEdited(),
      onSubmitted: (_) => onSubmit(),
    );
    final Widget button = CairnButton(
      expand: compact,
      onPressed: submitting ? null : onSubmit,
      leading: submitting ? const CairnSpinner(semanticLabel: 'Joining') : null,
      child: Text(content.buttonLabel),
    );

    final String? error = (invalid || failed) ? state.message : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (compact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: CairnSpacing.s3,
            children: <Widget>[input, button],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s3,
            children: <Widget>[
              Expanded(child: input),
              button,
            ],
          ),
        if (error != null) ...<Widget>[
          const SizedBox(height: CairnSpacing.s2p5),
          Semantics(
            liveRegion: true,
            child: Text(
              error,
              textAlign: TextAlign.start,
              style: landingText(
                theme,
                CairnTypography.sm,
                color: theme.destructive,
              ),
            ),
          ),
        ],
        const SizedBox(height: CairnSpacing.s4),
        Text(
          content.privacyNote,
          textAlign: TextAlign.center,
          style: landingText(
            theme,
            CairnTypography.xs,
            color: theme.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({
    super.key,
    required this.content,
    required this.state,
    required this.onReset,
  });

  final WaitlistContent content;
  final WaitlistState state;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color good = CairnToneColors.resolve(theme, CairnTone.success).fill;
    final int? position = state.receipt?.position;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CairnIcon(CairnIconData.circleCheck, size: 40, color: good),
          const SizedBox(height: CairnSpacing.s3),
          Text(
            content.successTitle,
            textAlign: TextAlign.center,
            style: landingText(
              theme,
              CairnTypography.xl2,
              weight: CairnTypography.semibold,
              tight: true,
            ),
          ),
          const SizedBox(height: CairnSpacing.s2),
          Text(
            content.successMessage,
            textAlign: TextAlign.center,
            style: landingText(
              theme,
              CairnTypography.base,
              color: theme.mutedForeground,
              height: 1.6,
            ),
          ),
          if (position != null) ...<Widget>[
            const SizedBox(height: CairnSpacing.s3),
            CairnBadge(
              variant: CairnBadgeVariant.secondary,
              label: Text('You are number $position in line'),
            ),
          ],
          const SizedBox(height: CairnSpacing.s4),
          CairnLink(
            onPressed: onReset,
            child: const Text('Use a different email'),
          ),
        ],
      ),
    );
  }
}
