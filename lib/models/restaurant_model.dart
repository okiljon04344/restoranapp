class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String currency;
  final bool isTableServiceEnabled;
  final bool isTakeawayEnabled;
  final bool isDeliveryEnabled;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.currency,
    required this.isTableServiceEnabled,
    required this.isTakeawayEnabled,
    required this.isDeliveryEnabled,
  });

  factory RestaurantModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RestaurantModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      currency: data['currency'] ?? 'so\'m',
      isTableServiceEnabled: data['isTableServiceEnabled'] ?? true,
      isTakeawayEnabled: data['isTakeawayEnabled'] ?? true,
      isDeliveryEnabled: data['isDeliveryEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'currency': currency,
      'isTableServiceEnabled': isTableServiceEnabled,
      'isTakeawayEnabled': isTakeawayEnabled,
      'isDeliveryEnabled': isDeliveryEnabled,
    };
  }
}
