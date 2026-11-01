import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/features/auth/data/auth_repository.dart';

class _FakeAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  _FakeUser(this.uid);

  @override
  final String uid;

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

  test('isAdmin is true only when admins/{uid} exists', () async {
    await db.collection('admins').doc('admin-uid').set({'role': 'admin'});

    expect(await repo.isAdmin(_FakeUser('admin-uid')), isTrue);
    expect(await repo.isAdmin(_FakeUser('other-uid')), isFalse);
    expect(await repo.isAdmin(null), isFalse);
  });
}
