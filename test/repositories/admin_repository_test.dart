import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/features/admin/data/admin_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late AdminRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = AdminRepository(db);
  });

  test('callStaff creates a pending call that watchPendingStaffCalls returns',
      () async {
    await repo.callStaff(7);

    final calls = await repo.watchPendingStaffCalls().first;
    expect(calls, hasLength(1));
    expect(calls.single.tableNumber, 7);
    expect(calls.single.status, 'pending');
  });

  test('resolveCall removes the call from the pending list', () async {
    await repo.callStaff(3);
    await repo.callStaff(4);
    final first = (await repo.watchPendingStaffCalls().first)
        .firstWhere((c) => c.tableNumber == 3);

    await repo.resolveCall(first.id);

    final pending = await repo.watchPendingStaffCalls().first;
    expect(pending.map((c) => c.tableNumber), [4]);
    final doc = await db
        .collection('cafes')
        .doc('main_cafe')
        .collection('calls')
        .doc(first.id)
        .get();
    expect(doc.data()!['status'], 'resolved');
  });

  test('cancelOrder sets status to cancelled under cafes/main_cafe/orders',
      () async {
    await db.collection('cafes').doc('main_cafe').collection('orders').doc('o1').set({'status': 'pending'});

    await repo.cancelOrder('o1');

    final doc = await db.collection('cafes').doc('main_cafe').collection('orders').doc('o1').get();
    expect(doc.data()!['status'], 'cancelled');
  });

  test('deleteStaffCall marks the call resolved under cafes/main_cafe/calls', () async {
    await db.collection('cafes').doc('main_cafe').collection('calls').doc('c1').set({'tableNumber': 1, 'status': 'pending'});

    await repo.deleteStaffCall('c1');

    final doc = await db.collection('cafes').doc('main_cafe').collection('calls').doc('c1').get();
    expect(doc.data()!['status'], 'resolved');
  });
}
