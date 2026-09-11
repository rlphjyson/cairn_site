import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

/// The live previews rendered on the Components catalogue and detail pages.
///
/// Every one of these is the *real* widget from `package:cairn_ui`, mounted in
/// the page. Nothing here is a screenshot, a mock or a re-implementation — if a
/// component regresses upstream, this site breaks, which is the point of
/// pinning the dependency to an exact commit.
///
/// Previews that need state get a small [StatefulWidget]; the rest are plain
/// builders. They are deliberately compact so a grid of them reads as a
/// catalogue rather than a demo app.
///
/// **Every preview must size itself.** The surfaces that host them — the bento
/// grid, the catalogue cards, the preview panes — hand them unbounded width so
/// that an oversized preview can scroll rather than overflow. A widget that
/// expects to fill (anything with an `Expanded`, or a `Column` with
/// `CrossAxisAlignment.stretch`) will assert under those constraints, so the
/// wrapping `SizedBox`es below are load-bearing, not cosmetic.
abstract final class Previews {
  /// Accordion, with one section open.
  static Widget accordion(BuildContext context) => const _AccordionPreview();

  /// Alert, default and destructive.
  static Widget alert(BuildContext context) => const SizedBox(
    width: 420,
    child: Column(
      spacing: CairnSpacing.s3,
      children: <Widget>[
        CairnAlert(
          icon: CairnIcon(CairnIconData.info),
          title: Text('Heads up'),
          description: Text('Your trial ends in three days.'),
        ),
        CairnAlert(
          variant: CairnAlertVariant.destructive,
          icon: CairnIcon(CairnIconData.alert),
          title: Text('Payment failed'),
          description: Text('Update your billing details to continue.'),
        ),
      ],
    ),
  );

  /// Alert Dialog, opened from a trigger.
  static Widget alertDialog(BuildContext context) => CairnButton(
    variant: CairnButtonVariant.outline,
    onPressed: () => showCairnAlertDialog<void>(
      context: context,
      builder: (BuildContext context) => CairnAlertDialog(
        title: const Text('Are you absolutely sure?'),
        description: const Text(
          'This permanently deletes the project and everything in it. '
          'There is no undo.',
        ),
        actions: <Widget>[
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CairnButton(
            variant: CairnButtonVariant.destructive,
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete project'),
          ),
        ],
      ),
    ),
    child: const Text('Show alert dialog'),
  );

