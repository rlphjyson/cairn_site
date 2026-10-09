/// The three client islands, tested with `jaspr_test`. Browser-only code paths
/// (fetch, cookies, `window` events) are guarded by `kIsWeb`, so here we assert
/// what the server renders and the state transitions that do not need a DOM.
library;

import 'package:cairn_template_jaspr_store/presentation/islands/add_to_cart_button.dart';
import 'package:cairn_template_jaspr_store/presentation/islands/cart_link.dart';
import 'package:cairn_template_jaspr_store/presentation/islands/theme_toggle.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('ThemeToggle', () {
    testComponents('renders a labelled button reflecting the server-resolved theme', (tester) async {
      tester.pumpComponent(const ThemeToggle(initialTheme: 'dark'));
      await tester.pump();
      expect(find.tag('button'), findsOneComponent);
    });

    testComponents('clicking flips light to dark and back', (tester) async {
      tester.pumpComponent(const ThemeToggle(initialTheme: 'light'));
      await tester.pump();
      expect(find.tag('button'), findsOneComponent);
      await tester.click(find.tag('button'));
      await tester.click(find.tag('button'));
      expect(find.tag('button'), findsOneComponent);
    });

    test('the cookie name is the one the server reads', () {
      expect(kThemeCookieName, 'theme');
    });
  });

  group('AddToCartButton', () {
    testComponents('renders a submit button with its label and a polite live region', (tester) async {
      tester.pumpComponent(const AddToCartButton());
      await tester.pump();
      expect(find.text('Add to cart'), findsOneComponent);
      expect(find.tag('button'), findsOneComponent);
      expect(find.tag('p'), findsOneComponent);
    });

    testComponents('a custom label is used', (tester) async {
      tester.pumpComponent(const AddToCartButton(label: 'Buy now'));
      await tester.pump();
      expect(find.text('Buy now'), findsOneComponent);
    });

    testComponents('a disabled button does not change state when clicked', (tester) async {
      tester.pumpComponent(const AddToCartButton(disabled: true));
      await tester.pump();
      await tester.click(find.tag('button'));
      expect(find.text('Add to cart'), findsOneComponent);
    });

    test('the cart-changed event name is shared between islands', () {
      expect(kCartChangedEvent, 'cart:changed');
    });
  });

  group('CartLink', () {
    testComponents('renders a plain link to /cart that works before hydration', (tester) async {
      tester.pumpComponent(const CartLink());
      await tester.pump();
      expect(find.tag('a'), findsOneComponent);
      expect(find.text('Cart'), findsOneComponent);
    });
  });
}
