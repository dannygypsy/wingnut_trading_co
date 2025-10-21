import 'order_item.dart';

class Order {
  final String id;
  String? customer;
  String? notes;
  final int? createdAt;  // milliseconds since epoch
  final String? createdBy;
  final double? total;
  final String? status;
  final String? paymentMethod;

  List<OrderItem> items = [];

  clearItems() {
    items = [];
  }

  Order({
    required this.id,
    this.customer,
    this.notes,
    this.createdAt,
    this.createdBy,
    this.total,
    this.status,
    this.paymentMethod,
    List<OrderItem>? items,
  }) : items = items ?? [];

  // Convert from database map to Order
  factory Order.fromMap(Map<String, dynamic> map, {List<OrderItem>? items}) {
    return Order(
      id: map['id'] as String,
      customer: map['customer'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as int?,
      createdBy: map['created_by'] as String?,
      total: map['total'] as double?,
      status: map['status'] as String?,
      paymentMethod: map['payment_method'] as String?,
      items: items,
    );
  }

  // Convert from Order to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer': customer,
      'notes': notes,
      'created_at': createdAt,
      'created_by': createdBy,
      'total': total,
      'status': status,
      'payment_method': paymentMethod,
    };
  }

  // Create a copy with modified fields
  Order copyWith({
    String? id,
    String? customer,
    String? notes,
    int? createdAt,
    String? createdBy,
    double? total,
    String? status,
    String? paymentMethod,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
    );
  }

  // Helper to get DateTime from createdAt
  DateTime? get createdAtDate {
    return createdAt != null ? DateTime.fromMillisecondsSinceEpoch(createdAt!) : null;
  }

  // Calculate total from items (which includes their customizations)
  double calculateTotal() {
    double total = 0;
    for (var item in items) {
      total += item.lineTotal;
    }
    return total;
  }

  // Get item count
  int get itemCount => items.length;

  @override
  String toString() {
    return 'Order{id: $id, customer: $customer, status: $status, total: $total, payment method: $paymentMethod, items: ${items.length}}';
  }
}