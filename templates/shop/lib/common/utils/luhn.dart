/// Whether [digits] (digits only) passes the Luhn checksum used by card
/// numbers.
bool passesLuhn(String digits) {
  if (digits.isEmpty) return false;
  int sum = 0;
  bool doubleIt = false;
  for (int i = digits.length - 1; i >= 0; i--) {
    final int? d = int.tryParse(digits[i]);
    if (d == null) return false;
    int value = d;
    if (doubleIt) {
      value *= 2;
      if (value > 9) value -= 9;
    }
    sum += value;
    doubleIt = !doubleIt;
  }
  return sum % 10 == 0;
}
