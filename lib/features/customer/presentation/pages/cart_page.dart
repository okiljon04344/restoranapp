import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../orders/application/order_providers.dart';
import '../../../orders/data/orders_repository.dart';
import '../../application/table_provider.dart';

final _submittingProvider = StateProvider.autoDispose<bool>((ref) => false);

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  Future<void> _placeOrder(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final tableNumber = ref.read(currentTableProvider);
    if (tableNumber == null) {
      showMessage(context, l.tableRequired, isError: true);
      context.go('/table-entry');
      return;
    }
    final submitting = ref.read(_submittingProvider.notifier);
    submitting.state = true;
    final placed = await runAction(
      context,
      () async {
        final uid =
            await ref.read(authRepositoryProvider).ensureCustomerSession();
        await ref.read(ordersRepositoryProvider).placeOrder(
              customerUid: uid,
              tableNumber: tableNumber,
              items: ref.read(cartProvider),
            );
      },
      successMessage: l.orderPlaced,
    );
    if (!context.mounted) return;
    submitting.state = false;
    if (placed) {
      ref.read(cartProvider.notifier).clear();
      context.go('/customer/orders');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cartItems = ref.watch(cartProvider);
    final isSubmitting = ref.watch(_submittingProvider);
    final total = cartItems.fold<double>(0, (sum, item) => sum + item.total);

    return AppScaffold(
      title: l.yourCart,
      fallbackLocation: '/customer/menu',
      child: cartItems.isEmpty
          ? EmptyNotice(
              message: l.cartEmpty, icon: Icons.shopping_cart_outlined)
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
                        subtitle: Text(formatMoney(l, item.price)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: isSubmitting
                                  ? null
                                  : () => ref
                                      .read(cartProvider.notifier)
                                      .decrement(item.menuItemId),
                            ),
                            Text('${item.quantity}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: isSubmitting
                                  ? null
                                  : () => ref
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
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l.totalAmount,
                                style: const TextStyle(fontSize: 16)),
                            Text(
                              formatMoney(l, total),
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
                            onPressed: isSubmitting
                                ? null
                                : () => _placeOrder(context, ref),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(l.placeOrder),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
