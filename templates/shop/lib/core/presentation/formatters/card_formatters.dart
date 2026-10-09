import 'package:flutter/services.dart';

/// Keeps digits only and groups them in fours: `4242 4242 4242 4242`.
class CardNumberFormatter extends TextInputFormatter {
  /// Creates the formatter.
  const CardNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 19) digits = digits.substring(0, 19);
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) out.write(' ');
      out.write(digits[i]);
    }
    final String text = out.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Keeps digits only and inserts the slash: `1228` becomes `12/28`.
class ExpiryFormatter extends TextInputFormatter {
  /// Creates the formatter.
  const ExpiryFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    // Deleting the slash should delete the digit before it too.
    final bool deleting = newValue.text.length < oldValue.text.length;
    final String text = digits.length > 2 || (digits.length == 2 && !deleting)
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
