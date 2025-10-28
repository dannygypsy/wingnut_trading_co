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
          status TEXT,
          discount_desc TEXT,
          discount_percent REAL DEFAULT 0,
          payment_method TEXT,
          synced INTEGER DEFAULT 0
          )''',
        );

        await database.execute('''CREATE TABLE order_items (
          id TEXT PRIMARY KEY, 
          order_id TEXT,
          inventory_id TEXT,
          name TEXT,
          retail REAL,
          quantity INTEGER,
          FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
          )''',
        );

        await database.execute('''CREATE TABLE customizations (
          id TEXT PRIMARY KEY, 
          order_id TEXT,
          item_id TEXT,
          position TEXT,
          inventory_id TEXT,
          name TEXT,
          retail REAL,
          notes TEXT,
          FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
          FOREIGN KEY (item_id) REFERENCES order_items(id) ON DELETE CASCADE
          )''',
        );

        await database.execute('''CREATE TABLE wtc_order_counter (
              date DATE PRIMARY KEY,
              last_order_number INT DEFAULT 0
          );''',
        );
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Add payment_method column to orders table
          await database.execute(
              'ALTER TABLE orders ADD COLUMN discount_desc TEXT'
          );
          await database.execute(
              'ALTER TABLE orders ADD COLUMN discount_percent REAL DEFAULT 0'
          );
          debugPrint("Database upgraded to version 3: Added discount columns to orders table");
        }
      },
      version: 3,
    );
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