import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/ui/feedback.dart';
import '../../../core/widgets/async_view.dart';
import '../../../models/table_model.dart';
import '../../orders/application/order_providers.dart';
import '../application/tables_provider.dart';
import '../data/table_qr_codec.dart';
import '../data/tables_repository.dart';
import 'table_qr_printer.dart';

/// Admin: register, enable/disable and delete tables, and print their QR
/// codes. Only registered, enabled tables are accepted at customer check-in.
class TablesAdminView extends ConsumerWidget {
  const TablesAdminView({super.key});

  Future<void> _addTable(BuildContext context, WidgetRef ref) async {
    final number = await showDialog<int>(
      context: context,
      builder: (_) => const _AddTableDialog(),
    );
    if (number == null || !context.mounted) return;
    await runAction(
      context,
      () => ref.read(tablesRepositoryProvider).createTable(number),
      successMessage: context.l10n.tableAdded('$number'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final occupied = {
      for (final order
          in ref.watch(activeOrdersProvider).valueOrNull ?? const [])
        order.tableNumber,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.qrSelectHint, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        AsyncView<List<TableModel>>(
          value: ref.watch(tablesProvider),
          onRetry: () => ref.invalidate(tablesProvider),
          data: (tables) {
            final printable =
                tables.where((t) => t.isActive).map((t) => t.number).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _addTable(context, ref),
                      icon: const Icon(Icons.add),
                      label: Text(l.addTable),
                    ),
                    OutlinedButton.icon(
                      onPressed: printable.isEmpty
                          ? null
                          : () => runAction(
                              context, () => printTableQrCodes(printable)),
                      icon: const Icon(Icons.print),
                      label: Text(l.printQrCodes),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (tables.isEmpty)
                  EmptyNotice(
                      message: l.noTablesYet, icon: Icons.table_restaurant)
                else
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final table in tables)
                        SizedBox(
                          width: 220,
                          child: _TableCard(
                            table: table,
                            isOccupied: occupied.contains(table.number),
                          ),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TableCard extends ConsumerWidget {
  const _TableCard({required this.table, required this.isOccupied});

  final TableModel table;
  final bool isOccupied;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final confirmed = await confirm(
      context,
      title: l.deleteAction,
      message: l.confirmDeleteTable('${table.number}'),
    );
    if (!confirmed || !context.mounted) return;
    await runAction(context,
        () => ref.read(tablesRepositoryProvider).deleteTable(table.number));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final repo = ref.read(tablesRepositoryProvider);
    final (String status, Color color) = !table.isActive
        ? (l.tableStatusDisabled, Colors.grey)
        : isOccupied
            ? (l.tableStatusOccupied, Colors.orange)
            : (l.tableStatusFree, Colors.green);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              l.tableWithNumber('${table.number}'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
            Opacity(
              opacity: table.isActive ? 1 : 0.3,
              child: QrImageView(
                data: TableQrCodec.encode(table.number),
                version: QrVersions.auto,
                size: 150,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Switch(
                  value: table.isActive,
                  onChanged: (value) => runAction(
                    context,
                    () => repo.setActive(table.number, isActive: value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.print),
                  tooltip: l.printQrCodes,
                  onPressed: () => runAction(
                      context, () => printTableQrCodes([table.number])),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: l.deleteAction,
                  // A table with an open bill has to be settled first.
                  onPressed: isOccupied ? null : () => _delete(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTableDialog extends StatefulWidget {
  const _AddTableDialog();

  @override
  State<_AddTableDialog> createState() => _AddTableDialogState();
}

class _AddTableDialogState extends State<_AddTableDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, int.tryParse(_controller.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.addTable),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l.tableNumber,
            hintText: l.tableHint,
          ),
          validator: (value) {
            final number = int.tryParse(value?.trim() ?? '');
            return number == null || number <= 0 || number > 9999
                ? l.tableInvalid
                : null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.addAction)),
      ],
    );
  }
}
