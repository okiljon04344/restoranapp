import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single place where the global [FirebaseFirestore] instance is
/// obtained. Repositories receive it through their constructor, which keeps
/// them testable with a fake Firestore.
final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