  /// Aspect Ratio, at 16:9.
  static Widget aspectRatio(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: 320,
      child: CairnAspectRatio(
        ratio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.muted,
            borderRadius: BorderRadius.circular(theme.radiusScale.lg),
          ),
          child: const Center(child: Text('16 : 9')),
        ),
      ),
    );
  }

  /// Avatars in three sizes plus a stacked group.
  static Widget avatar(BuildContext context) => const Wrap(
    spacing: CairnSpacing.s4,
    runSpacing: CairnSpacing.s4,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: <Widget>[
      CairnAvatar(size: CairnAvatarSize.sm, fallback: Text('RJ')),
      CairnAvatar(fallback: Text('CA')),
      CairnAvatar(size: CairnAvatarSize.lg, fallback: Text('UI')),
      CairnAvatarGroup(
        children: <Widget>[
          CairnAvatar(fallback: Text('A')),
          CairnAvatar(fallback: Text('B')),
          CairnAvatar(fallback: Text('+7')),
        ],
      ),
    ],
  );

  /// Every badge variant.
  static Widget badge(BuildContext context) => const Wrap(
    spacing: CairnSpacing.s2,
    runSpacing: CairnSpacing.s2,
    children: <Widget>[
      CairnBadge(label: Text('Default')),
      CairnBadge(
        variant: CairnBadgeVariant.secondary,
        label: Text('Secondary'),
      ),
      CairnBadge(
        variant: CairnBadgeVariant.destructive,
        label: Text('Destructive'),
      ),
      CairnBadge(variant: CairnBadgeVariant.outline, label: Text('Outline')),
      CairnBadge(
        leading: CairnIcon(CairnIconData.check, size: 12),
        label: Text('Verified'),
      ),
    ],
  );

  /// Breadcrumb with a current-page crumb.
  static Widget breadcrumb(BuildContext context) => SizedBox(
    width: 340,
    child: CairnBreadcrumb(
      crumbs: <CairnCrumb>[
        CairnCrumb(label: 'Home', onTap: () {}),
        CairnCrumb(label: 'Components', onTap: () {}),
        const CairnCrumb.current(label: 'Breadcrumb'),
      ],
    ),
  );

  /// Six button variants and the icon/loading/disabled states.
  static Widget button(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: CairnSpacing.s3,
    children: <Widget>[
      Wrap(
        spacing: CairnSpacing.s2,
        runSpacing: CairnSpacing.s2,
        children: <Widget>[
          CairnButton(onPressed: () {}, child: const Text('Primary')),
          CairnButton(
            variant: CairnButtonVariant.secondary,
            onPressed: () {},
            child: const Text('Secondary'),
          ),
          CairnButton(
            variant: CairnButtonVariant.destructive,
            onPressed: () {},
            child: const Text('Destructive'),
          ),
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: () {},
            child: const Text('Outline'),
          ),
          CairnButton(
            variant: CairnButtonVariant.ghost,
            onPressed: () {},
            child: const Text('Ghost'),
          ),
          CairnButton(
            variant: CairnButtonVariant.link,
            onPressed: () {},
            child: const Text('Link'),
          ),
        ],
      ),
      Wrap(
        spacing: CairnSpacing.s2,
        runSpacing: CairnSpacing.s2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          CairnButton.icon(
            icon: const CairnIcon(CairnIconData.check),
            semanticLabel: 'Confirm',
            variant: CairnButtonVariant.outline,
            onPressed: () {},
          ),
          CairnButton(
            onPressed: () {},
            leading: const CairnSpinner(),
            child: const Text('Saving'),
          ),
          const CairnButton(onPressed: null, child: Text('Disabled')),
        ],
      ),
    ],
  );

  /// A month grid with a selected day.
  static Widget calendar(BuildContext context) => const _CalendarPreview();

  /// Card with header, content and footer slots.
  static Widget card(BuildContext context) => CairnCard(
    width: 360,
    children: <Widget>[
      const CairnCardHeader(
        title: Text('Deploy your project'),
        description: Text('Ship to production in one click.'),
      ),
      const CairnCardContent(
        child: Text(
          'Your changes have been reviewed and are ready to go live.',
        ),
      ),
      CairnCardFooter(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: () {},
            child: const Text('Cancel'),
          ),
          CairnButton(onPressed: () {}, child: const Text('Deploy')),
        ],
      ),
    ],
  );

  /// A five-slide carousel.
  static Widget carousel(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: 380,
      child: CairnCarousel(
        height: 150,
        items: <Widget>[
          for (int i = 1; i <= 5; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.muted,
                borderRadius: BorderRadius.circular(theme.radiusScale.lg),
              ),
              child: Center(
                child: Text(
                  '$i',
                  style: theme
                      .textStyle(CairnTypography.xl3)
                      .copyWith(
                        fontWeight: CairnTypography.semibold,
                        color: theme.foreground,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// A tristate checkbox next to a label.
  static Widget checkbox(BuildContext context) => const _CheckboxPreview();

  /// A disclosure with a chevron trigger.
  static Widget collapsible(BuildContext context) =>
      const _CollapsiblePreview();

  /// A searchable select.
  static Widget combobox(BuildContext context) => const _ComboboxPreview();

  /// The command palette, inline rather than in a route.
  static Widget command(BuildContext context) => SizedBox(
    width: 380,
    child: CairnSurface(
      padding: EdgeInsets.zero,
      elevated: true,
      child: CairnCommand(
        autofocus: false,
        maxListHeight: 200,
        items: <CairnCommandItem>[
          CairnCommandItem(
            label: 'New project',
            group: 'Actions',
            shortcut: 'Ctrl+N',
            onSelected: () {},
          ),
          CairnCommandItem(
            label: 'Open settings',
            group: 'Actions',
            keywords: const <String>['preferences', 'config'],
            onSelected: () {},
          ),
          CairnCommandItem(
            label: 'Profile',
            group: 'Account',
            onSelected: () {},
          ),
          CairnCommandItem(
            label: 'Sign out',
            group: 'Account',
            keywords: const <String>['logout'],
            onSelected: () {},
          ),
        ],
      ),
    ),
  );

  /// A right-click / long-press target.
  static Widget contextMenu(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnContextMenu(
      items: <Widget>[
        CairnMenuItem(onPressed: () {}, child: const Text('Back')),
        CairnMenuItem(onPressed: () {}, child: const Text('Forward')),
        const CairnMenuSeparator(),
        CairnMenuItem(
          onPressed: () {},
          shortcut: 'Ctrl+R',
          child: const Text('Reload'),
        ),
      ],
      child: Container(
        width: 280,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        ),
        child: const Text('Right-click or long-press here'),
      ),
    );
  }

  /// A sortable, filterable, paginated table.
  static Widget dataTable(BuildContext context) => SizedBox(
    width: 560,
    child: CairnDataTable<_Payment>(
      rows: _payments,
      pageSize: 4,
      searchBy: (_Payment p) => p.email,
      searchPlaceholder: 'Filter emails...',
      columns: <CairnColumn<_Payment>>[
        CairnColumn<_Payment>(
          label: 'Email',
          flex: 3,
          cell: (_Payment p) => Text(p.email),
          sortKey: (_Payment p) => p.email,
        ),
        CairnColumn<_Payment>(
          label: 'Status',
          flex: 2,
          cell: (_Payment p) => CairnBadge(
            variant: switch (p.status) {
              'Success' => CairnBadgeVariant.primary,
              'Failed' => CairnBadgeVariant.destructive,
              _ => CairnBadgeVariant.secondary,
            },
            label: Text(p.status),
          ),
          sortKey: (_Payment p) => p.status,
        ),
        CairnColumn<_Payment>(
          label: 'Amount',
          flex: 2,
          alignment: Alignment.centerRight,
          cell: (_Payment p) => Text('\$${p.amount.toStringAsFixed(2)}'),
          sortKey: (_Payment p) => p.amount,
        ),
      ],
    ),
  );

  /// A calendar in a popover.
  static Widget datePicker(BuildContext context) => const _DatePickerPreview();

  /// A modal dialog with a form inside.
  static Widget dialog(BuildContext context) => CairnButton(
    variant: CairnButtonVariant.outline,
    onPressed: () => showCairnDialog<void>(
      context: context,
      builder: (BuildContext context) => CairnDialog(
        title: const Text('Edit profile'),
        description: const Text(
          'Make changes to your profile here. Save when you are done.',
        ),
        content: const SizedBox(
          width: double.infinity,
          child: Column(
            spacing: CairnSpacing.s3,
            children: <Widget>[
              CairnFormField(label: 'Name', child: CairnInput()),
              CairnFormField(label: 'Username', child: CairnInput()),
            ],
          ),
        ),
        actions: <Widget>[
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CairnButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save changes'),
          ),
        ],
      ),
    ),
    child: const Text('Open dialog'),
  );

  /// A bottom sheet with a grab handle.
  static Widget drawer(BuildContext context) => CairnButton(
    variant: CairnButtonVariant.outline,
    onPressed: () => showCairnDrawer<void>(
      context: context,
      builder: (BuildContext context) => CairnDrawer(
        title: const Text('Move goal'),
        description: const Text('Set your daily activity goal.'),
        content: const Text('Drag the handle down to dismiss.'),
        footer: <Widget>[
          CairnButton(
            expand: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
    child: const Text('Open drawer'),
  );

  /// A dropdown menu with labels, shortcuts and a destructive item.
  static Widget dropdownMenu(BuildContext context) =>
      const _DropdownMenuPreview();

  /// The empty state, with its hand-painted dashed border.
  static Widget empty(BuildContext context) => SizedBox(
    width: 400,
    child: CairnEmpty(
      media: const CairnIcon(CairnIconData.search, size: 32),
      title: 'No results',
      description: 'Try adjusting your filters, or clear them to start over.',
      actions: <Widget>[
        CairnButton(
          variant: CairnButtonVariant.outline,
          onPressed: () {},
          child: const Text('Clear filters'),
        ),
      ],
    ),
  );

  /// Label, description and error text around a control.
  static Widget formField(BuildContext context) => const SizedBox(
    width: 340,
    child: Column(
      spacing: CairnSpacing.s4,
      children: <Widget>[
        CairnFormField(
          label: 'Email',
          description: 'We will never share it.',
          child: CairnInput(placeholder: 'name@example.com'),
        ),
        CairnFormField(
          label: 'Username',
          error: 'That name is already taken.',
          child: CairnInput(hasError: true),
        ),
      ],
    ),
  );

  /// A hover card with a grace period on both edges.
  static Widget hoverCard(BuildContext context) => CairnHoverCard(
    openDelay: const Duration(milliseconds: 250),
    content: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s2,
      children: <Widget>[
        CairnAvatar(fallback: Text('CA')),
        Text('Cairn UI'),
        Text('shadcn/ui, measured and rebuilt in Flutter.'),
      ],
    ),
    child: CairnButton(
      variant: CairnButtonVariant.link,
      onPressed: () {},
      child: const Text('@cairn_ui'),
    ),
  );

  /// Input with placeholder, error and disabled states.
  static Widget input(BuildContext context) => const SizedBox(
    width: 320,
    child: Column(
      spacing: CairnSpacing.s3,
      children: <Widget>[
        CairnInput(placeholder: 'name@example.com'),
        CairnInput(placeholder: 'Invalid', hasError: true),
        CairnInput(placeholder: 'Disabled', enabled: false),
      ],
    ),
  );

  /// A six-slot one-time-code field.
  static Widget inputOtp(BuildContext context) => const SizedBox(
    width: 300,
    child: Align(child: CairnInputOtp(length: 6, groupSizes: <int>[3, 3])),
  );

  /// Keyboard hints, single and grouped.
  static Widget kbd(BuildContext context) => const Wrap(
    spacing: CairnSpacing.s4,
    runSpacing: CairnSpacing.s2,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: <Widget>[
      CairnKbd('Esc'),
      CairnKbdGroup(keys: <String>['Ctrl', 'K']),
      CairnKbdGroup(keys: <String>['Shift', 'Alt', 'D']),
    ],
  );

  /// A label in both enabled and disabled states.
  static Widget label(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: CairnSpacing.s3,
    children: <Widget>[
      CairnLabel('Accept terms and conditions'),
      CairnLabel('Disabled field', enabled: false),
    ],
  );

  /// The raw menu primitives, rendered inline.
  static Widget menu(BuildContext context) => const _MenuPreview();

  /// A desktop-style menu bar.
  static Widget menubar(BuildContext context) => SizedBox(
    width: 300,
    child: CairnMenubar(
      menus: <CairnMenubarMenu>[
        CairnMenubarMenu(
          label: 'File',
          items: <Widget>[
            CairnMenuItem(
              onPressed: () {},
              shortcut: 'Ctrl+N',
              child: const Text('New tab'),
            ),
            CairnMenuItem(
              onPressed: () {},
              shortcut: 'Ctrl+O',
              child: const Text('Open...'),
            ),
            const CairnMenuSeparator(),
            CairnMenuItem(onPressed: () {}, child: const Text('Print')),
          ],
        ),
        CairnMenubarMenu(
          label: 'Edit',
          items: <Widget>[
            CairnMenuItem(
              onPressed: () {},
              shortcut: 'Ctrl+Z',
              child: const Text('Undo'),
            ),
            CairnMenuItem(
              onPressed: () {},
              shortcut: 'Ctrl+Y',
              child: const Text('Redo'),
            ),
          ],
        ),
        CairnMenubarMenu(
          label: 'View',
          items: <Widget>[
            CairnMenuItem(onPressed: () {}, child: const Text('Reload')),
          ],
        ),
      ],
    ),
  );

  /// A navigation menu with an arbitrary panel.
  static Widget navigationMenu(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: 420,
      child: CairnNavigationMenu(
        items: <CairnNavigationItem>[
          CairnNavigationItem(
            label: 'Getting started',
            content: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: CairnSpacing.s2,
                children: <Widget>[
                  Text(
                    'Introduction',
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(fontWeight: CairnTypography.medium),
                  ),
                  Text(
                    'Components built to shadcn/ui\'s exact measurements, in '
                    'Flutter.',
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(color: theme.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
          CairnNavigationItem(label: 'Docs', onPressed: () {}),
          CairnNavigationItem(label: 'Blocks', onPressed: () {}),
        ],
      ),
    );
  }

  /// A windowed page range with ellipses.
  static Widget pagination(BuildContext context) => const _PaginationPreview();

  /// An anchored popover.
  static Widget popover(BuildContext context) => const _PopoverPreview();

  /// Determinate and indeterminate progress.
  static Widget progress(BuildContext context) => const SizedBox(
    width: 320,
    child: Column(
      spacing: CairnSpacing.s4,
      children: <Widget>[
        CairnProgress(value: 0.62, semanticLabel: 'Upload'),
        CairnProgress(semanticLabel: 'Working'),
      ],
    ),
  );

  /// A roving-focus radio group.
  static Widget radioGroup(BuildContext context) => const _RadioGroupPreview();

  /// A scroll area with an always-visible thumb.
  static Widget scrollArea(BuildContext context) => SizedBox(
    width: 300,
    child: CairnScrollArea(
      height: 160,
      alwaysVisible: true,
      padding: const EdgeInsets.only(right: CairnSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 1; i <= 18; i++) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s2),
              child: Text('Tag $i'),
            ),
            if (i != 18) const CairnSeparator(),
          ],
        ],
      ),
    ),
  );

  /// A select whose menu matches the trigger width.
  static Widget select(BuildContext context) => const _SelectPreview();

  /// Horizontal and vertical rules.
  static Widget separator(BuildContext context) => const SizedBox(
    width: 300,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: CairnSpacing.s4,
      children: <Widget>[
        Text('Cairn UI'),
        CairnSeparator(),
        SizedBox(
          height: 20,
          child: Row(
            spacing: CairnSpacing.s4,
            children: <Widget>[
              Text('Docs'),
              CairnSeparator(axis: Axis.vertical),
              Text('Components'),
              CairnSeparator(axis: Axis.vertical),
              Text('Blocks'),
            ],
          ),
        ),
      ],
    ),
  );

  /// A side sheet.
  static Widget sheet(BuildContext context) => Wrap(
    spacing: CairnSpacing.s2,
    runSpacing: CairnSpacing.s2,
    children: <Widget>[
      for (final CairnSheetSide side in CairnSheetSide.values)
        CairnButton(
          variant: CairnButtonVariant.outline,
          size: CairnButtonSize.sm,
          onPressed: () => showCairnSheet<void>(
            context: context,
            side: side,
            builder: (BuildContext context) => CairnSheet(
              side: side,
              title: const Text('Filters'),
              description: const Text('Narrow the results.'),
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: CairnSpacing.s4,
                children: <Widget>[
                  CairnFormField(label: 'Query', child: CairnInput()),
                ],
              ),
              footer: <Widget>[
                CairnButton(
                  expand: true,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
          child: Text(side.name),
        ),
    ],
  );

  /// A loading placeholder.
  static Widget skeleton(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    spacing: CairnSpacing.s4,
    children: <Widget>[
      CairnSkeleton.circle(size: 44),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: CairnSpacing.s2,
        children: <Widget>[
          CairnSkeleton(width: 220, height: 12),
          CairnSkeleton(width: 160, height: 12),
        ],
      ),
    ],
  );

  /// A keyboard-operable slider.
  static Widget slider(BuildContext context) => const _SliderPreview();

  /// Three spinner sizes.
  static Widget spinner(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    spacing: CairnSpacing.s5,
    children: <Widget>[
      CairnSpinner(),
      CairnSpinner(size: 24),
      CairnSpinner(size: 32, strokeWidth: 3),
    ],
  );

  /// A switch with the literal `h-[1.15rem]` track.
  static Widget switchToggle(BuildContext context) => const _SwitchPreview();

  /// A static table with a caption.
  static Widget table(BuildContext context) => SizedBox(
    width: 460,
    child: CairnTable<_Invoice>(
      caption: const Text('A list of recent invoices.'),
      rows: const <_Invoice>[
        _Invoice('INV001', 'Paid', r'$250.00'),
        _Invoice('INV002', 'Pending', r'$150.00'),
        _Invoice('INV003', 'Unpaid', r'$350.00'),
      ],
      columns: <CairnColumn<_Invoice>>[
        CairnColumn<_Invoice>(
          label: 'Invoice',
          cell: (_Invoice i) => Text(i.id),
        ),
        CairnColumn<_Invoice>(
          label: 'Status',
          cell: (_Invoice i) => CairnBadge(
            variant: i.status == 'Paid'
                ? CairnBadgeVariant.primary
                : CairnBadgeVariant.secondary,
            label: Text(i.status),
          ),
        ),
        CairnColumn<_Invoice>(
          label: 'Amount',
          alignment: Alignment.centerRight,
          cell: (_Invoice i) => Text(i.amount),
        ),
      ],
    ),
  );

  /// Filled and line tab variants.
  static Widget tabs(BuildContext context) => const _TabsPreview();

  /// An auto-growing textarea.
  static Widget textarea(BuildContext context) => const SizedBox(
    width: 340,
    child: CairnTextarea(placeholder: 'Tell us a little about yourself...'),
  );

  /// Toasts in each variant.
  static Widget toast(BuildContext context) => Wrap(
    spacing: CairnSpacing.s2,
    runSpacing: CairnSpacing.s2,
    children: <Widget>[
      CairnButton(
        variant: CairnButtonVariant.outline,
        size: CairnButtonSize.sm,
        onPressed: () => CairnToast.show(
          context,
          const CairnToast(
            title: 'Event created',
            description: 'Friday, 12 September at 9:00 AM.',
          ),
        ),
        child: const Text('Default'),
      ),
      CairnButton(
        variant: CairnButtonVariant.outline,
        size: CairnButtonSize.sm,
        onPressed: () => CairnToast.show(
          context,
          const CairnToast(
            variant: CairnToastVariant.success,
            title: 'Changes saved',
            description: 'Your profile is up to date.',
          ),
        ),
        child: const Text('Success'),
      ),
      CairnButton(
        variant: CairnButtonVariant.outline,
        size: CairnButtonSize.sm,
        onPressed: () => CairnToast.show(
          context,
          const CairnToast(
            variant: CairnToastVariant.error,
            title: 'Something went wrong',
            description: 'Your changes were not saved.',
          ),
        ),
        child: const Text('Error'),
      ),
      CairnButton(
        variant: CairnButtonVariant.outline,
        size: CairnButtonSize.sm,
        onPressed: () => CairnToast.show(
          context,
          CairnToast(
            variant: CairnToastVariant.info,
            title: 'Update available',
            description: 'Version 0.2.0 is ready to install.',
            action: 'Install',
            onActionPressed: () {},
          ),
        ),
        child: const Text('With action'),
      ),
    ],
  );

  /// A two-state toggle.
  static Widget toggle(BuildContext context) => const _TogglePreview();

  /// A joined, single-select toggle group.
  static Widget toggleGroup(BuildContext context) =>
      const _ToggleGroupPreview();

  /// A tooltip that opens on hover and on keyboard focus.
  static Widget tooltip(BuildContext context) => CairnTooltip(
    message: 'Copy to clipboard',
    openDelay: const Duration(milliseconds: 250),
    child: CairnButton(
      variant: CairnButtonVariant.outline,
      onPressed: () {},
      child: const Text('Hover or tab to me'),
    ),
  );
}

// ---------------------------------------------------------------------------
// Stateful previews
// ---------------------------------------------------------------------------

class _AccordionPreview extends StatefulWidget {
  const _AccordionPreview();

  @override
  State<_AccordionPreview> createState() => _AccordionPreviewState();
}

class _AccordionPreviewState extends State<_AccordionPreview> {
  Set<String> _open = <String>{'a'};

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 420,
    child: CairnAccordion(
      expanded: _open,
      onChanged: (Set<String> v) => setState(() => _open = v),
      items: const <CairnAccordionItem>[
        CairnAccordionItem(
          value: 'a',
          title: Text('Is it accessible?'),
          content: Text(
            'Yes. It follows the WAI-ARIA disclosure pattern and is fully '
            'keyboard operable.',
          ),
        ),
        CairnAccordionItem(
          value: 'b',
          title: Text('Is it styled?'),
          content: Text(
            'To shadcn/ui measurements, down to the 2px chevron nudge.',
          ),
        ),
        CairnAccordionItem(
          value: 'c',
          title: Text('Is it animated?'),
          content: Text(
            'The body animates over 200ms on Tailwind\'s default easing.',
          ),
        ),
      ],
    ),
  );
}

class _CalendarPreview extends StatefulWidget {
  const _CalendarPreview();

  @override
  State<_CalendarPreview> createState() => _CalendarPreviewState();
}

class _CalendarPreviewState extends State<_CalendarPreview> {
  DateTime? _selected = DateTime(2026, 9, 11);

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    // The calendar grid is seven fixed-width cells wide, but its caption row
    // uses an Expanded, so it needs bounded width to lay out at all.
    return SizedBox(
      width: 280,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(CairnSpacing.s3),
          child: CairnCalendar(
            selected: _selected,
            initialMonth: DateTime(2026, 9),
            onChanged: (DateTime d) => setState(() => _selected = d),
          ),
        ),
      ),
    );
  }
}

class _CheckboxPreview extends StatefulWidget {
  const _CheckboxPreview();

  @override
  State<_CheckboxPreview> createState() => _CheckboxPreviewState();
}

class _CheckboxPreviewState extends State<_CheckboxPreview> {
  bool? _terms = true;
  bool? _mixed;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: CairnSpacing.s3,
    children: <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s2,
        children: <Widget>[
          CairnCheckbox(
            value: _terms,
            onChanged: (bool? v) => setState(() => _terms = v),
          ),
          const CairnLabel('Accept terms and conditions'),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s2,
        children: <Widget>[
          CairnCheckbox(
            value: _mixed,
            tristate: true,
            onChanged: (bool? v) => setState(() => _mixed = v),
          ),
          const CairnLabel('Tristate (click through null)'),
        ],
      ),
    ],
  );
}

