import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/cafe_refs.dart';

enum StaffRole { none, kitchen, admin }

class AuthRepository {
  AuthRepository(this._auth, FirebaseFirestore db) : _refs = CafeRefs(db);

  final FirebaseAuth _auth;
  final CafeRefs _refs;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  /// Uid of the current session, signing in anonymously when there is none.
  /// Customers use an anonymous session so the security rules can tie orders
  /// to the device that placed them.
  Future<String> ensureCustomerSession() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;
    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'anonymous-sign-in-failed');
    }
    return user.uid;
  }

  /// Role of [user], decided by the existence of `admins/{uid}` or
  /// `staff/{uid}` (the same checks `firestore.rules` performs). Throws when
  /// Firestore cannot be reached so callers can tell "no role" from "unknown".
  Future<StaffRole> roleOf(User? user) async {
    if (user == null || user.isAnonymous) return StaffRole.none;
    final admin = await _refs.admins.doc(user.uid).get();
    if (admin.exists) return StaffRole.admin;
    final staff = await _refs.staff.doc(user.uid).get();
    return staff.exists ? StaffRole.kitchen : StaffRole.none;
  }
}
