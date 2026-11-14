import 'package:flutter/material.dart';

import '../../../../core/ui/feedback.dart';

/// Web build: the camera scanner is not used, the printed code is typed in.
/// Pops with the entered code.
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

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

  void _submit() {
    final value = _qrController.text.trim();
    if (value.isNotEmpty) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.qrScanManualTitle),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_2, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                Text(
                  l.cameraNotAvailable,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(l.enterQrManuallyShort,
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 24),
                TextField(
                  controller: _qrController,
                  decoration: const InputDecoration(
                    hintText: 'table_1',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child:
                      FilledButton(onPressed: _submit, child: Text(l.confirm)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.cancel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