class _CollapsiblePreview extends StatefulWidget {
  const _CollapsiblePreview();

  @override
  State<_CollapsiblePreview> createState() => _CollapsiblePreviewState();
}

class _CollapsiblePreviewState extends State<_CollapsiblePreview> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: 360,
      child: CairnCollapsible(
        open: _open,
        onToggle: () => setState(() => _open = !_open),
        trigger: Padding(
          padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Starred repositories',
                  style: theme
                      .textStyle(CairnTypography.sm)
                      .copyWith(
                        fontWeight: CairnTypography.medium,
                        color: theme.foreground,
                      ),
                ),
              ),
              CairnIcon(
                _open ? CairnIconData.chevronUp : CairnIconData.chevronDown,
                color: theme.mutedForeground,
              ),
            ],
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.only(bottom: CairnSpacing.s2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s2,
            children: <Widget>[
              Text('@rlphjyson/cairn_ui'),
              Text('@rlphjyson/cairn_site'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComboboxPreview extends StatefulWidget {
  const _ComboboxPreview();

  @override
  State<_ComboboxPreview> createState() => _ComboboxPreviewState();
}

class _ComboboxPreviewState extends State<_ComboboxPreview> {
  String? _value;

  @override
  Widget build(BuildContext context) => CairnCombobox<String>(
    value: _value,
    placeholder: 'Select a framework',
    searchPlaceholder: 'Search frameworks...',
    options: _frameworks,
    onChanged: (String v) => setState(() => _value = v),
  );
}

class _DatePickerPreview extends StatefulWidget {
  const _DatePickerPreview();

  @override
  State<_DatePickerPreview> createState() => _DatePickerPreviewState();
}

class _DatePickerPreviewState extends State<_DatePickerPreview> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) => CairnDatePicker(
    value: _value,
    onChanged: (DateTime d) => setState(() => _value = d),
  );
}

class _DropdownMenuPreview extends StatefulWidget {
  const _DropdownMenuPreview();

  @override
  State<_DropdownMenuPreview> createState() => _DropdownMenuPreviewState();
}

class _DropdownMenuPreviewState extends State<_DropdownMenuPreview> {
  final CairnOverlayController _controller = CairnOverlayController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CairnDropdownMenu(
    controller: _controller,
    items: <Widget>[
      const CairnMenuLabel('My account'),
      const CairnMenuSeparator(),
      CairnMenuItem(
        onPressed: () {},
        shortcut: 'Ctrl+P',
        child: const Text('Profile'),
      ),
      CairnMenuItem(
        onPressed: () {},
        shortcut: 'Ctrl+S',
        child: const Text('Settings'),
      ),
      const CairnMenuSeparator(),
      CairnMenuItem(
        variant: CairnMenuItemVariant.destructive,
        onPressed: () {},
        child: const Text('Sign out'),
      ),
    ],
    child: CairnButton(
      variant: CairnButtonVariant.outline,
      onPressed: _controller.toggle,
      trailing: const CairnIcon(CairnIconData.chevronDown),
      child: const Text('Open menu'),
    ),
  );
}

class _MenuPreview extends StatefulWidget {
  const _MenuPreview();

  @override
  State<_MenuPreview> createState() => _MenuPreviewState();
}

class _MenuPreviewState extends State<_MenuPreview> {
  bool _statusBar = true;
  bool _activityBar = false;

  @override
  Widget build(BuildContext context) => CairnMenuPanel(
    minWidth: 240,
    children: <Widget>[
      const CairnMenuLabel('Appearance'),
      const CairnMenuSeparator(),
      CairnMenuCheckboxItem(
        value: _statusBar,
        onChanged: (bool v) => setState(() => _statusBar = v),
        child: const Text('Status bar'),
      ),
      CairnMenuCheckboxItem(
        value: _activityBar,
        onChanged: (bool v) => setState(() => _activityBar = v),
        child: const Text('Activity bar'),
      ),
      const CairnMenuSeparator(),
      CairnMenuItem(
        onPressed: () {},
        shortcut: 'Ctrl+,',
        child: const Text('Preferences'),
      ),
      CairnMenuItem(
        variant: CairnMenuItemVariant.destructive,
        onPressed: () {},
        child: const Text('Reset layout'),
      ),
    ],
  );
}

class _PaginationPreview extends StatefulWidget {
  const _PaginationPreview();

  @override
  State<_PaginationPreview> createState() => _PaginationPreviewState();
}

class _PaginationPreviewState extends State<_PaginationPreview> {
  int _page = 4;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 520,
    child: CairnPagination(
      page: _page,
      pageCount: 12,
      onChanged: (int p) => setState(() => _page = p),
    ),
  );
}

