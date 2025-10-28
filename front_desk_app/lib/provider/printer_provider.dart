
import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_desk_app/model/order.dart';
import 'package:front_desk_app/model/values.dart';
import 'package:intl/intl.dart';

class PrinterProvider extends ChangeNotifier {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool connected = false;
  BluetoothDevice? printer;

  setPrinter(BluetoothDevice? d) async {
    if (d == null) {
      printer = null;
      notifyListeners();
      return;
    } else {
      printer = d;
      await bluetoothPrint.connect(printer!);
      notifyListeners();
    }
  }

  isConnected() async {
    return await bluetoothPrint.isConnected??false;
  }

  disconnectPrinter() async {
    if (printer != null) {
      bool isConnected = await bluetoothPrint.isConnected??false;
      if (isConnected) {
        await bluetoothPrint.disconnect();
        notifyListeners();
      }

    }
  }

  printOrder(Order o) async {

    Map<String, dynamic> config = Map();

    List<LineText> list = [];

    //debugPrint("Loading image...");
    //ByteData data = await rootBundle.load("assets/receipt_logo.png");
    //List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    //String base64Image = base64Encode(imageBytes);
    //list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

    list.add(LineText(type: LineText.TYPE_TEXT, content: 'THE WINGNUT TRADING CO.', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2,linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'Cameron, North Carolina', weight: 2, align: LineText.ALIGN_CENTER, linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'ORDER: ${o.id}', weight: 2, align: LineText.ALIGN_CENTER, linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'GUEST: ${o.customer?.toUpperCase()}', weight: 2, align: LineText.ALIGN_CENTER, linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: '********************************', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
    list.add(LineText(linefeed: 1));

    // Go through the order

    double orderTotal = o.calculateTotal();

    for (var element in o.items) {

      double price = element.retail??0;
      if (element.customizations != null && element.customizations!.isNotEmpty) {
        for (var c in element.customizations) {
          price += (c.retail??0);
        }
      }

      double total = element.quantity * price;

      final s = formatReceiptLine("${element.quantity} ${element.name}", "\$${total.toStringAsFixed(2)}");
      list.add(LineText(type: LineText.TYPE_TEXT, content: s, weight: 2, align: LineText.ALIGN_LEFT, linefeed: 1));

      if (element.customizations.isNotEmpty) {
        for (var c in element.customizations) {
          list.add(LineText(type: LineText.TYPE_TEXT, content: cropString("   ${c.position}:${c.name}", 32), weight: 2, align: LineText.ALIGN_LEFT, linefeed: 1));
        }
      }
    }



    if (o.notes != null && o.notes!.isNotEmpty) {
      list.add(LineText(linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'NOTES: ${o.notes}', weight: 1, align: LineText.ALIGN_LEFT,linefeed: 1));
    }

    list.add(LineText(linefeed: 1));

    if (o.discountDesc != null && o.discountDesc!.isNotEmpty) {

      final subtotal = o.calculateSubtotal();
      final subtotalString = formatReceiptLine("SUBTOTAL:", "\$${subtotal.toStringAsFixed(2)}");
      list.add(LineText(type: LineText.TYPE_TEXT, content: subtotalString, weight: 1, align: LineText.ALIGN_LEFT, linefeed: 1));

      final discountString = formatReceiptLine("DISCOUNT (${o.discountDesc}):", "-\$${(subtotal * (o.discountPercent??0) / 100).toStringAsFixed(2)}");
      list.add(LineText(type: LineText.TYPE_TEXT, content: discountString, weight: 1, align: LineText.ALIGN_LEFT, linefeed: 1));
    }

    final totalString = formatReceiptLine("TOTAL:", "\$${orderTotal.toStringAsFixed(2)}");
    list.add(LineText(type: LineText.TYPE_TEXT, content: totalString, weight: 1, align: LineText.ALIGN_LEFT, linefeed: 1));

    final paymentString = formatReceiptLine("PAYMENT:", "${o.paymentMethod?.toUpperCase()??"NOT PAID"}");
    list.add(LineText(type: LineText.TYPE_TEXT, content: paymentString, weight: 1, align: LineText.ALIGN_LEFT, linefeed: 1));

    list.add(LineText(linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: '********************************', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
    list.add(LineText(linefeed: 1));
    //list.add(LineText(type: LineText.TYPE_TEXT, content: 'PAYMENT: Free - we love you', weight: 2, align: LineText.ALIGN_LEFT, linefeed: 1));
    DateTime now = DateTime.now();
    if (o.createdAt != null) {
      now = DateTime.fromMillisecondsSinceEpoch(o.createdAt??0);
    }
    String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);
    list.add(LineText(type: LineText.TYPE_TEXT, content: '$formattedDate', weight: 2, align: LineText.ALIGN_CENTER, linefeed: 1));
    //list.add(LineText(type: LineText.TYPE_TEXT, content: 'GUEST: ${o.customer?.toUpperCase()}', weight: 2, align: LineText.ALIGN_LEFT, linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'THANK YOU FOR SUPPORTING', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2,linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'WINGNUT STABLES!', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2,linefeed: 1));

    //ByteData data = await rootBundle.load("assets/images/bluetooth_print.png");
    //List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    //String base64Image = base64Encode(imageBytes);
    // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

    await bluetoothPrint.printReceipt(config, list);
  }

  String formatReceiptLine(String leftText, String rightText) {
    // If combined text is too long, truncate left text
    if (leftText.length + rightText.length > Values.printerWidth) {
      int availableForLeft = Values.printerWidth - rightText.length - 1; // -1 for at least one space
      if (availableForLeft > 0) {
        leftText = leftText.substring(0, availableForLeft);
      } else {
        leftText = "";
      }
    }

    // Calculate spaces needed
    int spacesNeeded = Values.printerWidth - leftText.length - rightText.length;
    String spaces = ' ' * spacesNeeded.clamp(0, Values.printerWidth);

    return leftText + spaces + rightText;
  }

  String cropString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength);
  }
}