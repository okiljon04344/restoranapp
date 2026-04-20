import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../orders/domain/order_providers.dart';
import '../../../../services/qr_code_service.dart';

final _tablesListProvider = FutureProvider<List<int>>((ref) async {
  // Generate list of tables (1-50 for now, can be customized)
  return List.generate(50, (i) => i + 1);
});

final _selectedTablesProvider =
    StateProvider<Set<int>>((ref) => <int>{}.toSet());

class AdminQRCodePage extends ConsumerWidget {
  const AdminQRCodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final tablesAsync = ref.watch(_tablesListProvider);
    final selectedTables = ref.watch(_selectedTablesProvider);
    final qrService = ref.watch(qrCodeServiceProvider);

    return AppScaffold(
      title: 'QR Code Generator',
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go back',
          onPressed: () => context.go('/dashboard'),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generate Table QR Codes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select tables to generate QR codes for. Customers can scan these QR codes at their table with their phone.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (selectedTables.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selected Tables: ${selectedTables.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          ref
                              .read(_selectedTablesProvider.notifier)
                              .state
                              .clear();
                        },
                        style:
                            FilledButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _QRPreviewGrid(selectedTables: selectedTables),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _downloadQRCodes(
                        context,
                        selectedTables,
                        qrService,
                      ),
                      icon: const Icon(Icons.download),
                      label: const Text('Download QR Codes'),
                    ),
                  ),
                ],
              )
            else
              const SizedBox.shrink(),
            const SizedBox(height: 24),
            const Text(
              'Select Tables',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            tablesAsync.when(
              data: (tables) => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  final tableNum = tables[index];
                  final isSelected = selectedTables.contains(tableNum);
                  final activeOrders =
                      orders.where((o) => o.tableNumber == tableNum).length;

                  return GestureDetector(
                    onTap: () {
                      final newSet = Set<int>.from(selectedTables);
                      if (isSelected) {
                        newSet.remove(tableNum);
                      } else {
                        newSet.add(tableNum);
                      }
                      ref.read(_selectedTablesProvider.notifier).state = newSet;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade100
                            : Colors.grey.shade100,
                        border: Border.all(
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tableNum.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                          ),
                          if (activeOrders > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$activeOrders',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadQRCodes(
    BuildContext context,
    Set<int> tables,
    QRCodeService qrService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Codes Ready'),
        content: Text(
          'Generated QR codes for ${tables.length} tables.\n\nYou can now:\n- Print them\n- Display on screens\n- Share with customers',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _QRPreviewGrid extends StatelessWidget {
  final Set<int> selectedTables;

  const _QRPreviewGrid({required this.selectedTables});

  @override
  Widget build(BuildContext context) {
    final qrService = ProviderContainer().read(qrCodeServiceProvider);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: selectedTables.length,
      itemBuilder: (context, index) {
        final tableNum = selectedTables.toList()[index];
        final qrData = qrService.generateTableQRData(tableNum);

        return Card(
          elevation: 2,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 150,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  'Table $tableNum',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
