import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/feedback.dart';
import '../../../core/widgets/async_view.dart';
import '../../../models/staff_call_model.dart';
import '../application/calls_provider.dart';
import '../data/calls_repository.dart';

/// Pending "call staff" / "bring the bill" requests with a resolve action.
class StaffCallsView extends ConsumerWidget {
  const StaffCallsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return AsyncView<List<StaffCall>>(
      value: ref.watch(staffCallsProvider),
      onRetry: () => ref.invalidate(staffCallsProvider),
      data: (calls) {
        if (calls.isEmpty) {
          return EmptyNotice(
              message: l.noStaffCalls, icon: Icons.notifications_none);
        }
        return Column(
          children: [
            for (final call in calls)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: call.isBillRequest
                    ? Colors.orange.shade50
                    : Colors.red.shade50,
                child: ListTile(
                  leading: Icon(
                    call.isBillRequest
                        ? Icons.receipt_long
                        : Icons.notifications_active,
                    color: call.isBillRequest ? Colors.orange : Colors.red,
                  ),
                  title: Text(
                    l.tableWithNumber('${call.tableNumber}'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${call.isBillRequest ? l.billRequestedByTable : l.staffRequested} · ${formatTime(call.createdAt)}',
                  ),
                  trailing: FilledButton(
                    onPressed: () => runAction(
                      context,
                      () => ref.read(callsRepositoryProvider).resolve(call.id),
                      successMessage: l.staffCallResolved,
                    ),
                    child: Text(l.markDone),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
