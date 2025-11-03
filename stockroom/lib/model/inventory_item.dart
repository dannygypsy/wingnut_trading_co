// lib/models/inventory_item.dart
class InventoryItem {
  final String id;
  final String type;
  final String category;
  final String name;
  final String fullName;
  final double cost;
  final double retail;
  final DateTime purchasedOn;
  final int numPurchased;
  final int remaining;

  InventoryItem({
    required this.id,
    required this.type,
    required this.category,
    required this.name,
    required this.fullName,
    required this.cost,
    required this.retail,
    required this.purchasedOn,
    required this.numPurchased,
    required this.remaining,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      name: map['name'],
      fullName: map['full_name'],
      cost: (map['cost'] as num).toDouble(),
      retail: (map['retail'] as num).toDouble(),
      purchasedOn: DateTime.parse(map['purchased_on'].toString()),
      numPurchased: map['num_purchased'],
      remaining: map['remaining'],
    );
  }

  double get profitMargin => retail - cost;
  double get profitPercent => (profitMargin / cost) * 100;
}