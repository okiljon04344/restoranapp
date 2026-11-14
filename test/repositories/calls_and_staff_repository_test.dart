import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/features/auth/data/staff_repository.dart';
import 'package:restaurant_universal_app/features/calls/data/calls_repository.dart';
import 'package:restaurant_universal_app/models/staff_call_model.dart';

void main() {
  late FakeFirebaseFirestore db;

  setUp(() => db = FakeFirebaseFirestore());

  group('CallsRepository', () {
    test('create writes a pending call that watchPending reads back',
        () async {
      final repo = CallsRepository(db);
      await repo.create(tableNumber: 3, customerUid: 'u1');
      await repo.create(
          tableNumber: 5, customerUid: 'u2', type: StaffCall.typeBill);

      final calls = await repo.watchPending().first;

      expect(calls, hasLength(2));
      expect(calls.map((c) => c.tableNumber).toSet(), {3, 5});
      expect(calls.firstWhere((c) => c.tableNumber == 5).isBillRequest, isTrue);
      expect(calls.firstWhere((c) => c.tableNumber == 3).isBillRequest, isFalse);
      final raw = await db
          .collection('cafes')
          .doc('main_cafe')
          .collection('calls')
          .get();
      expect(raw.docs.first.data()['tableId'], startsWith('table_'));
    });

    test('resolve removes the call from the pending stream', () async {
      final repo = CallsRepository(db);
      await repo.create(tableNumber: 3, customerUid: 'u1');
      final id = (await repo.watchPending().first).single.id;

      await repo.resolve(id);

      expect(await repo.watchPending().first, isEmpty);
    });
  });

  group('StaffRepository', () {
    test('approving a request creates staff/{uid} and removes the request',
        () async {
      final repo = StaffRepository(db);
      await repo.submitRequest(uid: 'cook', email: 'cook@example.com');
      final request = (await repo.watchRequests().first).single;
      expect(request.email, 'cook@example.com');
      expect(await repo.watchStaff().first, isEmpty);

      await repo.approve(request);

      expect(await repo.watchRequests().first, isEmpty);
      expect((await repo.watchStaff().first).single.uid, 'cook');
      final doc = await db.collection('staff').doc('cook').get();
      expect(doc.data()?['role'], 'kitchen');
    });

    test('reject and revoke delete the documents', () async {
      final repo = StaffRepository(db);
      await repo.submitRequest(uid: 'a', email: 'a@example.com');
      await repo.submitRequest(uid: 'b', email: 'b@example.com');
      final requests = await repo.watchRequests().first;

      await repo.reject('a');
      await repo.approve(requests.firstWhere((r) => r.uid == 'b'));
      expect(await repo.watchRequests().first, isEmpty);

      await repo.revoke('b');
      expect(await repo.watchStaff().first, isEmpty);
    });
  });
}