class _PopoverPreview extends StatefulWidget {
  const _PopoverPreview();

  @override
  State<_PopoverPreview> createState() => _PopoverPreviewState();
}

class _PopoverPreviewState extends State<_PopoverPreview> {
  final CairnOverlayController _controller = CairnOverlayController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CairnPopover(
    controller: _controller,
    content: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s3,
      children: <Widget>[
        CairnPopoverTitle('Dimensions'),
        CairnPopoverDescription('Set the layout bounds for this layer.'),
        CairnFormField(label: 'Width', child: CairnInput()),
      ],
    ),
    child: CairnButton(
      variant: CairnButtonVariant.outline,
      onPressed: _controller.toggle,
      child: const Text('Open popover'),
    ),
  );
}

class _RadioGroupPreview extends StatefulWidget {
  const _RadioGroupPreview();

  @override
  State<_RadioGroupPreview> createState() => _RadioGroupPreviewState();
}

class _RadioGroupPreviewState extends State<_RadioGroupPreview> {
  String _plan = 'pro';

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    child: CairnRadioGroup<String>(
      value: _plan,
      onChanged: (String v) => setState(() => _plan = v),
      children: const <Widget>[
        CairnRadioItem<String>(value: 'free', label: Text('Free')),
        CairnRadioItem<String>(value: 'pro', label: Text('Pro')),
        CairnRadioItem<String>(
          value: 'team',
          label: Text('Team (unavailable)'),
          enabled: false,
        ),
      ],
    ),
  );
}

