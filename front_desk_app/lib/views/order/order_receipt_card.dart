

import 'package:flutter/material.dart';
import 'package:front_desk_app/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderReceiptCard extends StatefulWidget {

  const OrderReceiptCard({super.key});

  @override
  State<StatefulWidget> createState() => OrderReceiptCardState();
}

class OrderReceiptCardState extends State<OrderReceiptCard> {

  final _fontStyle = const TextStyle(fontSize: 24.0, color: Colors.black, fontFamily: 'MerchantCopy');
  final _boldStyle = const TextStyle(fontSize: 24.0, color: Colors.black, fontFamily: 'MerchantCopy', fontWeight: FontWeight.bold);
  List<ReceiptLine> _receipt = [];

  @override
  Widget build(BuildContext context) {

    _constructReceipt();

    return Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        width: 350,
        child:  MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
                itemCount: _receipt.length,
                itemBuilder: (context, i) {
                  if (_receipt[i].type == 2) {
                    return Image(image: AssetImage(_receipt[i].text));
                  } else {
                    TextStyle ts = _fontStyle;
                    if (_receipt[i].bold) {
                      ts = _boldStyle;
                    }

                    if (_receipt[i].text == "--") {
                      return const Divider(color: Colors.black,);
                    } else if (_receipt[i].centered) {
                      return Center(child: Text(_receipt[i].text, style: ts,));
                    } else {
                      return Text(_receipt[i].text, style: ts,);
                    }
                  }
                }
            )
        )
    );

  }

  _constructReceipt() {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: true);

    // Header
    _receipt = [];

    //_receipt.add(ReceiptLine(text:"assets/receipt_logo.png", bold: true, centered: true, type: 2));
    _receipt.add(ReceiptLine(text:"THE WINGNUT TRADING CO.", bold: true, centered: true));
    _receipt.add(ReceiptLine(text:"Cameron, North Carolina", centered: true));
    _receipt.add(ReceiptLine(text:"--"));
    _receipt.add(ReceiptLine(text:" "));
    // Items

    for (var element in op.currentItems) {
      //if (element.num > 1) {
      //  _receipt.add(ReceiptLine(text: "${element.name} (${element.num})", centered: false));
      //} else {
      _receipt.add(ReceiptLine(text: "${element.quantity} ${element.name}", centered: false));
      //}
    }

    if (op.currentOrder!.notes != null && op.currentOrder!.notes!.isNotEmpty) {
      _receipt.add(ReceiptLine(text:" "));
      _receipt.add(ReceiptLine(text: "NOTES: ${op.currentOrder!.notes}", centered: false));
      _receipt.add(ReceiptLine(text:" "));
    }

    // Bottom
    DateTime now = DateTime.now();
    if (op.currentOrder!.createdAt != null) {
      now = DateTime.fromMillisecondsSinceEpoch(op.currentOrder!.createdAt??0);
    }
    String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);
    _receipt.add(ReceiptLine(text:" "));
    _receipt.add(ReceiptLine(text:"--"));
    _receipt.add(ReceiptLine(text:" "));
    //_receipt.add(ReceiptLine(text:"PAYMENT: Free because we love you"));

    _receipt.add(ReceiptLine(text:"DATE/TIME: $formattedDate"));
    _receipt.add(ReceiptLine(text:"CUSTOMER: ${op.currentOrder!.customer??"Guest"}"));
    _receipt.add(ReceiptLine(text:" "));
    _receipt.add(ReceiptLine(text:"THANK YOU FOR SUPPORTING", centered: true, bold:true));
    _receipt.add(ReceiptLine(text:"WINGNUT STABLES!", centered: true, bold:true));
  }


}

class ReceiptLine {
  int type = 1; // 2 = image
  String text = "";
  bool centered = false;
  bool bold = false;

  ReceiptLine({this.text = "", this.centered = false, this.bold = false, this.type=1});
}
