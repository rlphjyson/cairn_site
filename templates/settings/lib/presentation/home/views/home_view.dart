import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/settings_layout.dart';
import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/navigation/settings_navigation_cubit.dart';
import '../../../core/presentation/navigation/settings_navigator.dart';
import '../../../core/presentation/navigation/settings_page.dart';
import '../../../core/presentation/settings_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/control_scale.dart';
import '../../../core/presentation/widgets/setting_rows.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../domain/settings/models/setting_definition.dart';
import '../../../domain/settings/models/settings_section.dart';
import '../../../domain/settings/models/settings_snapshot.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/registry/home_groups.dart';
import '../../../domain/settings/registry/settings_registry.dart';
import '../../../domain/settings/use_cases/search_settings.dart';
import '../../settings/bloc/settings_cubit.dart';
import '../../settings/bloc/settings_state.dart';
import '../bloc/search_cubit.dart';
import '../view_models/search_view_model.dart';
import '../widgets/profile_card.dart';
import '../widgets/section_icons.dart';

/// The settings home: a title, a search field, the profile card and the
/// categories in groups. While a search is active it shows the matching
/// settings under their section headings instead, or "No results".
///
/// On a tablet this is the left-hand list, and the chosen category is
/// highlighted.
class HomeView extends StatelessWidget {
  /// Creates the view.
  const HomeView({super.key, required this.wide});

  /// Whether the list sits beside a detail pane.
  final bool wide;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<SearchViewModel>(
    builder: (BuildContext context, SearchViewModel vm) =>
        BlocProvider<SearchCubit>.value(
          value: vm.cubit,
          child: _HomeBody(wide: wide),
        ),
  );
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({required this.wide});

