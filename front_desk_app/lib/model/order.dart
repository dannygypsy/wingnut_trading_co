class Order {
  final String id;
  final String? customer;
  final String? notes;
  final int? createdAt;  // milliseconds since epoch
  final String? createdBy;
  final double? total;
  final String? status;

  Order({
    required this.id,
    this.customer,
    this.notes,
    this.createdAt,
    this.createdBy,
    this.total,
    this.status,
  });

  // Convert from database map to Order
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      customer: map['customer'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as int?,
      createdBy: map['created_by'] as String?,
      total: map['total'] as double?,
      status: map['status'] as String?,
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
  }) {
    return Order(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      total: total ?? this.total,
      status: status ?? this.status,
    );
  }

  // Helper to get DateTime from createdAt
  DateTime? get createdAtDate {
    return createdAt != null ? DateTime.fromMillisecondsSinceEpoch(createdAt!) : null;
  }

  @override
  String toString() {
    return 'Order{id: $id, customer: $customer, status: $status, total: $total}';
  }
}