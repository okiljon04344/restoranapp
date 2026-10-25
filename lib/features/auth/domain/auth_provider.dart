import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authRepositoryProvider =
    Provider((ref) => AuthRepository(ref.watch(firebaseAuthProvider)));

/// Staff roles granted through Firebase Auth custom claims.
///
/// Claims are set server-side only (see `tools/set_staff_role/`), so a user
/// cannot promote themselves by registering a particular email address.
/// `firestore.rules` checks the same claims.
enum StaffRole {
  admin,
  kitchen;

  /// Whether a user holding [claims] may act as this role.
  /// Admins may access every staff screen.
  bool isGrantedBy(Map<String, dynamic>? claims) {
    if (claims == null) return false;
    if (claims['admin'] == true) return true;
    return claims[name] == true;
  }

  static StaffRole fromName(String? value) =>
      value == StaffRole.kitchen.name ? StaffRole.kitchen : StaffRole.admin;
}

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository(this._auth);

  Future<UserCredential> signIn(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  /// Force-refreshes the ID token so freshly granted claims are picked up.
  Future<bool> hasRole(User user, StaffRole role) async {
    final token = await user.getIdTokenResult(true);
    return role.isGrantedBy(token.claims);
  }
}
