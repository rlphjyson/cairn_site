import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import 'variant_sample.dart';

/// The live previews rendered on the Components catalogue and detail pages.
///
/// Every one of these is the *real* widget from `package:cairn_ui`, mounted in
/// the page. Nothing here is a screenshot, a mock or a re-implementation — if a
/// component regresses upstream, this site breaks, which is the point of
/// pinning the dependency to an exact commit.
///
/// Each builder returns a [VariantSet]: the same arrangement the preview always
/// had, but broken into individually addressable [VariantSample]s so that a
/// visitor can click the one instance they are actually looking at and get the
/// snippet for *that* instance. The code strings below are therefore held to a
/// hard standard — each one is a complete, compiling expression using the real
/// public API with the same argument values as the widget beside it. A snippet
/// that does not paste and run is a bug, not a typo.
///
/// Previews that need state get a small [StatefulWidget], one per variant, so
/// that two instances of the same component never share a value.
///
/// **Every preview must size itself.** The surfaces that host them — the bento
/// grid, the catalogue cards, the preview panes — hand them unbounded width so
/// that an oversized preview can scroll rather than overflow. A widget that
/// expects to fill (anything with an `Expanded`, or a `Column` with
/// `CrossAxisAlignment.stretch`) will assert under those constraints, so the
/// `width` on a [VariantSet] and the wrapping `SizedBox`es below are
/// load-bearing, not cosmetic.
abstract final class Previews {
  // ---------------------------------------------------------------------------
  // Forms
  // ---------------------------------------------------------------------------

  /// Six button variants, the icon/loading/disabled forms, and four sizes.
  static VariantSet button(BuildContext context) => VariantSet(<VariantGroup>[
    VariantGroup(<VariantSample>[
      VariantSample(
        label: 'Primary',
        code: '''
CairnButton(
  onPressed: () {},
  child: const Text('Primary'),
)''',
        child: CairnButton(onPressed: () {}, child: const Text('Primary')),
      ),
      VariantSample(
        label: 'Secondary',
        code: '''
CairnButton(
  variant: CairnButtonVariant.secondary,
  onPressed: () {},
  child: const Text('Secondary'),
)''',
        child: CairnButton(
          variant: CairnButtonVariant.secondary,
          onPressed: () {},
          child: const Text('Secondary'),
        ),
      ),
      VariantSample(
        label: 'Destructive',
        code: '''
CairnButton(
  variant: CairnButtonVariant.destructive,
  onPressed: () {},
  child: const Text('Destructive'),
)''',
        child: CairnButton(
          variant: CairnButtonVariant.destructive,
          onPressed: () {},
          child: const Text('Destructive'),
        ),
      ),
      VariantSample(
        label: 'Outline',
        code: '''
CairnButton(
  variant: CairnButtonVariant.outline,
  onPressed: () {},
  child: const Text('Outline'),
)''',
        child: CairnButton(
          variant: CairnButtonVariant.outline,
          onPressed: () {},
          child: const Text('Outline'),
        ),
      ),
      VariantSample(
        label: 'Ghost',
        code: '''
CairnButton(
  variant: CairnButtonVariant.ghost,
  onPressed: () {},
  child: const Text('Ghost'),
)''',
        child: CairnButton(
          variant: CairnButtonVariant.ghost,
          onPressed: () {},
          child: const Text('Ghost'),
        ),
      ),
      VariantSample(
        label: 'Link',
        code: '''
CairnButton(
  variant: CairnButtonVariant.link,
  onPressed: () {},
  child: const Text('Link'),
)''',
        child: CairnButton(
          variant: CairnButtonVariant.link,
          onPressed: () {},
          child: const Text('Link'),
        ),
      ),
    ]),
    VariantGroup(<VariantSample>[
      VariantSample(
        label: 'Icon only',
        code: '''
CairnButton.icon(
  icon: const CairnIcon(CairnIconData.check),
  semanticLabel: 'Confirm',
  variant: CairnButtonVariant.outline,
  onPressed: () {},
)''',
        child: CairnButton.icon(
          icon: const CairnIcon(CairnIconData.check),
          semanticLabel: 'Confirm',
          variant: CairnButtonVariant.outline,
          onPressed: () {},
        ),
      ),
      VariantSample(
        label: 'Loading',
        code: '''
CairnButton(
  onPressed: () {},
  leading: const CairnSpinner(),
  child: const Text('Saving'),
)''',
        child: CairnButton(
          onPressed: () {},
          leading: const CairnSpinner(),
          child: const Text('Saving'),
        ),
      ),
      const VariantSample(
        label: 'Disabled',
        code: '''
const CairnButton(
  onPressed: null,
  child: Text('Disabled'),
)''',
        child: CairnButton(onPressed: null, child: Text('Disabled')),
      ),
    ]),
    VariantGroup(<VariantSample>[
      VariantSample(
        label: 'Size · xs',
        code: '''
CairnButton(
  size: CairnButtonSize.xs,
  onPressed: () {},
  child: const Text('Extra small'),
)''',
        child: CairnButton(
          size: CairnButtonSize.xs,
          onPressed: () {},
          child: const Text('Extra small'),
        ),
      ),
      VariantSample(
        label: 'Size · sm',
        code: '''
CairnButton(
  variant: CairnButtonVariant.destructive,
  size: CairnButtonSize.sm,
  onPressed: () {},
  child: const Text('Small'),
)''',
        child: CairnButton(
          variant: CairnButtonVariant.destructive,
          size: CairnButtonSize.sm,
          onPressed: () {},
          child: const Text('Small'),
        ),
      ),
      VariantSample(
        label: 'Size · md',
        code: '''
CairnButton(
  size: CairnButtonSize.md,
  onPressed: () {},
  child: const Text('Medium'),
)''',
        child: CairnButton(
          size: CairnButtonSize.md,
          onPressed: () {},
          child: const Text('Medium'),
        ),
      ),
      VariantSample(
        label: 'Size · lg',
        code: '''
CairnButton(
  size: CairnButtonSize.lg,
  onPressed: () {},
  child: const Text('Large'),
)''',
        child: CairnButton(
          size: CairnButtonSize.lg,
          onPressed: () {},
          child: const Text('Large'),
        ),
      ),
    ]),
  ]);

