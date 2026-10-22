import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class QRScannerPage extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerPage({super.key, required this.onQRScanned});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final _qrController = TextEditingController();

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.qrScanTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            Text(
              l.webNoCameraTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l.enterQrManually,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _qrController,
              decoration: const InputDecoration(
                hintText: 'table_1, table_2, ...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.onQRScanned(value);
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  if (_qrController.text.isNotEmpty) {
                    widget.onQRScanned(_qrController.text);
                    Navigator.pop(context);
                  }
                },
                child: Text(l.confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
