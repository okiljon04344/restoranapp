import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/table_model.dart';

class DemoRepository {
  const DemoRepository();

  List<CategoryModel> get categories => const [
        CategoryModel(
            id: 'cat_1',
            name: 'Taomlar',
            icon: 'lunch_dining',
            sortOrder: 1,
            isActive: true),
        CategoryModel(
            id: 'cat_2',
            name: 'Ichimliklar',
            icon: 'local_drink',
            sortOrder: 2,
            isActive: true),
        CategoryModel(
            id: 'cat_3',
            name: 'Desertlar',
            icon: 'cake',
            sortOrder: 3,
            isActive: true),
      ];

  List<MenuItemModel> get menuItems => const [
        MenuItemModel(
          id: 'm_1',
          categoryId: 'cat_1',
          name: 'Osh',
          description: 'Mazali milliy osh',
          price: 45000,
          imageUrl: '',
        ),
        MenuItemModel(
          id: 'm_2',
          categoryId: 'cat_1',
          name: 'Lagmon',
          description: 'Qo\'lda cho\'zilgan lagmon',
          price: 35000,
          imageUrl: '',
        ),
      ];

  List<TableModel> get tables => const [
        TableModel(id: 't_1', name: 'Hall', number: 1, isActive: true),
        TableModel(id: 't_2', name: 'Hall', number: 2, isActive: true),
        TableModel(id: 't_3', name: 'VIP', number: 7, isActive: true),
      ];
}
