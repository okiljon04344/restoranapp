import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/qr_code_service.dart';
import '../../domain/table_provider.dart';
import '../../domain/table_status_provider.dart';

import 'qr_scanner_page.dart' if (dart.library.html) 'qr_scanner_page_web.dart'
    as qr_scanner;

class TableEntryPage extends ConsumerStatefulWidget {
  const TableEntryPage({super.key});

  @override
  ConsumerState<TableEntryPage> createState() => _TableEntryPageState();
}

class _TableEntryPageState extends ConsumerState<TableEntryPage> {
  final _tableIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tableIdController.dispose();
    super.dispose();
  }

  void _handleQRData(String qrData) {
    final l = AppLocalizations.of(context)!;
    final qrService = ref.read(qrCodeServiceProvider);
    final tableNum = qrService.parseTableQRData(qrData);

    if (tableNum != null) {
      _tableIdController.text = tableNum.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.qrScanned(tableNum.toString()))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.invalidQr)),
      );
    }
  }

  void _showScanQRDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final dl = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(dl.scanQrDialog),
          content: Text(dl.scanQrDialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(dl.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => qr_scanner.QRScannerPage(
                      onQRScanned: _handleQRData,
                    ),
                  ),
                );
              },
              child: Text(dl.openCamera),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onContinue() async {
    final l = AppLocalizations.of(context)!;
    final tableId = _tableIdController.text.trim();
    if (tableId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.tableRequired)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tableNumber = int.tryParse(tableId);
      if (tableNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.tableInvalid)),
        );
        setState(() => _isLoading = false);
        return;
      }

      final isTableOccupied = ref.read(tableStatusProvider)(tableNumber);

      if (isTableOccupied) {
        if (!mounted) return;
        final action = await showDialog<String>(
          context: context,
          builder: (context) {
            final dl = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(dl.tableOccupied),
              content: Text(dl.tableOccupiedMsg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'cancel'),
                  child: Text(dl.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, 'continue'),
                  child: Text(dl.continueAnyway),
                ),
              ],
            );
          },
        );

        if (action != 'continue') {
          setState(() => _isLoading = false);
          return;
        }
      }

      ref.read(tableIdProvider.notifier).state = tableId;
      if (!mounted) return;
      context.go('/customer');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tableEntry),
        leading: IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.welcomeTitle, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  l.enterTableManually,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _tableIdController,
                  decoration: InputDecoration(
                    labelText: l.tableNumber,
                    hintText: l.tableHint,
                    prefixIcon: const Icon(Icons.table_restaurant_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _showScanQRDialog,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l.scanQr),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _onContinue,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(_isLoading ? l.checking : l.goToMenu),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
