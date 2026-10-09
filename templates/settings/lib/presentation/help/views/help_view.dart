import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/faq_items.dart';
import '../../../common/constants/support_subjects.dart';
import '../../../core/presentation/notice.dart';
import '../../../core/presentation/settings_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/labeled_field.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/setting_rows.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../domain/settings/models/app_info.dart';
import '../../../domain/settings/models/settings_section.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/registry/settings_registry.dart';
import '../../../domain/support/models/support_request.dart';
import '../../settings/bloc/settings_cubit.dart';
import '../bloc/support_cubit.dart';
import '../view_models/support_view_model.dart';

/// Help: frequently asked questions in an accordion, a contact form and the app
/// version, which copies itself when tapped.
class HelpView extends StatelessWidget {
  /// Creates the view.
  const HelpView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<SupportViewModel>(
    builder: (BuildContext context, SupportViewModel vm) =>
        BlocProvider<SupportCubit>.value(
          value: vm.cubit,
          child: NoticeListener<SupportCubit, SupportState>(
            pick: (SupportState s) => s.notice,
            child: _Body(onBack: onBack),
          ),
        ),
  );
}

class _Body extends StatefulWidget {
  const _Body({required this.onBack});

  final VoidCallback? onBack;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  Set<String> _open = <String>{};
  String _subject = '';
  final TextEditingController _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _copyVersion(AppInfo info) {
    unawaited(Clipboard.setData(ClipboardData(text: info.versionLabel)));
    showSettingsToast(
      context,
      Notice('Version copied', description: info.versionLabel),
    );
  }

  void _send() => unawaited(
    context.read<SupportCubit>().send(
      subject: _subject,
      message: _message.text,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final SettingsRegistry registry = context.read<SettingsRegistry>();
    final SupportState support = context.watch<SupportCubit>().state;
    final AppInfo? info = context.watch<SettingsCubit>().state.appInfo;
    return BlocListener<SupportCubit, SupportState>(
      listenWhen: (SupportState a, SupportState b) =>
          b.sentCount != a.sentCount,
      listener: (BuildContext context, SupportState _) {
        _message.clear();
        setState(() => _subject = '');
      },
      child: PageFrame(
        title: SettingsSection.help.title,
        onBack: widget.onBack,
        children: <Widget>[
          if (registry.contains(SettingIds.faq))
            SettingsGroup(
              title: registry.byId(SettingIds.faq)!.title,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CairnAccordion(
                    expanded: _open,
                    onChanged: (Set<String> next) =>
                        setState(() => _open = next),
                    items: <CairnAccordionItem>[
                      for (final ({String id, String question, String answer}) q
                          in FaqItems.all)
                        CairnAccordionItem(
                          value: q.id,
                          title: Text(q.question),
                          content: Text(
                            q.answer,
                            style: settingsText(
                              theme,
                              CairnTypography.sm,
                              color: theme.mutedForeground,
                              height: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          if (registry.contains(SettingIds.contact))
            _ContactCard(
              title: registry.byId(SettingIds.contact)!.title,
              subject: _subject,
              onSubject: (String v) => setState(() => _subject = v),
              message: _message,
              state: support,
              onSend: _send,
            ),
          if (registry.contains(SettingIds.version) && info != null)
            SettingsGroup(
              children: <Widget>[
                NavRow(
                  title: registry.byId(SettingIds.version)!.title,
                  subtitle: 'Tap to copy',
                  value: info.versionLabel,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(info.versionLabel),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.copy_outlined,
                        size: 16,
                        color: theme.mutedForeground,
                      ),
                    ],
                  ),
                  onTap: () => _copyVersion(info),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.title,
    required this.subject,
    required this.onSubject,
    required this.message,
    required this.state,
    required this.onSend,
  });

  final String title;
  final String subject;
  final ValueChanged<String> onSubject;
  final TextEditingController message;
  final SupportState state;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              title,
              style: settingsText(
                theme,
                CairnTypography.base,
                weight: CairnTypography.semibold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const HelpText('We usually reply within one working day.'),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Subject',
            error: state.validation.subjectError,
            child: CairnSelect<String>(
              semanticLabel: 'Subject',
              placeholder: 'Choose a subject',
              width: double.infinity,
              value: subject.isEmpty ? null : subject,
              hasError: state.validation.subjectError != null,
              onChanged: onSubject,
              options: <CairnSelectOption<String>>[
                for (final ({String id, String label}) s in SupportSubjects.all)
                  CairnSelectOption<String>(value: s.id, label: s.label),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Message',
            error: state.validation.messageError,
            description: 'At least ${SupportRequest.minMessage} characters.',
            child: CairnTextarea(
              controller: message,
              semanticLabel: 'Message',
              placeholder: 'How can we help?',
              minLines: 4,
              maxLines: 8,
              autoGrow: false,
              maxLength: SupportRequest.maxMessage,
              hasError: state.validation.messageError != null,
            ),
          ),
          const SizedBox(height: 16),
          DialogButton(
            label: state.sending ? 'Sending...' : 'Send message',
            busy: state.sending,
            onPressed: state.sending ? null : onSend,
          ),
        ],
      ),
    );
  }
}
