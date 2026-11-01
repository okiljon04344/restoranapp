import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/ingredient_model.dart';
import '../data/ingredients_repository.dart';

export '../../../models/ingredient_model.dart';

final ingredientsProvider = StreamProvider<List<Ingredient>>((ref) {
  return ref.watch(ingredientsRepositoryProvider).watchAll();
});

final outOfStockIngredientsProvider = StreamProvider<List<Ingredient>>((ref) {
  return ref.watch(ingredientsRepositoryProvider).watchLowStock();
});
