/// Form controls. Each one is a labelled, accessible, no-JS-required field:
/// the `<label>` is tied to the control with `for`/`id`, an error is tied to
/// the control with `aria-describedby` + `aria-invalid`, and error text is
/// plain server-rendered markup.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../theme/tokens.dart';
import 'html.dart';

String _id(String name, String? prefix) => '${prefix ?? 'f'}-$name';

class TextField extends StatelessComponent {
  const TextField({
    required this.name,
    required this.label,
    this.value = '',
    this.type = 'text',
    this.error,
    this.hint,
    this.autocomplete,
    this.inputMode,
    this.required = false,
    this.placeholder,
    this.maxLength,
    this.idPrefix,
    this.classes,
    super.key,
  });

  final String name;
  final String label;
  final String value;
  final String type;
  final String? error;
  final String? hint;
  final String? autocomplete;
  final String? inputMode;
  final bool required;
  final String? placeholder;
  final int? maxLength;
  final String? idPrefix;
  final String? classes;

  @override
  Component build(BuildContext context) {
    final id = _id(name, idPrefix);
    final describedBy = [if (hint != null) '$id-hint', if (error != null) '$id-error'].join(' ');
    return div(classes: cx(['field', if (error != null) 'field--invalid', classes]), [
      el(
        'label',
        classes: 'label',
        attrs: {'for': id},
        children: [
          Component.text(label),
          if (required) span(classes: 'label__req', attributes: const {'aria-hidden': 'true'}, [Component.text(' *')]),
        ],
      ),
      el(
        'input',
        classes: 'input',
        id: id,
        attrs: {
          'type': type,
          'name': name,
          'value': value,
          if (required) 'required': '',
          'autocomplete': ?autocomplete,
          'inputmode': ?inputMode,
          'placeholder': ?placeholder,
          if (maxLength != null) 'maxlength': '$maxLength',
          if (error != null) 'aria-invalid': 'true',
          if (describedBy.isNotEmpty) 'aria-describedby': describedBy,
        },
      ),
      if (hint != null) p(id: '$id-hint', classes: 'field__hint', [Component.text(hint!)]),
      if (error != null) FieldError(id: '$id-error', message: error!),
    ]);
  }
}

class FieldError extends StatelessComponent {
  const FieldError({required this.id, required this.message, super.key});
  final String id;
  final String message;

  @override
  Component build(BuildContext context) {
    // role=alert makes screen readers announce the message when it appears
    // (the page is re-rendered by the server with the error already in place).
    return p(id: id, classes: 'field__error', attributes: const {'role': 'alert'}, [Component.text(message)]);
  }
}

class SelectField extends StatelessComponent {
  const SelectField({
    required this.name,
    required this.label,
    required this.options,
    this.value,
    this.error,
    this.autocomplete,
    this.idPrefix,
    this.classes,
    this.hideLabel = false,
    this.autoSubmit = false,
    super.key,
  });

  final String name;
  final String label;

  /// value -> label
  final Map<String, String> options;
  final String? value;
  final String? error;
  final String? autocomplete;
  final String? idPrefix;
  final String? classes;
  final bool hideLabel;
  final bool autoSubmit;

  @override
  Component build(BuildContext context) {
    final id = _id(name, idPrefix);
    return div(classes: cx(['field', if (error != null) 'field--invalid', classes]), [
      el(
        'label',
        classes: cx(['label', if (hideLabel) 'sr-only']),
        attrs: {'for': id},
        children: [Component.text(label)],
      ),
      div(classes: 'select-wrap', [
        el(
          'select',
          classes: 'select',
          id: id,
          attrs: {
            'name': name,
            'autocomplete': ?autocomplete,
            if (error != null) 'aria-invalid': 'true',
            if (error != null) 'aria-describedby': '$id-error',
          },
          children: [
            for (final e in options.entries)
              el(
                'option',
                attrs: {'value': e.key, if (e.key == value) 'selected': ''},
                children: [Component.text(e.value)],
              ),
          ],
        ),
        el(
          'span',
          classes: 'select-wrap__chevron',
          attrs: {'aria-hidden': 'true'},
          children: [
            RawText(
              '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>',
            ),
          ],
        ),
      ]),
      if (error != null) FieldError(id: '$id-error', message: error!),
    ]);
  }
}

