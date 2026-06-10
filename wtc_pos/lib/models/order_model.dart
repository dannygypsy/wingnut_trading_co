import 'package:flutter/foundation.dart';

/// Convert short size code to full label
String sizeLabel(String? size) {
  const map = {
    'XS': 'X-Small',
    'S': 'Small',
    'M': 'Medium',
    'L': 'Large',
    'XL': 'X-Large',
    '2XL': '2X-Large',
    '3XL': '3X-Large',
    '4XL': '4X-Large',
  };
  return map[size] ?? size ?? '';
}

class DecalPlacement {
  final String slot;
  String? transferProductId;
  String? transferName;
  double transferRetail;

  DecalPlacement({required this.slot, this.transferProductId, this.transferName, this.transferRetail = 0.0});

  bool get hasDecal => transferProductId != null;

  Map<String, dynamic> toJson() => {
    'slot': slot,
    'transfer_id': transferProductId,
    'transfer_name': transferName,
    'transfer_retail': transferRetail,
  };
}

class OrderItem {
  final String blankProductId;
  final String blankName;
  final String size;
  final List<DecalPlacement> placements;
  double price;
  int quantity;

  OrderItem({
    required this.blankProductId,
    required this.blankName,
    required this.size,
    required this.placements,
    this.price = 0.0,
    this.quantity = 1,
  });

  bool get hasPlacementSlots => placements.isNotEmpty;
  double get transferTotal => placements.fold(0, (sum, p) => sum + p.transferRetail);
  double get unitPrice => price + transferTotal;
  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'blank_id': blankProductId,
    'blank_name': blankName,
    'size': size,
    'quantity': quantity,
    'placements': placements.map((p) => p.toJson()).toList(),
    'price': price,
  };
}

/// Parsed result from a QR code scan — just the product ID
class QrScanResult {
  final String productId;

  QrScanResult({required this.productId});

  /// Parse QR payload — just a WTC-XXXXXXXX code
  factory QrScanResult.fromQrString(String raw) {
    return QrScanResult(productId: raw.trim());
  }
}

/// Full product detail returned by the server after lookup
class ProductDetail {
  final String productId;
  final String name;
  final String? size;
  final String? category;
  final List<String> placementSlots;
  final bool isTransfer;
  final bool inStock;
  final double retail;

  ProductDetail({
    required this.productId,
    required this.name,
    this.size,
    this.category,
    this.placementSlots = const [],
    this.isTransfer = false,
    this.inStock = true,
    this.retail = 0.0,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final placements = (json['placements'] as List? ?? [])
        .map((p) => p.toString())
        .toList();
    return ProductDetail(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      size: json['size'],
      category: json['category'],
      placementSlots: placements,
      isTransfer: json['is_transfer'] == true,
      inStock: json['in_stock'] != false,
      retail: (json['retail'] as num?)?.toDouble() ?? 0.0,
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
  String paymentMethod = 'not paid';
  String? notes;
  final String salespersonName;
  String? id;

  Order({required this.salespersonName});

  /// Reconstruct an Order from the API detail response for reprinting
  factory Order.fromDetailJson(Map<String, dynamic> json) {
    final o = Order(salespersonName: json['salesperson_name'] ?? '');
    o.id = json['id'] as String?;
    o.customerName = json['customer'];
    o.notes = json['notes'] as String?;
    o.discountPct = (json['discount_percent'] as num? ?? 0).toDouble();
    o.paymentMethod = json['payment_method'] ?? 'not paid';

    for (final item in (json['items'] as List? ?? [])) {
      final placements = (item['placements'] as List? ?? []).map((p) {
        final dp = DecalPlacement(slot: p['slot'] ?? '');
        dp.transferProductId = p['transfer_id'];
        dp.transferName = p['transfer_name'];
        dp.transferRetail = (p['transfer_retail'] as num? ?? 0).toDouble();
        return dp;
      }).toList();

      o.items.add(OrderItem(
        blankProductId: item['inventory_id'] ?? '',
        blankName: item['name'] ?? '',
        size: item['size'] ?? '',
        placements: placements,
        price: (item['retail'] as num? ?? 0).toDouble(),
        quantity: (item['quantity'] as num? ?? 1).toInt(),
      ));
    }
    return o;
  }

  double get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);
  double get discountAmount => subtotal * (discountPct / 100);
  double get total => subtotal - discountAmount;

  void dump() {
    debugPrint('═══ ORDER DUMP ═══');
    debugPrint('ID: ${id ?? '(not yet submitted)'}');
    debugPrint('Customer: ${customerName ?? '???'}');
    debugPrint('Salesperson: $salespersonName');
    debugPrint('Discount: $discountPct%');
    debugPrint('Payment: $paymentMethod');
    debugPrint('Items (${items.length}):');
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      debugPrint('  [$i] ${item.blankName} size=${item.size}');
      debugPrint('      price(blank)=\$${item.price.toStringAsFixed(2)}  qty=${item.quantity}');
      debugPrint('      transferTotal=\$${item.transferTotal.toStringAsFixed(2)}');
      debugPrint('      unitPrice=\$${item.unitPrice.toStringAsFixed(2)}');
      debugPrint('      lineTotal=\$${item.lineTotal.toStringAsFixed(2)}');
      if (item.placements.isEmpty) {
        debugPrint('      placements: none');
      } else {
        for (final p in item.placements) {
          debugPrint('      placement: ${p.slot} → ${p.transferName ?? '(empty)'} retail=\$${p.transferRetail.toStringAsFixed(2)}');
        }
      }
    }
    debugPrint('Subtotal: \$${subtotal.toStringAsFixed(2)}');
    debugPrint('Discount amt: \$${discountAmount.toStringAsFixed(2)}');
    debugPrint('Total: \$${total.toStringAsFixed(2)}');
    debugPrint('══════════════════');
  }

  Map<String, dynamic> toJson() => {
    'salesperson_name': salespersonName,
    'customer_name': customerName,
    'discount_pct': discountPct,
    'payment_method': paymentMethod,
    'notes': notes,
    'items': items.map((i) => i.toJson()).toList(),
    'total': total,
  };
}