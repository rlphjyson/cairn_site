import 'package:flutter/widgets.dart';

import 'component_previews.dart';

/// How the catalogue is grouped.
///
/// The grouping mirrors the one Cairn's own example app uses, which in turn
/// follows shadcn/ui's mental model — a visitor looking for "the thing that
/// floats above the page" should find Popover, Dialog and Sheet next to each
/// other rather than scattered through an alphabetical list.
enum ComponentCategory {
  /// Controls that collect input.
  forms('Forms'),

  /// Static surfaces and content containers.
  display('Display'),

  /// Floating and modal surfaces.
  overlays('Overlays'),

  /// Getting between places.
  navigation('Navigation'),

  /// Progress, notifications and tabular data.
  data('Data & feedback');

  const ComponentCategory(this.label);

  /// The heading shown above the group.
  final String label;
}

/// One component in the catalogue.
@immutable
class ComponentEntry {
  /// Creates an entry.
  const ComponentEntry({
    required this.name,
    required this.slug,
    required this.category,
    required this.description,
    required this.code,
    required this.preview,
    this.alsoExports = const <String>[],
    this.livesIn,
    this.note,
  });

  /// The display name, e.g. `Alert Dialog`.
  final String name;

  /// The URL segment, e.g. `alert-dialog`.
  final String slug;

  /// Which group it belongs to.
  final ComponentCategory category;

  /// A one-line summary, shown in the catalogue and the directory.
  final String description;

  /// A realistic usage snippet.
  final String code;

  /// Builds the live preview.
  final WidgetBuilder preview;

  /// Additional public widgets this component's source file exports.
  ///
  /// Cairn ships 45 component modules but 49 documented widgets: `dialog.dart`
  /// also exports `CairnAlertDialog`, `sheet.dart` also exports `CairnDrawer`,
  /// and so on. Listing them here keeps the count honest while still making
  /// each widget findable in the Directory.
  final List<String> alsoExports;

  /// Set when this widget ships inside a sibling's source file rather than its
  /// own module, e.g. Alert Dialog lives in `dialog.dart`.
  ///
  /// This is what reconciles "45 components" (the number of modules under
  /// `lib/src/components/`, and the number the library's own README quotes)
  /// with the 50 cards in this catalogue.
  final String? livesIn;

  /// A measurement or behaviour worth calling out, shown under the preview.
  final String? note;

  /// The route for this component's detail page.
  String get path => '/components/$slug';
}

/// Looks up an entry by slug.
ComponentEntry? findComponent(String slug) {
  for (final ComponentEntry entry in componentCatalog) {
    if (entry.slug == slug) return entry;
  }
  return null;
}

