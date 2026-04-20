import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerPage({super.key, required this.onQRScanned});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with WidgetsBindingObserver {
  late MobileScannerController controller;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isPageActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  void _initializeScanner() {
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
      print('Error disposing scanner: $e');
    }
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    // Avoid processing multiple barcodes at once
    if (_isProcessing || !_isPageActive) return;
    _isProcessing = true;

    try {
      if (barcodes.barcodes.isNotEmpty) {
        final String code = barcodes.barcodes.first.rawValue ?? '';
        if (code.isNotEmpty) {
          // Call the callback
          widget.onQRScanned(code);

          // Pop after small delay to ensure callback is processed
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _isPageActive) {
              Navigator.of(context).pop();
            }
          });
        }
      }
    } catch (e) {
      print('Error processing barcode: $e');
      _isProcessing = false;
    }
  }

  void _toggleTorch() async {
    try {
      await controller.toggleTorch();
      if (mounted) {
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
      }
    } catch (e) {
      print('Error toggling torch: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Torch error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _isPageActive = false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QR Codeni Skanerlang'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Camera view
            MobileScanner(
              controller: controller,
              onDetect: _handleBarcode,
              errorBuilder: (context, error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text('Camera Error: $error'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Orqaga qaytish'),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Semi-transparent overlay with centered cutout
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cutout box for QR code
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.qr_code_2,
                                size: 80,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              const Text(
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
                      // Torch toggle button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(50),
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
            // Cancel button at the bottom
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
