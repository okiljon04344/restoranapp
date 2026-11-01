import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/ingredients_repository.dart';
import '../../application/ingredients_provider.dart';

/// Maps a stored unit code (the value kept in Firestore) to a localized label.
/// Unknown codes fall back to the raw value.
String _unitLabel(AppLocalizations l, String code) {
  switch (code) {
    case 'dona':
      return l.unitPiece;
    case 'kg':
      return l.unitKg;
    case 'g':
      return l.unitGram;
    case 'l':
      return l.unitLiter;
    case 'ml':
      return l.unitMl;
    case 'box':
      return l.unitBox;
    case 'pack':
      return l.unitPack;
    default:
      return code;
  }
}

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
    final l = AppLocalizations.of(context)!;
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final outOfStockAsync = ref.watch(outOfStockIngredientsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.ingredientsManagement,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l.newIngredient),
              onPressed: () => _showAddIngredientDialog(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l.ingredientsSubtitle,
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
                              l.lowStockAlert('${outOfStock.length}'),
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
                                      '${ing.quantity} / ${ing.minimumQuantity} ${_unitLabel(l, ing.unit)}',
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
                                child: Text(l.updateAction),
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
                            l.noIngredientsFound,
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
                                    child: Text(
                                      l.lowStock,
                                      style: const TextStyle(
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
                              '${ing.quantity} ${_unitLabel(l, ing.unit)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l.minQuantityShort('${ing.minimumQuantity} ${_unitLabel(l, ing.unit)}'),
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
                                    child: Text(l.editAction),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _deleteIngredient(ing.id),
                                  tooltip: l.deleteAction,
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
          error: (err, stack) => Text(l.error('$err')),
        ),
      ],
    );
  }

  void _showAddIngredientDialog() {
    final l = AppLocalizations.of(context)!;
    _nameController.clear();
    _quantityController.clear();
    _minimumController.clear();
    _selectedUnit = 'dona';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.addIngredientTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l.ingredientName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: InputDecoration(
                    labelText: l.unitLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: units
                      .map((u) => DropdownMenuItem(
                          value: u, child: Text(_unitLabel(l, u))))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedUnit = value ?? 'dona');
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.quantityLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _minimumController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.minimumQuantityLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _quantityController.text.isEmpty ||
                    _minimumController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.fillAllFields)),
                  );
                  return;
                }

                await ref.read(ingredientsRepositoryProvider).add(
                      name: _nameController.text,
                      unit: _selectedUnit,
                      quantity: double.parse(_quantityController.text),
                      minimumQuantity: double.parse(_minimumController.text),
                    );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.ingredientAdded)),
                );
              },
              child: Text(l.addAction),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditIngredientDialog(Ingredient ingredient) {
    final l = AppLocalizations.of(context)!;
    _nameController.text = ingredient.name;
    _quantityController.text = ingredient.quantity.toString();
    _minimumController.text = ingredient.minimumQuantity.toString();
    _selectedUnit = ingredient.unit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.editIngredientTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l.ingredientName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: InputDecoration(
                    labelText: l.unitLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    ...units,
                    // Keep a stored unit that is not in the fixed list selectable.
                    if (!units.contains(ingredient.unit)) ingredient.unit,
                  ]
                      .map((u) => DropdownMenuItem(
                          value: u, child: Text(_unitLabel(l, u))))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedUnit = value ?? 'dona');
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.quantityLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _minimumController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.minimumQuantityLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _quantityController.text.isEmpty ||
                    _minimumController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.fillAllFields)),
                  );
                  return;
                }

                final quantity = double.parse(_quantityController.text);
                final minimum = double.parse(_minimumController.text);

                await ref.read(ingredientsRepositoryProvider).update(
                      ingredient.id,
                      name: _nameController.text,
                      unit: _selectedUnit,
                      quantity: quantity,
                      minimumQuantity: minimum,
                    );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.ingredientUpdated)),
                );
              },
              child: Text(l.saveAction),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteIngredient(String ingredientId) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteAction),
        content: Text(l.deleteIngredientConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.no),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(ingredientsRepositoryProvider)
                  .delete(ingredientId);

              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.ingredientDeleted)),
              );
            },
            child: Text(l.yesDelete),
          ),
        ],
      ),
    );
  }
}
