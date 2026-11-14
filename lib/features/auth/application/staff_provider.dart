import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/staff_member_model.dart';
import '../data/staff_repository.dart';

final staffMembersProvider = StreamProvider<List<StaffMember>>((ref) {
  return ref.watch(staffRepositoryProvider).watchStaff();
});

final staffRequestsProvider = StreamProvider<List<StaffMember>>((ref) {
  return ref.watch(staffRepositoryProvider).watchRequests();
});