class CheckboxField extends StatelessComponent {
  const CheckboxField({
    required this.name,
    required this.label,
    this.checked = false,
    this.error,
    this.idPrefix,
    super.key,
  });
  final String name;
  final Component label;
  final bool checked;
  final String? error;
  final String? idPrefix;

  @override
  Component build(BuildContext context) {
    final id = _id(name, idPrefix);
    return div(classes: cx(['field', if (error != null) 'field--invalid']), [
      el(
        'label',
        classes: 'check',
        attrs: {'for': id},
        children: [
          el(
            'input',
            id: id,
            classes: 'check__input',
            attrs: {
              'type': 'checkbox',
              'name': name,
              'value': 'on',
              if (checked) 'checked': '',
              if (error != null) 'aria-invalid': 'true',
              if (error != null) 'aria-describedby': '$id-error',
            },
          ),
          span(classes: 'check__text', [label]),
        ],
      ),
      if (error != null) FieldError(id: '$id-error', message: error!),
    ]);
  }
}

@css
List<StyleRule> get formStyles => [
  rule('.field', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(1.5), 'min-width': '0'}),
  rule('.label', {'font-size': 'var(--text-sm)', 'font-weight': '500', 'line-height': '1'}),
  rule('.label__req', {'color': Tok.mutedForeground}),
  // Cairn input: h-9, rounded-md, border-input, shadow-xs, px-3.
  rule('.input, .select, .textarea', {
    'width': '100%',
    'height': '2.25rem',
    'padding': '0 ${Tok.space(3)}',
    'border': '1px solid var(--input)',
    'border-radius': Tok.radiusMd,
    'background': 'transparent',
    'box-shadow': Tok.shadowXs,
    'font-size': 'var(--text-sm)',
    'transition': 'border-color 150ms var(--ease), box-shadow 150ms var(--ease)',
  }),
  rule('.input::placeholder', {'color': Tok.mutedForeground}),
  rule('.input:focus-visible, .select:focus-visible', {
    'border-color': Tok.ring,
    'box-shadow': '0 0 0 3px color-mix(in oklab, var(--ring) 50%, transparent)',
  }),
  rule('.field--invalid .input, .field--invalid .select', {'border-color': Tok.destructive}),
  rule('.field--invalid .input:focus-visible, .field--invalid .select:focus-visible', {
    'box-shadow': '0 0 0 3px color-mix(in oklab, var(--destructive) 25%, transparent)',
  }),
  rule('.field__hint', {'font-size': 'var(--text-xs)', 'color': Tok.mutedForeground}),
  rule('.field__error', {'font-size': 'var(--text-sm)', 'color': Tok.destructive}),
  rule('.select-wrap', {'position': 'relative'}),
  rule('.select', {
    'appearance': 'none',
    '-webkit-appearance': 'none',
    'padding-right': Tok.space(8),
    'background': Tok.background,
  }),
  rule('.select-wrap__chevron', {
    'position': 'absolute',
    'right': Tok.space(3),
    'top': '50%',
    'transform': 'translateY(-50%)',
    'pointer-events': 'none',
    'color': Tok.mutedForeground,
    'display': 'flex',
  }),
  rule('.check', {
    'display': 'flex',
    'gap': Tok.space(2.5),
    'align-items': 'flex-start',
    'cursor': 'pointer',
    'font-size': 'var(--text-sm)',
    'line-height': '1.4',
  }),
  rule('.check__input', {
    'width': '1rem',
    'height': '1rem',
    'margin': '0.125rem 0 0',
    'accent-color': 'var(--primary)',
    'flex': 'none',
  }),
  rule('.field--invalid .check__input', {'outline': '2px solid var(--destructive)'}),
];
