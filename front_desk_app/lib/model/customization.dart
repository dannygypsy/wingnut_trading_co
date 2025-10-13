class Customization {
  final String id;
  final String orderId;
  final String itemId;
  final String inventoryId;
  final String position;
  final String name;
  final double retail;
  final String? notes;

  Customization({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.inventoryId,
    required this.name,
    required this.retail,
    required this.position,
    this.notes,
  });

  factory Customization.fromMap(Map<String, dynamic> map) {
    return Customization(
      id: map['id'] as String,
      orderId: map['order_id']??"" as String?,
      itemId: map['item_id']??"" as String?,
      inventoryId: map['inventory_id']??"" as String?,
      name: map['name']??"" as String?,
      retail: map['retail']??"0.0" as double?,
      position: map['position']??"" as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'item_id': itemId,
      'inventory_id': inventoryId,
      'name': name,
      'position': position,
      'retail': retail,
      'notes': notes,
    };
  }

  Customization copyWith({
    String? id,
    String? orderId,
    String? itemId,
    String? inventoryId,
    String? name,
    String? position,
    double? retail,
    String? notes,
  }) {
    return Customization(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      inventoryId: inventoryId ?? this.inventoryId,
      name: name ?? this.name,
      position: position ?? this.position,
      retail: retail ?? this.retail,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Customization{id: $id, name: $name, retail: $retail}';
  }
}