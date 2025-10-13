import 'package:flutter/material.dart';
import 'package:front_desk_app/model/customization.dart';
import 'package:front_desk_app/model/order.dart';
import 'package:front_desk_app/model/order_item.dart';
import 'package:front_desk_app/util/db.dart';
import 'package:uuid/uuid.dart';

class OrderProvider extends ChangeNotifier {
  Order? _currentOrder;
  List<OrderItem> _currentItems = [];
  List<Customization> _currentCustomizations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Order? get currentOrder => _currentOrder;
  List<OrderItem> get currentItems => _currentItems;
  List<Customization> get currentCustomizations => _currentCustomizations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrder => _currentOrder != null;

  // Calculate current order total
  double get currentTotal {
    double total = 0;
    for (var item in _currentItems) {
      total += item.retail * item.quantity;
    }
    for (var custom in _currentCustomizations) {
      total += (custom.retail ?? 0);
    }
    return total;
  }

  // Get number of items in current order
  int get itemCount => _currentItems.length;

  // Start a new order
  void startNewOrder({String? createdBy}) {
    final orderId = Uuid().v4();

    _currentOrder = Order(
      id: orderId,
      customer: "",
      notes: "",
      createdAt: DateTime.now().millisecondsSinceEpoch,
      createdBy: createdBy,
      total: 0,
      status: 'pending',
    );
    _currentItems = [];
    _currentCustomizations = [];
    _error = null;

    //notifyListeners();
  }

  // Load an existing order for editing
  Future<void> loadOrder(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHandler().initializeDB();

      // Load order
      final orderResults = await db.query(
        'orders',
        where: 'id = ?',
        whereArgs: [orderId],
      );

      if (orderResults.isEmpty) {
        throw Exception('Order not found');
      }

      _currentOrder = Order.fromMap(orderResults.first);

      // Load order items
      final itemResults = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      _currentItems = itemResults.map((map) => OrderItem.fromMap(map)).toList();

      // Load customizations
      final customResults = await db.query(
        'customizations',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      _currentCustomizations = customResults.map((map) => Customization.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update order details (customer, notes, etc.)
  void updateOrderDetails({String? customer, String? notes, String? createdBy, String? status}) {
    if (_currentOrder == null) return;

    _currentOrder = _currentOrder!.copyWith(
      customer: customer ?? _currentOrder!.customer,
      notes: notes ?? _currentOrder!.notes,
      createdBy: createdBy ?? _currentOrder!.createdBy,
      status: status ?? _currentOrder!.status,
    );

    notifyListeners();
  }

  // Add item to current order
  void addItem({
    required String inventoryId,
    required String name,
    required double retail,
    int quantity = 1,
  }) {
    if (_currentOrder == null) {
      _error = 'No active order. Start a new order first.';
      notifyListeners();
      return;
    }

    final itemId = Uuid().v4();

    final item = OrderItem(
      id: itemId,
      orderId: _currentOrder!.id,
      inventoryId: inventoryId,
      name: name,
      retail: retail,
      quantity: quantity,
    );

    _currentItems.add(item);
    notifyListeners();
  }

  // Update item quantity
  void updateItemQuantity(String itemId, int newQuantity) {
    final index = _currentItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _currentItems.removeAt(index);
      } else {
        _currentItems[index] = _currentItems[index].copyWith(quantity: newQuantity);
      }
      notifyListeners();
    }
  }

  // Remove item from current order
  void removeItem(String itemId) {
    _currentItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  // Add customization to current order
  void addCustomization({
    required String name,
    required double retail,
    String? itemId,
    String? inventoryId,
    String? notes,
  }) {
    if (_currentOrder == null) {
      _error = 'No active order. Start a new order first.';
      notifyListeners();
      return;
    }

    final customId = Uuid().v4();

    final customization = Customization(
      id: customId,
      orderId: _currentOrder!.id,
      itemId: itemId,
      inventoryId: inventoryId,
      name: name,
      retail: retail,
      notes: notes,
    );

    _currentCustomizations.add(customization);
    notifyListeners();
  }

  // Remove customization
  void removeCustomization(String customId) {
    _currentCustomizations.removeWhere((custom) => custom.id == customId);
    notifyListeners();
  }

  // Save current order to database
  Future<String> saveOrder() async {
    if (_currentOrder == null) {
      throw Exception('No active order to save');
    }

    if (_currentItems.isEmpty) {
      throw Exception('Cannot save order with no items');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHandler().initializeDB();

      // Update order total before saving
      final orderToSave = _currentOrder!.copyWith(total: currentTotal);

      await db.transaction((txn) async {
        // Check if order exists (update vs insert)
        final existing = await txn.query(
          'orders',
          where: 'id = ?',
          whereArgs: [orderToSave.id],
        );

        if (existing.isEmpty) {
          // Insert new order
          await txn.insert('orders', orderToSave.toMap());
        } else {
          // Update existing order
          await txn.update(
            'orders',
            orderToSave.toMap(),
            where: 'id = ?',
            whereArgs: [orderToSave.id],
          );
        }

        // Delete existing items and customizations (we'll re-insert)
        await txn.delete('order_items', where: 'order_id = ?', whereArgs: [orderToSave.id]);
        await txn.delete('customizations', where: 'order_id = ?', whereArgs: [orderToSave.id]);

        // Insert items
        for (var item in _currentItems) {
          await txn.insert('order_items', item.toMap());
        }

        // Insert customizations
        for (var custom in _currentCustomizations) {
          await txn.insert('customizations', custom.toMap());
        }
      });

      _currentOrder = orderToSave;
      _isLoading = false;
      notifyListeners();

      return orderToSave.id;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Clear current order (without saving)
  void clearOrder() {
    _currentOrder = null;
    _currentItems = [];
    _currentCustomizations = [];
    _error = null;
    notifyListeners();
  }

  // Get item by ID from current order
  OrderItem? getItemById(String itemId) {
    try {
      return _currentItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Check if inventory item is already in order
  bool hasInventoryItem(String inventoryId) {
    return _currentItems.any((item) => item.inventoryId == inventoryId);
  }

}