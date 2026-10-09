import 'dart:convert';

import 'package:cairn_template_jaspr_store/common/constants.dart';
import 'package:cairn_template_jaspr_store/common/utils/escape.dart';
import 'package:cairn_template_jaspr_store/common/utils/money.dart';
import 'package:cairn_template_jaspr_store/common/utils/slug.dart';
import 'package:cairn_template_jaspr_store/common/utils/text.dart';
import 'package:cairn_template_jaspr_store/core/seo/url_policy.dart';
import 'package:test/test.dart';

void main() {
  group('money', () {
    test('formats whole and fractional amounts', () {
      expect(formatMoney(0), r'$0.00');
      expect(formatMoney(5), r'$0.05');
      expect(formatMoney(9800), r'$98.00');
      expect(formatMoney(12345), r'$123.45');
    });

    test('groups thousands', () {
      expect(formatMoney(123456789), r'$1,234,567.89');
      expect(formatMoney(100000), r'$1,000.00');
    });

    test('formats negatives and other currencies', () {
      expect(formatMoney(-250), r'-$2.50');
      expect(formatMoney(1999, currency: 'EUR'), '€19.99');
      expect(formatMoney(1999, currency: 'GBP'), '£19.99');
      expect(formatMoney(1999, currency: 'XYZ'), 'XYZ 19.99');
    });

    test('decimalAmount is machine-readable', () {
      expect(decimalAmount(9800), '98.00');
      expect(decimalAmount(5), '0.05');
      expect(decimalAmount(123456), '1234.56');
    });

    test('discountPercent rounds and guards', () {
      expect(discountPercent(price: 9800, compareAt: 12000), 18);
      expect(discountPercent(price: 5900, compareAt: 7900), 25);
      expect(discountPercent(price: 100), 0);
      expect(discountPercent(price: 100, compareAt: 100), 0);
      expect(discountPercent(price: 200, compareAt: 100), 0);
    });

    test('percentOf rounds half up in integers', () {
      expect(percentOf(1000, 10), 100);
      expect(percentOf(1005, 10), 101);
      expect(percentOf(999, 10), 100);
      expect(percentOf(0, 10), 0);
    });
  });

  group('slug', () {
    test('slugify', () {
      expect(slugify('Stride Knit — Sneaker!'), 'stride-knit-sneaker');
      expect(slugify('  --Hello   World--  '), 'hello-world');
      expect(slugify('A/B Test'), 'a-b-test');
    });

    test('isValidSlug accepts canonical slugs only', () {
      expect(isValidSlug('stride-knit-sneaker'), isTrue);
      expect(isValidSlug('classic-38-watch'), isTrue);
      expect(isValidSlug('Upper'), isFalse);
      expect(isValidSlug('a--b'), isFalse);
      expect(isValidSlug('-a'), isFalse);
      expect(isValidSlug('a b'), isFalse);
      expect(isValidSlug('../etc/passwd'), isFalse);
      expect(isValidSlug(''), isFalse);
      expect(isValidSlug('a' * 121), isFalse);
    });
  });

  group('escape', () {
    test('safeJsonForScript cannot close the script tag', () {
      final out = safeJsonForScript({'name': '</script><script>alert(1)</script>'});
      expect(out, isNot(contains('</script')));
      expect(out, isNot(contains('<')));
      expect(jsonDecode(out)['name'], '</script><script>alert(1)</script>');
    });

    test('safeJsonForScript escapes ampersands and angle brackets', () {
      final out = safeJsonForScript({'a': 'x & y > z'});
      expect(out, contains('\\u0026'));
      expect(out, contains('\\u003e'));
      expect(jsonDecode(out)['a'], 'x & y > z');
    });

    test('escapeXml', () {
      expect(escapeXml('a & b < c > "d" \'e\''), 'a &amp; b &lt; c &gt; &quot;d&quot; &apos;e&apos;');
    });
  });

  group('text', () {
    test('truncate leaves short text alone', () {
      expect(truncate('hello', 10), 'hello');
    });

    test('truncate cuts on a word boundary with an ellipsis', () {
      final out = truncate('The quick brown fox jumps over the lazy dog', 20);
      expect(out.length, lessThanOrEqualTo(20));
      expect(out, endsWith('…'));
      expect(out, isNot(contains('jum')));
    });

    test('truncate collapses whitespace', () {
      expect(truncate('a   b\n c', 50), 'a b c');
    });

    test('title and description helpers use SEO-safe limits', () {
      expect(title60('x ' * 100).length, lessThanOrEqualTo(kMaxTitleLength));
      expect(description158('word ' * 100).length, lessThanOrEqualTo(kMaxDescriptionLength));
    });

    test('pluralize', () {
      expect(pluralize(1, 'item'), 'item');
      expect(pluralize(2, 'item'), 'items');
      expect(pluralize(0, 'item'), 'items');
      expect(pluralize(2, 'box', 'boxes'), 'boxes');
    });
  });

  group('url policy', () {
    test('normalizePath', () {
      expect(normalizePath(''), '/');
      expect(normalizePath('/'), '/');
      expect(normalizePath('/products/'), '/products');
      expect(normalizePath('//products//x'), '/products/x');
      expect(normalizePath('products'), '/products');
    });

    test('tracking parameters are recognised', () {
      expect(isTrackingParam('utm_source'), isTrue);
      expect(isTrackingParam('utm_campaign'), isTrue);
      expect(isTrackingParam('gclid'), isTrue);
      expect(isTrackingParam('fbclid'), isTrue);
      expect(isTrackingParam('q'), isFalse);
      expect(isTrackingParam('page'), isFalse);
    });

    test('stripTracking drops tracking and empty values', () {
      expect(stripTracking({'q': 'a', 'utm_source': 'x', 'sort': '', 'gclid': '1'}), {'q': 'a'});
    });

    test('buildUrl orders parameters deterministically and omits empties', () {
      expect(buildUrl('/p', {'page': '2', 'q': 'a b', 'sort': null}, order: ['q', 'sort', 'page']), '/p?q=a+b&page=2');
      expect(buildUrl('/p', {'page': '', 'q': null}), '/p');
    });
  });
}
