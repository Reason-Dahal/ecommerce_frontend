abstract final class PriceFormatter {
  static String format(num price) {
    final isNegative = price < 0;
    final p = price.abs().toInt();
    final formatted = _groupIndian(p.toString());
    return 'Rs. ${isNegative ? '-' : ''}$formatted';
  }

  /// Groups digits using the South Asian (lakh/crore) numbering system:
  /// last 3 digits together, then groups of 2 from the right.
  /// e.g. 125000 -> "1,25,000", 12500000 -> "1,25,00,000"
  static String _groupIndian(String digits) {
    if (digits.length <= 3) return digits;

    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);

    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);

    return '${parts.join(',')},$last3';
  }
}
