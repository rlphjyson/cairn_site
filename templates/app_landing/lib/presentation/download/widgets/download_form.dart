import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/app_landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../domain/download/models/download_content.dart';
import '../../../domain/download/models/send_outcome.dart';
import '../bloc/download_cubit.dart';

/// The send-me-the-link form and, once the link has been sent, the success
/// panel.
///
/// Presentational: it reports what the visitor does through callbacks and
/// draws whatever [state] says.
class DownloadForm extends StatefulWidget {
  /// Creates the form.
  const DownloadForm({
    super.key,
    required this.content,
    required this.state,
    required this.onSubmit,
    required this.onEdited,
    required this.onReset,
  });

  /// The copy.
  final DownloadContent content;

  /// The form state.
  final DownloadState state;

  /// Called with the typed text when the visitor submits.
  final ValueChanged<String> onSubmit;

  /// Called when the visitor edits the field, to clear an error.
  final VoidCallback onEdited;

  /// Called when the visitor asks to send to another address.
  final VoidCallback onReset;

  @override
  State<DownloadForm> createState() => _DownloadFormState();
}

class _DownloadFormState extends State<DownloadForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => widget.onSubmit(_controller.text);

  @override
  void didUpdateWidget(DownloadForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.status != DownloadStatus.sent &&
        widget.state.status == DownloadStatus.sent) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool done = widget.state.status == DownloadStatus.sent;
    return AnimatedSwitcher(
      duration: CairnMotion.d200,
      layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[...previous, ?current],
      ),
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

  final DownloadContent content;
  final DownloadState state;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onEdited;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool compact = AppLandingViewport.of(context).isCompact;
    final bool sending = state.status == DownloadStatus.sending;
    final bool invalid = state.status == DownloadStatus.invalid;
    final bool failed = state.status == DownloadStatus.failure;

    final Widget input = CairnInput(
      controller: controller,
      placeholder: content.placeholder,
      semanticLabel: 'Email address or phone number',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.send,
      enabled: !sending,
      hasError: invalid,
      leading: Icon(Icons.smartphone, size: 16, color: theme.mutedForeground),
      onChanged: (_) => onEdited(),
      onSubmitted: (_) => onSubmit(),
    );
    final Widget button = CairnButton(
      expand: compact,
      onPressed: sending ? null : onSubmit,
      leading: sending ? const CairnSpinner(semanticLabel: 'Sending') : null,
      child: Text(content.buttonLabel),
    );

    final String? error = (invalid || failed) ? state.message : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            content.formTitle,
            style: appLandingText(
              theme,
              CairnTypography.lg,
              weight: CairnTypography.semibold,
              tight: true,
            ),
          ),
        ),
        const SizedBox(height: CairnSpacing.s4),
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
              style: appLandingText(
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
          style: appLandingText(
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

class _Success extends StatelessWidget {
  const _Success({
    super.key,
    required this.content,
    required this.state,
    required this.onReset,
  });

  final DownloadContent content;
  final DownloadState state;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color good = CairnToneColors.resolve(theme, CairnTone.success).fill;
    final Contact? contact = state.contact;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CairnIcon(CairnIconData.circleCheck, size: 36, color: good),
          const SizedBox(height: CairnSpacing.s3),
          Text(
            content.successTitle,
            style: appLandingText(
              theme,
              CairnTypography.xl,
              weight: CairnTypography.semibold,
              tight: true,
            ),
          ),
          const SizedBox(height: CairnSpacing.s2),
          Text(
            content.successMessage,
            style: appLandingText(
              theme,
              CairnTypography.sm,
              color: theme.mutedForeground,
              height: 1.6,
            ),
          ),
          if (contact != null) ...<Widget>[
            const SizedBox(height: CairnSpacing.s3),
            CairnBadge(
              variant: CairnBadgeVariant.secondary,
              label: Text(
                '${contact.kind == ContactKind.email ? 'Email' : 'SMS'}: '
                '${contact.value}',
              ),
            ),
          ],
          const SizedBox(height: CairnSpacing.s4),
          CairnLink(
            onPressed: onReset,
            child: const Text('Send to a different address'),
          ),
        ],
      ),
    );
  }
}
