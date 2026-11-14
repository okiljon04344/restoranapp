import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Number of the table the customer checked in at (validated against
/// Firestore by the table entry page), or null before check-in.
final currentTableProvider = StateProvider<int?>((ref) => null);
