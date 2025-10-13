class OrderItem {
  final String id;
  final String? orderId;
  final String? inventoryId;
  final String? name;
  final double retail;
  final int quantity;

  OrderItem({
    required this.id,
    this.orderId,
    this.inventoryId,
    this.name,
    required this.retail,
    this.quantity = 1,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String,
      orderId: map['order_id'] as String?,
      inventoryId: map['inventory_id'] as String?,
      name: map['name'] as String?,
      retail: map['retail']??"0.0" as double?,
      quantity: map['quantity']??"1" as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'inventory_id': inventoryId,
      'name': name,
      'retail': retail,
      'quantity': quantity,
    };
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? inventoryId,
    String? name,
    double? retail,
    int? quantity,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      inventoryId: inventoryId ?? this.inventoryId,
      name: name ?? this.name,
      retail: retail ?? this.retail,
      quantity: quantity ?? this.quantity,
    );
  }

  // Calculate line total
  double get lineTotal => (retail ?? 0) * (quantity ?? 0);

  @override
  String toString() {
    return 'OrderItem{id: $id, name: $name, quantity: $quantity, retail: $retail}';
  }
}