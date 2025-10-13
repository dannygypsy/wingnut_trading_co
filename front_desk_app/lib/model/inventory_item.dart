import 'package:front_desk_app/model/values.dart' show Values;

class InventoryItem {
  final String id;
  final String type;
  final String name;
  final String fullName;
  final String category;
  final double cost;
  final double retail;
  final String? purchasedOn;
  final int? numPurchased;
  final int? remaining;

  InventoryItem({
    required this.id,
    required this.type,
    required this.name,
    required this.fullName,
    required this.category,
    required this.cost,
    required this.retail,
    this.purchasedOn,
    this.numPurchased,
    this.remaining,
  });

  // Convert from database map to InventoryItem
  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String,
      type: map['type']??"" as String?,
      name: map['name']??"" as String?,
      fullName: map['full_name']??"" as String?,
      category: map['category']??"" as String?,
      cost: map['cost']??"0.0" as double?,
      retail: map['retail']??"0.0" as double?,
      purchasedOn: map['purchased_on'] as String?,
      numPurchased: map['num_purchased'] as int?,
      remaining: map['remaining'] as int?,
    );
  }

  // Convert from InventoryItem to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'full_name': fullName,
      'category': category,
      'cost': cost,
      'retail': retail,
      'purchased_on': purchasedOn,
      'num_purchased': numPurchased,
      'remaining': remaining,
    };
  }

  // Create a copy with modified fields
  InventoryItem copyWith({
    String? id,
    String? type,
    String? name,
    String? fullName,
    String? category,
    double? cost,
    double? retail,
    String? image,
    String? purchasedOn,
    int? numPurchased,
    int? remaining,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      category: category ?? this.category,
      cost: cost ?? this.cost,
      retail: retail ?? this.retail,
      purchasedOn: purchasedOn ?? this.purchasedOn,
      numPurchased: numPurchased ?? this.numPurchased,
      remaining: remaining ?? this.remaining,
    );
  }

  String get imageURL {
    if (Values.useSSL) {
      return "https://${Values.restAPIHost}${Values.scriptFolder}/item/${id}/image";
    } else {
      return "http://${Values.restAPIHost}${Values.scriptFolder}/item/${id}/image";
    }
  }

  @override
  String toString() {
    return 'InventoryItem{id: $id, name: $name, fullName: $fullName, category: $category, cost: $cost, retail: $retail, remaining: $remaining}';
  }
}