import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/table_model.dart';
import '../data/tables_repository.dart';

final tablesProvider = StreamProvider<List<TableModel>>((ref) {
  return ref.watch(tablesRepositoryProvider).watchTables();
});
