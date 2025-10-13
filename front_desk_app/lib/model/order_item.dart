import 'customization.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String inventoryId;
  final String name;
  final double retail;
  final int quantity;

  List<Customization> customizations;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.inventoryId,
    required this.name,
    required this.retail,
    this.quantity = 1,
    List<Customization>? customizations,
  }) : customizations = customizations ?? [];

  factory OrderItem.fromMap(Map<String, dynamic> map, {List<Customization>? customizations}) {
    return OrderItem(
      id: map['id'] as String,
      orderId: map['order_id']??"" as String?,
      inventoryId: map['inventory_id']??"" as String?,
      name: map['name']??"" as String?,
      retail: map['retail']??"0.0" as double?,
      quantity: map['quantity']??"1" as int?,
      customizations: customizations,
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
    List<Customization>? customizations,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      inventoryId: inventoryId ?? this.inventoryId,
      name: name ?? this.name,
      retail: retail ?? this.retail,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
    );
  }

  // Calculate line total (item price + customizations)
  double get lineTotal {
    double total = (retail ?? 0) * (quantity ?? 0);
    for (var custom in customizations) {
      total += (custom.retail ?? 0);
    }
    return total;
  }

  @override
  String toString() {
    return 'OrderItem{id: $id, name: $name, quantity: $quantity, retail: $retail, customizations: ${customizations.length}}';
  }
}