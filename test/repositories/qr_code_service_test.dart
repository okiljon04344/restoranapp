import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/services/qr_code_service.dart';

void main() {
  late QRCodeService service;

  setUp(() {
    service = QRCodeService(FakeFirebaseFirestore());
  });

  test('saveTableQR persists data that getAllTablesQR reads back', () async {
    await service.saveTableQR(4, service.generateTableQRData(4));

    final tables = await service.getAllTablesQR().first;
    expect(tables.single.tableNumber, 4);
    expect(tables.single.qrData, 'table_4');
    expect(service.parseTableQRData(tables.single.qrData), 4);
  });

  test('deleteTableQR removes the table', () async {
    await service.saveTableQR(4, 'table_4');

    await service.deleteTableQR(4);

    expect(await service.getAllTablesQR().first, isEmpty);
  });
}
