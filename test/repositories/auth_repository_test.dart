import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/features/auth/data/auth_repository.dart';

class _FakeAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  _FakeUser(this.uid, {this.isAnonymous = false});

  @override
  final String uid;

  @override
  final bool isAnonymous;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeFirebaseFirestore db;
  late AuthRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = AuthRepository(_FakeAuth(), db);
  });

  test('roleOf is admin only when admins/{uid} exists', () async {
    await db.collection('admins').doc('admin-uid').set({'role': 'admin'});

    expect(await repo.roleOf(_FakeUser('admin-uid')), StaffRole.admin);
    expect(await repo.roleOf(_FakeUser('other-uid')), StaffRole.none);
    expect(await repo.roleOf(null), StaffRole.none);
  });

  test('roleOf is kitchen when staff/{uid} exists', () async {
    await db.collection('staff').doc('cook-uid').set({'role': 'kitchen'});

    expect(await repo.roleOf(_FakeUser('cook-uid')), StaffRole.kitchen);
  });

  test('admin wins when both role documents exist', () async {
    await db.collection('admins').doc('uid').set({});
    await db.collection('staff').doc('uid').set({});

    expect(await repo.roleOf(_FakeUser('uid')), StaffRole.admin);
  });

  test('an anonymous customer session never has a staff role', () async {
    await db.collection('staff').doc('anon').set({});

    expect(await repo.roleOf(_FakeUser('anon', isAnonymous: true)),
        StaffRole.none);
  });
}
