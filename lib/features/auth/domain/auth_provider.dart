import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(firebaseAuthProvider)));

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository(this._auth);

  Future<UserCredential> signIn(String email, String padding) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: padding);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Admin role is decided by the existence of a Firestore document at
  /// `admins/{uid}` (the same check is used in `firestore.rules`).
  Future<bool> isAdmin(User? user) async {
    if (user == null) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }
}