  /// Input with placeholder, error and disabled states.
  static VariantSet input(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Default',
        code: "const CairnInput(placeholder: 'name@example.com')",
        child: CairnInput(placeholder: 'name@example.com'),
      ),
      VariantSample(
        label: 'Error',
        code: '''
const CairnInput(
  placeholder: 'Invalid',
  hasError: true,
)''',
        child: CairnInput(placeholder: 'Invalid', hasError: true),
      ),
      VariantSample(
        label: 'Disabled',
        code: '''
const CairnInput(
  placeholder: 'Disabled',
  enabled: false,
)''',
        child: CairnInput(placeholder: 'Disabled', enabled: false),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s3,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 320,
  );

  /// An auto-growing textarea, resting and invalid.
  static VariantSet textarea(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Default',
        code: '''
const CairnTextarea(
  placeholder: 'Tell us a little about yourself...',
)''',
        child: CairnTextarea(placeholder: 'Tell us a little about yourself...'),
      ),
      VariantSample(
        label: 'Error',
        code: '''
const CairnTextarea(
  placeholder: 'Say a little more than that',
  hasError: true,
)''',
        child: CairnTextarea(
          placeholder: 'Say a little more than that',
          hasError: true,
        ),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s3,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 340,
  );

  /// A label in both enabled and disabled states.
  static VariantSet label(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Default',
        code: "const CairnLabel('Accept terms and conditions')",
        child: CairnLabel('Accept terms and conditions'),
      ),
      VariantSample(
        label: 'Disabled',
        code: "const CairnLabel('Disabled field', enabled: false)",
        child: CairnLabel('Disabled field', enabled: false),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s3,
  );

  /// A checked checkbox and an indeterminate one.
  static VariantSet checkbox(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Checked',
        code: '''
bool? _accepted = true;

Row(
  mainAxisSize: MainAxisSize.min,
  spacing: CairnSpacing.s2,
  children: <Widget>[
    CairnCheckbox(
      value: _accepted,
      onChanged: (bool? v) => setState(() => _accepted = v),
    ),
    const CairnLabel('Accept terms and conditions'),
  ],
)''',
        child: _CheckboxRow(
          label: 'Accept terms and conditions',
          initial: true,
        ),
      ),
      VariantSample(
        label: 'Indeterminate',
        code: '''
bool? _mixed;

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
)''',
        child: _CheckboxRow(
          label: 'Tristate (click through null)',
          tristate: true,
        ),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s3,
  );

  /// A switch at both sizes.
  static VariantSet switchToggle(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Default',
        code: '''
bool _notifications = true;

Row(
  mainAxisSize: MainAxisSize.min,
  spacing: CairnSpacing.s3,
  children: <Widget>[
    CairnSwitch(
      value: _notifications,
      semanticLabel: 'Notifications',
      onChanged: (bool v) => setState(() => _notifications = v),
    ),
    const CairnLabel('Email notifications'),
  ],
)''',
        child: _SwitchRow(label: 'Email notifications', initial: true),
      ),
      VariantSample(
        label: 'Small',
        code: '''
bool _compact = false;

Row(
  mainAxisSize: MainAxisSize.min,
  spacing: CairnSpacing.s3,
  children: <Widget>[
    CairnSwitch(
      value: _compact,
      size: CairnSwitchSize.sm,
      semanticLabel: 'Compact mode',
      onChanged: (bool v) => setState(() => _compact = v),
    ),
    const CairnLabel('Compact mode'),
  ],
)''',
        child: _SwitchRow(
          label: 'Compact mode',
          semanticLabel: 'Compact mode',
          size: CairnSwitchSize.sm,
        ),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s3,
  );

  /// A roving-focus radio group.
  static VariantSet radioGroup(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Plan picker',
        code: '''
String _plan = 'pro';

CairnRadioGroup<String>(
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
)''',
        child: _RadioGroupSample(),
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 260,
  );

  /// A continuous slider and a stepped one.
  static VariantSet slider(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Continuous',
        code: '''
double _volume = 0.6;

CairnSlider(
  value: _volume,
  semanticLabel: 'Volume',
  onChanged: (double v) => setState(() => _volume = v),
)''',
        child: _SliderSample(initial: 0.6, semanticLabel: 'Volume'),
      ),
      VariantSample(
        label: 'Stepped',
        code: '''
double _zoom = 0.4;

CairnSlider(
  value: _zoom,
  step: 0.1,
  semanticLabel: 'Zoom',
  onChanged: (double v) => setState(() => _zoom = v),
)''',
        child: _SliderSample(initial: 0.4, step: 0.1, semanticLabel: 'Zoom'),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s6,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 300,
  );

