import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../models/category_model.dart';
import '../../../../models/menu_item_model.dart';
import '../../../../models/recipe_item_model.dart';
import '../../../menu/data/menu_repository.dart';
import '../../../orders/application/order_providers.dart';
import '../../application/ingredients_provider.dart';
import 'ingredients_view.dart';

/// Admin: categories and menu items, including each item's recipe (the
/// ingredients one portion takes out of stock).
class MenuAdminView extends ConsumerWidget {
  const MenuAdminView({super.key});

  Future<void> _addCategory(
      BuildContext context, WidgetRef ref, int count) async {
    final l = context.l10n;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _CategoryDialog(),
    );
    if (name == null || !context.mounted) return;
    await runAction(
      context,
      () => ref
          .read(menuRepositoryProvider)
          .createCategory(name: name, sortOrder: count),
      successMessage: l.categoryCreated,
    );
  }

  Future<void> _deleteCategory(
      BuildContext context, WidgetRef ref, CategoryModel category) async {
    final l = context.l10n;
    final confirmed = await confirm(
      context,
      title: l.deleteAction,
      message: l.confirmDeleteCategory(category.name),
    );
    if (!confirmed || !context.mounted) return;
    await runAction(context,
        () => ref.read(menuRepositoryProvider).deleteCategory(category.id));
  }

  Future<void> _editItem(BuildContext context, WidgetRef ref,
      List<CategoryModel> categories,
      [MenuItemModel? existing]) async {
    final l = context.l10n;
    if (categories.isEmpty) {
      showMessage(context, l.createCategoryFirst, isError: true);
      return;
    }
    final draft = await showDialog<_ItemDraft>(
      context: context,
      builder: (_) => _ItemDialog(
        categories: categories,
        ingredients: ref.read(ingredientsProvider).valueOrNull ?? const [],
        existing: existing,
      ),
    );
    if (draft == null || !context.mounted) return;
    final repo = ref.read(menuRepositoryProvider);
    await runAction(
      context,
      () async {
        if (existing == null) {
          await repo.createMenuItem(
            name: draft.name,
            description: draft.description,
            price: draft.price,
            categoryId: draft.categoryId,
            imageUrl: draft.imageUrl,
            recipe: draft.recipe,
          );
        } else {
          await repo.updateMenuItem(
            existing.id,
            name: draft.name,
            description: draft.description,
            price: draft.price,
            categoryId: draft.categoryId,
            imageUrl: draft.imageUrl,
            recipe: draft.recipe,
          );
        }
      },
      successMessage: existing == null ? l.menuItemAdded : l.menuItemUpdated,
    );
  }

  Future<void> _deleteItem(
      BuildContext context, WidgetRef ref, MenuItemModel item) async {
    final l = context.l10n;
    final confirmed = await confirm(
      context,
      title: l.deleteItem,
      message: l.confirmDeleteItem,
    );
    if (!confirmed || !context.mounted) return;
    await runAction(
      context,
      () => ref.read(menuRepositoryProvider).deleteMenuItem(item.id),
      successMessage: l.itemDeleted,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? const <CategoryModel>[];
    // Kept alive while the menu is open so the recipe editor has the list.
    ref.watch(ingredientsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.categoriesLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        AsyncView<List<CategoryModel>>(
          value: categoriesAsync,
          onRetry: () => ref.invalidate(categoriesProvider),
          data: (categories) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in categories)
                InputChip(
                  label: Text(category.name),
                  onDeleted: () => _deleteCategory(context, ref, category),
                  deleteButtonTooltipMessage: l.deleteAction,
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: Text(l.createNewCategory),
                onPressed: () => _addCategory(context, ref, categories.length),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(l.menuItems,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            FilledButton.icon(
              onPressed: () => _editItem(context, ref, categories),
              icon: const Icon(Icons.add),
              label: Text(l.addMenuItem),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AsyncView<List<MenuItemModel>>(
          value: ref.watch(menuItemsProvider),
          onRetry: () => ref.invalidate(menuItemsProvider),
          data: (items) {
            if (items.isEmpty) {
              return EmptyNotice(
                  message: l.noMenuItemsYet, icon: Icons.restaurant_menu);
            }
            final categoryNames = {for (final c in categories) c.id: c.name};
            return Column(
              children: [
                for (final item in items)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text([
                        formatMoney(l, item.price),
                        categoryNames[item.categoryId] ?? '—',
                        l.recipeLinesCount('${item.recipe.length}'),
                        if (item.outOfStock) l.soldOut,
                      ].join(' · ')),
                      leading: Icon(
                        Icons.fastfood,
                        color: item.canOrder ? Colors.green : Colors.red,
                      ),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Tooltip(
                            message: l.availableOnMenu,
                            child: Switch(
                              value: item.isAvailable,
                              onChanged: (value) => runAction(
                                context,
                                () => ref
                                    .read(menuRepositoryProvider)
                                    .setAvailable(item.id, isAvailable: value),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: l.editAction,
                            onPressed: () =>
                                _editItem(context, ref, categories, item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            tooltip: l.deleteAction,
                            onPressed: () => _deleteItem(context, ref, item),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog();

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.createNewCategory),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l.categoryNameHint),
          validator: (value) =>
              (value?.trim().isEmpty ?? true) ? l.enterCategoryName : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.createAction)),
      ],
    );
  }
}

class _ItemDraft {
  const _ItemDraft({
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageUrl,
    required this.recipe,
  });

  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String imageUrl;
  final List<RecipeItem> recipe;
}

class _RecipeRow {
  _RecipeRow(this.ingredientId, String quantity)
      : quantity = TextEditingController(text: quantity);

  String? ingredientId;
  final TextEditingController quantity;
}

class _ItemDialog extends StatefulWidget {
  const _ItemDialog({
    required this.categories,
    required this.ingredients,
    this.existing,
  });

  final List<CategoryModel> categories;
  final List<Ingredient> ingredients;
  final MenuItemModel? existing;

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _imageUrl;
  late String _categoryId;
  final List<_RecipeRow> _recipe = [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _description = TextEditingController(text: existing?.description ?? '');
    _price = TextEditingController(
        text: existing == null ? '' : formatQuantity(existing.price));
    _imageUrl = TextEditingController(text: existing?.imageUrl ?? '');
    final ids = widget.categories.map((c) => c.id).toSet();
    final current = existing?.categoryId;
    _categoryId =
        current != null && ids.contains(current) ? current : ids.first;
    final known = widget.ingredients.map((i) => i.id).toSet();
    for (final line in existing?.recipe ?? const <RecipeItem>[]) {
      // Lines pointing at a deleted ingredient are dropped on save.
      if (known.contains(line.ingredientId)) {
        _recipe.add(_RecipeRow(line.ingredientId, formatQuantity(line.quantity)));
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _imageUrl.dispose();
    for (final row in _recipe) {
      row.quantity.dispose();
    }
    super.dispose();
  }

  void _removeRow(_RecipeRow row) {
    setState(() => _recipe.remove(row));
    // Disposed after the frame that unmounts the row's text field.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => row.quantity.dispose());
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Merge duplicate ingredient lines into one.
    final merged = <String, double>{};
    for (final row in _recipe) {
      final id = row.ingredientId;
      final quantity = parseDecimal(row.quantity.text);
      if (id == null || quantity == null || quantity <= 0) continue;
      merged[id] = (merged[id] ?? 0) + quantity;
    }
    Navigator.pop(
      context,
      _ItemDraft(
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: parseDecimal(_price.text) ?? 0,
        categoryId: _categoryId,
        imageUrl: _imageUrl.text.trim(),
        recipe: [
          for (final e in merged.entries)
            RecipeItem(ingredientId: e.key, quantity: e.value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String? required(String? value) =>
        (value?.trim().isEmpty ?? true) ? l.fillRequiredFields : null;

    return AlertDialog(
      title: Text(widget.existing == null ? l.addNewMenuItem : l.editMenu),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l.itemNameRequired),
                  validator: required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: l.descriptionLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: l.priceRequired, suffixText: l.som),
                  validator: (value) {
                    final price = parseDecimal(value ?? '');
                    return price == null || price < 0 ? l.invalidNumber : null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: InputDecoration(labelText: l.categoryRequired),
                  items: [
                    for (final category in widget.categories)
                      DropdownMenuItem(
                          value: category.id, child: Text(category.name)),
                  ],
                  onChanged: (value) =>
                      setState(() => _categoryId = value ?? _categoryId),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrl,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(labelText: l.imageUrl),
                ),
                const SizedBox(height: 20),
                Text(l.recipeTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(l.recipeHint,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                for (final row in _recipe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            initialValue: row.ingredientId,
                            isExpanded: true,
                            decoration:
                                InputDecoration(labelText: l.ingredientName),
                            items: [
                              for (final ingredient in widget.ingredients)
                                DropdownMenuItem(
                                  value: ingredient.id,
                                  child: Text(
                                    '${ingredient.name} (${ingredientUnitLabel(l, ingredient.unit)})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            validator: (value) =>
                                value == null ? l.fillRequiredFields : null,
                            onChanged: (value) =>
                                setState(() => row.ingredientId = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: row.quantity,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration:
                                InputDecoration(labelText: l.quantityLabel),
                            validator: (value) {
                              final quantity = parseDecimal(value ?? '');
                              return quantity == null || quantity <= 0
                                  ? l.invalidNumber
                                  : null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: l.deleteAction,
                          onPressed: () => _removeRow(row),
                        ),
                      ],
                    ),
                  ),
                TextButton.icon(
                  onPressed: widget.ingredients.isEmpty
                      ? null
                      : () =>
                          setState(() => _recipe.add(_RecipeRow(null, ''))),
                  icon: const Icon(Icons.add),
                  label: Text(l.addRecipeLine),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.existing == null ? l.addAction : l.saveAction),
        ),
      ],
    );
  }
}
