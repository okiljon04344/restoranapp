import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../l10n/app_localizations.dart';

class QRScannerPage extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerPage({super.key, required this.onQRScanned});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with WidgetsBindingObserver {
  late final MobileScannerController controller;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isPageActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _isPageActive = false;
        break;
      case AppLifecycleState.resumed:
        _isPageActive = true;
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      controller.dispose();
    } catch (e) {
      debugPrint('Error disposing scanner: $e');
    }
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (_isProcessing || !_isPageActive) return;
    _isProcessing = true;

    try {
      if (barcodes.barcodes.isNotEmpty) {
        final String code = barcodes.barcodes.first.rawValue ?? '';
        if (code.isNotEmpty) {
          widget.onQRScanned(code);

          // Let the callback's snackbar show before leaving the scanner.
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _isPageActive) {
              Navigator.of(context).pop();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error processing barcode: $e');
      _isProcessing = false;
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await controller.toggleTorch();
      if (mounted) {
        setState(() => _isTorchOn = !_isTorchOn);
      }
    } catch (e) {
      debugPrint('Error toggling torch: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Torch error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _isPageActive = false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.qrScanTitle ??
              'QR Codeni Skanerlang'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: controller,
              onDetect: _handleBarcode,
              errorBuilder: (context, error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text('Camera Error: $error'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                            AppLocalizations.of(context)?.goBack ?? 'Go Back'),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 80,
                                color: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'QR codeni to\'g\'ri joyda qo\'ying',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isTorchOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          ),
                          onPressed: _toggleTorch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('Bekor qilish'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
