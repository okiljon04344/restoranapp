import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

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
      final doc = await _db.collection('admins').doc(user.uid).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }
}
