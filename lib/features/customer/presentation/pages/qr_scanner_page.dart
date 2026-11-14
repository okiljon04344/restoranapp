import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/ui/feedback.dart';

/// Camera scanner; pops with the raw value of the first QR code it reads.
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final _controller = MobileScannerController(facing: CameraFacing.back);
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    // The camera keeps reporting the same code; only the first one counts.
    if (_handled || !mounted) return;
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(code);
        return;
      }
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } catch (e) {
      if (mounted) {
        showMessage(context, context.l10n.torchError('$e'), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.qrScanTitle), centerTitle: true),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      l.cameraError(error.errorCode.name),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.goBack),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: IgnorePointer(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.placeQrInFrame,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<MobileScannerState>(
                      valueListenable: _controller,
                      builder: (context, state, _) => IconButton.filledTonal(
                        onPressed: _toggleTorch,
                        icon: Icon(state.torchState == TorchState.on
                            ? Icons.flash_on
                            : Icons.flash_off),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.tonal(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l.cancel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
