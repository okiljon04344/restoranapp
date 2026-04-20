import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/ingredients_provider.dart';

class AdminIngredientsPage extends ConsumerStatefulWidget {
  const AdminIngredientsPage({super.key});

  @override
  ConsumerState<AdminIngredientsPage> createState() =>
      _AdminIngredientsPageState();
}

class _AdminIngredientsPageState extends ConsumerState<AdminIngredientsPage> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _minimumController;
  String _selectedUnit = 'dona';

  final units = ['dona', 'kg', 'g', 'l', 'ml', 'box', 'pack'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _minimumController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minimumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final outOfStockAsync = ref.watch(outOfStockIngredientsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Massaliqlar Boshqaruvi',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Yangi Massaliq'),
              onPressed: () => _showAddIngredientDialog(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Taom tayyorlash uchun kerak bo\'lgan massaliqlar ro\'yxati',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        // Out of Stock Alert
        outOfStockAsync.when(
          data: (outOfStock) => outOfStock.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.shade300, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red.shade50,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.red, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '⚠️ Sotib Bo\'lindi (${outOfStock.length} massaliq)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...outOfStock.map(
                        (ing) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ing.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${ing.quantity} / ${ing.minimumQuantity} ${ing.unit}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              FilledButton.tonal(
                                onPressed: () => _showEditIngredientDialog(ing),
                                child: const Text('Yangilash'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
        ),

        if (outOfStockAsync.maybeWhen(
          data: (outOfStock) => outOfStock.isNotEmpty,
          orElse: () => false,
        ))
          const SizedBox(height: 24),

        // Ingredients List
        ingredientsAsync.when(
          data: (ingredients) => ingredients.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2,
                              size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Massaliq topilmadi',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 1200 ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: ingredients.length,
                  itemBuilder: (_, idx) {
                    final ing = ingredients[idx];
                    final percentage =
                        (ing.quantity / ing.minimumQuantity * 100)
                            .clamp(0, 100);
                    final isLow = ing.quantity <= ing.minimumQuantity;

                    return Card(
                      elevation: isLow ? 2 : 1,
                      color: isLow ? Colors.red.shade50 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    ing.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isLow)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Sotib Bo\'lindi',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${ing.quantity} ${ing.unit}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Min: ${ing.minimumQuantity} ${ing.unit}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation(
                                  isLow ? Colors.red : Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.tonal(
                                    onPressed: () =>
                                        _showEditIngredientDialog(ing),
                                    child: const Text('Tahrirlash'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _deleteIngredient(ing.id),
                                  tooltip: 'O\'chirish',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Xato: $err'),
        ),
      ],
    );
  }

  void _showAddIngredientDialog() {
    _nameController.clear();
    _quantityController.clear();
    _minimumController.clear();
    _selectedUnit = 'dona';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Yangi Massaliq Qo\'shish'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Massaliq Nomi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Birlik',
                    border: OutlineInputBorder(),
                  ),
                  items: units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedUnit = value ?? 'dona');
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Miqdori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _minimumController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minimal Miqdori',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            FilledButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _quantityController.text.isEmpty ||
                    _minimumController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Barcha maydonlarni to\'ldiring')),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('cafes')
                    .doc('main_cafe')
                    .collection('ingredients')
                    .add({
                  'name': _nameController.text,
                  'unit': _selectedUnit,
                  'quantity': double.parse(_quantityController.text),
                  'minimumQuantity': double.parse(_minimumController.text),
                  'isOutOfStock': false,
                  'lastUpdated': Timestamp.now(),
                });

                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Massaliq qo\'shildi')),
                );
              },
              child: const Text('Qo\'shish'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditIngredientDialog(Ingredient ingredient) {
    _nameController.text = ingredient.name;
    _quantityController.text = ingredient.quantity.toString();
    _minimumController.text = ingredient.minimumQuantity.toString();
    _selectedUnit = ingredient.unit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Massaliq Tahrirlash'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Massaliq Nomi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Birlik',
                    border: OutlineInputBorder(),
                  ),
                  items: units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedUnit = value ?? 'dona');
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Miqdori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _minimumController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minimal Miqdori',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            FilledButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _quantityController.text.isEmpty ||
                    _minimumController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Barcha maydonlarni to\'ldiring')),
                  );
                  return;
                }

                final quantity = double.parse(_quantityController.text);
                final minimum = double.parse(_minimumController.text);

                await FirebaseFirestore.instance
                    .collection('cafes')
                    .doc('main_cafe')
                    .collection('ingredients')
                    .doc(ingredient.id)
                    .update({
                  'name': _nameController.text,
                  'unit': _selectedUnit,
                  'quantity': quantity,
                  'minimumQuantity': minimum,
                  'isOutOfStock': quantity <= minimum,
                  'lastUpdated': Timestamp.now(),
                });

                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Massaliq yangilandi')),
                );
              },
              child: const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteIngredient(String ingredientId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Ushbu massaliqni o\'chirib tashlamoqchisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo\'q'),
          ),
          FilledButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('cafes')
                  .doc('main_cafe')
                  .collection('ingredients')
                  .doc(ingredientId)
                  .delete();

              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Massaliq o\'chirildi')),
              );
            },
            child: const Text('Ha, O\'chirish'),
          ),
        ],
      ),
    );
  }
}
