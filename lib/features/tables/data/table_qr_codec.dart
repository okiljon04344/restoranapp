/// QR payload printed for a table: `table_<number>`. A bare number is also
/// accepted so a guest can type the number shown on the table.
abstract final class TableQrCodec {
  static const _prefix = 'table_';

  static String encode(int tableNumber) => '$_prefix$tableNumber';

  /// Returns the table number, or null when [raw] is not a table code.
  static int? decode(String raw) {
    final value = raw.trim();
    final digits =
        value.startsWith(_prefix) ? value.substring(_prefix.length) : value;
    final number = int.tryParse(digits);
    return number != null && number > 0 ? number : null;
  }
}