  /// A two-state toggle, in both variants.
  static VariantSet toggle(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Default',
          code: '''
bool _bold = false;

CairnToggle(
  value: _bold,
  onChanged: (bool v) => setState(() => _bold = v),
  child: const Text('Bold'),
)''',
          child: _ToggleSample(label: 'Bold'),
        ),
        VariantSample(
          label: 'Outline',
          code: '''
bool _italic = true;

CairnToggle(
  value: _italic,
  variant: CairnToggleVariant.outline,
  onChanged: (bool v) => setState(() => _italic = v),
  child: const Text('Italic'),
)''',
          child: _ToggleSample(
            label: 'Italic',
            variant: CairnToggleVariant.outline,
            initial: true,
          ),
        ),
      ]);

  /// Single- and multiple-select toggle groups.
  static VariantSet toggleGroup(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Single · outline',
        code: '''
Set<String> _alignment = <String>{'center'};

CairnToggleGroup<String>(
  values: _alignment,
  variant: CairnToggleVariant.outline,
  onChanged: (Set<String> v) => setState(() => _alignment = v),
  items: const <CairnToggleGroupItem<String>>[
    CairnToggleGroupItem<String>(value: 'left', child: Text('Left')),
    CairnToggleGroupItem<String>(value: 'center', child: Text('Center')),
    CairnToggleGroupItem<String>(value: 'right', child: Text('Right')),
  ],
)''',
        child: _ToggleGroupSample(
          initial: <String>{'center'},
          variant: CairnToggleVariant.outline,
          items: <CairnToggleGroupItem<String>>[
            CairnToggleGroupItem<String>(value: 'left', child: Text('Left')),
            CairnToggleGroupItem<String>(
              value: 'center',
              child: Text('Center'),
            ),
            CairnToggleGroupItem<String>(value: 'right', child: Text('Right')),
          ],
        ),
      ),
      VariantSample(
        label: 'Multiple',
        code: '''
Set<String> _marks = <String>{'bold'};

CairnToggleGroup<String>(
  values: _marks,
  type: CairnToggleGroupType.multiple,
  onChanged: (Set<String> v) => setState(() => _marks = v),
  items: const <CairnToggleGroupItem<String>>[
    CairnToggleGroupItem<String>(value: 'bold', child: Text('B')),
    CairnToggleGroupItem<String>(value: 'italic', child: Text('I')),
    CairnToggleGroupItem<String>(value: 'underline', child: Text('U')),
  ],
)''',
        child: _ToggleGroupSample(
          initial: <String>{'bold'},
          type: CairnToggleGroupType.multiple,
          items: <CairnToggleGroupItem<String>>[
            CairnToggleGroupItem<String>(value: 'bold', child: Text('B')),
            CairnToggleGroupItem<String>(value: 'italic', child: Text('I')),
            CairnToggleGroupItem<String>(value: 'underline', child: Text('U')),
          ],
        ),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s4,
  );

  /// A grouped one-time-code field, and an ungrouped one.
  static VariantSet inputOtp(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Six digits · 3 + 3',
        code: '''
CairnInputOtp(
  length: 6,
  groupSizes: const <int>[3, 3],
  onCompleted: (String code) => _verify(code),
)''',
        child: CairnInputOtp(length: 6, groupSizes: <int>[3, 3]),
      ),
      VariantSample(
        label: 'Four digits',
        code: '''
CairnInputOtp(
  length: 4,
  onCompleted: (String code) => _verify(code),
)''',
        child: CairnInputOtp(length: 4),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s4,
    width: 300,
  );

  /// Label, description and error text around a control.
  static VariantSet formField(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'With description',
        code: '''
const CairnFormField(
  label: 'Email',
  description: 'We will never share it.',
  child: CairnInput(placeholder: 'name@example.com'),
)''',
        child: CairnFormField(
          label: 'Email',
          description: 'We will never share it.',
          child: CairnInput(placeholder: 'name@example.com'),
        ),
      ),
      VariantSample(
        label: 'With error',
        code: '''
const CairnFormField(
  label: 'Username',
  error: 'That name is already taken.',
  child: CairnInput(hasError: true),
)''',
        child: CairnFormField(
          label: 'Username',
          error: 'That name is already taken.',
          child: CairnInput(hasError: true),
        ),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s4,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 340,
  );

  // ---------------------------------------------------------------------------
  // Display
  // ---------------------------------------------------------------------------

  /// Card with header, content and footer slots.
  static VariantSet card(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Header · content · footer',
          code: '''
CairnCard(
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
)''',
          child: CairnCard(
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
          ),
        ),
      ]);

  /// Every badge variant.
  static VariantSet badge(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Primary',
          code: "const CairnBadge(label: Text('Default'))",
          child: CairnBadge(label: Text('Default')),
        ),
        VariantSample(
          label: 'Secondary',
          code: '''
const CairnBadge(
  variant: CairnBadgeVariant.secondary,
  label: Text('Secondary'),
)''',
          child: CairnBadge(
            variant: CairnBadgeVariant.secondary,
            label: Text('Secondary'),
          ),
        ),
        VariantSample(
          label: 'Destructive',
          code: '''
const CairnBadge(
  variant: CairnBadgeVariant.destructive,
  label: Text('Destructive'),
)''',
          child: CairnBadge(
            variant: CairnBadgeVariant.destructive,
            label: Text('Destructive'),
          ),
        ),
        VariantSample(
          label: 'Outline',
          code: '''
const CairnBadge(
  variant: CairnBadgeVariant.outline,
  label: Text('Outline'),
)''',
          child: CairnBadge(
            variant: CairnBadgeVariant.outline,
            label: Text('Outline'),
          ),
        ),
        VariantSample(
          label: 'Ghost',
          code: '''
const CairnBadge(
  variant: CairnBadgeVariant.ghost,
  label: Text('Ghost'),
)''',
          child: CairnBadge(
            variant: CairnBadgeVariant.ghost,
            label: Text('Ghost'),
          ),
        ),
        VariantSample(
          label: 'With icon',
          code: '''
const CairnBadge(
  leading: CairnIcon(CairnIconData.check, size: 12),
  label: Text('Verified'),
)''',
          child: CairnBadge(
            leading: CairnIcon(CairnIconData.check, size: 12),
            label: Text('Verified'),
          ),
        ),
      ]);

  /// Avatars in three sizes plus a stacked group.
  static VariantSet avatar(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Small',
          code: '''
const CairnAvatar(
  size: CairnAvatarSize.sm,
  fallback: Text('RJ'),
)''',
          child: CairnAvatar(size: CairnAvatarSize.sm, fallback: Text('RJ')),
        ),
        VariantSample(
          label: 'Medium',
          code: "const CairnAvatar(fallback: Text('CA'))",
          child: CairnAvatar(fallback: Text('CA')),
        ),
        VariantSample(
          label: 'Large',
          code: '''
const CairnAvatar(
  size: CairnAvatarSize.lg,
  fallback: Text('UI'),
)''',
          child: CairnAvatar(size: CairnAvatarSize.lg, fallback: Text('UI')),
        ),
        VariantSample(
          label: 'Group',
          code: '''
const CairnAvatarGroup(
  children: <Widget>[
    CairnAvatar(fallback: Text('A')),
    CairnAvatar(fallback: Text('B')),
    CairnAvatar(fallback: Text('+7')),
  ],
)''',
          child: CairnAvatarGroup(
            children: <Widget>[
              CairnAvatar(fallback: Text('A')),
              CairnAvatar(fallback: Text('B')),
              CairnAvatar(fallback: Text('+7')),
            ],
          ),
        ),
      ], spacing: CairnSpacing.s4);

  /// Alert, default and destructive.
  static VariantSet alert(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Default',
        code: '''
const CairnAlert(
  icon: CairnIcon(CairnIconData.info),
  title: Text('Heads up'),
  description: Text('Your trial ends in three days.'),
)''',
        child: CairnAlert(
          icon: CairnIcon(CairnIconData.info),
          title: Text('Heads up'),
          description: Text('Your trial ends in three days.'),
        ),
      ),
      VariantSample(
        label: 'Destructive',
        code: '''
const CairnAlert(
  variant: CairnAlertVariant.destructive,
  icon: CairnIcon(CairnIconData.alert),
  title: Text('Payment failed'),
  description: Text('Update your billing details to continue.'),
)''',
        child: CairnAlert(
          variant: CairnAlertVariant.destructive,
          icon: CairnIcon(CairnIconData.alert),
          title: Text('Payment failed'),
          description: Text('Update your billing details to continue.'),
        ),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s3,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 420,
  );

  /// Horizontal and vertical rules.
  static VariantSet separator(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Horizontal',
        code: '''
const Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: CairnSpacing.s4,
  children: <Widget>[
    Text('Cairn UI'),
    CairnSeparator(),
  ],
)''',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: CairnSpacing.s4,
          children: <Widget>[Text('Cairn UI'), CairnSeparator()],
        ),
      ),
      VariantSample(
        label: 'Vertical',
        code: '''
const SizedBox(
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
)''',
        child: SizedBox(
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
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s4,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 300,
  );

  /// A loading placeholder.
  static VariantSet skeleton(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Circle',
        code: 'const CairnSkeleton.circle(size: 44)',
        child: CairnSkeleton.circle(size: 44),
      ),
      VariantSample(
        label: 'Text lines',
        code: '''
const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: CairnSpacing.s2,
  children: <Widget>[
    CairnSkeleton(width: 220, height: 12),
    CairnSkeleton(width: 160, height: 12),
  ],
)''',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: CairnSpacing.s2,
          children: <Widget>[
            CairnSkeleton(width: 220, height: 12),
            CairnSkeleton(width: 160, height: 12),
          ],
        ),
      ),
    ],
    layout: VariantLayout.row,
    spacing: CairnSpacing.s4,
    crossAxisAlignment: CrossAxisAlignment.center,
  );

  /// Three spinner sizes.
  static VariantSet spinner(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: '16px (default)',
        code: 'const CairnSpinner()',
        child: CairnSpinner(),
      ),
      VariantSample(
        label: '24px',
        code: 'const CairnSpinner(size: 24)',
        child: CairnSpinner(size: 24),
      ),
      VariantSample(
        label: '32px · 3px stroke',
        code: 'const CairnSpinner(size: 32, strokeWidth: 3)',
        child: CairnSpinner(size: 32, strokeWidth: 3),
      ),
    ],
    layout: VariantLayout.row,
    spacing: CairnSpacing.s5,
    crossAxisAlignment: CrossAxisAlignment.center,
  );

  /// Keyboard hints, single and grouped.
  static VariantSet kbd(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Single key',
          code: "const CairnKbd('Esc')",
          child: CairnKbd('Esc'),
        ),
        VariantSample(
          label: 'Two-key group',
          code: "const CairnKbdGroup(keys: <String>['Ctrl', 'K'])",
          child: CairnKbdGroup(keys: <String>['Ctrl', 'K']),
        ),
        VariantSample(
          label: 'Three-key group',
          code: "const CairnKbdGroup(keys: <String>['Shift', 'Alt', 'D'])",
          child: CairnKbdGroup(keys: <String>['Shift', 'Alt', 'D']),
        ),
      ], spacing: CairnSpacing.s4);

  /// Aspect Ratio, at 16:9 and 1:1.
  static VariantSet aspectRatio(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    Widget box(String caption) => DecoratedBox(
      decoration: BoxDecoration(
        color: theme.muted,
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: Center(child: Text(caption)),
    );

    return VariantSet.one(<VariantSample>[
      VariantSample(
        label: '16 : 9',
        code: '''
SizedBox(
  width: 280,
  child: CairnAspectRatio(
    ratio: 16 / 9,
    child: Image.network(url, fit: BoxFit.cover),
  ),
)''',
        child: SizedBox(
          width: 280,
          child: CairnAspectRatio(ratio: 16 / 9, child: box('16 : 9')),
        ),
      ),
      VariantSample(
        label: '1 : 1',
        code: '''
SizedBox(
  width: 160,
  child: CairnAspectRatio(
    ratio: 1,
    child: Image.network(url, fit: BoxFit.cover),
  ),
)''',
        child: SizedBox(
          width: 160,
          child: CairnAspectRatio(ratio: 1, child: box('1 : 1')),
        ),
      ),
    ], spacing: CairnSpacing.s5);
  }

  /// The empty state, with its hand-painted dashed border.
  static VariantSet empty(BuildContext context) => VariantSet.one(
    <VariantSample>[
      VariantSample(
        label: 'No results',
        code: '''
CairnEmpty(
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
)''',
        child: CairnEmpty(
          media: const CairnIcon(CairnIconData.search, size: 32),
          title: 'No results',
          description:
              'Try adjusting your filters, or clear them to start over.',
          actions: <Widget>[
            CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: () {},
              child: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 400,
  );

  /// A static table with a caption.
  static VariantSet table(BuildContext context) => VariantSet.one(
    <VariantSample>[
      VariantSample(
        label: 'Invoices',
        code: r'''
class Invoice {
  const Invoice(this.id, this.status, this.amount);
  final String id;
  final String status;
  final String amount;
}

CairnTable<Invoice>(
  caption: const Text('A list of recent invoices.'),
  rows: const <Invoice>[
    Invoice('INV001', 'Paid', r'$250.00'),
    Invoice('INV002', 'Pending', r'$150.00'),
    Invoice('INV003', 'Unpaid', r'$350.00'),
  ],
  columns: <CairnColumn<Invoice>>[
    CairnColumn<Invoice>(
      label: 'Invoice',
      cell: (Invoice i) => Text(i.id),
    ),
    CairnColumn<Invoice>(
      label: 'Status',
      cell: (Invoice i) => CairnBadge(
        variant: i.status == 'Paid'
            ? CairnBadgeVariant.primary
            : CairnBadgeVariant.secondary,
        label: Text(i.status),
      ),
    ),
    CairnColumn<Invoice>(
      label: 'Amount',
      alignment: Alignment.centerRight,
      cell: (Invoice i) => Text(i.amount),
    ),
  ],
)''',
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
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 460,
  );

  // ---------------------------------------------------------------------------
  // Overlays
  // ---------------------------------------------------------------------------

  /// A modal dialog with a form inside.
  static VariantSet dialog(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Edit profile',
          code: '''
CairnButton(
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
)''',
          child: CairnButton(
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
          ),
        ),
      ]);

  /// Alert Dialog, opened from a trigger.
  static VariantSet alertDialog(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Confirm deletion',
          code: '''
CairnButton(
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
)''',
          child: CairnButton(
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
          ),
        ),
      ]);

  /// A sheet from each of the four edges.
  static VariantSet sheet(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        for (final CairnSheetSide side in CairnSheetSide.values)
          VariantSample(
            label: 'From ${side.name}',
            code: _sheetCode(side),
            child: CairnButton(
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
          ),
      ]);

  static String _sheetCode(CairnSheetSide side) =>
      '''
CairnButton(
  variant: CairnButtonVariant.outline,
  size: CairnButtonSize.sm,
  onPressed: () => showCairnSheet<void>(
    context: context,
    side: CairnSheetSide.${side.name},
    builder: (BuildContext context) => CairnSheet(
      side: CairnSheetSide.${side.name},
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
  child: const Text('${side.name}'),
)''';

  /// A bottom sheet with a grab handle.
  static VariantSet drawer(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Move goal',
          code: '''
CairnButton(
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
)''',
          child: CairnButton(
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
          ),
        ),
      ]);

  /// An anchored popover.
  static VariantSet popover(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Dimensions',
          code: '''
final CairnOverlayController _controller = CairnOverlayController();

CairnPopover(
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
)''',
          child: _PopoverSample(),
        ),
      ]);

  /// A tooltip that opens on hover and on keyboard focus.
  static VariantSet tooltip(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Top (default)',
          code: '''
CairnTooltip(
  message: 'Copy to clipboard',
  openDelay: const Duration(milliseconds: 250),
  child: CairnButton(
    variant: CairnButtonVariant.outline,
    onPressed: () {},
    child: const Text('Hover or tab to me'),
  ),
)''',
          child: CairnTooltip(
            message: 'Copy to clipboard',
            openDelay: const Duration(milliseconds: 250),
            child: CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: () {},
              child: const Text('Hover or tab to me'),
            ),
          ),
        ),
        VariantSample(
          label: 'Right side',
          code: '''
CairnTooltip(
  message: 'Opens to the right',
  side: CairnSide.right,
  openDelay: const Duration(milliseconds: 250),
  child: CairnButton.icon(
    icon: const CairnIcon(CairnIconData.info),
    semanticLabel: 'About',
    variant: CairnButtonVariant.ghost,
    onPressed: () {},
  ),
)''',
          child: CairnTooltip(
            message: 'Opens to the right',
            side: CairnSide.right,
            openDelay: const Duration(milliseconds: 250),
            child: CairnButton.icon(
              icon: const CairnIcon(CairnIconData.info),
              semanticLabel: 'About',
              variant: CairnButtonVariant.ghost,
              onPressed: () {},
            ),
          ),
        ),
      ], spacing: CairnSpacing.s3);

  /// A hover card with a grace period on both edges.
  static VariantSet hoverCard(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Profile preview',
          code: '''
CairnHoverCard(
  openDelay: const Duration(milliseconds: 250),
  content: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: CairnSpacing.s2,
    children: <Widget>[
      CairnAvatar(fallback: Text('CA')),
      Text('Cairn UI'),
      Text('A modern, accessible component library for Flutter.'),
    ],
  ),
  child: CairnButton(
    variant: CairnButtonVariant.link,
    onPressed: () {},
    child: const Text('@cairn_ui'),
  ),
)''',
          child: CairnHoverCard(
            openDelay: const Duration(milliseconds: 250),
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CairnSpacing.s2,
              children: <Widget>[
                CairnAvatar(fallback: Text('CA')),
                Text('Cairn UI'),
                Text('A modern, accessible component library for Flutter.'),
              ],
            ),
            child: CairnButton(
              variant: CairnButtonVariant.link,
              onPressed: () {},
              child: const Text('@cairn_ui'),
            ),
          ),
        ),
      ]);

  /// A dropdown menu with labels, shortcuts and a destructive item.
  static VariantSet dropdownMenu(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'My account',
          code: '''
final CairnOverlayController _controller = CairnOverlayController();

CairnDropdownMenu(
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
)''',
          child: _DropdownMenuSample(),
        ),
      ]);

  /// A right-click / long-press target.
  static VariantSet contextMenu(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return VariantSet.one(<VariantSample>[
      VariantSample(
        label: 'Right-click target',
        code: '''
CairnContextMenu(
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
)''',
        child: CairnContextMenu(
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
        ),
      ),
    ]);
  }

  /// The raw menu primitives, rendered inline.
  static VariantSet menu(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Appearance panel',
          code: '''
bool _statusBar = true;
bool _activityBar = false;

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
)''',
          child: _MenuSample(),
        ),
      ]);

  /// A select whose menu matches the trigger width, at both sizes.
  static VariantSet select(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Default',
        code: '''
String? _framework;

CairnSelect<String>(
  value: _framework,
  width: 260,
  placeholder: 'Select a framework',
  options: const <CairnSelectOption<String>>[
    CairnSelectOption<String>(value: 'flutter', label: 'Flutter'),
    CairnSelectOption<String>(value: 'react', label: 'React'),
    CairnSelectOption<String>(value: 'svelte', label: 'Svelte'),
    CairnSelectOption<String>(value: 'vue', label: 'Vue'),
    CairnSelectOption<String>(
      value: 'ember',
      label: 'Ember (unavailable)',
      enabled: false,
    ),
  ],
  onChanged: (String v) => setState(() => _framework = v),
)''',
        child: _SelectSample(width: 260),
      ),
      VariantSample(
        label: 'Small',
        code: '''
String? _framework;

CairnSelect<String>(
  value: _framework,
  size: CairnSelectSize.sm,
  width: 220,
  placeholder: 'Select a framework',
  options: frameworks,
  onChanged: (String v) => setState(() => _framework = v),
)''',
        child: _SelectSample(width: 220, size: CairnSelectSize.sm),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s4,
  );

  /// A searchable select.
  static VariantSet combobox(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Framework picker',
          code: '''
String? _value;

CairnCombobox<String>(
  value: _value,
  placeholder: 'Select a framework',
  searchPlaceholder: 'Search frameworks...',
  options: const <CairnSelectOption<String>>[
    CairnSelectOption<String>(value: 'flutter', label: 'Flutter'),
    CairnSelectOption<String>(value: 'react', label: 'React'),
    CairnSelectOption<String>(value: 'svelte', label: 'Svelte'),
    CairnSelectOption<String>(value: 'vue', label: 'Vue'),
    CairnSelectOption<String>(
      value: 'ember',
      label: 'Ember (unavailable)',
      enabled: false,
    ),
  ],
  onChanged: (String v) => setState(() => _value = v),
)''',
          child: _ComboboxSample(),
        ),
      ]);

  /// The command palette, inline rather than in a route.
  static VariantSet command(BuildContext context) => VariantSet.one(
    <VariantSample>[
      VariantSample(
        label: 'Inline palette',
        code: '''
CairnSurface(
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
)''',
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
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 380,
  );

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  /// Filled and line tab variants.
  static VariantSet tabs(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Filled',
        code: '''
String _tab = 'account';

CairnTabs<String>(
  value: _tab,
  onChanged: (String v) => setState(() => _tab = v),
  tabs: const <CairnTab<String>>[
    CairnTab<String>(value: 'account', label: Text('Account')),
    CairnTab<String>(value: 'password', label: Text('Password')),
    CairnTab<String>(value: 'team', label: Text('Team')),
  ],
)''',
        child: _TabsSample(
          initial: 'account',
          tabs: <CairnTab<String>>[
            CairnTab<String>(value: 'account', label: Text('Account')),
            CairnTab<String>(value: 'password', label: Text('Password')),
            CairnTab<String>(value: 'team', label: Text('Team')),
          ],
        ),
      ),
      VariantSample(
        label: 'Line',
        code: '''
String _tab = 'overview';

CairnTabs<String>(
  value: _tab,
  variant: CairnTabsVariant.line,
  onChanged: (String v) => setState(() => _tab = v),
  tabs: const <CairnTab<String>>[
    CairnTab<String>(value: 'overview', label: Text('Overview')),
    CairnTab<String>(value: 'analytics', label: Text('Analytics')),
    CairnTab<String>(value: 'reports', label: Text('Reports')),
  ],
)''',
        child: _TabsSample(
          initial: 'overview',
          variant: CairnTabsVariant.line,
          tabs: <CairnTab<String>>[
            CairnTab<String>(value: 'overview', label: Text('Overview')),
            CairnTab<String>(value: 'analytics', label: Text('Analytics')),
            CairnTab<String>(value: 'reports', label: Text('Reports')),
          ],
        ),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s5,
  );

  /// Accordion, with one section open.
  static VariantSet accordion(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Single, one open',
        code: '''
Set<String> _open = <String>{'a'};

CairnAccordion(
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
        'Every value comes from a token, down to the 2px chevron nudge.',
      ),
    ),
    CairnAccordionItem(
      value: 'c',
      title: Text('Is it animated?'),
      content: Text(
        'The body animates over 200ms on Tailwind\\'s default easing.',
      ),
    ),
  ],
)''',
        child: _AccordionSample(),
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 420,
  );

  /// A disclosure with a chevron trigger.
  static VariantSet collapsible(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Starred repositories',
        code: '''
bool _open = true;

CairnCollapsible(
  open: _open,
  onToggle: () => setState(() => _open = !_open),
  trigger: Padding(
    padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s2),
    child: Row(
      children: <Widget>[
        const Expanded(child: Text('Starred repositories')),
        CairnIcon(
          _open ? CairnIconData.chevronUp : CairnIconData.chevronDown,
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
)''',
        child: _CollapsibleSample(),
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 360,
  );

  /// Breadcrumb with a current-page crumb, and the ellipsis form.
  static VariantSet breadcrumb(BuildContext context) => VariantSet.one(
    <VariantSample>[
      VariantSample(
        label: 'Trail',
        code: '''
CairnBreadcrumb(
  crumbs: <CairnCrumb>[
    CairnCrumb(label: 'Home', onTap: () {}),
    CairnCrumb(label: 'Components', onTap: () {}),
    const CairnCrumb.current(label: 'Breadcrumb'),
  ],
)''',
        child: CairnBreadcrumb(
          crumbs: <CairnCrumb>[
            CairnCrumb(label: 'Home', onTap: () {}),
            CairnCrumb(label: 'Components', onTap: () {}),
            const CairnCrumb.current(label: 'Breadcrumb'),
          ],
        ),
      ),
      const VariantSample(
        label: 'Ellipsis',
        code: 'const CairnBreadcrumbEllipsis()',
        child: CairnBreadcrumbEllipsis(),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s2,
    width: 340,
  );

  /// A windowed page range with ellipses.
  static VariantSet pagination(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Page 4 of 12',
        code: '''
int _page = 4;

CairnPagination(
  page: _page,
  pageCount: 12,
  onChanged: (int p) => setState(() => _page = p),
)''',
        child: _PaginationSample(),
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 520,
  );

  /// A desktop-style menu bar.
  static VariantSet menubar(BuildContext context) => VariantSet.one(
    <VariantSample>[
      VariantSample(
        label: 'File · Edit · View',
        code: '''
CairnMenubar(
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
)''',
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
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 300,
  );

  /// A navigation menu with an arbitrary panel.
  static VariantSet navigationMenu(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return VariantSet.one(
      <VariantSample>[
        VariantSample(
          label: 'Getting started',
          code: '''
CairnNavigationMenu(
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
              'Sixty-five components on one token layer, in Flutter.',
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
)''',
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
                        'Sixty-five components on one token layer, in Flutter.',
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
        ),
      ],
      layout: VariantLayout.column,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      width: 420,
    );
  }

  /// A scroll area with an always-visible thumb.
  static VariantSet scrollArea(BuildContext context) => VariantSet.one(
    <VariantSample>[
      VariantSample(
        label: 'Vertical, always visible',
        code: '''
CairnScrollArea(
  height: 160,
  alwaysVisible: true,
  padding: const EdgeInsets.only(right: CairnSpacing.s4),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      for (int i = 1; i <= 18; i++) ...<Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s2),
          child: Text('Tag \$i'),
        ),
        if (i != 18) const CairnSeparator(),
      ],
    ],
  ),
)''',
        child: CairnScrollArea(
          height: 160,
          alwaysVisible: true,
          padding: const EdgeInsets.only(right: CairnSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 1; i <= 18; i++) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: CairnSpacing.s2,
                  ),
                  child: Text('Tag $i'),
                ),
                if (i != 18) const CairnSeparator(),
              ],
            ],
          ),
        ),
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 300,
  );

  /// A five-slide carousel.
  static VariantSet carousel(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return VariantSet.one(
      <VariantSample>[
        VariantSample(
          label: 'Five slides',
          code: '''
CairnCarousel(
  height: 150,
  items: <Widget>[
    for (int i = 1; i <= 5; i++)
      DecoratedBox(
        decoration: BoxDecoration(
          color: theme.muted,
          borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        ),
        child: Center(child: Text('\$i')),
      ),
  ],
)''',
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
        ),
      ],
      layout: VariantLayout.column,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      width: 380,
    );
  }

  // ---------------------------------------------------------------------------
  // Data & feedback
  // ---------------------------------------------------------------------------

  /// Determinate and indeterminate progress.
  static VariantSet progress(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'Determinate',
        code: "const CairnProgress(value: 0.62, semanticLabel: 'Upload')",
        child: CairnProgress(value: 0.62, semanticLabel: 'Upload'),
      ),
      VariantSample(
        label: 'Indeterminate',
        code: "const CairnProgress(semanticLabel: 'Working')",
        child: CairnProgress(semanticLabel: 'Working'),
      ),
    ],
    layout: VariantLayout.column,
    spacing: CairnSpacing.s6,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 320,
  );

  /// Toasts in each variant.
  static VariantSet toast(BuildContext context) =>
      VariantSet.one(<VariantSample>[
        VariantSample(
          label: 'Default',
          code: '''
// CairnToaster is installed once, in MaterialApp.builder:
//   builder: (context, child) => CairnToaster(child: child!),

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
)''',
          child: CairnButton(
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
        ),
        VariantSample(
          label: 'Success',
          code: '''
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
)''',
          child: CairnButton(
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
        ),
        VariantSample(
          label: 'Error',
          code: '''
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
)''',
          child: CairnButton(
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
        ),
        VariantSample(
          label: 'With action',
          code: '''
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
)''',
          child: CairnButton(
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
        ),
      ]);

  /// A sortable, filterable, paginated table.
  static VariantSet dataTable(BuildContext context) => VariantSet.one(
    <VariantSample>[
      VariantSample(
        label: 'Payments',
        code: r'''
class Payment {
  const Payment(this.email, this.status, this.amount);
  final String email;
  final String status;
  final double amount;
}

CairnDataTable<Payment>(
  rows: payments,
  pageSize: 4,
  searchBy: (Payment p) => p.email,
  searchPlaceholder: 'Filter emails...',
  columns: <CairnColumn<Payment>>[
    CairnColumn<Payment>(
      label: 'Email',
      flex: 3,
      cell: (Payment p) => Text(p.email),
      sortKey: (Payment p) => p.email,
    ),
    CairnColumn<Payment>(
      label: 'Status',
      flex: 2,
      cell: (Payment p) => CairnBadge(
        variant: switch (p.status) {
          'Success' => CairnBadgeVariant.primary,
          'Failed' => CairnBadgeVariant.destructive,
          _ => CairnBadgeVariant.secondary,
        },
        label: Text(p.status),
      ),
      sortKey: (Payment p) => p.status,
    ),
    CairnColumn<Payment>(
      label: 'Amount',
      flex: 2,
      alignment: Alignment.centerRight,
      cell: (Payment p) => Text('\$${p.amount.toStringAsFixed(2)}'),
      sortKey: (Payment p) => p.amount,
    ),
  ],
)''',
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
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 560,
  );

  /// A month grid with a selected day.
  static VariantSet calendar(BuildContext context) => VariantSet.one(
    const <VariantSample>[
      VariantSample(
        label: 'September 2026',
        code: '''
DateTime? _selected = DateTime(2026, 9, 11);

CairnCalendar(
  selected: _selected,
  initialMonth: DateTime(2026, 9),
  onChanged: (DateTime d) => setState(() => _selected = d),
)''',
        child: _CalendarSample(),
      ),
    ],
    layout: VariantLayout.column,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    width: 280,
  );

  /// A calendar in a popover.
  static VariantSet datePicker(BuildContext context) =>
      VariantSet.one(const <VariantSample>[
        VariantSample(
          label: 'Pick a date',
          code: '''
DateTime? _date;

CairnDatePicker(
  value: _date,
  onChanged: (DateTime d) => setState(() => _date = d),
)''',
          child: _DatePickerSample(),
        ),
      ]);
}

// ---------------------------------------------------------------------------
// Per-variant stateful samples
// ---------------------------------------------------------------------------
//
// One small widget per *instance*, not per component. Two checkboxes in the
// same preview must not share a value, and each one's snippet has to be
// truthful about the single piece of state it actually needs.

class _CheckboxRow extends StatefulWidget {
  const _CheckboxRow({
    required this.label,
    this.tristate = false,
    this.initial,
  });

  final String label;
  final bool tristate;
  final bool? initial;

  @override
  State<_CheckboxRow> createState() => _CheckboxRowState();
}

class _CheckboxRowState extends State<_CheckboxRow> {
  bool? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: CairnSpacing.s2,
    children: <Widget>[
      CairnCheckbox(
        value: _value,
        tristate: widget.tristate,
        onChanged: (bool? v) => setState(() => _value = v),
      ),
      CairnLabel(widget.label),
    ],
  );
}

class _SwitchRow extends StatefulWidget {
  const _SwitchRow({
    required this.label,
    this.semanticLabel = 'Notifications',
    this.size = CairnSwitchSize.md,
    this.initial = false,
  });

  final String label;
  final String semanticLabel;
  final CairnSwitchSize size;
  final bool initial;

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: CairnSpacing.s3,
    children: <Widget>[
      CairnSwitch(
        value: _value,
        size: widget.size,
        semanticLabel: widget.semanticLabel,
        onChanged: (bool v) => setState(() => _value = v),
      ),
      CairnLabel(widget.label),
    ],
  );
}

class _RadioGroupSample extends StatefulWidget {
  const _RadioGroupSample();

  @override
  State<_RadioGroupSample> createState() => _RadioGroupSampleState();
}

class _RadioGroupSampleState extends State<_RadioGroupSample> {
  String _plan = 'pro';

  @override
  Widget build(BuildContext context) => CairnRadioGroup<String>(
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
  );
}

class _SliderSample extends StatefulWidget {
  const _SliderSample({
    required this.initial,
    required this.semanticLabel,
    this.step,
  });

  final double initial;
  final String semanticLabel;
  final double? step;

  @override
  State<_SliderSample> createState() => _SliderSampleState();
}

class _SliderSampleState extends State<_SliderSample> {
  late double _value = widget.initial;

  @override
  Widget build(BuildContext context) => CairnSlider(
    value: _value,
    step: widget.step,
    semanticLabel: widget.semanticLabel,
    onChanged: (double v) => setState(() => _value = v),
  );
}

class _ToggleSample extends StatefulWidget {
  const _ToggleSample({
    required this.label,
    this.variant = CairnToggleVariant.normal,
    this.initial = false,
  });

  final String label;
  final CairnToggleVariant variant;
  final bool initial;

  @override
  State<_ToggleSample> createState() => _ToggleSampleState();
}

class _ToggleSampleState extends State<_ToggleSample> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) => CairnToggle(
    value: _value,
    variant: widget.variant,
    onChanged: (bool v) => setState(() => _value = v),
    child: Text(widget.label),
  );
}

class _ToggleGroupSample extends StatefulWidget {
  const _ToggleGroupSample({
    required this.initial,
    required this.items,
    this.type = CairnToggleGroupType.single,
    this.variant = CairnToggleVariant.normal,
  });

  final Set<String> initial;
  final List<CairnToggleGroupItem<String>> items;
  final CairnToggleGroupType type;
  final CairnToggleVariant variant;

  @override
  State<_ToggleGroupSample> createState() => _ToggleGroupSampleState();
}

class _ToggleGroupSampleState extends State<_ToggleGroupSample> {
  late Set<String> _values = <String>{...widget.initial};

  @override
  Widget build(BuildContext context) => CairnToggleGroup<String>(
    values: _values,
    type: widget.type,
    variant: widget.variant,
    onChanged: (Set<String> v) => setState(() => _values = v),
    items: widget.items,
  );
}

class _SelectSample extends StatefulWidget {
  const _SelectSample({required this.width, this.size = CairnSelectSize.md});

  final double width;
  final CairnSelectSize size;

  @override
  State<_SelectSample> createState() => _SelectSampleState();
}

class _SelectSampleState extends State<_SelectSample> {
  String? _value;

  @override
  Widget build(BuildContext context) => CairnSelect<String>(
    value: _value,
    size: widget.size,
    width: widget.width,
    placeholder: 'Select a framework',
    options: _frameworks,
    onChanged: (String v) => setState(() => _value = v),
  );
}

class _ComboboxSample extends StatefulWidget {
  const _ComboboxSample();

  @override
  State<_ComboboxSample> createState() => _ComboboxSampleState();
}

class _ComboboxSampleState extends State<_ComboboxSample> {
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

class _TabsSample extends StatefulWidget {
  const _TabsSample({
    required this.initial,
    required this.tabs,
    this.variant = CairnTabsVariant.filled,
  });

  final String initial;
  final List<CairnTab<String>> tabs;
  final CairnTabsVariant variant;

  @override
  State<_TabsSample> createState() => _TabsSampleState();
}

class _TabsSampleState extends State<_TabsSample> {
  late String _value = widget.initial;

  @override
  Widget build(BuildContext context) => CairnTabs<String>(
    value: _value,
    variant: widget.variant,
    onChanged: (String v) => setState(() => _value = v),
    tabs: widget.tabs,
  );
}

class _AccordionSample extends StatefulWidget {
  const _AccordionSample();

  @override
  State<_AccordionSample> createState() => _AccordionSampleState();
}

class _AccordionSampleState extends State<_AccordionSample> {
  Set<String> _open = <String>{'a'};

  @override
  Widget build(BuildContext context) => CairnAccordion(
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
          'Every value comes from a token, down to the 2px chevron nudge.',
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
  );
}

class _CollapsibleSample extends StatefulWidget {
  const _CollapsibleSample();

  @override
  State<_CollapsibleSample> createState() => _CollapsibleSampleState();
}

class _CollapsibleSampleState extends State<_CollapsibleSample> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnCollapsible(
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
    );
  }
}

class _PaginationSample extends StatefulWidget {
  const _PaginationSample();

  @override
  State<_PaginationSample> createState() => _PaginationSampleState();
}

class _PaginationSampleState extends State<_PaginationSample> {
  int _page = 4;

  @override
  Widget build(BuildContext context) => CairnPagination(
    page: _page,
    pageCount: 12,
    onChanged: (int p) => setState(() => _page = p),
  );
}

class _PopoverSample extends StatefulWidget {
  const _PopoverSample();

  @override
  State<_PopoverSample> createState() => _PopoverSampleState();
}

class _PopoverSampleState extends State<_PopoverSample> {
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

class _DropdownMenuSample extends StatefulWidget {
  const _DropdownMenuSample();

  @override
  State<_DropdownMenuSample> createState() => _DropdownMenuSampleState();
}

class _DropdownMenuSampleState extends State<_DropdownMenuSample> {
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

class _MenuSample extends StatefulWidget {
  const _MenuSample();

  @override
  State<_MenuSample> createState() => _MenuSampleState();
}

class _MenuSampleState extends State<_MenuSample> {
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

class _CalendarSample extends StatefulWidget {
  const _CalendarSample();

  @override
  State<_CalendarSample> createState() => _CalendarSampleState();
}

class _CalendarSampleState extends State<_CalendarSample> {
  DateTime? _selected = DateTime(2026, 9, 11);

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    // The calendar grid is seven fixed-width cells wide, but its caption row
    // uses an Expanded, so it needs bounded width to lay out at all.
    return DecoratedBox(
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
    );
  }
}

class _DatePickerSample extends StatefulWidget {
  const _DatePickerSample();

  @override
  State<_DatePickerSample> createState() => _DatePickerSampleState();
}

class _DatePickerSampleState extends State<_DatePickerSample> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) => CairnDatePicker(
    value: _value,
    onChanged: (DateTime d) => setState(() => _value = d),
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
