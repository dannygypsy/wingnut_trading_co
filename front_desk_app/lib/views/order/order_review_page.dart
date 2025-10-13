
import 'package:flutter/material.dart';
import 'package:front_desk_app/provider/order_provider.dart';
import 'package:front_desk_app/provider/printer_provider.dart';
import 'package:front_desk_app/util/dialogs.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'order_receipt_card.dart';

class OrderReviewPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);

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
                        ),
                      ),
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
                          Material( //Wrap with Material
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0)),
                            elevation: 18.0,
                            color: Colors.red,
                            clipBehavior: Clip.antiAlias,
                            // Add This
                            child: MaterialButton(
                                child: Text(op.currentOrder!.status == "canceled" ? 'RESTORE ORDER' : 'CANCEL ORDER'),
                                onPressed: () {
                                  if (op.currentOrder!.status == "canceled") {
                                    op.restoreOrder();
                                    Navigator.pop(context);
                                    return;
                                  } else if (op.currentOrder!.status == "completed") {
                                      errorDialog(context, "You cannot cancel a completed order.");
                                      return;
                                  } else if (op.currentOrder!.status == "refunded") {
                                      errorDialog(context, "You cannot cancel a refunded order.");
                                      return;

                                  } else {
                                    // proceed to cancel
                                    _cancelOrder(context);
                                  }
                                }
                            ),
                          )
                        ],
                      )
                    ]
                )
            )
        ),
      ),
    );
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