import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_providers.dart';
import '../data/auth_repository.dart';

export '../data/auth_repository.dart' show StaffRole;

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final authRepositoryProvider = Provider((ref) => AuthRepository(
    ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider)));

/// Uid of the signed-in session (anonymous customer or staff), if any.
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

/// Role of the signed-in user; re-evaluated whenever the auth state changes.
final staffRoleProvider = FutureProvider<StaffRole>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  return ref.watch(authRepositoryProvider).roleOf(user);
});
