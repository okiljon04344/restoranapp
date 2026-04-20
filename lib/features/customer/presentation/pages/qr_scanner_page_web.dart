import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Codeni Kiritib Chiqing'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            const Text(
              'Kamera bu platform-da mavjud emas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'QR code ma\'lumotini qo\'lda kiritib chiqing:',
              style: TextStyle(fontSize: 14),
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
                child: const Text('Tasdiqlang'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: const Text('Bekor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
