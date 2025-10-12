
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    //debugPrint("DB Path=$path");
    return openDatabase(
      join(path, 'glittery_pig.db'),
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute('''CREATE TABLE menu_sections(
          id INTEGER PRIMARY KEY, 
          name TEXT, 
          sort_order INT
          )''',
        );
        await database.execute('''CREATE TABLE menu_items(
          id INTEGER PRIMARY KEY, 
          name TEXT, 
          section_id TEXT,
          description TEXT, 
          image TEXT, 
          sort_order INT,
          FOREIGN KEY (section_id) REFERENCES menu_sections(id) ON DELETE CASCADE
          )''',
        );
        await database.execute('''CREATE TABLE orders(
          id INTEGER PRIMARY KEY, 
          datetime INT,
          wristband_code TEXT, 
          customer_name TEXT, 
          comments TEXT
          )''',
        );
        await database.execute('''CREATE TABLE order_items(
          id INTEGER PRIMARY KEY, 
          order_id INT, 
          item_name TEXT,
          num INT,
          
          FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
          )''',
        );
      },
      version: 1,
    );
  }
}