import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/menu_item_model.dart';
import '../../../orders/domain/order_providers.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage>
    with SingleTickerProviderStateMixin {
  String selectedCategoryId = 'all';
  String searchQuery = '';
  bool _isGridView = true;
  final _searchController = TextEditingController();
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);
    final itemsAsync = ref.watch(menuItemsProvider);
    final cartItems = ref.watch(cartProvider);
    final theme = Theme.of(context);

    if (cartItems.isNotEmpty) {
      _fabAnimController.forward();
    } else {
      _fabAnimController.reverse();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            floating: true,
            snap: true,
            pinned: false,
            elevation: 0,
            backgroundColor: theme.colorScheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/customer'),
            ),
            title: Text(
              l.menu,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isGridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => searchQuery = val),
                  decoration: InputDecoration(
                    hintText: l.searchFood,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchQuery = '');
                            })
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              data: (categories) => SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  children: [
                    _CategoryChip(
                      label: l.all,
                      icon: Icons.apps_rounded,
                      isSelected: selectedCategoryId == 'all',
                      onTap: () => setState(() => selectedCategoryId = 'all'),
                    ),
                    ...categories.map((cat) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _CategoryChip(
                            label: cat.name,
                            icon: Icons.restaurant_menu,
                            isSelected: selectedCategoryId == cat.id,
                            onTap: () =>
                                setState(() => selectedCategoryId = cat.id),
                          ),
                        )),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 52),
              error: (_, __) => const SizedBox(height: 8),
            ),
          ),
          itemsAsync.when(
            data: (items) {
              final filtered = items.where((item) {
                final matchesCat = selectedCategoryId == 'all' ||
                    item.categoryId == selectedCategoryId;
                final matchesSearch =
                    item.name.toLowerCase().contains(searchQuery.toLowerCase());
                return matchesCat && matchesSearch;
              }).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(l.noItemsFound,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }

              if (_isGridView) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _GridMenuCard(
                        item: filtered[index],
                        cartItems: cartItems,
                        onAdd: () => _addToCart(filtered[index]),
                      ),
                      childCount: filtered.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ListMenuCard(
                        item: filtered[index],
                        cartItems: cartItems,
                        onAdd: () => _addToCart(filtered[index]),
                      ),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                  child:
                      Text(AppLocalizations.of(context)!.error(e.toString()))),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnim,
        child: FloatingActionButton.extended(
          onPressed: () => context.go('/customer/cart'),
          backgroundColor: theme.colorScheme.primary,
          icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
          label: Text(
            '${cartItems.length}  ${AppLocalizations.of(context)!.cart}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _addToCart(MenuItemModel item) {
    ref.read(cartProvider.notifier).addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.addedToCart(item.name)),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.green[700],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15, color: isSelected ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridMenuCard extends StatelessWidget {
  final MenuItemModel item;
  final List cartItems;
  final VoidCallback onAdd;

  const _GridMenuCard(
      {required this.item, required this.cartItems, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final inCart = cartItems.any((c) => c.menuItemId == item.id);
    final color = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onAdd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                            color: Colors.blue[50],
                            child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))),
                        errorWidget: (_, __, ___) => _Placeholder(),
                      )
                    : _Placeholder(),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            height: 1.2)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.price.toStringAsFixed(0)} ${l.som}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _AddButton(inCart: inCart, onTap: onAdd),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListMenuCard extends StatelessWidget {
  final MenuItemModel item;
  final List cartItems;
  final VoidCallback onAdd;

  const _ListMenuCard(
      {required this.item, required this.cartItems, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final inCart = cartItems.any((c) => c.menuItemId == item.id);
    final color = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onAdd,
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(20)),
                child: SizedBox(
                  width: 120,
                  height: double.infinity,
                  child: item.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                              color: Colors.blue[50],
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))),
                          errorWidget: (_, __, ___) => _Placeholder(),
                        )
                      : _Placeholder(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.3)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.price.toStringAsFixed(0)} ${l.som}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: color),
                          ),
                          _AddButton(inCart: inCart, onTap: onAdd),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[50],
      width: double.infinity,
      height: double.infinity,
      child: Icon(Icons.fastfood_rounded, size: 36, color: Colors.blue[200]),
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool inCart;
  final VoidCallback onTap;

  const _AddButton({required this.inCart, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: inCart ? Colors.green : color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (inCart ? Colors.green : color).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Icon(inCart ? Icons.check : Icons.add,
            color: Colors.white, size: 18),
      ),
    );
  }
}
