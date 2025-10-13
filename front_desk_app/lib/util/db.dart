import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHandler {

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    //debugPrint("DB Path=$path");
    return openDatabase(
      join(path, 'wtc.db'),
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {

        await database.execute('''CREATE TABLE inventory (
          id TEXT PRIMARY KEY, 
          type TEXT,
          name TEXT, 
          full_name TEXT,
          category TEXT,
          cost REAL,
          retail REAL,
          purchased_on TEXT,
          num_purchased INTEGER,
          remaining INTEGER
          )''',
        );

        await database.execute('''CREATE TABLE orders (
          id TEXT PRIMARY KEY, 
          customer TEXT, 
          notes TEXT,
          created_at INTEGER,
          created_by TEXT,
          total REAL,
          status TEXT
          )''',
        );

        await database.execute('''CREATE TABLE order_items (
          id TEXT PRIMARY KEY, 
          order_id TEXT,
          inventory_id TEXT,
          name TEXT,
          retail REAL,
          quantity INTEGER,
          FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
          FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON DELETE SET NULL
          )''',
        );

        await database.execute('''CREATE TABLE customizations (
          id TEXT PRIMARY KEY, 
          order_id TEXT,
          item_id TEXT,
          inventory_id TEXT,
          name TEXT,
          retail REAL,
          notes TEXT,
          FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
          FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON DELETE SET NULL,
          FOREIGN KEY (item_id) REFERENCES order_items(id) ON DELETE CASCADE
          )''',
        );

      },
      version: 1,
    );
  }

  Future<String> generateOrderNumber() async {
    final db = await DatabaseHandler().initializeDB();

    // Get the count of existing orders
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM orders');
    int count = Sqflite.firstIntValue(result) ?? 0;

    // Generate order number like: ORD-0001, ORD-0002, etc.
    return 'WTC-${(count + 1).toString().padLeft(4, '0')}';
  }

  // Method to clear/reset the entire database
  Future<void> clearDatabase() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'wtc.db');

    // Delete the database file
    await deleteDatabase(dbPath);

    debugPrint("Database deleted successfully");
  }

  // Method to clear all data but keep tables
  Future<void> clearAllData() async {
    final Database db = await initializeDB();

    await db.transaction((txn) async {
      await txn.delete('customizations');
      await txn.delete('order_items');
      await txn.delete('orders');
      await txn.delete('inventory');
    });

    debugPrint("All data cleared");
  }

  // Method to reset database (delete and recreate)
  Future<Database> resetDatabase() async {
    await clearDatabase();
    return await initializeDB();
  }
}