class _SelectPreview extends StatefulWidget {
  const _SelectPreview();

  @override
  State<_SelectPreview> createState() => _SelectPreviewState();
}

class _SelectPreviewState extends State<_SelectPreview> {
  String? _value;

  @override
  Widget build(BuildContext context) => CairnSelect<String>(
    value: _value,
    width: 260,
    placeholder: 'Select a framework',
    options: _frameworks,
    onChanged: (String v) => setState(() => _value = v),
  );
}

class _SliderPreview extends StatefulWidget {
  const _SliderPreview();

  @override
  State<_SliderPreview> createState() => _SliderPreviewState();
}

class _SliderPreviewState extends State<_SliderPreview> {
  double _value = 0.6;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: CairnSlider(
      value: _value,
      semanticLabel: 'Volume',
      onChanged: (double v) => setState(() => _value = v),
    ),
  );
}

class _SwitchPreview extends StatefulWidget {
  const _SwitchPreview();

  @override
  State<_SwitchPreview> createState() => _SwitchPreviewState();
}

class _SwitchPreviewState extends State<_SwitchPreview> {
  bool _on = true;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: CairnSpacing.s3,
    children: <Widget>[
      CairnSwitch(
        value: _on,
        semanticLabel: 'Notifications',
        onChanged: (bool v) => setState(() => _on = v),
      ),
      const CairnLabel('Email notifications'),
    ],
  );
}

