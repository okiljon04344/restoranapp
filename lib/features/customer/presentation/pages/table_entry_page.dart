import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/table_provider.dart';
import '../../domain/table_status_provider.dart';
import '../../../../services/qr_code_service.dart';

// Conditional imports based on platform
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

  void _handleQRData(String qrData) {
    final l10n = AppLocalizations.of(context)!;
    // Parse QR data (format: table_1, table_2, etc.)
    final qrService = ref.read(qrCodeServiceProvider);
    final tableNum = qrService.parseTableQRData(qrData);

    if (tableNum != null) {
      _tableIdController.text = tableNum.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.qrScannedTable(tableNum.toString()))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidQrCode)),
      );
    }
  }

  void _showScanQRDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scanQrTitle),
        content: Text(l10n.scanQrDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Open camera scanner
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => qr_scanner.QRScannerPage(
                    onQRScanned: _handleQRData,
                  ),
                ),
              );
            },
            child: Text(l10n.openCamera),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinue() async {
    final l10n = AppLocalizations.of(context)!;
    final tableId = _tableIdController.text.trim();
    if (tableId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterTableNumber)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tableNumber = int.tryParse(tableId);
      if (tableNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tableNumberMustBeNumber)),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Check if table has active orders
      final isTableOccupied = ref.read(tableStatusProvider)(tableNumber);

      if (isTableOccupied) {
        // Show dialog that table is occupied
        if (!mounted) return;
        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('⚠️ ${l10n.tableOccupiedTitle}'),
            content: Text(l10n.tableOccupiedMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, 'continue'),
                child: Text(l10n.continueText),
              ),
            ],
          ),
        );

        if (action != 'continue') {
          setState(() => _isLoading = false);
          return;
        }
      }

      // Set table ID and navigate
      ref.read(tableIdProvider.notifier).state = tableId;
      if (!mounted) return;
      context.go('/customer');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorMessage(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tableEntry),
        leading: IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.qr_code_scanner, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            Text(
              l10n.welcome,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.enterTableOrScan,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _tableIdController,
              decoration: InputDecoration(
                labelText: l10n.tableNumberLabel,
                hintText: l10n.tableNumberHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.table_restaurant),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _showScanQRDialog,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.scanQr),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isLoading ? null : _onContinue,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(_isLoading ? l10n.checking : l10n.goToMenu),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tableIdController.dispose();
    super.dispose();
  }
}
