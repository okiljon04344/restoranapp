import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../orders/domain/order_providers.dart';

class AdminMenuManagementPage extends ConsumerStatefulWidget {
  const AdminMenuManagementPage({super.key});

  @override
  ConsumerState<AdminMenuManagementPage> createState() =>
      _AdminMenuManagementPageState();
}

class _AdminMenuManagementPageState
    extends ConsumerState<AdminMenuManagementPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return AppScaffold(
      title: 'Menyuni boshqarish',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Yangi taom qo\'shish',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Name field
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Taom nomi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.restaurant),
            ),
          ),
          const SizedBox(height: 16),
          // Description field
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Tasviri',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // Price field
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(
              labelText: 'Narxi (so\'m)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          // Image URL field
          TextField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              labelText: 'Rasm URL (ixtiyoriy)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.image),
            ),
          ),
          const SizedBox(height: 16),
          // Category dropdown
          categoriesAsync.when(
            data: (categories) => DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              items: categories
                  .map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
              decoration: const InputDecoration(
                labelText: 'Kategoriya',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text('Xato: $err'),
          ),
          const SizedBox(height: 24),
          // Submit button
          FilledButton.icon(
            onPressed: _isLoading ? null : _submitForm,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: Text(_isLoading ? 'Qo\'shilyapti...' : 'Taom qo\'shish'),
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'Mavjud taomlar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ref.watch(menuItemsProvider).when(
                data: (items) => items.isEmpty
                    ? const Center(child: Text('Taom mavjud emas'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text(
                                  '${item.price.toStringAsFixed(0)} so\'m'),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('O\'chirish'),
                                    onTap: () => _deleteItem(item.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Xato: $err'),
              ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barcha maydonlarni to\'ldiring')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = double.parse(_priceController.text);
      final firestoreService = ref.read(firestoreServiceProvider);

      await firestoreService.createMenuItem(
        name: _nameController.text,
        description: _descriptionController.text,
        price: price,
        categoryId: _selectedCategoryId!,
        imageUrl:
            _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Taom muvaffaqiyat qo\'shildi!')),
      );

      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      setState(() => _selectedCategoryId = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xato: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteItem(String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Taomni o\'chirish'),
        content: const Text('Bu taomni o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Yo\'q'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.deleteMenuItem(itemId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Taom o\'chirildi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xato: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
