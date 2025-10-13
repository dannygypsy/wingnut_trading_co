

import 'package:flutter/material.dart';
import 'package:front_desk_app/model/order_item.dart';
import 'package:front_desk_app/provider/order_provider.dart';
import 'package:front_desk_app/provider/printer_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderReceiptCard extends StatefulWidget {
  final Function onGuestTapped;
  final Function onNotesTapped;
  final Function(BuildContext, OrderItem) onItemTapped;
  final OrderItem ? selectedItem;

  const OrderReceiptCard({super.key, required this.onGuestTapped, required this.onNotesTapped, this.selectedItem, required this.onItemTapped});

  @override
  State<StatefulWidget> createState() => OrderReceiptCardState();
}

class OrderReceiptCardState extends State<OrderReceiptCard> {

  final _fontStyle = const TextStyle(fontSize: 24.0, color: Colors.black, fontFamily: 'MerchantCopy', height: 0.8);
  final _boldStyle = const TextStyle(fontSize: 24.0, color: Colors.black, fontFamily: 'MerchantCopy', fontWeight: FontWeight.bold, height: 0.8);
  final _fontStyleSelected = const TextStyle(fontSize: 24.0, color: Colors.red, fontFamily: 'MerchantCopy', height: 0.8);
  final _boldStyleSelected = const TextStyle(fontSize: 24.0, color: Colors.red, fontFamily: 'MerchantCopy', fontWeight: FontWeight.bold, height: 0.8);
  List<ReceiptLine> _receipt = [];

  @override
  Widget build(BuildContext context) {

    _constructReceipt();

    return Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        width: 365,
        child:  MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
                itemCount: _receipt.length,
                itemBuilder: (context, i) {
                  Widget w;

                  if (_receipt[i].type == 2) {
                    w = Image(image: AssetImage(_receipt[i].text));
                  } else {
                    TextStyle ts = _fontStyle;
                    if (_receipt[i].bold) {
                      if (_receipt[i].selected) {
                        ts = _boldStyleSelected;
                      } else {
                        ts = _boldStyle;
                      }
                    } else {
                      if (_receipt[i].selected) {
                        ts = _fontStyleSelected;
                      } else {
                        ts = _fontStyle;
                      }
                    }

                    if (_receipt[i].text == "--") {
                      w = const Divider(color: Colors.black,);
                    } else if (_receipt[i].centered) {
                      w = Center(child: Text(_receipt[i].text, style: ts,));
                    } else {
                      w = Text(
                        _receipt[i].text,
                        style: ts,
                        softWrap: false,  // Add this
                        overflow: TextOverflow.visible,  // Add this
                      );
                    }
                    if (_receipt[i].onTap != null) {
                      return InkWell(
                        onTap: () { _receipt[i].onTap!(); },
                        child: w,
                      );
                    } else {
                      return w;
                    }
                  }
                }
            )
        )
    );

  }

  _constructReceipt() {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: true);
    PrinterProvider pp = Provider.of<PrinterProvider>(context, listen: false);

    double totalAll = 0.0;

    // Header
    _receipt = [];

    //_receipt.add(ReceiptLine(text:"assets/receipt_logo.png", bold: true, centered: true, type: 2));
    _receipt.add(ReceiptLine(text:"THE WINGNUT TRADING CO.", bold: true, centered: true));
    _receipt.add(ReceiptLine(text:"Cameron, North Carolina", centered: true));
    _receipt.add(ReceiptLine(text:" "));
    _receipt.add(ReceiptLine(text:"ORDER #${op.currentOrder!.id}", centered: true));
    _receipt.add(ReceiptLine(text:"GUEST: ${op.currentOrder!.customer?.toUpperCase()??"???"}", centered: true,onTap: () {
      widget.onGuestTapped();
    }));
    _receipt.add(ReceiptLine(text:" "));
    _receipt.add(ReceiptLine(text:"********************************"));
    _receipt.add(ReceiptLine(text:" "));
    // Items

    for (var element in op.currentItems) {
      //if (element.num > 1) {
      //  _receipt.add(ReceiptLine(text: "${element.name} (${element.num})", centered: false));
      //} else {
      double total = (element.quantity??1) * (element.retail??0);
      totalAll += total;
      final s = pp.formatReceiptLine("${element.quantity} ${element.name}", "\$${total.toStringAsFixed(2)}");
      debugPrint("Receipt line: $s");
      _receipt.add(
          ReceiptLine(
              text: s,
              centered: false,
              selected: widget.selectedItem != null && widget.selectedItem!.id == element.id,
              onTap: () { widget.onItemTapped(context, element); }
          )
      );
      if (element.customizations != null && element.customizations!.isNotEmpty) {
        for (var c in element.customizations) {
          _receipt.add(ReceiptLine(text: pp.cropString("   ${c.position}:${c.name}", 32), centered: false, bold: false));
        }
      }
      //}
    }

    if (op.currentOrder!.notes != null && op.currentOrder!.notes!.isNotEmpty) {
      _receipt.add(ReceiptLine(text:" "));
      _receipt.add(ReceiptLine(text: "NOTES: ${op.currentOrder!.notes}", centered: false, onTap: () {
        widget.onNotesTapped();
      }));
    }


    _receipt.add(ReceiptLine(text:" "));
    final totalString = pp.formatReceiptLine("TOTAL:", "\$${totalAll.toStringAsFixed(2)}");
    _receipt.add(ReceiptLine(text: totalString, centered: false, bold:true));


    // Bottom
    DateTime now = DateTime.now();
    if (op.currentOrder!.createdAt != null) {
      now = DateTime.fromMillisecondsSinceEpoch(op.currentOrder!.createdAt??0);
    }
    String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);
    _receipt.add(ReceiptLine(text:" "));
    _receipt.add(ReceiptLine(text:"********************************"));
    _receipt.add(ReceiptLine(text:" "));
    //_receipt.add(ReceiptLine(text:"PAYMENT: Free because we love you"));

    _receipt.add(ReceiptLine(text:"$formattedDate", centered: true));
    //_receipt.add(ReceiptLine(text:"GUEST: ${op.currentOrder!.customer??"???"}", onTap: () {
    //  widget.onGuestTapped();
    //}));
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
  bool selected = false;
  Function ? onTap;

  ReceiptLine({this.text = "", this.centered = false, this.bold = false, this.type=1, this.onTap, this.selected = false});
}
