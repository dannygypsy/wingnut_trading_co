
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_desk_app/model/order.dart';
import 'package:front_desk_app/model/order_item.dart';
import 'package:front_desk_app/provider/order_provider.dart';
import 'package:front_desk_app/util/db.dart';
import 'package:front_desk_app/util/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'order_review_page.dart';


class OrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OrderListPageState();
}


class OrderListPageState extends State<OrderListPage> {

  final _titleFont = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);
  final _dekFont = const TextStyle(fontSize: 16.0, color: Colors.black);

  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _isLoading = true;
    });
    await _loadOrders();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        centerTitle: true,
        elevation: 0,
        title: Text("Orders"),
      ),
      body: SizedBox.expand(
          child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/wallpaper.webp"),
                    fit: BoxFit.cover,
                  )
              ),
              child: _isLoading
                  ? LoadingIndicator()
                  : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (BuildContext context, int index) {
                    DateTime dt = DateTime.fromMillisecondsSinceEpoch(_orders[index].createdAt??0);
                    String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(dt);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _orders[index].status == "canceled" ? Colors.red.withAlpha(150) : Colors.white.withAlpha(100),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: Colors.white.withAlpha(100),
                                  width: 3
                              ),

                            ),
                            child: _buildOrderTile(op, index, formattedDate),
                          ),
                        ),
                      ),
                    );
                  }
              )
          )
      ),
    );
  }

  Widget _buildOrderTile(OrderProvider op, int index, String formattedDate) {
    NumberFormat formatter = NumberFormat("00000");

    Widget leading;
    if (_orders[index].status == "canceled") {
      leading = const Icon(FontAwesomeIcons.trashCan, color: Colors.red, size: 40.0,);
    } else if (_orders[index].status == "refunded") {
      leading = const Icon(CupertinoIcons.arrow_left_circle, color: Colors.red, size: 40.0,);
    } else if (_orders[index].status == "completed") {
      leading = const Icon(FontAwesomeIcons.fileCircleCheck, color: Colors.teal, size: 40.0,);
    } else if (_orders[index].status == "delivered") {
      leading = const Icon(FontAwesomeIcons.solidTruck, color: Colors.green, size: 40.0,);
    } else {
      leading = const Icon(Icons.pending, color: Colors.yellow, size: 40.0,);
    }

    if (_orders[index].paymentMethod == null || _orders[index].paymentMethod == "" || _orders[index].paymentMethod == "not paid") {
      leading = Stack(
        children: [
          leading,
          const Positioned(
            right: 0,
            bottom: 0,
            child: Icon(Icons.warning, color: Colors.red, size: 20.0,),
          )
        ],
      );
    }
    return ListTile(
      leading: leading,
      title: Text("ORDER #${_orders[index].id} - ${_orders[index].customer}", style: _titleFont),
      subtitle: Text("${_orders[index].items.length} items, on ${formattedDate}", style: _dekFont),

      trailing: const Icon(Icons.navigate_next, color: Colors.black,),
      onTap: () async {
        await op.loadOrder(_orders[index].id);
        await Navigator.push(context,MaterialPageRoute(builder: (context) => OrderReviewPage(), settings: const RouteSettings(name: 'Order Review Page'),));
        // Refresh the list when returning from order review page
        _refreshOrders();
      },
    );
  }

  _cancelOrder(Order o) async {

    //Database db = await DatabaseHandler().initializeDB();

    //await db.delete('orders', where: 'id=?', whereArgs: [o.id]);

    //setState(() {
    //  _orders = [];
    //});
  }

  Future<bool> _loadOrders() async {
    _orders = [];

    debugPrint("Loading the orders...");

    Database db = await DatabaseHandler().initializeDB();

    final List<Map<String, dynamic>> sl = await db.query('orders', orderBy: 'created_at DESC');

    for (var element in sl) {
      Order o = Order.fromMap(element);
      _orders.add(o);
      // Now load the items
      final List<Map<String, dynamic>> sil = await db.query('order_items', where: 'order_id=?', whereArgs: [o.id]);
      for (var itemElement in sil) {
        o.items.add(OrderItem.fromMap(itemElement));
      }
    }

    return true;

  }

}