import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import 'receipt_helper.dart';

class PrinterService extends ChangeNotifier {
  final BluetoothPrint _bt = BluetoothPrint.instance;
  BluetoothDevice? printer;
  bool connected = false;

  PrinterService() {
    _bt.state.listen((state) {
      connected = state == BluetoothPrint.CONNECTED;
      notifyListeners();
    });
  }

  Stream<List<BluetoothDevice>> get scanResults =>
      _bt.scanResults.map((list) => list.cast<BluetoothDevice>());

  Future<void> startScan() =>
      _bt.startScan(timeout: const Duration(seconds: 4));

  Future<void> connect(BluetoothDevice device) async {
    printer = device;
    await _bt.connect(device);
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _bt.disconnect();
    printer = null;
    notifyListeners();
  }

  Future<bool> isConnected() async => await _bt.isConnected ?? false;

  Future<void> printOrder(Order order) async {
    final lines = ReceiptHelper.buildLines(order);
    final list = <LineText>[];

    for (final line in lines) {
      if (line.divider) {
        list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '********************************',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ));
        continue;
      }

      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: line.text,
        weight: line.bold ? 2 : 1,
        align: line.centered ? LineText.ALIGN_CENTER : LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
    }

    await _bt.printReceipt({}, list);
  }
}