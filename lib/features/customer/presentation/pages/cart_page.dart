import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../orders/domain/order_providers.dart';
import '../../domain/table_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cartItems = ref.watch(cartProvider);
    final tableId = ref.watch(tableIdProvider);
    final total = cartItems.fold<double>(0, (sum, item) => sum + item.total);

    return AppScaffold(
      title: l.yourCart,
      child: cartItems.isEmpty
          ? Center(child: Text(l.cartEmpty))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Text(item.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle:
                            Text('${item.price.toStringAsFixed(0)} ${l.som}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .decrement(item.menuItemId),
                            ),
                            Text('${item.quantity}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .increment(item.menuItemId),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l.totalAmount,
                              style: const TextStyle(fontSize: 16)),
                          Text(
                            '${total.toStringAsFixed(0)} ${l.som}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () async {
                            await ref.read(ordersActionProvider).placeOrder(
                                  items: cartItems,
                                  orderType: 'Dine-in',
                                  tableName: 'Table $tableId',
                                  tableNumber:
                                      int.tryParse(tableId ?? '0') ?? 0,
                                );
                            ref.read(cartProvider.notifier).clear();
                            if (context.mounted) {
                              context.go('/customer/tracking');
                            }
                          },
                          child: Text(l.placeOrder),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
