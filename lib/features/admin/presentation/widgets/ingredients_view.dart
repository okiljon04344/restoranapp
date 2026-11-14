import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/ingredients_provider.dart';
import '../../data/ingredients_repository.dart';

const ingredientUnitCodes = ['dona', 'kg', 'g', 'l', 'ml', 'box', 'pack'];

/// Maps a stored unit code to its localized label; unknown codes are shown
/// as stored.
String ingredientUnitLabel(AppLocalizations l, String code) => switch (code) {
      'dona' => l.unitPiece,
      'kg' => l.unitKg,
      'g' => l.unitGram,
      'l' => l.unitLiter,
      'ml' => l.unitMl,
      'box' => l.unitBox,
      'pack' => l.unitPack,
      _ => code,
    };

/// Admin: stock list with low-stock alert, add/edit/delete.
class IngredientsView extends ConsumerWidget {
  const IngredientsView({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref,
      [Ingredient? existing]) async {
    final l = context.l10n;
    final draft = await showDialog<_IngredientDraft>(
      context: context,
      builder: (_) => _IngredientDialog(existing: existing),
    );
    if (draft == null || !context.mounted) return;
    final repo = ref.read(ingredientsRepositoryProvider);
    await runAction(
      context,
      () async {
        if (existing == null) {
          await repo.add(
            name: draft.name,
            unit: draft.unit,
            quantity: draft.quantity,
            minimumQuantity: draft.minimum,
          );
        } else {
          await repo.update(
            existing.id,
            name: draft.name,
            unit: draft.unit,
            quantity: draft.quantity,
            minimumQuantity: draft.minimum,
          );
        }
      },
      successMessage: existing == null ? l.ingredientAdded : l.ingredientUpdated,
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Ingredient ingredient) async {
    final l = context.l10n;
    final confirmed = await confirm(
      context,
      title: l.deleteAction,
      message: l.deleteIngredientConfirm,
    );
    if (!confirmed || !context.mounted) return;
    await runAction(
      context,
      () => ref.read(ingredientsRepositoryProvider).delete(ingredient.id),
      successMessage: l.ingredientDeleted,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.ingredientsSubtitle,
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _edit(context, ref),
          icon: const Icon(Icons.add),
          label: Text(l.newIngredient),
        ),
        const SizedBox(height: 16),
        AsyncView<List<Ingredient>>(
          value: ref.watch(ingredientsProvider),
          onRetry: () => ref.invalidate(ingredientsProvider),
          data: (ingredients) {
            if (ingredients.isEmpty) {
              return EmptyNotice(
                  message: l.noIngredientsFound, icon: Icons.inventory_2);
            }
            final low = ingredients.where((i) => i.isLow).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (low.isNotEmpty)
                  Card(
                    color: Colors.red.shade50,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_rounded,
                          color: Colors.red),
                      title: Text(
                        l.lowStockAlert('${low.length}'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(low.map((i) => i.name).join(', ')),
                    ),
                  ),
                for (final ingredient in ingredients)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.inventory_2,
                        color: ingredient.isLow ? Colors.red : Colors.green,
                      ),
                      title: Text(ingredient.name),
                      subtitle: Text(
                        '${formatQuantity(ingredient.quantity)} ${ingredientUnitLabel(l, ingredient.unit)}'
                        ' · ${l.minQuantityShort(formatQuantity(ingredient.minimumQuantity))}'
                        '${ingredient.isLow ? ' · ${l.lowStock}' : ''}',
                      ),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: l.editAction,
                            onPressed: () => _edit(context, ref, ingredient),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            tooltip: l.deleteAction,
                            onPressed: () => _delete(context, ref, ingredient),
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

class _IngredientDraft {
  const _IngredientDraft(this.name, this.unit, this.quantity, this.minimum);

  final String name;
  final String unit;
  final double quantity;
  final double minimum;
}

class _IngredientDialog extends StatefulWidget {
  const _IngredientDialog({this.existing});

  final Ingredient? existing;

  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late final TextEditingController _minimum;
  late String _unit;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _quantity = TextEditingController(
        text: existing == null ? '' : formatQuantity(existing.quantity));
    _minimum = TextEditingController(
        text: existing == null ? '' : formatQuantity(existing.minimumQuantity));
    _unit = existing?.unit ?? ingredientUnitCodes.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _minimum.dispose();
    super.dispose();
  }

  String? _validateAmount(AppLocalizations l, String? value) {
    final amount = parseDecimal(value ?? '');
    return amount == null || amount < 0 ? l.invalidNumber : null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      _IngredientDraft(
        _name.text.trim(),
        _unit,
        parseDecimal(_quantity.text) ?? 0,
        parseDecimal(_minimum.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // Keep a unit stored by an older version selectable.
    final units = {...ingredientUnitCodes, _unit}.toList();
    return AlertDialog(
      title: Text(widget.existing == null
          ? l.addIngredientTitle
          : l.editIngredientTitle),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l.ingredientName),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? l.fillRequiredFields
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: InputDecoration(labelText: l.unitLabel),
                  items: [
                    for (final code in units)
                      DropdownMenuItem(
                        value: code,
                        child: Text(ingredientUnitLabel(l, code)),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _unit = value ?? _unit),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantity,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l.quantityLabel),
                  validator: (value) => _validateAmount(l, value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _minimum,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(labelText: l.minimumQuantityLabel),
                  validator: (value) => _validateAmount(l, value),
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
