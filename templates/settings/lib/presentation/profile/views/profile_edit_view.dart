import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/infrastructure/unsaved_changes_guard.dart';
import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/settings_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/labeled_field.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../domain/profile/models/profile.dart';
import '../../../domain/profile/models/profile_validation.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_edit_cubit.dart';
import '../bloc/profile_edit_state.dart';
import '../view_models/profile_edit_view_model.dart';
import '../widgets/avatar_chooser.dart';
import '../widgets/profile_avatar.dart';

/// Edit profile: avatar, name, username (checked as you type), email and bio,
/// with a Save button and a guard against leaving unsaved changes.
class ProfileEditView extends StatelessWidget {
  /// Creates the view.
  const ProfileEditView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final ProfileState profile = context.watch<ProfileCubit>().state;
    if (profile.profile == null) {
      return PageFrame(
        title: 'Edit profile',
        onBack: onBack,
        children: <Widget>[
          profile.status == LoadStatus.failure
              ? const HelpText('Could not load your profile.')
              : const CairnSkeleton(height: 200),
        ],
      );
    }
    return ViewModelBuilder<ProfileEditViewModel>(
      builder: (BuildContext context, ProfileEditViewModel vm) =>
          BlocProvider<ProfileEditCubit>.value(
            value: vm.cubit,
            child: _Form(onBack: onBack),
          ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.onBack});

  final VoidCallback? onBack;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final ProfileEditCubit _cubit = context.read<ProfileEditCubit>();
  late final UnsavedChangesGuard _guard = context.read<UnsavedChangesGuard>();
  bool _dirty() => _cubit.state.isDirty;

  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _bio;

  @override
  void initState() {
    super.initState();
    final Profile p = _cubit.state.draft;
    _name = TextEditingController(text: p.name);
    _username = TextEditingController(text: p.username);
    _email = TextEditingController(text: p.email);
    _bio = TextEditingController(text: p.bio);
    _guard.isDirty = _dirty;
  }

  @override
  void dispose() {
    // Only clear the guard if it is still ours: during a page transition the
    // next page may already have registered its own.
    if (identical(_guard.isDirty, _dirty)) _guard.isDirty = null;
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return NoticeListener<ProfileEditCubit, ProfileEditState>(
      pick: (ProfileEditState s) => s.notice,
      child: BlocBuilder<ProfileEditCubit, ProfileEditState>(
        builder: (BuildContext context, ProfileEditState state) {
          final ProfileValidation errors = _cubit.visibleErrors;
          final UsernameCheck check = state.usernameCheck;
          final bool taken = check.status == UsernameStatus.taken;
          final String? usernameError =
              errors[ProfileField.username] ?? (taken ? check.message : null);
          final String? usernameHelp = state.checkingUsername
              ? 'Checking...'
              : check.status == UsernameStatus.available
              ? check.message
              : 'Lower case letters, numbers, dots and underscores.';
          return PageFrame(
            title: 'Edit profile',
            onBack: widget.onBack,
            bottom: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _SaveButton(
                saving: state.isSaving,
                enabled: state.isDirty && !state.isSaving,
                onPressed: _cubit.save,
              ),
            ),
            children: <Widget>[
              Row(
                children: <Widget>[
                  ProfileAvatar(
                    initials: state.draft.initials,
                    presetId: state.draft.avatarId,
                    size: 64,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Pick an avatar. It shows your initials on a colour.',
                      style: settingsText(
                        theme,
                        CairnTypography.sm,
                        color: theme.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
              AvatarChooser(
                initials: state.draft.initials,
                selectedId: state.draft.avatarId,
                onChanged: _cubit.setAvatar,
              ),
              LabeledField(
                label: 'Name',
                error: errors[ProfileField.name],
                child: CairnInput(
                  controller: _name,
                  semanticLabel: 'Name',
                  hasError: errors[ProfileField.name] != null,
                  textInputAction: TextInputAction.next,
                  onChanged: _cubit.setName,
                ),
              ),
              LabeledField(
                label: 'Username',
                error: usernameError,
                description: usernameHelp,
                child: CairnInput(
                  controller: _username,
                  semanticLabel: 'Username',
                  hasError: usernameError != null,
                  textInputAction: TextInputAction.next,
                  leading: const Text('@'),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  onChanged: _cubit.setUsername,
                ),
              ),
              LabeledField(
                label: 'Email',
                error: errors[ProfileField.email],
                child: CairnInput(
                  controller: _email,
                  semanticLabel: 'Email',
                  hasError: errors[ProfileField.email] != null,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: _cubit.setEmail,
                ),
              ),
              LabeledField(
                label: 'Bio',
                error: errors[ProfileField.bio],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CairnTextarea(
                      controller: _bio,
                      semanticLabel: 'Bio',
                      minLines: 3,
                      maxLines: 6,
                      autoGrow: false,
                      maxLength: Profile.maxBioLength,
                      hasError: errors[ProfileField.bio] != null,
                      onChanged: _cubit.setBio,
                    ),
                    const SizedBox(height: 6),
                    Semantics(
                      label:
                          '${state.draft.bio.length} of ${Profile.maxBioLength} characters',
                      excludeSemantics: true,
                      child: Text(
                        '${state.draft.bio.length}/${Profile.maxBioLength}',
                        textAlign: TextAlign.end,
                        style: settingsText(
                          theme,
                          CairnTypography.xs,
                          color: theme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.saving,
    required this.enabled,
    required this.onPressed,
  });

  final bool saving;
  final bool enabled;
  final Future<bool> Function() onPressed;

  @override
  Widget build(BuildContext context) => DialogButton(
    label: saving ? 'Saving...' : 'Save changes',
    busy: saving,
    onPressed: enabled
        ? () {
            unawaited(onPressed());
          }
        : null,
  );
}
