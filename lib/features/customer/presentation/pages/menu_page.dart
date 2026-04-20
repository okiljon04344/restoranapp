import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/menu_item_model.dart';
import '../../../orders/domain/order_providers.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  String selectedCategoryId = 'all';
  String searchQuery = '';
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);
    final itemsAsync = ref.watch(menuItemsProvider);
    final cartItems = ref.watch(cartProvider);

    return AppScaffold(
      title: l10n.menu,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () => context.go('/customer/cart'),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
            if (cartItems.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${cartItems.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ],
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: l10n.searchFood,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      _searchController.clear();
                      setState(() => searchQuery = '');
                    }) 
                  : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          // Categories
          categoriesAsync.when(
            data: (categories) => SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ChoiceChip(
                    label: Text(l10n.all),
                    selected: selectedCategoryId == 'all',
                    onSelected: (_) => setState(() => selectedCategoryId = 'all'),
                  ),
                  ...categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: selectedCategoryId == cat.id,
                      onSelected: (_) => setState(() => selectedCategoryId = cat.id),
                    ),
                  )),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 16),

          // Menu Items
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filtered = items.where((item) {
                  final matchesCategory = selectedCategoryId == 'all' || item.categoryId == selectedCategoryId;
                  final matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase());
                  return matchesCategory && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.noItemsFound));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Hero(
                      tag: 'menu_item_${item.id}',
                      child: _EnhancedMenuCard(
                        item: item,
                        currency: l10n.currency,
                        onAdd: () {
                          ref.read(cartProvider.notifier).addItem(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.itemAdded(item.name)), duration: const Duration(seconds: 1)),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.errorMessage(e.toString()))),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedMenuCard extends StatelessWidget {
  final MenuItemModel item;
  final String currency;
  final VoidCallback onAdd;

  const _EnhancedMenuCard({required this.item, required this.currency, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.fastfood, size: 40, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(item.description, maxLines: 2, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.price.toStringAsFixed(0)} $currency', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)),
                      IconButton.filled(onPressed: onAdd, icon: const Icon(Icons.add)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
