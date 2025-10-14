
import 'package:flutter/material.dart';
import 'package:front_desk_app/model/order.dart';
import 'package:front_desk_app/model/order_item.dart';
import 'package:front_desk_app/model/customization.dart';
import 'package:front_desk_app/util/db.dart';
import 'package:front_desk_app/util/comms.dart';
import 'package:sqflite/sqflite.dart';

class OrderUploadService {

  /// Upload all orders to the server one at a time
  /// Returns a map with success count and list of failed order IDs
  Future<Map<String, dynamic>> uploadAllOrders() async {
    List<Order> orders = await _loadAllOrders();

    int successCount = 0;
    List<String> failedOrderIds = [];

    for (Order order in orders) {
      bool success = await uploadOrder(order);
      if (success) {
        successCount++;
      } else {
        failedOrderIds.add(order.id);
      }
    }

    return {
      'total': orders.length,
      'success': successCount,
      'failed': failedOrderIds.length,
      'failedIds': failedOrderIds
    };
  }

  /// Upload a single order with its items and customizations
  Future<bool> uploadOrder(Order order) async {
    try {
      // Convert order to JSON-compatible map
      Map<String, dynamic> orderData = _orderToJson(order);

      debugPrint("Uploading order #${order.id}...");

      // Make the API call
      CallResults results = await remotePost(
          'orders',
          orderData
      );

      if (results.success) {
        debugPrint("Order #${order.id} uploaded successfully");
        // Optionally mark order as synced in local DB
        //await _markOrderAsSynced(order.id);
        return true;
      } else {
        debugPrint("Failed to upload order #${order.id}: ${results.message}");
        return false;
      }

    } catch (e) {
      debugPrint("Error uploading order #${order.id}: $e");
      return false;
    }
  }

  /// Convert order and its items to JSON structure
  Map<String, dynamic> _orderToJson(Order order) {
    return {
      'id': order.id,
      'customer': order.customer,
      'notes': order.notes,
      'created_at': order.createdAt,
      'created_by': order.createdBy,
      'total': order.total,
      'status': order.status,
      'items': order.items.map((item) => _orderItemToJson(item)).toList(),
    };
  }

  /// Convert order item to JSON structure
  Map<String, dynamic> _orderItemToJson(OrderItem item) {
    return {
      'id': item.id,
      'order_id': item.orderId,
      'inventory_id': item.inventoryId,
      'name': item.name,
      'retail': item.retail,
      'quantity': item.quantity,
      'customizations': item.customizations.map((custom) => _customizationToJson(custom)).toList(),
    };
  }

  /// Convert customization to JSON structure
  Map<String, dynamic> _customizationToJson(Customization customization) {
    return {
      'id': customization.id,
      'order_id': customization.orderId,
      'item_id': customization.itemId,
      'inventory_id': customization.inventoryId,
      'position': customization.position,
      'name': customization.name,
      'retail': customization.retail,
      'notes': customization.notes,
    };
  }

  /// Load all orders from local database with items and customizations
  Future<List<Order>> _loadAllOrders() async {
    List<Order> orders = [];

    Database db = await DatabaseHandler().initializeDB();

    final List<Map<String, dynamic>> orderMaps = await db.query(
        'orders',
        orderBy: 'created_at DESC'
    );

    for (var orderMap in orderMaps) {
      Order order = Order.fromMap(orderMap);

      // Load items for this order
      final List<Map<String, dynamic>> itemMaps = await db.query(
          'order_items',
          where: 'order_id=?',
          whereArgs: [order.id]
      );

      for (var itemMap in itemMaps) {
        OrderItem item = OrderItem.fromMap(itemMap);

        // Load customizations for this item
        final List<Map<String, dynamic>> customizationMaps = await db.query(
            'customizations',
            where: 'item_id=?',
            whereArgs: [item.id]
        );

        for (var customMap in customizationMaps) {
          item.customizations.add(Customization.fromMap(customMap));
        }

        order.items.add(item);
      }

      orders.add(order);
    }

    return orders;
  }

  /// Mark order as synced in local database
  Future<void> _markOrderAsSynced(String orderId) async {
    Database db = await DatabaseHandler().initializeDB();
    await db.update(
      'orders',
      {'synced': 1, 'synced_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  /// Upload only unsynced orders
  Future<Map<String, dynamic>> uploadUnsyncedOrders() async {
    Database db = await DatabaseHandler().initializeDB();

    final List<Map<String, dynamic>> orderMaps = await db.query(
        'orders',
        where: 'synced = ? OR synced IS NULL',
        whereArgs: [0],
        orderBy: 'created_at DESC'
    );

    int successCount = 0;
    List<String> failedOrderIds = [];

    for (var orderMap in orderMaps) {
      Order order = Order.fromMap(orderMap);

      // Load items
      final List<Map<String, dynamic>> itemMaps = await db.query(
          'order_items',
          where: 'order_id=?',
          whereArgs: [order.id]
      );

      for (var itemMap in itemMaps) {
        OrderItem item = OrderItem.fromMap(itemMap);

        // Load customizations for this item
        final List<Map<String, dynamic>> customizationMaps = await db.query(
            'customizations',
            where: 'item_id=?',
            whereArgs: [item.id]
        );

        for (var customMap in customizationMaps) {
          item.customizations.add(Customization.fromMap(customMap));
        }

        order.items.add(item);
      }

      // Upload the order
      bool success = await uploadOrder(order);
      if (success) {
        successCount++;
      } else {
        failedOrderIds.add(order.id);
      }
    }

    return {
      'total': orderMaps.length,
      'success': successCount,
      'failed': failedOrderIds.length,
      'failedIds': failedOrderIds
    };
  }
}