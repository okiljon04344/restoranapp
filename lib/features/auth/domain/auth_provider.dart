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

  bool isAdmin(String? email) {
    final admins = [
      'admin@gmail.com',
      'oqiljonnabiyev0434@gmail.com',
      '123@gmail.com'
    ];
    return admins.contains(email);
  }
}
