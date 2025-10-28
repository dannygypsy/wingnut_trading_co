
import 'package:flutter/material.dart';
import 'package:front_desk_app/model/values.dart';
import 'package:front_desk_app/provider/inventory_provider.dart';
import 'package:front_desk_app/provider/order_provider.dart';
import 'package:front_desk_app/provider/printer_provider.dart';
import 'package:front_desk_app/util/dialogs.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'order_receipt_card.dart';

class OrderReviewPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    OrderProvider op = Provider.of<OrderProvider>(context, listen: true);
    InventoryProvider ip = Provider.of<InventoryProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        centerTitle: true,
        elevation: 0,
        title: Builder(
            builder: (BuildContext context) {
              //print("App is ${_controller.app.value.name}");
              return Text("Order #${op.currentOrder!.id}");
            }
        ),
      ),
      body: SizedBox.expand(
        child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/wallpaper.webp"),
                  fit: BoxFit.cover,
                )
            ),
            child: Center(
                child: Column(
                    children: [
                      const SizedBox(height:100),
                      SizedBox(
                        width:365,
                        height:600,
                        child: OrderReceiptCard(
                          onItemTapped: (context, i) {},
                          onNotesTapped: () {},
                          onGuestTapped: () {},
                          onPaymentTapped: () {},
                          onDiscountTapped: () {},
                        ),
                      ),
                      const SizedBox(height:20),
                      // Status
                      Material(
                        child: InkWell(
                          onTap: () {
                            _statusDialog(context);
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4.0,
                                  spreadRadius: 1.0,
                                  offset: Offset(2.0, 2.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: Text(
                              "Status: ${op.currentOrder!.status!.toUpperCase()}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      ),
                      const SizedBox(height:20),
                      Material(
                          child: InkWell(
                            onTap: () {
                              _paymentDialog(context);
                            },
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4.0,
                                    spreadRadius: 1.0,
                                    offset: Offset(2.0, 2.0), // shadow direction: bottom right
                                  )
                                ],
                              ),
                              child: Text(
                                "Payment: ${op.currentOrder!.paymentMethod??"Not Paid".toUpperCase()}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                      ),
                      const SizedBox(height:20),
                      ButtonBar(
                        mainAxisSize: MainAxisSize.min,
                        // this will take space as minimum as posible(to center)
                        children: <Widget>[
                          Material( //Wrap with Material
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0)),
                            elevation: 18.0,
                            color: Colors.green,
                            clipBehavior: Clip.antiAlias,
                            // Add This
                            child: MaterialButton(
                                child: const Text('REPRINT'),
                                onPressed: () {
                                  _reprint(context);
                                }
                            ),
                          ),
                          if (Values.locked == false)
                            Material( //Wrap with Material
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0)),
                              elevation: 18.0,
                              color: Colors.red,
                              clipBehavior: Clip.antiAlias,
                              // Add This
                              child: MaterialButton(
                                  child: const Text('DELETE ORDER'),
                                  onPressed: () async {
                                    bool? confirm = await confirmDialog(
                                        c: context,
                                        message: "Are you sure you want to delete this order? This action cannot be undone.",
                                        cancel: "Don't Delete",
                                        ok: "Delete Order");
                                    if (confirm ?? false) {
                                      await op.restoreOrderInventory(op.currentOrder!);
                                      await ip.refresh();
                                      op.deleteOrder(op.currentOrder!.id);
                                      Navigator.pop(context);
                                    }
                                  }
                              ),
                            ),


                        ],
                      )
                    ]
                )
            )
        ),
      ),
    );
  }

  _statusDialog(BuildContext context) async {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);
    InventoryProvider ip = Provider.of<InventoryProvider>(context, listen: false);

    String? newStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Order Status'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'pending'); },
              child: const Text('Pending', style: TextStyle(color: Colors.yellow)),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'completed'); },
              child: const Text('Completed', style: TextStyle(color: Colors.teal)),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'delivered'); },
              child: const Text('Delivered', style: TextStyle(color: Colors.green)),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'canceled'); },
              child: const Text('Canceled', style: TextStyle(color: Colors.red)),
            ),
            //SimpleDialogOption(
            //  onPressed: () { Navigator.pop(context); },
            //  child: const Text('Cancel'),
            //),
          ],
        );
      },
    );

    if (newStatus != null && newStatus != op.currentOrder!.status) {
      String oldStatus = op.currentOrder!.status ?? 'pending';

      // Check if changing TO canceled (restore inventory)
      if (newStatus == 'canceled' && oldStatus != 'canceled') {
        await op.restoreOrderInventory(op.currentOrder!);
        await ip.refresh();
      }

      // Check if changing FROM canceled to anything else (remove inventory)
      if (oldStatus == 'canceled' && newStatus != 'canceled') {
        bool success = await op.removeOrderInventory(op.currentOrder!);
        if (!success) {
          // Insufficient inventory - show error and don't change status
          errorDialog(context, "Insufficient inventory to restore this order");
          return;
        }
        await ip.refresh();
      }

      // Update the order status
      await op.updateOrderStatus(newStatus);


    }
  }

  _paymentDialog(BuildContext context) async {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);
    InventoryProvider ip = Provider.of<InventoryProvider>(context, listen: false);

    String? newPayment = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Payment Method'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'not paid'); },
              child: const Text('Not Paid', style: TextStyle(color: Colors.red)),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'cash'); },
              child: const Text('Cash', style: TextStyle(color: Colors.green)),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'venmo'); },
              child: const Text('Venmo', style: TextStyle(color: Colors.green)),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'cashapp'); },
              child: const Text('CashApp', style: TextStyle(color: Colors.green)),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'zelle'); },
              child: const Text('Zelle', style: TextStyle(color: Colors.green)),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'comped'); },
              child: const Text('Comped', style: TextStyle(color: Colors.yellow)),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'other'); },
              child: const Text('Other', style: TextStyle(color: Colors.green)),
            ),
            //SimpleDialogOption(
            //  onPressed: () { Navigator.pop(context); },
            //  child: const Text('Cancel'),
            //),
          ],
        );
      },
    );

    if (newPayment != null && newPayment != op.currentOrder!.paymentMethod) {
      // Update the order payment method
      await op.updateOrderPaymentMethod(newPayment);
    }

  }

  _reprint(BuildContext context) async {
    PrinterProvider pp = Provider.of<PrinterProvider>(context, listen: false);
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);

    if (await pp.isConnected()) {
      pp.printOrder(op.currentOrder!);
    } else {
      errorDialog(context, "No printer is connected. Please go to the printer menu and connect to a bluetooth printer.");
    }
  }

  _cancelOrder(BuildContext context) async {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);

    bool? confirm = await confirmDialog(c: context, message: "Are you sure you want to cancel this order? This action cannot be undone.", cancel: "Don't Cancel", ok: "Cancel Order");
    if (confirm??false) {
      op.cancelOrder();
      //op.cancelCurrentOrder();
      Navigator.pop(context);
    }
  }

}