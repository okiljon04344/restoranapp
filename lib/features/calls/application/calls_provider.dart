import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/staff_call_model.dart';
import '../data/calls_repository.dart';

final staffCallsProvider = StreamProvider<List<StaffCall>>((ref) {
  return ref.watch(callsRepositoryProvider).watchPending();
});