  final bool wide;

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<SearchCubit>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final SearchState search = context.watch<SearchCubit>().state;
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SettingsLayout.gutter,
              16,
              SettingsLayout.gutter,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    'Settings',
                    style: settingsText(
                      theme,
                      CairnTypography.xl2,
                      weight: CairnTypography.semibold,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ControlScale(
                  child: CairnInput(
                    controller: _controller,
                    semanticLabel: 'Search settings',
                    placeholder: 'Search settings',
                    textInputAction: TextInputAction.search,
                    leading: const CairnIcon(CairnIconData.search),
                    trailing: search.isSearching
                        ? CairnButton.icon(
                            variant: CairnButtonVariant.ghost,
                            size: CairnButtonSize.iconSm,
                            semanticLabel: 'Clear search',
                            icon: const CairnIcon(CairnIconData.close),
                            onPressed: _clear,
                          )
                        : null,
                    onChanged: context.read<SearchCubit>().setQuery,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                SettingsLayout.gutter,
                4,
                SettingsLayout.gutter,
                24,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: SettingsLayout.maxContentWidth,
                  ),
                  child: search.isSearching
                      ? _Results(search: search, wide: widget.wide)
                      : _Browse(wide: widget.wide),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The profile card and the grouped categories.
class _Browse extends StatelessWidget {
  const _Browse({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final SettingsRegistry registry = context.read<SettingsRegistry>();
    final SettingsNavigator navigator = context.read<SettingsNavigator>();
    final SettingsState settings = context.watch<SettingsCubit>().state;
    final SettingsNavigationState nav = context
        .watch<SettingsNavigationCubit>()
        .state;
    final SettingsSection? selected = wide
        ? (nav.section ?? registry.sections.firstOrNull)
        : null;
    final List<SettingsSection> present = registry.sections;

    void go(SettingsSection section) {
      final SettingsPage page = SettingsPage.of(section);
      if (wide) {
        navigator.select(context, page);
      } else {
        navigator.open(page);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (settings.status == LoadStatus.failure) ...<Widget>[
          const CairnAlert(
            variant: CairnAlertVariant.destructive,
            icon: CairnIcon(CairnIconData.alert),
            title: Text('Could not load your settings'),
            description: Text('Some values may be out of date.'),
          ),
          const SizedBox(height: 12),
          DialogButton(
            label: 'Try again',
            variant: CairnButtonVariant.outline,
            onPressed: context.read<SettingsCubit>().load,
          ),
          const SizedBox(height: 20),
        ],
        if (present.contains(SettingsSection.profile)) ...<Widget>[
          ProfileCard(
            selected: selected == SettingsSection.profile,
            onTap: () => go(SettingsSection.profile),
          ),
          const SizedBox(height: 20),
        ],
        for (final ({String title, List<SettingsSection> sections}) group
            in HomeGroups.all)
          ..._group(
            context,
            group,
            present: present,
            selected: selected,
            snapshot: settings.snapshot,
            registry: registry,
            go: go,
          ),
      ],
    );
  }

  List<Widget> _group(
    BuildContext context,
    ({String title, List<SettingsSection> sections}) group, {
    required List<SettingsSection> present,
    required SettingsSection? selected,
    required SettingsSnapshot? snapshot,
    required SettingsRegistry registry,
    required void Function(SettingsSection) go,
  }) {
    // The profile has its own card above, so it is not repeated as a row.
    final List<SettingsSection> sections = <SettingsSection>[
      for (final SettingsSection s in group.sections)
        if (present.contains(s) && s != SettingsSection.profile) s,
    ];
    if (sections.isEmpty) return const <Widget>[];
    return <Widget>[
      SettingsGroup(
        title: group.title,
        children: <Widget>[
          for (final SettingsSection s in sections)
            NavRow(
              icon: sectionIcon(s),
              title: s.title,
              subtitle: s.summary,
              value: _value(s, snapshot, registry),
              destructive: s == SettingsSection.danger,
              selected: selected == s,
              onTap: () => go(s),
            ),
        ],
      ),
      const SizedBox(height: 20),
    ];
  }

  /// The current value shown at the end of a row, for the few sections where
  /// one fits on a line.
  String? _value(
    SettingsSection section,
    SettingsSnapshot? snapshot,
    SettingsRegistry registry,
  ) {
    if (snapshot == null) return null;
    String labelOf(String id) {
      final ChoiceSetting? d = registry.maybe<ChoiceSetting>(id);
      return d == null ? '' : d.labelOf(snapshot.choice(id));
    }

    return switch (section) {
      SettingsSection.appearance => labelOf(SettingIds.themeMode),
      SettingsSection.notifications =>
        snapshot.flag(SettingIds.notificationsMaster) ? 'On' : 'Off',
      SettingsSection.language => labelOf(SettingIds.language),
      _ => null,
    };
  }
}

/// Search results under their section headings, or "No results".
class _Results extends StatelessWidget {
  const _Results({required this.search, required this.wide});

  final SearchState search;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final SettingsNavigator navigator = context.read<SettingsNavigator>();
    if (search.isEmpty) {
      return Semantics(
        liveRegion: true,
        child: CairnEmpty(
          bordered: false,
          media: const CairnIcon(CairnIconData.search, size: 32),
          title: 'No results',
          description:
              'Nothing matches "${search.query.trim()}". Try a different word, '
              'such as "password" or "dark".',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              search.count == 1 ? '1 result' : '${search.count} results',
              style: settingsText(
                theme,
                CairnTypography.xs,
                color: theme.mutedForeground,
              ),
            ),
          ),
        ),
        for (final SettingsSearchGroup group in search.groups) ...<Widget>[
          SettingsGroup(
            title: group.section.title,
            children: <Widget>[
              for (final SettingDefinition d in group.hits)
                NavRow(
                  title: d.title,
                  subtitle: d.description,
                  onTap: () {
                    final SettingsPage page = SettingsPage.forSetting(
                      d.id,
                      d.section,
                    );
                    if (wide) {
                      navigator.select(context, page);
                    } else {
                      navigator.open(page);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
