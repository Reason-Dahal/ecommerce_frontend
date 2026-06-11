abstract final class PriceFormatter {
  static String format(num price) {
    final p = price.toInt();

    if (p >= 100000) {
      final lakh = p / 100000;
      final display = lakh % 1 == 0
          ? lakh.toInt().toString()
          : lakh.toStringAsFixed(1);
      return 'Rs. $display L';
    }

    if (p >= 1000) {
      final k = p / 1000;
      final display = k % 1 == 0 ? k.toInt().toString() : k.toStringAsFixed(1);
      return 'Rs. ${display}K';
    }

    return 'Rs. $p';
  }
}
