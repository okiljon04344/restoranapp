import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/ingredients_provider.dart';

const _units = ['dona', 'kg', 'g', 'l', 'ml', 'box', 'pack'];

class AdminIngredientsPage extends ConsumerStatefulWidget {
  const AdminIngredientsPage({super.key});

  @override
  ConsumerState<AdminIngredientsPage> createState() =>
      _AdminIngredientsPageState();
}

class _AdminIngredientsPageState extends ConsumerState<AdminIngredientsPage> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minimumController = TextEditingController();
  String _selectedUnit = _units.first;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance
          .collection('cafes')
          .doc('main_cafe')
          .collection('ingredients');

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minimumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final outOfStockAsync = ref.watch(outOfStockIngredientsProvider);
    final outOfStock = outOfStockAsync.value ?? const <Ingredient>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Massaliqlar Boshqaruvi',
              style: theme.textTheme.headlineMedium,
            ),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Yangi Massaliq'),
              onPressed: _showIngredientDialog,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Taom tayyorlash uchun kerak bo\'lgan massaliqlar ro\'yxati',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        if (outOfStock.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.08),
              border: Border.all(color: scheme.error.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: scheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sotib Bo\'lindi (${outOfStock.length} massaliq)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final ing in outOfStock)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ing.name, style: theme.textTheme.bodyLarge),
                              Text(
                                '${ing.quantity} / ${ing.minimumQuantity} ${ing.unit}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _showIngredientDialog(ing),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                          ),
                          child: const Text('Yangilash'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        ingredientsAsync.when(
          data: (ingredients) => ingredients.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Massaliq topilmadi',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisExtent: 200,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: ingredients.length,
                  itemBuilder: (_, idx) =>
                      _buildIngredientCard(context, ingredients[idx]),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Xato: $err'),
        ),
      ],
    );
  }

  Widget _buildIngredientCard(BuildContext context, Ingredient ing) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLow = ing.quantity <= ing.minimumQuantity;
    final fill = ing.minimumQuantity == 0
        ? 1.0
        : (ing.quantity / ing.minimumQuantity).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ing.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLow)
                  StatusBadge(label: 'Sotib Bo\'lindi', color: scheme.error),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${ing.quantity} ${ing.unit}',
              style: theme.textTheme.titleLarge,
            ),
            Text(
              'Min: ${ing.minimumQuantity} ${ing.unit}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fill,
                minHeight: 6,
                color: isLow ? scheme.error : context.palette.success,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showIngredientDialog(ing),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Tahrirlash'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                  onPressed: () => _deleteIngredient(ing.id),
                  tooltip: 'O\'chirish',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the add form, or the edit form when [ingredient] is given.
  void _showIngredientDialog([Ingredient? ingredient]) {
    _nameController.text = ingredient?.name ?? '';
    _quantityController.text = ingredient?.quantity.toString() ?? '';
    _minimumController.text = ingredient?.minimumQuantity.toString() ?? '';
    _selectedUnit = ingredient?.unit ?? _units.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            ingredient == null
                ? 'Yangi Massaliq Qo\'shish'
                : 'Massaliq Tahrirlash',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Massaliq Nomi',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: const InputDecoration(labelText: 'Birlik'),
                  items: _units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedUnit = value ?? _units.first);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Miqdori'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _minimumController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Minimal Miqdori'),
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
              onPressed: () => _saveIngredient(context, ingredient),
              child: Text(ingredient == null ? 'Qo\'shish' : 'Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveIngredient(
      BuildContext dialogContext, Ingredient? ingredient) async {
    if (_nameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _minimumController.text.isEmpty) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        const SnackBar(content: Text('Barcha maydonlarni to\'ldiring')),
      );
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final minimum = double.parse(_minimumController.text);
    final data = {
      'name': _nameController.text,
      'unit': _selectedUnit,
      'quantity': quantity,
      'minimumQuantity': minimum,
      'isOutOfStock': ingredient == null ? false : quantity <= minimum,
      'lastUpdated': Timestamp.now(),
    };

    if (ingredient == null) {
      await _collection.add(data);
    } else {
      await _collection.doc(ingredient.id).update(data);
    }

    if (!dialogContext.mounted) return;
    Navigator.pop(dialogContext);
    ScaffoldMessenger.of(dialogContext).showSnackBar(
      SnackBar(
        content: Text(
          ingredient == null ? 'Massaliq qo\'shildi' : 'Massaliq yangilandi',
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
              await _collection.doc(ingredientId).delete();

              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Massaliq o\'chirildi')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Ha, O\'chirish'),
          ),
        ],
      ),
    );
  }
}