class _TabsPreview extends StatefulWidget {
  const _TabsPreview();

  @override
  State<_TabsPreview> createState() => _TabsPreviewState();
}

class _TabsPreviewState extends State<_TabsPreview> {
  String _filled = 'account';
  String _line = 'overview';

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: CairnSpacing.s5,
    children: <Widget>[
      CairnTabs<String>(
        value: _filled,
        onChanged: (String v) => setState(() => _filled = v),
        tabs: const <CairnTab<String>>[
          CairnTab<String>(value: 'account', label: Text('Account')),
          CairnTab<String>(value: 'password', label: Text('Password')),
          CairnTab<String>(value: 'team', label: Text('Team')),
        ],
      ),
      CairnTabs<String>(
        value: _line,
        variant: CairnTabsVariant.line,
        onChanged: (String v) => setState(() => _line = v),
        tabs: const <CairnTab<String>>[
          CairnTab<String>(value: 'overview', label: Text('Overview')),
          CairnTab<String>(value: 'analytics', label: Text('Analytics')),
          CairnTab<String>(value: 'reports', label: Text('Reports')),
        ],
      ),
    ],
  );
}

class _TogglePreview extends StatefulWidget {
  const _TogglePreview();

  @override
  State<_TogglePreview> createState() => _TogglePreviewState();
}

