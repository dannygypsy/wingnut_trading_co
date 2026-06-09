class DecalPlacement {
  final String slot;
  String? decalId;
  String? decalName;

  DecalPlacement({required this.slot, this.decalId, this.decalName});

  bool get hasDecal => decalId != null;

  Map<String, dynamic> toJson() => {
    'placement': slot,
    'decal_id': decalId,
    'decal_name': decalName,
  };
}

class OrderItem {
  final String blankId;
  final String blankName;
  final String size;
  final List<DecalPlacement> placements;
  double price;

  OrderItem({
    required this.blankId,
    required this.blankName,
    required this.size,
    required this.placements,
    this.price = 0.0,
  });

  bool get hasPlacementSlots => placements.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'blank_id': blankId,
    'blank_name': blankName,
    'size': size,
    'placements': placements.map((p) => p.toJson()).toList(),
    'price': price,
  };

  String sizeToDisplay() {
    switch (size.toUpperCase()) {
      case 'XS': return 'X-Small';
      case 'S': return 'Small';
      case 'M': return 'Medium';
      case 'L': return 'Large';
      case 'XL': return 'X-Large';
      case '2XL': return '2X-Large';
      case '3XL': return '3X-Large';
      case '4XL': return '4X-Large';
      default: return size;
    }
  }
}

/// Parsed result from a QR code scan
class QrScanResult {
  final String id;
  final String name;
  final String? size;
  final String? category;
  final List<String> placementSlots;
  final bool isTransfer;

  QrScanResult({
    required this.id,
    required this.name,
    this.size,
    this.category,
    this.placementSlots = const [],
    this.isTransfer = false,
  });

  /// Parse QR payload: ID:WTC-xxx|C:category|N:name|S:size|P:Front,Back
  /// Transfer format:  ID:WTC-xxx|N:name|T:transfer
  factory QrScanResult.fromQrString(String raw) {
    final parts = <String, String>{};
    for (final segment in raw.split('|')) {
      final idx = segment.indexOf(':');
      if (idx == -1) continue;
      final key = segment.substring(0, idx).trim().toUpperCase();
      final value = segment.substring(idx + 1).trim();
      parts[key] = value;
    }

    final placements = (parts['P'] ?? '').isNotEmpty
        ? parts['P']!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : <String>[];

    return QrScanResult(
      id: parts['ID'] ?? '',
      name: parts['N'] ?? 'Unknown Item',
      size: parts['S'],
      category: parts['C'],
      placementSlots: placements,
      isTransfer: parts['C']?.toLowerCase() == 'transfers',
    );
  }
}

/// Server search result
class InventorySearchResult {
  final String id;
  final String name;
  final String? size;
  final List<String> placementSlots;

  InventorySearchResult({
    required this.id,
    required this.name,
    this.size,
    this.placementSlots = const [],
  });

  factory InventorySearchResult.fromJson(Map<String, dynamic> json) {
    final placements = (json['placements'] as String? ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return InventorySearchResult(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      size: json['size'],
      placementSlots: placements,
    );
  }
}

class Order {
  final List<OrderItem> items = [];
  String? customerName;
  double discountPct = 0.0;
  final String salespersonName;

  Order({required this.salespersonName});

  double get subtotal => items.fold(0, (sum, i) => sum + i.price);
  double get discountAmount => subtotal * (discountPct / 100);
  double get total => subtotal - discountAmount;

  Map<String, dynamic> toJson() => {
    'salesperson_name': salespersonName,
    'customer_name': customerName,
    'discount_pct': discountPct,
    'items': items.map((i) => i.toJson()).toList(),
    'total': total,
  };
}