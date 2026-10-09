import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/contacts/models/contact.dart';
import '../../../domain/contacts/models/presence.dart';
import '../../../domain/contacts/use_cases/get_current_user.dart';
import '../../../domain/contacts/use_cases/update_profile.dart';
import '../../../domain/contacts/use_cases/watch_presence.dart';

/// Your profile and the simple settings next to it.
class ProfileState extends Equatable {
  /// Creates a state.
  const ProfileState({
    this.me,
    this.notifications = true,
    this.previews = true,
    this.readReceipts = true,
    this.enterToSend = false,
  });

  /// The signed-in user, or `null` while loading.
  final Contact? me;

  /// Whether notifications are on.
  final bool notifications;

  /// Whether notifications show message text.
  final bool previews;

  /// Whether others see when you have read their messages.
  final bool readReceipts;

  /// Whether the keyboard's enter key sends.
  final bool enterToSend;

  /// A copy with some fields replaced.
  ProfileState copyWith({
    Contact? me,
    bool? notifications,
    bool? previews,
    bool? readReceipts,
    bool? enterToSend,
  }) => ProfileState(
    me: me ?? this.me,
    notifications: notifications ?? this.notifications,
    previews: previews ?? this.previews,
    readReceipts: readReceipts ?? this.readReceipts,
    enterToSend: enterToSend ?? this.enterToSend,
  );

  @override
  List<Object?> get props => <Object?>[
    me,
    notifications,
    previews,
    readReceipts,
    enterToSend,
  ];
}

/// State for the Profile tab.
///
/// The settings switches are kept in memory only; persist them with your own
/// preferences store where marked in `doc/index.html`.
class ProfileCubit extends Cubit<ProfileState> {
  /// Creates the cubit.
  ProfileCubit(this._getCurrentUser, this._updateProfile, this._watchPresence)
    : super(const ProfileState());

  final GetCurrentUser _getCurrentUser;
  final UpdateProfile _updateProfile;
  final WatchPresence _watchPresence;

  StreamSubscription<Contact>? _subscription;

  /// Loads the profile.
  Future<void> load() async {
    _subscription ??= _watchPresence().listen((Contact c) {
      if (c.id == state.me?.id) emit(state.copyWith(me: c));
    });
    try {
      final Contact me = await _getCurrentUser();
      if (!isClosed) emit(state.copyWith(me: me));
    } on Object {
      // The tab simply stays on its skeleton.
    }
  }

  /// Saves a new display name.
  Future<void> saveName(String name) => _save(name: name);

  /// Saves a new status line.
  Future<void> saveAbout(String about) => _save(about: about);

  /// Chooses Online, Away or Do not disturb.
  Future<void> setPresence(Presence presence) => _save(presence: presence);

  Future<void> _save({String? name, String? about, Presence? presence}) async {
    final Contact updated = await _updateProfile(
      name: name,
      about: about,
      presence: presence,
    );
    if (!isClosed) emit(state.copyWith(me: updated));
  }

  /// Turns notifications on or off.
  void setNotifications({required bool value}) =>
      emit(state.copyWith(notifications: value));

  /// Shows or hides message text in notifications.
  void setPreviews({required bool value}) =>
      emit(state.copyWith(previews: value));

  /// Sends or withholds read receipts.
  void setReadReceipts({required bool value}) =>
      emit(state.copyWith(readReceipts: value));

  /// Makes the enter key send.
  void setEnterToSend({required bool value}) =>
      emit(state.copyWith(enterToSend: value));

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
