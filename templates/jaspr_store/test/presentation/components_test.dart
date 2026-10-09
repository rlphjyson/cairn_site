import 'dart:convert';

import 'package:cairn_template_jaspr_store/domain/reviews/models/review.dart';
import 'package:cairn_template_jaspr_store/presentation/components/buttons.dart';
import 'package:cairn_template_jaspr_store/presentation/components/commerce.dart';
import 'package:cairn_template_jaspr_store/presentation/components/feedback.dart';
import 'package:cairn_template_jaspr_store/presentation/components/forms.dart';
import 'package:cairn_template_jaspr_store/presentation/components/html.dart';
import 'package:cairn_template_jaspr_store/presentation/components/navigation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:jaspr/server.dart' show Component, renderComponent;
import 'package:test/test.dart';

import '../support/harness.dart';

/// Renders one component to an HTML fragment and parses it.
Future<Document> render(Component c) async {
  initJaspr();
  final out = await renderComponent(c, standalone: true);
  return html_parser.parse(utf8.decode(out.body));
}

void main() {
  group('Rating', () {
    test('is one accessible sentence, with decorative stars', () async {
      final d = await render(const Rating(summary: RatingSummary(average: 4.5, count: 12)));
      final root = d.querySelector('.rating')!;
      expect(root.attributes['role'], 'img');
      expect(root.attributes['aria-label'], 'Rated 4.5 out of 5 from 12 reviews');
      expect(d.querySelector('.rating__stars')!.attributes['aria-hidden'], 'true');
      expect(d.querySelector('.rating__stars')!.attributes['style'], '--pct:90%');
    });

    test('singular review', () async {
      final d = await render(const Rating(summary: RatingSummary(average: 5, count: 1)));
      expect(d.querySelector('.rating')!.attributes['aria-label'], 'Rated 5.0 out of 5 from 1 review');
    });

    test('no reviews says so in text', () async {
      final d = await render(const Rating(summary: RatingSummary.empty));
      expect(d.body!.text.trim(), 'No reviews yet');
      expect(d.querySelector('.rating__stars'), isNull);
    });

    test('count can be hidden', () async {
      final d = await render(const Rating(summary: RatingSummary(average: 4, count: 2), showCount: false));
      expect(d.querySelector('.rating__count'), isNull);
    });
  });

  group('Price', () {
    test('plain price', () async {
      final d = await render(const Price(cents: 9800));
      expect(d.querySelector('.price__now')!.text.trim(), r'$98.00');
      expect(d.querySelector('.price__was'), isNull);
    });

    test('sale price has screen-reader labels and a struck-through regular price', () async {
      final d = await render(const Price(cents: 9800, compareAtCents: 12000));
      expect(d.querySelector('.price__now .sr-only')!.text, contains('Sale price'));
      expect(d.querySelector('.price__was .sr-only')!.text, contains('Regular price'));
      expect(d.querySelector('.price__was del')!.text, r'$120.00');
    });

    test('compare-at at or below the price is ignored', () async {
      final d = await render(const Price(cents: 9800, compareAtCents: 9800));
      expect(d.querySelector('.price__was'), isNull);
    });

    test('other currencies', () async {
      final d = await render(const Price(cents: 1999, currency: 'EUR'));
      expect(d.body!.text, contains('€19.99'));
    });
  });

  group('Badge and Alert', () {
    test('badge variants map to classes and carry text', () async {
      for (final v in BadgeVariant.values) {
        final d = await render(Badge('Hi', variant: v));
        expect(d.querySelector('.badge--${v.name}')!.text, 'Hi');
      }
    });

    test('destructive alerts use role=alert, success uses role=status', () async {
      final bad = await render(
        Alert(variant: AlertVariant.destructive, live: true, title: 'Oops', children: [t('detail')]),
      );
      expect(bad.querySelector('.alert')!.attributes['role'], 'alert');
      expect(bad.querySelector('.alert__title')!.text, 'Oops');
      final ok = await render(Alert(variant: AlertVariant.success, live: true, children: [t('done')]));
      expect(ok.querySelector('.alert')!.attributes['role'], 'status');
      final quiet = await render(Alert(children: [t('fyi')]));
      expect(quiet.querySelector('.alert')!.attributes.containsKey('role'), isFalse);
    });

    test('icons are hidden from assistive technology', () async {
      final d = await render(Alert(children: [t('x')]));
      expect(d.querySelector('svg')!.attributes['aria-hidden'], 'true');
    });
  });

  group('Accordion', () {
    test('uses native details/summary and can open the first item', () async {
      final d = await render(
        Accordion(openFirst: true, items: [(title: 'A', content: t('one')), (title: 'B', content: t('two'))]),
      );
      final items = d.querySelectorAll('details');
      expect(items, hasLength(2));
      expect(items.first.attributes.containsKey('open'), isTrue);
      expect(items.last.attributes.containsKey('open'), isFalse);
      expect(items.first.querySelector('summary')!.text, contains('A'));
      expect(d.body!.text, contains('two')); // content is in the HTML even when closed
    });
  });

  group('Skeleton', () {
    test('is hidden from assistive technology and sized inline', () async {
      final d = await render(const Skeleton(width: '4rem', height: '1rem'));
      final s = d.querySelector('.skeleton')!;
      expect(s.attributes['aria-hidden'], 'true');
      expect(s.attributes['style'], contains('width:4rem'));
    });
  });

  group('Breadcrumb', () {
    test('marks the current page and separates links', () async {
      final d = await render(const Breadcrumb([Crumb('Home', '/'), Crumb('Shop', '/products'), Crumb('Thing')]));
      expect(d.querySelector('nav')!.attributes['aria-label'], 'Breadcrumb');
      expect(d.querySelectorAll('li'), hasLength(3));
      expect(d.querySelectorAll('a').map((a) => a.attributes['href']), ['/', '/products']);
      expect(d.querySelector('[aria-current="page"]')!.text, 'Thing');
    });

    test('the last crumb is never a link even if it has a path', () async {
      final d = await render(const Breadcrumb([Crumb('Home', '/'), Crumb('Here', '/here')]));
      expect(d.querySelectorAll('a'), hasLength(1));
    });
  });

  group('Pagination', () {
    test('window shows first, last and neighbours with ellipses', () {
      expect(Pagination.window(1, 3), [1, 2, 3]);
      expect(Pagination.window(1, 10), [1, 2, null, 10]);
      expect(Pagination.window(5, 10), [1, null, 4, 5, 6, null, 10]);
      expect(Pagination.window(10, 10), [1, null, 9, 10]);
      expect(Pagination.window(1, 1), [1]);
      expect(Pagination.window(2, 4), [1, 2, 3, 4]);
    });

    test('renders prev/next with rel attributes and the current page', () async {
      final d = await render(Pagination(page: 2, pageCount: 3, hrefFor: (p) => p == 1 ? '/x' : '/x?page=$p'));
      expect(d.querySelector('a[rel="prev"]')!.attributes['href'], '/x');
      expect(d.querySelector('a[rel="next"]')!.attributes['href'], '/x?page=3');
      expect(d.querySelector('[aria-current="page"]')!.text, '2');
      expect(d.querySelector('nav')!.attributes['aria-label'], 'Pagination');
    });

    test('disabled ends are not links', () async {
      final d = await render(Pagination(page: 1, pageCount: 2, hrefFor: (p) => '/x?page=$p'));
      expect(d.querySelector('a[rel="prev"]'), isNull);
      expect(d.querySelector('.is-disabled')!.attributes['aria-disabled'], 'true');
    });

    test('a single page renders nothing', () async {
      final d = await render(Pagination(page: 1, pageCount: 1, hrefFor: (p) => '/x'));
      expect(d.querySelector('nav'), isNull);
    });
  });

  group('form controls', () {
    test('TextField: label tied by for/id, no error by default', () async {
      final d = await render(
        const TextField(name: 'email', label: 'Email', type: 'email', autocomplete: 'email', required: true),
      );
      expect(d.querySelector('label')!.attributes['for'], 'f-email');
      final input = d.querySelector('input')!;
      expect(input.attributes['id'], 'f-email');
      expect(input.attributes['type'], 'email');
      expect(input.attributes.containsKey('aria-invalid'), isFalse);
      expect(input.attributes.containsKey('required'), isTrue);
    });

    test('TextField with an error: aria-invalid, aria-describedby and an alert', () async {
      final d = await render(const TextField(name: 'email', label: 'Email', error: 'Bad', hint: 'Hint'));
      final input = d.querySelector('input')!;
      expect(input.attributes['aria-invalid'], 'true');
      expect(input.attributes['aria-describedby'], 'f-email-hint f-email-error');
      expect(d.querySelector('#f-email-error')!.attributes['role'], 'alert');
      expect(d.querySelector('.field--invalid'), isNotNull);
    });

    test('TextField value is attribute-escaped', () async {
      final d = await render(const TextField(name: 'q', label: 'Q', value: '"><script>x</script>'));
      expect(d.body!.querySelector('script'), isNull);
      expect(d.querySelector('input')!.attributes['value'], '"><script>x</script>');
    });

    test('SelectField selects the current value', () async {
      final d = await render(const SelectField(name: 'sort', label: 'Sort', value: 'b', options: {'a': 'A', 'b': 'B'}));
      expect(d.querySelector('option[selected]')!.attributes['value'], 'b');
      expect(d.querySelector('label')!.attributes['for'], 'f-sort');
    });

    test('SelectField can hide its label visually but keep it', () async {
      final d = await render(const SelectField(name: 's', label: 'Sort', options: {'a': 'A'}, hideLabel: true));
      expect(d.querySelector('label.sr-only'), isNotNull);
    });

    test('CheckboxField wraps the control in its label', () async {
      final d = await render(CheckboxField(name: 'ok', label: t('Agree'), checked: true, error: 'Required'));
      expect(d.querySelector('label.check input[type="checkbox"]'), isNotNull);
      expect(d.querySelector('input')!.attributes.containsKey('checked'), isTrue);
      expect(d.querySelector('input')!.attributes['aria-describedby'], 'f-ok-error');
    });
  });

  group('buttons', () {
    test('ButtonLink is a real anchor', () async {
      final d = await render(
        const ButtonLink(href: '/x', label: 'Go', variant: ButtonVariant.outline, size: ButtonSize.lg, block: true),
      );
      final a = d.querySelector('a')!;
      expect(a.attributes['href'], '/x');
      expect(a.classes, containsAll(['btn', 'btn--outline', 'btn--lg', 'btn--block']));
    });

    test('SubmitButton is a submit button, optionally disabled', () async {
      final d = await render(const SubmitButton(label: 'Pay', disabled: true, name: 'a', value: 'b'));
      final b = d.querySelector('button')!;
      expect(b.attributes['type'], 'submit');
      expect(b.attributes.containsKey('disabled'), isTrue);
      expect(b.attributes['name'], 'a');
    });

    test('class helpers', () {
      expect(buttonClasses(ButtonVariant.primary, ButtonSize.md), 'btn btn--primary btn--md');
      expect(cx(['a', null, '', 'b']), 'a b');
    });
  });
}