class _TogglePreviewState extends State<_TogglePreview> {
  bool _bold = false;
  bool _italic = true;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: CairnSpacing.s2,
    runSpacing: CairnSpacing.s2,
    children: <Widget>[
      CairnToggle(
        value: _bold,
        onChanged: (bool v) => setState(() => _bold = v),
        child: const Text('Bold'),
      ),
      CairnToggle(
        value: _italic,
        variant: CairnToggleVariant.outline,
        onChanged: (bool v) => setState(() => _italic = v),
        child: const Text('Italic'),
      ),
    ],
  );
}

class _ToggleGroupPreview extends StatefulWidget {
  const _ToggleGroupPreview();

  @override
  State<_ToggleGroupPreview> createState() => _ToggleGroupPreviewState();
}

class _ToggleGroupPreviewState extends State<_ToggleGroupPreview> {
  Set<String> _alignment = <String>{'center'};
  Set<String> _marks = <String>{'bold'};

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: CairnSpacing.s4,
    children: <Widget>[
      CairnToggleGroup<String>(
        values: _alignment,
        variant: CairnToggleVariant.outline,
        onChanged: (Set<String> v) => setState(() => _alignment = v),
        items: const <CairnToggleGroupItem<String>>[
          CairnToggleGroupItem<String>(value: 'left', child: Text('Left')),
          CairnToggleGroupItem<String>(value: 'center', child: Text('Center')),
          CairnToggleGroupItem<String>(value: 'right', child: Text('Right')),
        ],
      ),
      CairnToggleGroup<String>(
        values: _marks,
        type: CairnToggleGroupType.multiple,
        onChanged: (Set<String> v) => setState(() => _marks = v),
        items: const <CairnToggleGroupItem<String>>[
          CairnToggleGroupItem<String>(value: 'bold', child: Text('B')),
          CairnToggleGroupItem<String>(value: 'italic', child: Text('I')),
          CairnToggleGroupItem<String>(value: 'underline', child: Text('U')),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

const List<CairnSelectOption<String>> _frameworks = <CairnSelectOption<String>>[
  CairnSelectOption<String>(value: 'flutter', label: 'Flutter'),
  CairnSelectOption<String>(value: 'react', label: 'React'),
  CairnSelectOption<String>(value: 'svelte', label: 'Svelte'),
  CairnSelectOption<String>(value: 'vue', label: 'Vue'),
  CairnSelectOption<String>(
    value: 'ember',
    label: 'Ember (unavailable)',
    enabled: false,
  ),
];

class _Payment {
  const _Payment(this.email, this.status, this.amount);

  final String email;
  final String status;
  final double amount;
}

const List<_Payment> _payments = <_Payment>[
  _Payment('ken99@example.com', 'Success', 316.00),
  _Payment('abe45@example.com', 'Success', 242.00),
  _Payment('monserrat44@example.com', 'Processing', 837.00),
  _Payment('silas22@example.com', 'Failed', 874.00),
  _Payment('carmella@example.com', 'Success', 721.00),
  _Payment('jason78@example.com', 'Processing', 450.00),
  _Payment('nora12@example.com', 'Success', 129.00),
  _Payment('devon@example.com', 'Failed', 98.00),
];

class _Invoice {
  const _Invoice(this.id, this.status, this.amount);

  final String id;
  final String status;
  final String amount;
}
