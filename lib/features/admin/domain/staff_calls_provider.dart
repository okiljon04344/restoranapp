import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/staff_call_model.dart';
import '../data/admin_repository.dart';

export '../../../models/staff_call_model.dart';

final staffCallsProvider = StreamProvider<List<StaffCall>>((ref) {
  return ref.watch(adminRepositoryProvider).watchPendingStaffCalls();
});
