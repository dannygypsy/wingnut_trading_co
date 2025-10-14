
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_desk_app/model/inventory_item.dart';
import 'package:front_desk_app/model/order_item.dart';
import 'package:front_desk_app/model/values.dart';
import 'package:front_desk_app/provider/inventory_provider.dart';
import 'package:front_desk_app/provider/order_provider.dart';
import 'package:front_desk_app/provider/printer_provider.dart';
import 'package:front_desk_app/util/dialogs.dart';
import 'package:provider/provider.dart';
import 'customization_menu.dart';
import 'inventory_menu.dart';
import 'order_receipt_card.dart';

class OrderPage extends StatefulWidget {

  const OrderPage({super.key});

  @override
  State<StatefulWidget> createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {

  final TextStyle _titleStyle = const TextStyle(fontSize: 36, color: Colors.white);
  final TextEditingController _textController = TextEditingController();
  OrderItem ? _customizingItem;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: true);

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color(0x00000000),
          centerTitle: true,
          elevation: 0,
          title: Text("Order ${op.currentOrder!.id}", style: _titleStyle,),
        ),
        body: SizedBox.expand(
            child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/wallpaper.webp"),
                      fit: BoxFit.cover,
                    )
                ),
                child: Row(
                    children:[
                      Expanded(
                        child: _customizingItem == null
                            ? InventoryMenu(onSelect: _onSelectedItem)
                            : CustomizationMenu(
                                onSelect: (item, position) {
                                  if (item == null) {
                                    _removeCustomization(position);
                                  } else {
                                    debugPrint("Selected customized item: ${item
                                        .name}");
                                    _addCustomization(item, position);
                                  }
                                },
                                onDone: () {
                                  setState(() {
                                    _customizingItem = null;
                                  });
                                },
                              )
                      ),
                      SizedBox(width:10),
                      Padding(
                        padding: const EdgeInsets.only(top: 90, right:10, bottom:10),
                        child: Consumer<OrderProvider>(
                            builder: (context, order, child) {
                              return Column(
                                  children: [
                                    Expanded(
                                      child: OrderReceiptCard(onGuestTapped: _customer, onNotesTapped: _comments, selectedItem: _customizingItem, onItemTapped: _orderItemTapped),
                                    ),
                                    const SizedBox(height: 10),
                                    OverflowBar(
                                      spacing: 10,
                                      children: <Widget>[
                                        Material( //Wrap with Material
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.0)),
                                          elevation: 18.0,
                                          color: Colors.deepOrange,
                                          clipBehavior: Clip.antiAlias,
                                          // Add This
                                          child: MaterialButton(
                                            minWidth: 50,  // Add this
                                            height: 50,    // Add this
                                            padding: EdgeInsets.zero,
                                            child: const Icon(FontAwesomeIcons.arrowRotateLeft),
                                            onPressed: () {
                                              _resetOrder();
                                            },
                                          ),
                                        ),
                                        Material( //Wrap with Material
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.0)),
                                          elevation: 18.0,
                                          color: Colors.blueGrey,
                                          clipBehavior: Clip.antiAlias,
                                          // Add This
                                          child: MaterialButton(
                                            minWidth: 50,  // Add this
                                            height: 50,    // Add this
                                            padding: EdgeInsets.zero,
                                            child: Icon(FontAwesomeIcons.person),
                                            onPressed: () {
                                              _customer();
                                            },
                                          ),
                                        ),
                                        Material( //Wrap with Material
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.0)),
                                          elevation: 18.0,
                                          color: Colors.blueGrey,
                                          clipBehavior: Clip.antiAlias,
                                          // Add This
                                          child: MaterialButton(
                                            minWidth: 50,  // Add this
                                            height: 50,    // Add this
                                            padding: EdgeInsets.zero,
                                            child: Icon(FontAwesomeIcons.noteSticky),
                                            onPressed: () {
                                              _comments();
                                            },
                                          ),
                                        ),
                                        Material( //Wrap with Material
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.0)),
                                          elevation: 18.0,
                                          color: Colors.blueGrey,
                                          clipBehavior: Clip.antiAlias,
                                          // Add This
                                          child: MaterialButton(
                                            minWidth: 50,  // Add this
                                            height: 50,    // Add this
                                            padding: EdgeInsets.zero,
                                            child: Icon(FontAwesomeIcons.print),
                                            onPressed: order.currentItems.isNotEmpty && order.currentOrder!.customer != null && order.currentOrder!.customer!.isNotEmpty ? _printOrder : null,
                                          ),
                                        ),
                                        Material( //Wrap with Material
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.0)),
                                          elevation: 18.0,
                                          color: Colors.green,
                                          clipBehavior: Clip.antiAlias,
                                          // Add This
                                          child: MaterialButton(
                                            minWidth: 50,  // Add this
                                            height: 50,    // Add this
                                            padding: EdgeInsets.zero,
                                            child: Icon(FontAwesomeIcons.save),
                                            onPressed: order.currentItems.isNotEmpty && order.currentOrder!.customer != null && order.currentOrder!.customer!.isNotEmpty ? _saveOrder : null,
                                          ),
                                        )
                                      ],
                                    )
                                  ]
                              );
                            }),
                      )
                    ]
                )
            )
        )
    );
  }

  Future<bool> _saveOrder() async {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);


    debugPrint("Saving order...");

    await op.saveOrder();

    debugPrint("Order saved.");

    // Pop back to whatever page this came from
    Navigator.of(context).pop();







    /*
    Database db = await DatabaseHandler().initializeDB();

    DateTime now = DateTime.now();
    int dtn = now.millisecondsSinceEpoch;

    int id = await db.insert(
        'orders',
        {
          'customer_name': op.order!.customerName,
          'datetime': dtn,
          'wristband_code': op.order!.wristbandCode,
          'comments': op.order!.comments
        }
      //conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert the items now
    for (var element in op.order!.items) {
      await db.insert(
          'order_items',
          {
            'order_id': id,
            'item_name': element.name,
            'num': element.num
          }
        //conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

     */

    return true;
  }

  Future<bool>_printOrder() async {

    debugPrint("Attempting to print this order...");


    PrinterProvider pp = Provider.of<PrinterProvider>(context, listen: false);
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);

    if (await pp.isConnected()) {
      //debugPrint("Printer is connected.");
      pp.printOrder(op.currentOrder!);
    } else {
      //debugPrint("Printer is not connected.");
      await errorDialog(Values.navigatorKey.currentContext!, "No printer is connected, but the order has been entered. Go to the printer menu and connect to a printer, then go to the orders screen to reprint this order.");
    }



    // Pop back to whatever page this came from
    // Navigator.of(context).pop();

    return true;
  }

  _comments() async {

    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);

    _textController.text = op.currentOrder!.notes??"";

    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {

          //ColorThemeProvider ctp = Provider.of<ColorThemeProvider>(context, listen: true);
          return StatefulBuilder(
              builder: (context, setStateSB) =>
                  AlertDialog(
                    backgroundColor: const Color(0xff384051),
                    shape: const RoundedRectangleBorder(
                        borderRadius:BorderRadius.all(Radius.circular(10.0))
                    ),
                    content: Builder(
                      builder: (context) {
                        return Stack(
                            clipBehavior: Clip.none, alignment: Alignment.center,
                            children: <Widget>[

                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 300,
                                ),
                                child: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      const SizedBox(height:40),
                                      TextFormField(
                                        controller: _textController,
                                        textCapitalization: TextCapitalization.sentences,
                                        keyboardType: TextInputType.multiline,
                                        minLines: 4,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          //hintText: "Character Name",
                                            hintStyle: const TextStyle(color: Colors.grey),
                                            label: Text("Notes"),
                                            labelStyle: const TextStyle(color: Colors.grey),
                                            //prefixIcon: icon,
                                            counterText: '',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))
                                        ),

                                        maxLength: 200,
                                        textAlign: TextAlign.left,
                                        //onSaved: (val) {
                                        //  titleController.text = val??"";
                                        //},
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: -75,
                                  child: Container(
                                    width: 105.0,
                                    height: 105.0,
                                    decoration: const BoxDecoration(
                                      color: Color(0xff384051),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.textsms_outlined, size: 80),
                                  )
                              )
                            ]
                        );
                      },
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        //color: ctp.theme(context).buttonBackground,
                        child: const Text("CANCEL"),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      MaterialButton(
                        //color: ctp.theme(context).buttonBackground,
                        child: const Text("SAVE"),
                        onPressed: () async {
                          _changeComments(_textController.value.text);
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  )
          );
        }
    );
  }

  _customer() async {

    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);

    _textController.text = op.currentOrder!.customer??"";

    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {

          //ColorThemeProvider ctp = Provider.of<ColorThemeProvider>(context, listen: true);
          return StatefulBuilder(
              builder: (context, setStateSB) =>
                  AlertDialog(
                    backgroundColor: const Color(0xff384051),
                    shape: const RoundedRectangleBorder(
                        borderRadius:BorderRadius.all(Radius.circular(10.0))
                    ),
                    content: Builder(
                      builder: (context) {
                        return Stack(
                            clipBehavior: Clip.none, alignment: Alignment.center,
                            children: <Widget>[

                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 300,
                                ),
                                child: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      const SizedBox(height:40),
                                      TextFormField(
                                        controller: _textController,
                                        textCapitalization: TextCapitalization.sentences,
                                        keyboardType: TextInputType.text,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          //hintText: "Character Name",
                                            hintStyle: const TextStyle(color: Colors.grey),
                                            label: Text("Customer Name"),
                                            labelStyle: const TextStyle(color: Colors.grey),
                                            //prefixIcon: icon,
                                            counterText: '',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))
                                        ),

                                        maxLength: 200,
                                        textAlign: TextAlign.left,
                                        //onSaved: (val) {
                                        //  titleController.text = val??"";
                                        //},
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: -75,
                                  child: Container(
                                    width: 105.0,
                                    height: 105.0,
                                    decoration: const BoxDecoration(
                                      color: Color(0xff384051),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(FontAwesomeIcons.person, size: 80),
                                  )
                              )
                            ]
                        );
                      },
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        //color: ctp.theme(context).buttonBackground,
                        child: const Text("CANCEL"),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      MaterialButton(
                        //color: ctp.theme(context).buttonBackground,
                        child: const Text("SAVE"),
                        onPressed: () async {
                          _changeCustomer(_textController.value.text);
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  )
          );
        }
    );
  }

  _changeCustomer(String customer)  {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);
    op.updateOrderDetails(customer: customer);
  }

  _changeComments(String comments)  {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);
    op.updateOrderDetails(notes: comments);
  }

  _onSelectedItem(InventoryItem? i) {
    if (i == null)
      return;

    debugPrint("Selected ${i.name}");

    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);


    // Add the item to the order
    op.addItem(inventoryItem: i);

    // If this item is of type 'blank', go to the customization screen
    if (i.type == "blank") {
      debugPrint("This is a blank item, so go to customization screen...");
      setState(() {
        _customizingItem = op.currentItems.last;
      });
      //Navigator.push(context, MaterialPageRoute(builder: (context) => CustomizeItemPage(item
    }
  }

  _resetOrder() async {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);
    op.clearOrder();
  }

  _orderItemTapped(BuildContext context, OrderItem item) {
    InventoryProvider ip = Provider.of<InventoryProvider>(context, listen: false);

    debugPrint("Order item tapped: ${item.name}");

    // Get the inventory item, see if it's a blank
    InventoryItem? ii = ip.getItemById(item.inventoryId);
    bool canCustomize = ii != null && ii.type == 'blank';

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
            // Customize
            if (canCustomize)
              TextButton.icon(
                icon: const Icon(Icons.build),
                label: const Text('Customize'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _customizingItem = item;
                  });
                },
              ),
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

  _addCustomization(InventoryItem item, String position) {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);
    if (_customizingItem == null) return;

    debugPrint("Adding customization ${item.name} to item ${_customizingItem!.name} at position $position");

    op.addCustomizationToItem(itemId: _customizingItem!.id, name: item.name, retail: item.retail, inventoryId: item.id, position: position);
  }

  _removeCustomization(String position) {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);
    if (_customizingItem == null) return;

    debugPrint("Removing customization at position $position from item ${_customizingItem!.name}");

    op.removeCustomizationsByPosition(_customizingItem!.id, position);
  }


}

