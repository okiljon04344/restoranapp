import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../services/firestore_service.dart';
import '../../../orders/domain/order_providers.dart';

class AdminMenuManagementPageEnhanced extends ConsumerStatefulWidget {
  const AdminMenuManagementPageEnhanced({super.key});

  @override
  ConsumerState<AdminMenuManagementPageEnhanced> createState() =>
      _AdminMenuManagementPageEnhancedState();
}

class _AdminMenuManagementPageEnhancedState
    extends ConsumerState<AdminMenuManagementPageEnhanced> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = double.parse(_priceController.text.trim());
      final firestoreService = ref.read(firestoreServiceProvider);

      await firestoreService.createMenuItem(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        categoryId: _selectedCategoryId!,
        imageUrl: _imageUrlController.text.trim(),
      );

      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      setState(() => _selectedCategoryId = null);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu item added successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final itemsAsync = ref.watch(menuItemsProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Menu Management',
      maxContentWidth: 1100,
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go back',
          onPressed: () => context.go('/dashboard'),
        ),
      ],
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add New Menu Item',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Item Name *',
                            hintText: 'e.g., Chicken Biryani',
                            prefixIcon: Icon(Icons.restaurant_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Item description...',
                            prefixIcon: Icon(Icons.notes_outlined),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price *',
                            hintText: '50000',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        categoriesAsync.when(
                          data: (categories) => Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedCategoryId,
                                      decoration: const InputDecoration(
                                        labelText: 'Category *',
                                        prefixIcon:
                                            Icon(Icons.category_outlined),
                                      ),
                                      items: categories
                                          .map((cat) => DropdownMenuItem(
                                                value: cat.id,
                                                child: Text(cat.name),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(
                                            () => _selectedCategoryId = value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.icon(
                                    onPressed: _showCreateCategoryDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('New'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (err, stack) => Text('Error: $err'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Image URL',
                            hintText: 'https://example.com/image.jpg',
                            prefixIcon: Icon(Icons.image_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: _isLoading ? null : _submitForm,
                            icon: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  )
                                : const Icon(Icons.add),
                            label: Text(
                                _isLoading ? 'Adding...' : 'Add Menu Item'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Menu Items', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    itemsAsync.when(
                      data: (items) => items.isEmpty
                          ? const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('No menu items yet'),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: item.imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.network(
                                              item.imageUrl,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                width: 50,
                                                height: 50,
                                                color: theme.colorScheme
                                                    .surfaceContainer,
                                                child: const Icon(Icons
                                                    .image_not_supported_outlined),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme.surfaceContainer,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                                Icons.restaurant_outlined),
                                          ),
                                    title: Text(item.name),
                                    subtitle: Text(
                                        '${item.price.toStringAsFixed(0)} - ${item.description}'),
                                    trailing: PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: const Text('Delete'),
                                          onTap: () => _showDeleteConfirmation(
                                            context,
                                            item.id,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              try {
                await ref.read(firestoreServiceProvider).deleteMenuItem(itemId);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateCategoryDialog() {
    final categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Category'),
        content: TextField(
          controller: categoryNameController,
          decoration: const InputDecoration(
            hintText: 'Category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (categoryNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter category name')),
                );
                return;
              }

              try {
                await ref.read(firestoreServiceProvider).createCategory(
                      name: categoryNameController.text.trim(),
                      icon: 'restaurant',
                      sortOrder: 0,
                    );

                if (!context.mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category created')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