/// Every component in the library, grouped and ordered for browsing.
///
/// Const, and therefore built once at compile time — the preview fields are
/// static tear-offs rather than closures precisely so this list can be.
const List<ComponentEntry> componentCatalog = <ComponentEntry>[
  // -------------------------------------------------------------------------
  // Forms
  // -------------------------------------------------------------------------
  ComponentEntry(
    name: 'Button',
    slug: 'button',
    category: ComponentCategory.forms,
    description:
        'Six variants across eight sizes, with icon and loading forms.',
    note:
        'Heights are h-6 / h-8 / h-9 / h-10 — 24, 32, 36 and 40 logical '
        'pixels. The outline variant gains a dark:bg-input/30 fill that has no '
        'light-mode counterpart.',
    preview: Previews.button,
    code: '''
CairnButton(
  variant: CairnButtonVariant.outline,
  size: CairnButtonSize.md,
  onPressed: () => _deploy(),
  child: const Text('Deploy'),
)

CairnButton.icon(
  icon: const CairnIcon(CairnIconData.check),
  semanticLabel: 'Confirm',
  onPressed: _confirm,
)''',
  ),
  ComponentEntry(
    name: 'Input',
    slug: 'input',
    category: ComponentCategory.forms,
    description: 'A single-line text field with leading and trailing slots.',
    note:
        'h-9, px-3, rounded-md, bg-transparent with a shadow-xs resting '
        'elevation. Focus adds a 3px ring at 50% alpha.',
    preview: Previews.input,
    code: '''
CairnInput(
  controller: _email,
  placeholder: 'name@example.com',
  keyboardType: TextInputType.emailAddress,
  hasError: _error != null,
  onChanged: _validate,
)''',
  ),
  ComponentEntry(
    name: 'Textarea',
    slug: 'textarea',
    category: ComponentCategory.forms,
    description: 'A multi-line field that grows with its content.',
    note:
        'Auto-growing by default, matching CSS field-sizing: content, which '
        'Flutter has no direct equivalent for.',
    preview: Previews.textarea,
    code: '''
CairnTextarea(
  controller: _bio,
  placeholder: 'Tell us a little about yourself...',
  minLines: 3,
)''',
  ),
  ComponentEntry(
    name: 'Label',
    slug: 'label',
    category: ComponentCategory.forms,
    description: 'A form label with leading-none and a disabled treatment.',
    note:
        'line-height: 1 has to be set explicitly — Flutter defaults to the '
        'font metrics (~1.2), which makes labels sit low.',
    preview: Previews.label,
    code: '''
const CairnLabel('Accept terms and conditions')

CairnLabel.custom(
  child: Row(children: const <Widget>[Text('Email'), Text('*')]),
)''',
  ),
  ComponentEntry(
    name: 'Checkbox',
    slug: 'checkbox',
    category: ComponentCategory.forms,
    description: 'A checkbox with optional indeterminate state.',
    note:
        'The radius is a literal rounded-[4px], not a step on the --radius '
        'scale.',
    preview: Previews.checkbox,
    code: '''
CairnCheckbox(
  value: _accepted,
  tristate: true,
  onChanged: (bool? v) => setState(() => _accepted = v),
)''',
  ),
  ComponentEntry(
    name: 'Switch',
    slug: 'switch',
    category: ComponentCategory.forms,
    description: 'A binary toggle with an animated thumb.',
    note:
        'The track is h-[1.15rem] w-8 — literally 18.4 x 32 logical pixels. '
        'Rounding that to 18 or 20 is exactly the drift Cairn exists to avoid.',
    preview: Previews.switchToggle,
    code: '''
CairnSwitch(
  value: _notifications,
  semanticLabel: 'Email notifications',
  onChanged: (bool v) => setState(() => _notifications = v),
)''',
  ),
  ComponentEntry(
    name: 'Radio Group',
    slug: 'radio-group',
    category: ComponentCategory.forms,
    description: 'Mutually exclusive options with roving focus.',
    note:
        'One tab stop for the whole group; arrow keys move the selection '
        'within it, matching Radix.',
    preview: Previews.radioGroup,
    code: '''
CairnRadioGroup<String>(
  value: _plan,
  onChanged: (String v) => setState(() => _plan = v),
  children: const <Widget>[
    CairnRadioItem<String>(value: 'free', label: Text('Free')),
    CairnRadioItem<String>(value: 'pro', label: Text('Pro')),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Slider',
    slug: 'slider',
    category: ComponentCategory.forms,
    description: 'A range control driven by pointer or keyboard.',
    note:
        'The thumb is a literal bg-white in both themes, and the focus halo is '
        'ring-4 rather than the usual 3px.',
    preview: Previews.slider,
    code: '''
CairnSlider(
  value: _volume,
  min: 0,
  max: 1,
  step: 0.05,
  semanticLabel: 'Volume',
  onChanged: (double v) => setState(() => _volume = v),
)''',
  ),
  ComponentEntry(
    name: 'Toggle',
    slug: 'toggle',
    category: ComponentCategory.forms,
    description: 'A button that stays pressed.',
    preview: Previews.toggle,
    code: '''
CairnToggle(
  value: _bold,
  variant: CairnToggleVariant.outline,
  onChanged: (bool v) => setState(() => _bold = v),
  child: const Text('Bold'),
)''',
  ),
  ComponentEntry(
    name: 'Toggle Group',
    slug: 'toggle-group',
    category: ComponentCategory.forms,
    description: 'Joined or spaced toggles, single- or multi-select.',
    preview: Previews.toggleGroup,
    code: '''
CairnToggleGroup<String>(
  values: _alignment,
  type: CairnToggleGroupType.single,
  variant: CairnToggleVariant.outline,
  onChanged: (Set<String> v) => setState(() => _alignment = v),
  items: const <CairnToggleGroupItem<String>>[
    CairnToggleGroupItem<String>(value: 'left', child: Text('Left')),
    CairnToggleGroupItem<String>(value: 'center', child: Text('Center')),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Input OTP',
    slug: 'input-otp',
    category: ComponentCategory.forms,
    description: 'A grouped one-time-code field.',
    note:
        'One hidden text field sits behind painted slots, so paste and SMS '
        'autofill keep working. Only the first slot draws a left border, which '
        'avoids doubled hairlines.',
    preview: Previews.inputOtp,
    code: '''
CairnInputOtp(
  length: 6,
  groupSizes: const <int>[3, 3],
  onCompleted: _verify,
)''',
  ),
  ComponentEntry(
    name: 'Form Field',
    slug: 'form-field',
    category: ComponentCategory.forms,
    description: 'Label, description and error layout around any control.',
    note:
        'Layout only. Flutter already ships Form and FormField for validation; '
        'competing with them would fight the framework.',
    preview: Previews.formField,
    code: '''
CairnFormField(
  label: 'Email',
  description: 'We will never share it.',
  error: _error,
  child: CairnInput(controller: _email, hasError: _error != null),
)''',
  ),

  // -------------------------------------------------------------------------
  // Display
  // -------------------------------------------------------------------------
  ComponentEntry(
    name: 'Card',
    slug: 'card',
    category: ComponentCategory.display,
    description: 'A surface with header, content and footer slots.',
    note:
        'rounded-xl (14px) with py-6 on the card and px-6 on each slot, so a '
        'full-bleed child can still span edge to edge.',
    preview: Previews.card,
    code: '''
CairnCard(
  width: 360,
  children: <Widget>[
    const CairnCardHeader(
      title: Text('Deploy your project'),
      description: Text('Ship to production in one click.'),
    ),
    const CairnCardContent(child: Text('Ready to go live.')),
    CairnCardFooter(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        CairnButton(onPressed: _deploy, child: const Text('Deploy')),
      ],
    ),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Badge',
    slug: 'badge',
    category: ComponentCategory.display,
    description: 'A small status pill in five variants.',
    note:
        'Filled variants carry a transparent 1px border so their outer size is '
        'identical to the outline variant.',
    preview: Previews.badge,
    code: '''
const CairnBadge(
  variant: CairnBadgeVariant.secondary,
  leading: CairnIcon(CairnIconData.check, size: 12),
  label: Text('Verified'),
)''',
  ),
  ComponentEntry(
    name: 'Avatar',
    slug: 'avatar',
    category: ComponentCategory.display,
    description: 'A user image with a persistent fallback, plus a stack group.',
    alsoExports: <String>['CairnAvatarGroup'],
    note:
        'The fallback survives an image error rather than leaving a hole, '
        'which is what Radix does and what naive implementations miss.',
    preview: Previews.avatar,
    code: '''
const CairnAvatar(fallback: Text('CA'), size: CairnAvatarSize.lg)

const CairnAvatarGroup(
  children: <Widget>[
    CairnAvatar(fallback: Text('A')),
    CairnAvatar(fallback: Text('B')),
    CairnAvatar(fallback: Text('+7')),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Alert',
    slug: 'alert',
    category: ComponentCategory.display,
    description: 'An inline banner, default or destructive.',
    note:
        'The icon is nudged down 2px (translate-y-0.5) so it aligns to the '
        'title cap height rather than its line box.',
    preview: Previews.alert,
    code: '''
const CairnAlert(
  variant: CairnAlertVariant.destructive,
  icon: CairnIcon(CairnIconData.alert),
  title: Text('Payment failed'),
  description: Text('Update your billing details to continue.'),
)''',
  ),
  ComponentEntry(
    name: 'Separator',
    slug: 'separator',
    category: ComponentCategory.display,
    description: 'A hairline rule, horizontal or vertical.',
    note:
        'Decorative by default, so screen readers skip it; pass '
        'decorative: false when the rule carries meaning.',
    preview: Previews.separator,
    code: '''
const CairnSeparator()

const CairnSeparator(axis: Axis.vertical, decorative: false)''',
  ),
  ComponentEntry(
    name: 'Skeleton',
    slug: 'skeleton',
    category: ComponentCategory.display,
    description: 'A pulsing placeholder for loading content.',
    note:
        'Uses Tailwind\'s animate-pulse curve and honours '
        'MediaQuery.disableAnimations.',
    preview: Previews.skeleton,
    code: '''
const Row(
  children: <Widget>[
    CairnSkeleton.circle(size: 44),
    SizedBox(width: 16),
    CairnSkeleton(width: 220, height: 12),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Spinner',
    slug: 'spinner',
    category: ComponentCategory.display,
    description: 'An indeterminate activity indicator.',
    note: 'animate-spin at 1s, linear. Respects reduced motion.',
    preview: Previews.spinner,
    code: '''
const CairnSpinner(size: 24, strokeWidth: 2)''',
  ),
  ComponentEntry(
    name: 'Kbd',
    slug: 'kbd',
    category: ComponentCategory.display,
    description: 'Keyboard key hints, single or grouped.',
    alsoExports: <String>['CairnKbdGroup'],
    note:
        'font-sans, not monospace — a detail that is easy to get wrong from '
        'memory because every other design system uses a mono face here.',
    preview: Previews.kbd,
    code: '''
const CairnKbd('Esc')

const CairnKbdGroup(keys: <String>['Ctrl', 'K'])''',
  ),
  ComponentEntry(
    name: 'Aspect Ratio',
    slug: 'aspect-ratio',
    category: ComponentCategory.display,
    description: 'Constrains a child to a fixed ratio.',
    note: 'A thin wrapper over Flutter\'s own AspectRatio, with clipping.',
    preview: Previews.aspectRatio,
    code: '''
CairnAspectRatio(
  ratio: 16 / 9,
  child: Image.network(url, fit: BoxFit.cover),
)''',
  ),
  ComponentEntry(
    name: 'Empty',
    slug: 'empty',
    category: ComponentCategory.display,
    description: 'The zero-state panel, with a dashed border.',
    note:
        'The dashed border is hand-painted — Flutter\'s Border has no dash '
        'support, so a CustomPainter walks the rounded rect.',
    preview: Previews.empty,
    code: '''
CairnEmpty(
  media: const CairnIcon(CairnIconData.search, size: 32),
  title: 'No results',
  description: 'Try adjusting your filters.',
  actions: <Widget>[
    CairnButton(
      variant: CairnButtonVariant.outline,
      onPressed: _clear,
      child: const Text('Clear filters'),
    ),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Table',
    slug: 'table',
    category: ComponentCategory.display,
    description: 'A typed, column-driven table with an optional caption.',
    note:
        'Cells are p-2 and the header row is h-10 — considerably tighter than '
        'a Material DataTable.',
    preview: Previews.table,
    code: '''
CairnTable<Invoice>(
  caption: const Text('A list of recent invoices.'),
  rows: invoices,
  columns: <CairnColumn<Invoice>>[
    CairnColumn<Invoice>(label: 'Invoice', cell: (Invoice i) => Text(i.id)),
    CairnColumn<Invoice>(
      label: 'Amount',
      alignment: Alignment.centerRight,
      cell: (Invoice i) => Text(i.amount),
    ),
  ],
)''',
  ),

  // -------------------------------------------------------------------------
  // Overlays
  // -------------------------------------------------------------------------
  ComponentEntry(
    name: 'Dialog',
    slug: 'dialog',
    category: ComponentCategory.overlays,
    description: 'A focus-trapped modal, dismissible by Escape or barrier.',
    alsoExports: <String>[
      'CairnAlertDialog',
      'CairnDialogHeader',
      'CairnDialogFooter',
    ],
    note:
        'Pushes a PopupRoute, so Flutter supplies focus trapping, focus restore '
        'and back-gesture dismissal — behaviour Radix has no equivalent of.',
    preview: Previews.dialog,
    code: '''
showCairnDialog<void>(
  context: context,
  builder: (BuildContext context) => CairnDialog(
    title: const Text('Edit profile'),
    description: const Text('Save when you are done.'),
    content: const CairnFormField(label: 'Name', child: CairnInput()),
    actions: <Widget>[
      CairnButton(onPressed: _save, child: const Text('Save changes')),
    ],
  ),
)''',
  ),
  ComponentEntry(
    name: 'Alert Dialog',
    slug: 'alert-dialog',
    category: ComponentCategory.overlays,
    description: 'A modal that demands an explicit choice.',
    livesIn: 'dialog.dart',
    note:
        'Deliberately not dismissible by Escape or by tapping the barrier. '
        'Every other Cairn overlay closes on Escape; this one does not.',
    preview: Previews.alertDialog,
    code: '''
showCairnAlertDialog<void>(
  context: context,
  builder: (BuildContext context) => CairnAlertDialog(
    title: const Text('Are you absolutely sure?'),
    description: const Text('This cannot be undone.'),
    actions: <Widget>[
      CairnButton(
        variant: CairnButtonVariant.outline,
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      CairnButton(
        variant: CairnButtonVariant.destructive,
        onPressed: _delete,
        child: const Text('Delete'),
      ),
    ],
  ),
)''',
  ),
  ComponentEntry(
    name: 'Sheet',
    slug: 'sheet',
    category: ComponentCategory.overlays,
    description: 'A panel that slides in from any of the four edges.',
    alsoExports: <String>['CairnDrawer'],
    note:
        'Asymmetric motion: 500ms to open, 300ms to close, matching '
        'data-[state=open]:duration-500 / data-[state=closed]:duration-300.',
    preview: Previews.sheet,
    code: '''
showCairnSheet<void>(
  context: context,
  side: CairnSheetSide.right,
  builder: (BuildContext context) => CairnSheet(
    side: CairnSheetSide.right,
    title: const Text('Filters'),
    content: const CairnFormField(label: 'Query', child: CairnInput()),
    footer: <Widget>[
      CairnButton(expand: true, onPressed: _apply, child: const Text('Apply')),
    ],
  ),
)''',
  ),
  ComponentEntry(
    name: 'Drawer',
    slug: 'drawer',
    category: ComponentCategory.overlays,
    description: 'A bottom sheet with a grab handle and drag-to-dismiss.',
    livesIn: 'sheet.dart',
    preview: Previews.drawer,
    code: '''
showCairnDrawer<void>(
  context: context,
  builder: (BuildContext context) => CairnDrawer(
    title: const Text('Move goal'),
    description: const Text('Set your daily activity goal.'),
    content: const Text('Drag down to dismiss.'),
  ),
)''',
  ),
  ComponentEntry(
    name: 'Popover',
    slug: 'popover',
    category: ComponentCategory.overlays,
    description: 'An anchored surface that flips and shifts to stay on screen.',
    alsoExports: <String>[
      'CairnSurface',
      'CairnPopoverTitle',
      'CairnPopoverDescription',
    ],
    note:
        'Uses OverlayPortal rather than a route, so it stays out of the '
        'navigation stack and the back gesture does not close it.',
    preview: Previews.popover,
    code: '''
final CairnOverlayController controller = CairnOverlayController();

CairnPopover(
  controller: controller,
  side: CairnSide.bottom,
  align: CairnAlign.start,
  content: const CairnPopoverTitle('Dimensions'),
  child: CairnButton(
    variant: CairnButtonVariant.outline,
    onPressed: controller.toggle,
    child: const Text('Open popover'),
  ),
)''',
  ),
  ComponentEntry(
    name: 'Tooltip',
    slug: 'tooltip',
    category: ComponentCategory.overlays,
    description: 'A hint that opens on hover and on keyboard focus.',
    note:
        'Keyboard focus opens it too — a tooltip that only responds to a mouse '
        'is invisible to anyone tabbing through the page.',
    preview: Previews.tooltip,
    code: '''
CairnTooltip(
  message: 'Copy to clipboard',
  side: CairnSide.top,
  openDelay: const Duration(milliseconds: 700),
  child: CairnButton.icon(
    icon: const CairnIcon(CairnIconData.check),
    semanticLabel: 'Copy',
    onPressed: _copy,
  ),
)''',
  ),
  ComponentEntry(
    name: 'Hover Card',
    slug: 'hover-card',
    category: ComponentCategory.overlays,
    description: 'A rich preview with open and close grace periods.',
    livesIn: 'tooltip.dart',
    note:
        'The close delay is what makes it usable: without it, moving the '
        'pointer from the trigger into the card dismisses the card.',
    preview: Previews.hoverCard,
    code: '''
CairnHoverCard(
  openDelay: const Duration(milliseconds: 700),
  closeDelay: const Duration(milliseconds: 300),
  content: const Text('shadcn/ui, measured and rebuilt in Flutter.'),
  child: CairnButton(
    variant: CairnButtonVariant.link,
    onPressed: _open,
    child: const Text('@cairn_ui'),
  ),
)''',
  ),
  ComponentEntry(
    name: 'Dropdown Menu',
    slug: 'dropdown-menu',
    category: ComponentCategory.overlays,
    description: 'An anchored menu with labels, shortcuts and separators.',
    preview: Previews.dropdownMenu,
    code: '''
CairnDropdownMenu(
  controller: controller,
  align: CairnAlign.end,
  items: <Widget>[
    const CairnMenuLabel('My account'),
    const CairnMenuSeparator(),
    CairnMenuItem(
      onPressed: _profile,
      shortcut: 'Ctrl+P',
      child: const Text('Profile'),
    ),
  ],
  child: CairnButton(onPressed: controller.toggle, child: const Text('Open')),
)''',
  ),
  ComponentEntry(
    name: 'Context Menu',
    slug: 'context-menu',
    category: ComponentCategory.overlays,
    description: 'A menu anchored to the pointer on right-click or long-press.',
    note:
        'Anchors to the pointer position, not the widget, so the menu appears '
        'where the user actually clicked.',
    preview: Previews.contextMenu,
    code: '''
CairnContextMenu(
  items: <Widget>[
    CairnMenuItem(onPressed: _back, child: const Text('Back')),
    const CairnMenuSeparator(),
    CairnMenuItem(
      onPressed: _reload,
      shortcut: 'Ctrl+R',
      child: const Text('Reload'),
    ),
  ],
  child: const Placeholder(),
)''',
  ),
  ComponentEntry(
    name: 'Menu',
    slug: 'menu',
    category: ComponentCategory.overlays,
    description:
        'The panel, item, checkbox item, label and separator '
        'primitives.',
    alsoExports: <String>[
      'CairnMenuPanel',
      'CairnMenuItem',
      'CairnMenuCheckboxItem',
      'CairnMenuLabel',
      'CairnMenuSeparator',
    ],
    note:
        'Panels are p-1 with min-w-[8rem]. Menu items use cursor-default, not '
        'a pointer, matching Radix.',
    preview: Previews.menu,
    code: '''
CairnMenuPanel(
  minWidth: 240,
  children: <Widget>[
    const CairnMenuLabel('Appearance'),
    const CairnMenuSeparator(),
    CairnMenuCheckboxItem(
      value: _statusBar,
      onChanged: (bool v) => setState(() => _statusBar = v),
      child: const Text('Status bar'),
    ),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Select',
    slug: 'select',
    category: ComponentCategory.overlays,
    description: 'A trigger whose menu matches its width.',
    note:
        'Reproduces min-w-[var(--radix-select-trigger-width)] by measuring the '
        'trigger and constraining the menu to it.',
    preview: Previews.select,
    code: '''
CairnSelect<String>(
  value: _framework,
  width: 260,
  placeholder: 'Select a framework',
  options: const <CairnSelectOption<String>>[
    CairnSelectOption<String>(value: 'flutter', label: 'Flutter'),
    CairnSelectOption<String>(value: 'react', label: 'React'),
  ],
  onChanged: (String v) => setState(() => _framework = v),
)''',
  ),
  ComponentEntry(
    name: 'Combobox',
    slug: 'combobox',
    category: ComponentCategory.overlays,
    description: 'A select with a search field over the options.',
    preview: Previews.combobox,
    code: '''
CairnCombobox<String>(
  value: _value,
  placeholder: 'Select a framework',
  searchPlaceholder: 'Search frameworks...',
  options: frameworks,
  onChanged: (String v) => setState(() => _value = v),
)''',
  ),
  ComponentEntry(
    name: 'Command',
    slug: 'command',
    category: ComponentCategory.overlays,
    description: 'A cmdk-style palette with grouping and keyword matching.',
    note:
        'Focus stays in the input while arrow keys move a highlight through '
        'the list — the list itself is never focused, exactly as cmdk does it.',
    preview: Previews.command,
    code: '''
showCairnCommandPalette(
  context: context,
  items: <CairnCommandItem>[
    CairnCommandItem(
      label: 'New project',
      group: 'Actions',
      shortcut: 'Ctrl+N',
      onSelected: _newProject,
    ),
    CairnCommandItem(
      label: 'Sign out',
      group: 'Account',
      keywords: const <String>['logout'],
      onSelected: _signOut,
    ),
  ],
)''',
  ),

  // -------------------------------------------------------------------------
  // Navigation
  // -------------------------------------------------------------------------
  ComponentEntry(
    name: 'Tabs',
    slug: 'tabs',
    category: ComponentCategory.navigation,
    description: 'Filled and line variants with roving focus.',
    note:
        'The filled track is p-[3px] — an arbitrary value, not a step on the '
        'spacing scale. The line variant underlines 5px below the trigger.',
    preview: Previews.tabs,
    code: '''
CairnTabs<String>(
  value: _tab,
  variant: CairnTabsVariant.line,
  onChanged: (String v) => setState(() => _tab = v),
  tabs: const <CairnTab<String>>[
    CairnTab<String>(value: 'overview', label: Text('Overview')),
    CairnTab<String>(value: 'analytics', label: Text('Analytics')),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Accordion',
    slug: 'accordion',
    category: ComponentCategory.navigation,
    description: 'Single or multiple disclosure sections.',
    alsoExports: <String>['CairnCollapsible'],
    note:
        'The body animates its height over 200ms on Tailwind\'s default ease.',
    preview: Previews.accordion,
    code: '''
CairnAccordion(
  expanded: _open,
  multiple: false,
  onChanged: (Set<String> v) => setState(() => _open = v),
  items: const <CairnAccordionItem>[
    CairnAccordionItem(
      value: 'a',
      title: Text('Is it accessible?'),
      content: Text('Yes. It follows the WAI-ARIA disclosure pattern.'),
    ),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Collapsible',
    slug: 'collapsible',
    category: ComponentCategory.navigation,
    description: 'The single-section primitive underneath Accordion.',
    livesIn: 'accordion.dart',
    preview: Previews.collapsible,
    code: '''
CairnCollapsible(
  open: _open,
  onToggle: () => setState(() => _open = !_open),
  trigger: const Text('Starred repositories'),
  child: const Text('@rlphjyson/cairn_ui'),
)''',
  ),
  ComponentEntry(
    name: 'Breadcrumb',
    slug: 'breadcrumb',
    category: ComponentCategory.navigation,
    description: 'A trail with a current-page crumb and an ellipsis form.',
    alsoExports: <String>['CairnBreadcrumbEllipsis'],
    note:
        'The current crumb is announced as the current page rather than '
        'rendered as a dead link.',
    preview: Previews.breadcrumb,
    code: '''
CairnBreadcrumb(
  crumbs: <CairnCrumb>[
    CairnCrumb(label: 'Home', onTap: () => context.go('/')),
    CairnCrumb(label: 'Components', onTap: _components),
    const CairnCrumb.current(label: 'Breadcrumb'),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Pagination',
    slug: 'pagination',
    category: ComponentCategory.navigation,
    description: 'A windowed page range with ellipses.',
    preview: Previews.pagination,
    code: '''
CairnPagination(
  page: _page,
  pageCount: 12,
  siblingCount: 1,
  onChanged: (int p) => setState(() => _page = p),
)''',
  ),
  ComponentEntry(
    name: 'Menubar',
    slug: 'menubar',
    category: ComponentCategory.navigation,
    description: 'A desktop menu bar with hover-to-switch behaviour.',
    alsoExports: <String>['CairnNavigationMenu'],
    note:
        'Once one menu is open, hovering a sibling switches to it without a '
        'click — as every native menu bar does.',
    preview: Previews.menubar,
    code: '''
CairnMenubar(
  menus: <CairnMenubarMenu>[
    CairnMenubarMenu(
      label: 'File',
      items: <Widget>[
        CairnMenuItem(
          onPressed: _newTab,
          shortcut: 'Ctrl+N',
          child: const Text('New tab'),
        ),
      ],
    ),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Navigation Menu',
    slug: 'navigation-menu',
    category: ComponentCategory.navigation,
    description: 'A top-level nav with arbitrary dropdown panels.',
    livesIn: 'menubar.dart',
    preview: Previews.navigationMenu,
    code: '''
CairnNavigationMenu(
  items: <CairnNavigationItem>[
    CairnNavigationItem(
      label: 'Getting started',
      content: const SizedBox(width: 300, child: Text('Introduction')),
    ),
    CairnNavigationItem(label: 'Docs', onPressed: _docs),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Scroll Area',
    slug: 'scroll-area',
    category: ComponentCategory.navigation,
    description: 'A scroller with a shadcn-styled thumb.',
    note:
        'Configures Flutter\'s own Scrollbar rather than reimplementing '
        'scrolling: the thumb is bg-border on a w-2.5 track.',
    preview: Previews.scrollArea,
    code: '''
CairnScrollArea(
  height: 200,
  alwaysVisible: true,
  child: Column(children: tags),
)''',
  ),
  ComponentEntry(
    name: 'Carousel',
    slug: 'carousel',
    category: ComponentCategory.navigation,
    description: 'A paged viewport with controls and indicators.',
    preview: Previews.carousel,
    code: '''
CairnCarousel(
  height: 200,
  viewportFraction: 0.8,
  items: slides,
  onPageChanged: (int i) => setState(() => _page = i),
)''',
  ),

  // -------------------------------------------------------------------------
  // Data & feedback
  // -------------------------------------------------------------------------
  ComponentEntry(
    name: 'Progress',
    slug: 'progress',
    category: ComponentCategory.data,
    description: 'Determinate and indeterminate progress bars.',
    note:
        'The track is the primary colour at 20% alpha, not the muted token — '
        'a detail that is invisible until you put the two side by side.',
    preview: Previews.progress,
    code: '''
CairnProgress(value: _uploaded, semanticLabel: 'Upload')

const CairnProgress(semanticLabel: 'Working')''',
  ),
  ComponentEntry(
    name: 'Toast',
    slug: 'toast',
    category: ComponentCategory.data,
    description:
        'Stacked notifications that outlive the route that fired '
        'them.',
    alsoExports: <String>['CairnToaster'],
    note:
        'CairnToaster is installed in MaterialApp.builder, above the Navigator, '
        'so a toast fired from a screen survives that screen being popped.',
    preview: Previews.toast,
    code: '''
MaterialApp(
  builder: (BuildContext context, Widget? child) =>
      CairnToaster(child: child!),
);

CairnToast.show(
  context,
  const CairnToast(
    variant: CairnToastVariant.success,
    title: 'Changes saved',
    description: 'Your profile is up to date.',
  ),
);''',
  ),
  ComponentEntry(
    name: 'Data Table',
    slug: 'data-table',
    category: ComponentCategory.data,
    description: 'Sorting, filtering and pagination on top of Table.',
    note:
        'Sorting copies the list instead of mutating the caller\'s, so the '
        'rows you passed in are never reordered behind your back.',
    preview: Previews.dataTable,
    code: '''
CairnDataTable<Payment>(
  rows: payments,
  pageSize: 10,
  searchBy: (Payment p) => p.email,
  searchPlaceholder: 'Filter emails...',
  columns: <CairnColumn<Payment>>[
    CairnColumn<Payment>(
      label: 'Email',
      flex: 3,
      cell: (Payment p) => Text(p.email),
      sortKey: (Payment p) => p.email,
    ),
  ],
)''',
  ),
  ComponentEntry(
    name: 'Calendar',
    slug: 'calendar',
    category: ComponentCategory.data,
    description: 'A month grid on a fixed 7 x 6 layout.',
    note:
        'The grid is always 7 x 6, so paging between months never changes the '
        'popover height — a jumping calendar is the classic giveaway.',
    preview: Previews.calendar,
    code: '''
CairnCalendar(
  selected: _date,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  weekStartsOnMonday: true,
  onChanged: (DateTime d) => setState(() => _date = d),
)''',
  ),
  ComponentEntry(
    name: 'Date Picker',
    slug: 'date-picker',
    category: ComponentCategory.data,
    description: 'A Calendar inside a Popover, behind a formatted trigger.',
    preview: Previews.datePicker,
    code: '''
CairnDatePicker(
  value: _date,
  placeholder: 'Pick a date',
  format: (DateTime d) => DateFormat.yMMMd().format(d),
  onChanged: (DateTime d) => setState(() => _date = d),
)''',
  ),
];
