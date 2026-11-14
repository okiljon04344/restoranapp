import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/cafe_refs.dart';
import '../../../models/menu_item_model.dart';
import '../../../models/recipe_item_model.dart';

/// Stock quantities are doubles (0.2 kg per portion, ...). Comparisons allow
/// for binary rounding so that e.g. `1 - 4 * 0.2` still covers one portion.
const stockEpsilon = 1e-6;

/// Rounds a stock quantity to six decimals and never below zero, so repeated
/// deductions do not accumulate floating point noise.
double normalizeStock(double value) {
  final rounded = (value * 1e6).round() / 1e6;
  return rounded < 0 ? 0 : rounded;
}

/// True when [stock] cannot cover one portion of [recipe]. Ingredients that
/// are missing from [stock] (deleted, or not part of the lookup) are ignored.
bool isRecipeOutOfStock(List<RecipeItem> recipe, Map<String, double> stock) {
  for (final line in recipe) {
    final available = stock[line.ingredientId];
    if (available != null && available + stockEpsilon < line.quantity) {
      return true;
    }
  }
  return false;
}

/// Recomputes `outOfStock` for every menu item from the current ingredient
/// quantities and writes only the flags that changed. Called after an admin
/// edits stock or a recipe.
Future<void> syncMenuAvailability(FirebaseFirestore db) async {
  final refs = CafeRefs(db);
  final ingredients = await refs.ingredients.get();
  final stock = {
    for (final doc in ingredients.docs)
      doc.id: readDouble(doc.data()['quantity']),
  };
  final items = await refs.menuItems.get();
  final batch = db.batch();
  var changed = false;
  for (final doc in items.docs) {
    final item = MenuItemModel.fromFirestore(doc.data(), doc.id);
    final outOfStock = isRecipeOutOfStock(item.recipe, stock);
    if (outOfStock != item.outOfStock) {
      batch.update(doc.reference, {
        'outOfStock': outOfStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      changed = true;
    }
  }
  if (changed) await batch.commit();
}
