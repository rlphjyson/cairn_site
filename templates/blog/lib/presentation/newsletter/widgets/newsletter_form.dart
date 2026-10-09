import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/blog_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/blog_layout.dart';
import '../../../domain/newsletter/models/subscribe_result.dart';
import '../bloc/newsletter_cubit.dart';
import '../view_models/newsletter_view_model.dart';

/// The email sign-up form.
///
/// Owns its own cubit through a view model, so the copy on the home page and
/// the one in the footer are independent. Validates the address, shows a
/// spinner while submitting, an inline error on failure, and a toast plus an
/// inline confirmation on success.
class NewsletterForm extends StatelessWidget {
  /// Creates a form. [fieldLabel] names the input for screen readers and
  /// keeps the two forms on a page distinguishable.
  const NewsletterForm({super.key, this.fieldLabel = 'Email address'});

  /// The input's semantic label.
  final String fieldLabel;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewsletterViewModel>(
      builder: (BuildContext context, NewsletterViewModel vm) =>
          BlocProvider<NewsletterCubit>.value(
            value: vm.cubit,
            child: _FormBody(fieldLabel: fieldLabel),
          ),
    );
  }
}

class _FormBody extends StatefulWidget {
  const _FormBody({required this.fieldLabel});

  final String fieldLabel;

  @override
  State<_FormBody> createState() => _FormBodyState();
}

class _FormBodyState extends State<_FormBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => context.read<NewsletterCubit>().submit(_controller.text);

  void _onState(BuildContext context, NewsletterState state) {
    if (state.status != NewsletterStatus.success) return;
    final bool already = state.result == SubscribeResult.alreadySubscribed;
    CairnToast.show(
      context,
      CairnToast(
        title: already ? 'You are already subscribed' : 'You are subscribed',
        description: already
            ? '${_controller.text.trim()} is already on the list.'
            : 'Thanks! The next issue will land in '
                  '${_controller.text.trim()}.',
        variant: CairnToastVariant.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return BlocConsumer<NewsletterCubit, NewsletterState>(
      listenWhen: (NewsletterState a, NewsletterState b) =>
          a.status != b.status,
      listener: _onState,
      builder: (BuildContext context, NewsletterState state) {
        if (state.status == NewsletterStatus.success) {
          return _Success(
            email: _controller.text.trim(),
            onReset: () {
              _controller.clear();
              context.read<NewsletterCubit>().reset();
            },
          );
        }

        final bool busy = state.status == NewsletterStatus.submitting;
        final Widget field = CairnInput(
          controller: _controller,
          placeholder: 'you@example.com',
          semanticLabel: widget.fieldLabel,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          enabled: !busy,
          hasError: state.hasError,
          leading: Icon(
            Icons.mail_outline,
            size: 16,
            color: theme.mutedForeground,
          ),
          onChanged: (String _) => context.read<NewsletterCubit>().edit(),
          onSubmitted: (String _) => _submit(),
        );
        final Widget button = CairnButton(
          onPressed: busy ? null : _submit,
          leading: busy ? const CairnSpinner(size: 14) : null,
          expand: false,
          child: Text(busy ? 'Subscribing' : 'Subscribe'),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (BlogLayout.sizeOf(context) != BlogSize.compact)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: CairnSpacing.s2,
                children: <Widget>[
                  Expanded(child: field),
                  button,
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: CairnSpacing.s2,
                children: <Widget>[field, button],
              ),
            AnimatedSize(
              duration: CairnMotion.d150,
              alignment: Alignment.topLeft,
              child: state.hasError
                  ? Padding(
                      padding: const EdgeInsets.only(top: CairnSpacing.s2),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          state.error!,
                          style: blogText(
                            theme,
                            CairnTypography.xs,
                            color: theme.destructive,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        );
      },
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({required this.email, required this.onReset});

  final String email;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: CairnSpacing.s3,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CairnIcon(CairnIconData.circleCheck, color: theme.primary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CairnSpacing.s1,
              children: <Widget>[
                Text(
                  'You are on the list.',
                  style: blogText(
                    theme,
                    CairnTypography.sm,
                    weight: CairnTypography.semibold,
                  ),
                ),
                Text(
                  'We will write to $email when there is something worth '
                  'reading.',
                  style: blogText(theme, CairnTypography.sm, muted: true),
                ),
                CairnLink(
                  onPressed: onReset,
                  child: const Text('Use a different email'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
