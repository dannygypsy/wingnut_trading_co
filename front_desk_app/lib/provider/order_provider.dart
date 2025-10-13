import 'package:flutter/material.dart';
import 'package:front_desk_app/model/customization.dart';
import 'package:front_desk_app/model/inventory_item.dart';
import 'package:front_desk_app/model/order.dart';
import 'package:front_desk_app/model/order_item.dart';
import 'package:front_desk_app/util/db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class OrderProvider extends ChangeNotifier {
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  // Getters
  Order? get currentOrder => _currentOrder;
  List<OrderItem> get currentItems => _currentOrder?.items ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrder => _currentOrder != null;

  // Calculate current order total
  double get currentTotal => _currentOrder?.calculateTotal() ?? 0;

  // Get number of items in current order
  int get itemCount => _currentOrder?.itemCount ?? 0;

  // Start a new order
  Future<void> startNewOrder({String? customer, String? notes, String? createdBy}) async {
    final orderId = await DatabaseHandler().generateOrderNumber();

    _currentOrder = Order(
      id: orderId,
      customer: customer,
      notes: notes,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      createdBy: createdBy,
      total: 0,
      status: 'pending',
      items: [],
    );
    _error = null;

    // notifyListeners();
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

      // Load order items
      final itemResults = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      List<OrderItem> items = [];
      for (var itemMap in itemResults) {
        // Load customizations for this item
        final customResults = await db.query(
          'customizations',
          where: 'item_id = ?',
          whereArgs: [itemMap['id']],
        );

        List<Customization> customizations = customResults
            .map((map) => Customization.fromMap(map))
            .toList();

        items.add(OrderItem.fromMap(itemMap, customizations: customizations));
      }

      _currentOrder = Order.fromMap(orderResults.first, items: items);

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
    required InventoryItem inventoryItem,
    int quantity = 1,
  }) {
    if (_currentOrder == null) {
      _error = 'No active order. Start a new order first.';
      notifyListeners();
      return;
    }

    // Find the inventory item
    // Check if item already exists in order
    if (inventoryItem.type != 'blank') {
      final existingIndex = _currentOrder!.items.indexWhere((item) =>
      item.inventoryId == inventoryItem.id);
      if (existingIndex != -1) {
        // If it exists, just update the quantity
        final existingItem = _currentOrder!.items[existingIndex];
        _currentOrder!.items[existingIndex] =
            existingItem.copyWith(quantity: existingItem.quantity + quantity);
        notifyListeners();
        return;
      }
    }


    final itemId = Uuid().v4();

    final item = OrderItem(
      id: itemId,
      orderId: _currentOrder!.id,
      inventoryId: inventoryItem.id,
      name: inventoryItem.name,
      retail: inventoryItem.retail,
      quantity: quantity,
      customizations: [],
    );

    _currentOrder!.items.add(item);
    notifyListeners();
  }

  // Update item quantity
  void updateItemQuantity(String itemId, int newQuantity) {
    if (_currentOrder == null) return;

    final index = _currentOrder!.items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _currentOrder!.items.removeAt(index);
      } else {
        _currentOrder!.items[index] = _currentOrder!.items[index].copyWith(quantity: newQuantity);
      }
      notifyListeners();
    }
  }

  // Update an item's details (like price)
  void updateItem(OrderItem updatedItem) {
    if (_currentOrder == null) return;

    final index = _currentOrder!.items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _currentOrder!.items[index] = updatedItem;
      notifyListeners();
    }
  }

  // Remove item from current order
  void removeItem(String itemId) {
    if (_currentOrder == null) return;

    _currentOrder!.items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  // Add customization to a specific item
  void addCustomizationToItem({
    required String itemId,
    required String name,
    required double retail,
    String? inventoryId,
    String? notes,
  }) {
    if (_currentOrder == null) {
      _error = 'No active order. Start a new order first.';
      notifyListeners();
      return;
    }

    final item = _currentOrder!.items.firstWhere((item) => item.id == itemId);

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

    item.customizations.add(customization);
    notifyListeners();
  }

  // Remove customization from an item
  void removeCustomizationFromItem(String itemId, String customId) {
    if (_currentOrder == null) return;

    final item = _currentOrder!.items.firstWhere((item) => item.id == itemId);
    item.customizations.removeWhere((custom) => custom.id == customId);
    notifyListeners();
  }

  // Save current order to database
  Future<String> saveOrder() async {
    if (_currentOrder == null) {
      throw Exception('No active order to save');
    }

    if (_currentOrder!.items.isEmpty) {
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

        // Insert items and their customizations
        for (var item in orderToSave.items) {
          await txn.insert('order_items', item.toMap());

          // Insert customizations for this item
          for (var custom in item.customizations) {
            await txn.insert('customizations', custom.toMap());
          }
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
    // clear all items from the current order AND the note
    _currentOrder?.clearItems();
    _error = null;
    notifyListeners();
  }

  // Get item by ID from current order
  OrderItem? getItemById(String itemId) {
    if (_currentOrder == null) return null;

    try {
      return _currentOrder!.items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Check if inventory item is already in order
  bool hasInventoryItem(String inventoryId) {
    if (_currentOrder == null) return false;
    return _currentOrder!.items.any((item) => item.inventoryId == inventoryId);
  }

  // Get quantity of specific inventory item in order
  int getInventoryItemQuantity(String inventoryId) {
    if (_currentOrder == null) return 0;

    final item = _currentOrder!.items.firstWhere(
          (item) => item.inventoryId == inventoryId,
      orElse: () => OrderItem(id: '', orderId: '', inventoryId: '', name: '', retail: 0, quantity: 0)
    );
    return item.quantity ?? 0;
  }
}