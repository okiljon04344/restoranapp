import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../models/staff_member_model.dart';
import '../../application/staff_provider.dart';
import '../../data/staff_repository.dart';

/// Admin: approve or reject kitchen access requests and revoke access.
class StaffAdminView extends ConsumerWidget {
  const StaffAdminView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final repo = ref.read(staffRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.staffAdminHint, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        Text(l.staffRequestsTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        AsyncView<List<StaffMember>>(
          value: ref.watch(staffRequestsProvider),
          onRetry: () => ref.invalidate(staffRequestsProvider),
          data: (requests) => requests.isEmpty
              ? EmptyNotice(message: l.noStaffRequests)
              : Column(
                  children: [
                    for (final request in requests)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.person_add_alt),
                          title: Text(request.email),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed: () => runAction(
                                    context, () => repo.reject(request.uid)),
                                child: Text(l.rejectAction),
                              ),
                              FilledButton(
                                onPressed: () => runAction(
                                  context,
                                  () => repo.approve(request),
                                  successMessage:
                                      l.staffApproved(request.email),
                                ),
                                child: Text(l.approveAction),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 24),
        Text(l.kitchenStaffTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        AsyncView<List<StaffMember>>(
          value: ref.watch(staffMembersProvider),
          onRetry: () => ref.invalidate(staffMembersProvider),
          data: (staff) => staff.isEmpty
              ? EmptyNotice(message: l.noKitchenStaff)
              : Column(
                  children: [
                    for (final member in staff)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.soup_kitchen),
                          title: Text(member.email),
                          trailing: TextButton(
                            onPressed: () async {
                              final confirmed = await confirm(
                                context,
                                title: l.revokeAction,
                                message: l.confirmRevokeStaff(member.email),
                              );
                              if (!confirmed || !context.mounted) return;
                              await runAction(
                                  context, () => repo.revoke(member.uid));
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: Text(l.revokeAction),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
