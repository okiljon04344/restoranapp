import 'package:flutter_riverpod/flutter_riverpod.dart';

final qrCodeServiceProvider = Provider((ref) => QRCodeService());

/// Encodes a table number into the string printed in a QR code and back.
class QRCodeService {
  static const _prefix = 'table_';

  String generateTableQRData(int tableNumber) => '$_prefix$tableNumber';

  /// Accepts `table_<n>` or a bare number; returns null for anything else.
  int? parseTableQRData(String qrData) {
    if (qrData.startsWith(_prefix)) {
      return int.tryParse(qrData.substring(_prefix.length));
    }
    return int.tryParse(qrData);
  }
}
