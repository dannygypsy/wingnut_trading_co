
import 'package:flutter/material.dart';
import 'package:front_desk_app/model/inventory_item.dart';
import 'package:front_desk_app/util/db.dart';
import 'package:sqflite/sqflite.dart';

class InventoryType {
  String type;
  String category;

  InventoryType({required this.type, required this.category});
}

class InventoryProvider extends ChangeNotifier {
  List<InventoryItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get types {
    final types = <String>{};
    for (var item in _items) {
      //debugPrint('Item type: ${item.type}');
      types.add(item.type);
    }
    return types.toList();
  }

  // Get item by ID from cache
  InventoryItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
  // Get items by category
  List<InventoryItem> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  // Get items by type and category
  List<InventoryItem> getItemsByTypeAndCategory(InventoryType type) {
    return _items
        .where((item) => item.type == type.type && item.category == type.category)
        .toList();
  }

  // Get items by type
  List<InventoryItem> getItemsByType(String type) {
    return _items.where((item) => item.type == type).toList();
  }

  List<InventoryType> getCategoriesByType(String type) {
    // Return a list of
    final categories = <String>{};
    for (var item in _items) {
      if (item.type == type) {
        categories.add(item.category);
      }
    }
    return categories.map((c) => InventoryType(type: type, category: c)).toList();
  }

  // Load all items from database
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHandler().initializeDB();
      final results = await db.query('inventory');

      _items = results.map((map) => InventoryItem.fromMap(map)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new item
  Future<void> addItem(InventoryItem item) async {
    try {
      final db = await DatabaseHandler().initializeDB();
      await db.insert('inventory', item.toMap());

      _items.add(item);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update existing item
  Future<void> updateItem(InventoryItem item) async {
    try {
      final db = await DatabaseHandler().initializeDB();
      await db.update(
        'inventory',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );

      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete item
  Future<void> deleteItem(String id) async {
    try {
      final db = await DatabaseHandler().initializeDB();
      await db.delete(
        'inventory',
        where: 'id = ?',
        whereArgs: [id],
      );

      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update remaining quantity (common operation)
  Future<void> updateRemaining(String id, int newRemaining) async {
    final item = getItemById(id);
    if (item != null) {
      final updatedItem = item.copyWith(remaining: newRemaining);
      await updateItem(updatedItem);
    }
  }

  // Refresh from database
  Future<void> refresh() async {
    await loadItems();
  }
}