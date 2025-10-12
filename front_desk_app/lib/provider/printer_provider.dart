
import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_desk_app/model/order.dart';
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

    list.add(LineText(type: LineText.TYPE_TEXT, content: 'THE GLITTERY PIG', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2,linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: '"The bext meat in town!"', weight: 2, align: LineText.ALIGN_CENTER, linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'Cameron, North Carolina', weight: 2, align: LineText.ALIGN_CENTER, linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: "- ${o.customerName.toUpperCase()} -", weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: '*****************************', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
    list.add(LineText(linefeed: 1));

    // Go through the order
    for (var element in o.items) {
      list.add(LineText(type: LineText.TYPE_TEXT, content: "${element.num} ${element.name}", weight: 2, align: LineText.ALIGN_LEFT, linefeed: 1));
    }

    if (o.comments.isNotEmpty) {
      list.add(LineText(linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'COMMENTS: ${o.comments}', weight: 1, align: LineText.ALIGN_LEFT,linefeed: 1));
      list.add(LineText(linefeed: 1));
    }

    list.add(LineText(linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: '*****************************', weight: 1, align: LineText.ALIGN_LEFT,linefeed: 1));
    list.add(LineText(linefeed: 1));
    //list.add(LineText(type: LineText.TYPE_TEXT, content: 'PAYMENT: Free - we love you', weight: 2, align: LineText.ALIGN_LEFT, linefeed: 1));
    DateTime now = DateTime.now();
    if (o.datetime != null) {
      now = DateTime.fromMillisecondsSinceEpoch(o.datetime??0);
    }
    String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'DATE/TIME: $formattedDate', weight: 2, align: LineText.ALIGN_LEFT, linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'WRISTBAND CODE: ${o.wristbandCode}', weight: 2, align: LineText.ALIGN_LEFT, linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'SPRING HUNT 2025', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2,linefeed: 1));
    list.add(LineText(type: LineText.TYPE_TEXT, content: 'MAY THE ODDS BE IN YOUR FAVOR!', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2,linefeed: 1));

    //ByteData data = await rootBundle.load("assets/images/bluetooth_print.png");
    //List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    //String base64Image = base64Encode(imageBytes);
    // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

    await bluetoothPrint.printReceipt(config, list);
  }
}