
import 'package:flutter/material.dart';
import 'package:front_desk_app/util/db.dart';
import 'package:sqflite/sqflite.dart';
import 'order_item.dart';

class Order {
  int? id;
  int? datetime;
  String wristbandCode;
  String customerName;
  List<OrderItem> items = [];
  String comments = "";


  Order({required this.wristbandCode, required this.customerName, this.id, this.datetime});

  Order.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        datetime = res["datetime"],
        wristbandCode = res["wristband_code"],
        customerName = res["customer_name"],
        comments = res["comments"];

  loadItems() async {
    items = [];

    //debugPrint("Loading the order items...");

    Database db = await DatabaseHandler().initializeDB();

    final List<Map<String, dynamic>> sl = await db.query('order_items', where: "order_id=?", whereArgs: [id] );

    for (var element in sl) {
      OrderItem ms = OrderItem.fromMap(element);
      items.add(ms);
    }

    return true;
  }

}