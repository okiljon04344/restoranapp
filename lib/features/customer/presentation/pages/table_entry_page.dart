import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/feedback.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../tables/data/table_qr_codec.dart';
import '../../../tables/data/tables_repository.dart';
import '../../application/table_provider.dart';
import 'qr_scanner_page.dart' if (dart.library.html) 'qr_scanner_page_web.dart'
    as qr_scanner;

/// Customer check-in: scan the table QR code or type the table number. The
/// table has to be registered and enabled by an admin to continue.
class TableEntryPage extends ConsumerStatefulWidget {
  const TableEntryPage({super.key});

  @override
  ConsumerState<TableEntryPage> createState() => _TableEntryPageState();
}

class _TableEntryPageState extends ConsumerState<TableEntryPage> {
  final _tableController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const qr_scanner.QRScannerPage()),
    );
    if (code == null || !mounted) return;
    if (TableQrCodec.decode(code) == null) {
      showMessage(context, context.l10n.invalidQr, isError: true);
      return;
    }
    await _checkIn(code);
  }

  Future<void> _checkIn(String rawCode) async {
    final l = context.l10n;
    if (rawCode.trim().isEmpty) {
      showMessage(context, l.tableRequired, isError: true);
      return;
    }
    final tableNumber = TableQrCodec.decode(rawCode);
    if (tableNumber == null) {
      showMessage(context, l.tableInvalid, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // The anonymous session is what lets the rules tie orders to this
      // device; it has to exist before anything is written.
      await ref.read(authRepositoryProvider).ensureCustomerSession();
      final lookup =
          await ref.read(tablesRepositoryProvider).lookup(tableNumber);
      if (!mounted) return;
      switch (lookup) {
        case TableLookup.notFound:
          showMessage(context, l.tableNotFound('$tableNumber'), isError: true);
        case TableLookup.disabled:
          showMessage(context, l.tableDisabled('$tableNumber'), isError: true);
        case TableLookup.ok:
          ref.read(currentTableProvider.notifier).state = tableNumber;
          context.go('/customer');
      }
    } catch (e) {
      if (mounted) showMessage(context, describeError(l, e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tableEntry),
        leading: IconButton(
          icon: const Icon(Icons.language),
          tooltip: l.chooseLanguage,
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.qr_code_scanner, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                Text(
                  l.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l.enterTableManually,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _tableController,
                  decoration: InputDecoration(
                    labelText: l.tableNumber,
                    hintText: l.tableHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.table_restaurant),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !_isLoading,
                  onSubmitted: (value) => _checkIn(value),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _scan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l.scanQr),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _checkIn(_tableController.text),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(_isLoading ? l.checking : l.goToMenu),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _isLoading ? null : () => context.push('/login'),
                  child: Text(l.staffLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
