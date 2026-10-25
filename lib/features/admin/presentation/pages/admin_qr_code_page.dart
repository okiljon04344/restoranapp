import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../services/qr_code_service.dart';
import '../../../orders/domain/order_providers.dart';

/// Table numbers offered for QR generation.
final _tableNumbers = List.generate(50, (i) => i + 1);

final _selectedTablesProvider = StateProvider<Set<int>>((ref) => <int>{});

class AdminQRCodePage extends ConsumerWidget {
  const AdminQRCodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final selectedTables = ref.watch(_selectedTablesProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppScaffold(
      title: 'QR Code Generator',
      maxContentWidth: 960,
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Table QR Codes',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select tables to generate QR codes for. Customers can scan these QR codes at their table with their phone.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (selectedTables.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Tables: ${selectedTables.length}',
                    style: theme.textTheme.titleMedium,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      ref.read(_selectedTablesProvider.notifier).state = {};
                    },
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
                  onPressed: () => _downloadQRCodes(context, selectedTables),
                  icon: const Icon(Icons.download),
                  label: const Text('Download QR Codes'),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text('Select Tables', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 88,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tableNumbers.length,
              itemBuilder: (context, index) {
                final tableNum = _tableNumbers[index];
                final isSelected = selectedTables.contains(tableNum);
                final activeOrders =
                    orders.where((o) => o.tableNumber == tableNum).length;

                return Material(
                  color: isSelected ? scheme.primaryContainer : scheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    side: BorderSide(
                      color:
                          isSelected ? scheme.primary : scheme.outlineVariant,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    onTap: () {
                      final newSet = Set<int>.from(selectedTables);
                      if (!newSet.remove(tableNum)) newSet.add(tableNum);
                      ref.read(_selectedTablesProvider.notifier).state = newSet;
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$tableNum',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isSelected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurface,
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
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$activeOrders',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _downloadQRCodes(BuildContext context, Set<int> tables) {
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

class _QRPreviewGrid extends ConsumerWidget {
  final Set<int> selectedTables;

  const _QRPreviewGrid({required this.selectedTables});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrService = ref.watch(qrCodeServiceProvider);
    final theme = Theme.of(context);
    final tables = selectedTables.toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final tableNum = tables[index];

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: QrImageView(
                    data: qrService.generateTableQRData(tableNum),
                    version: QrVersions.auto,
                    size: 150,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: theme.colorScheme.surfaceContainer,
                child: Text(
                  'Table $tableNum',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
