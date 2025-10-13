

import 'package:flutter/material.dart';
import 'package:front_desk_app/model/order_item.dart';
import 'package:front_desk_app/provider/order_provider.dart';
import 'package:front_desk_app/provider/printer_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderReceiptCard extends StatefulWidget {
  Function onGuestTapped;

  OrderReceiptCard({super.key, required this.onGuestTapped});

  @override
  State<StatefulWidget> createState() => OrderReceiptCardState();
}

class OrderReceiptCardState extends State<OrderReceiptCard> {

  final _fontStyle = const TextStyle(fontSize: 24.0, color: Colors.black, fontFamily: 'MerchantCopy', height: 0.8);
  final _boldStyle = const TextStyle(fontSize: 24.0, color: Colors.black, fontFamily: 'MerchantCopy', fontWeight: FontWeight.bold, height: 0.8);
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
                      ts = _boldStyle;
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
              onTap: () { _orderItemTapped(element); }
          )
      );
      //}
    }

    if (op.currentOrder!.notes != null && op.currentOrder!.notes!.isNotEmpty) {
      _receipt.add(ReceiptLine(text:" "));
      _receipt.add(ReceiptLine(text: "NOTES: ${op.currentOrder!.notes}", centered: false));
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

    _receipt.add(ReceiptLine(text:"DATE/TIME: $formattedDate"));
    _receipt.add(ReceiptLine(text:"GUEST: ${op.currentOrder!.customer??"???"}", onTap: () {
      widget.onGuestTapped();
    }));
    _receipt.add(ReceiptLine(text:" "));
    _receipt.add(ReceiptLine(text:"THANK YOU FOR SUPPORTING", centered: true, bold:true));
    _receipt.add(ReceiptLine(text:"WINGNUT STABLES!", centered: true, bold:true));
  }

  _orderItemTapped(OrderItem item) {
    debugPrint("Order item tapped: ${item.name}");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.name ?? 'Order Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantity: ${item.quantity}'),
              Text('Price: \$${item.retail?.toStringAsFixed(2) ?? '0.00'}'),
              Text('Line Total: \$${item.lineTotal.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            // Change Quantity
            TextButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Change Quantity'),
              onPressed: () {
                Navigator.pop(context);
                _showQuantityDialog(item);
              },
            ),
            // Change Price
            TextButton.icon(
              icon: const Icon(Icons.attach_money),
              label: const Text('Change Price'),
              onPressed: () {
                Navigator.pop(context);
                _showPriceDialog(item);
              },
            ),
            // Remove Item
            TextButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Remove'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                _removeItem(item);
              },
            ),
            // Cancel
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showQuantityDialog(OrderItem item) {
    final TextEditingController quantityController = TextEditingController(
      text: item.quantity?.toString() ?? '1',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Quantity'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              hintText: 'Enter quantity',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                final newQuantity = int.tryParse(quantityController.text);
                if (newQuantity != null && newQuantity > 0) {
                  final provider = context.read<OrderProvider>();
                  provider.updateItemQuantity(item.id, newQuantity);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quantity updated')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid quantity')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showPriceDialog(OrderItem item) {
    final TextEditingController priceController = TextEditingController(
      text: item.retail?.toStringAsFixed(2) ?? '0.00',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Price'),
          content: TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Price',
              hintText: 'Enter price',
              prefixText: '\$',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                final newPrice = double.tryParse(priceController.text);
                if (newPrice != null && newPrice >= 0) {
                  final provider = context.read<OrderProvider>();
                  final updatedItem = item.copyWith(retail: newPrice);
                  // You'll need to add this method to OrderProvider
                  provider.updateItem(updatedItem);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Price updated')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid price')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _removeItem(OrderItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: Text('Remove ${item.name} from order?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Remove'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                final provider = context.read<OrderProvider>();
                provider.removeItem(item.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} removed')),
                );
              },
            ),
          ],
        );
      },
    );
  }



}

class ReceiptLine {
  int type = 1; // 2 = image
  String text = "";
  bool centered = false;
  bool bold = false;
  Function ? onTap;

  ReceiptLine({this.text = "", this.centered = false, this.bold = false, this.type=1, this.onTap});
}
