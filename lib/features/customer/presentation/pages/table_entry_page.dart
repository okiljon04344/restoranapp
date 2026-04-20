import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    // Parse QR data (format: table_1, table_2, etc.)
    final qrService = ref.read(qrCodeServiceProvider);
    final tableNum = qrService.parseTableQRData(qrData);

    if (tableNum != null) {
      _tableIdController.text = tableNum.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Scanned: Table $tableNum')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR code. Please try again.')),
      );
    }
  }

  void _showScanQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Codeni Skanerlang'),
        content:
            const Text('Stol QR-ini skanerlash uchun kamera-ni ishlatamiz'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor'),
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
            child: const Text('Kamera Oching'),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinue() async {
    final tableId = _tableIdController.text.trim();
    if (tableId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stol raqamini kiriting')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tableNumber = int.tryParse(tableId);
      if (tableNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stol raqami sonda bo\'lishi kerak')),
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
            title: const Text('⚠️ Stol Band'),
            content: const Text(
                'Bu stol hozir ishlatilyapti. Davom ettirishni xohlaysizmi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'),
                child: const Text('Bekor'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, 'continue'),
                child: const Text('Davom etish'),
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
        SnackBar(content: Text('Xato: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stol tanlang'),
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
            const Text(
              'Xush kelibsiz!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stol raqamini kiriting yoki stolda QR codeni skanerlang.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _tableIdController,
              decoration: const InputDecoration(
                labelText: 'Stol raqami',
                hintText: '1, 2, 3...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.table_restaurant),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _showScanQRDialog,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('QR Codeni Skanerlang'),
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
              label: Text(_isLoading ? 'Tekshirilmoqda...' : 'Menyuga o\'tish'),
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
