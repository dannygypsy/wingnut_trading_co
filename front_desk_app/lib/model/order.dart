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
  final String? discountDesc;
  final double? discountPercent;

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
    this.discountPercent,
    this.discountDesc,
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
      discountDesc: map['discount_desc'] as String?,
      discountPercent: map['discount_percent'] as double?,
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
      'discount_desc': discountDesc,
      'discount_percent': discountPercent,
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
    String? discountDesc,
    double? discountPercent,
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
      discountDesc: discountDesc ?? this.discountDesc,
      discountPercent: discountPercent ?? this.discountPercent,
      items: items ?? this.items,
    );
  }

  // Helper to get DateTime from createdAt
  DateTime? get createdAtDate {
    return createdAt != null ? DateTime.fromMillisecondsSinceEpoch(createdAt!) : null;
  }

  double calculateSubtotal() {
    double subtotal = 0;
    for (var item in items) {
      subtotal += item.lineTotal;
    }
    return subtotal;
  }

  // Calculate total from items (which includes their customizations)
  double calculateTotal() {
    double total = 0;
    for (var item in items) {
      total += item.lineTotal;
    }
    // Factor in the discount amount if any (percentage)
    if (discountPercent != null) {
      total -= total * (discountPercent! / 100);
    }
    return total;
  }

  // Get item count
  int get itemCount => items.length;

  @override
  String toString() {
    return 'Order{id: $id, customer: $customer, status: $status, total: $total, payment method: $paymentMethod, discount desc: $discountDesc, discount amount: $discountPercent, items: ${items.length}}';
  }
}