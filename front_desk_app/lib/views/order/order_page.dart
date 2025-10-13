
import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_desk_app/model/inventory_item.dart';
import 'package:front_desk_app/provider/inventory_provider.dart';
import 'package:front_desk_app/provider/order_provider.dart';
import 'package:front_desk_app/util/loading_indicator.dart';
import 'package:front_desk_app/views/order/inventory_category_card.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'order_receipt_card.dart';

class OrderPage extends StatefulWidget {

  const OrderPage({super.key});

  @override
  State<StatefulWidget> createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {

  final TextStyle _titleStyle = const TextStyle(fontSize: 36, color: Colors.white);
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set up a new order in the provider
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);
    op.startNewOrder(createdBy: "Danny");  // We can change created by later
  }

  @override
  Widget build(BuildContext context) {

    InventoryProvider ip = Provider.of<InventoryProvider>(context, listen: false);
    OrderProvider op = Provider.of<OrderProvider>(context, listen: true);

    // Assemble the top inventory list, which is FIRST anything with type blank, then any type that isn't a transfer
    // Find categories of type BLANK first
    List<InventoryType> cats = ip.getCategoriesByType("blank");

    // Now add all other categories that aren't transfer
    for (var type in ip.types) {
      debugPrint("Checking type ${type}");
      if (type != "transfer" && type != "blank") {
        List<InventoryType> tCats = ip.getCategoriesByType(type);
        for (var c in tCats) {
          if (!cats.contains(c)) {
            cats.add(c);
          }
        }
      }
    }




    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color(0x00000000),
          centerTitle: true,
          elevation: 0,
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
                        child: ListView.builder(
                          itemCount: cats.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InventoryCategoryCard(type: cats[index], onItemSelected: _onSelectedItem,);
                          }
                        ),
                      ),
                      SizedBox(width:10),
                      Padding(
                        padding: const EdgeInsets.only(top: 90, right:10, bottom:10),
                        child: Consumer<OrderProvider>(
                            builder: (context, order, child) {
                              return Column(
                                  children: [
                                    const Expanded(
                                      child: OrderReceiptCard(),
                                    ),
                                    const SizedBox(height: 10),
                                    ButtonBar(
                                      mainAxisSize: MainAxisSize.min,
                                      // this will take space as minimum as posible(to center)
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
                                          color: Colors.green,
                                          clipBehavior: Clip.antiAlias,
                                          // Add This
                                          child: MaterialButton(
                                            child: Icon(FontAwesomeIcons.print),
                                            onPressed: order.currentItems.isNotEmpty ? _submitOrder : null,
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

  Future<bool> _submitOrder() async {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);


    debugPrint("Saving order...");

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

    return await _printOrder();
  }

  Future<bool>_printOrder() async {

    debugPrint("Attempting to print this order...");

    /*
    PrinterProvider pp = Provider.of<PrinterProvider>(context, listen: false);
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);

    if (await pp.isConnected()) {
      //debugPrint("Printer is connected.");
      pp.printOrder(op.order!);
    } else {
      //debugPrint("Printer is not connected.");
      await errorDialog(Values.navigatorKey.currentContext!, "No printer is connected, but the order has been entered. Go to the printer menu and connect to a printer, then go to the orders screen to reprint this order.");
    }

     */

    // Pop back to whatever page this came from
    Navigator.of(context).pop();

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

  _onSelectedItem(InventoryItem i) {
    debugPrint("Selected ${i.name}");

    /*
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);

    int indx = op.order!.items.indexWhere((element) => element.menuItemId == i.id);
    if (indx >= 0) {
      op.order!.items[indx].num++;
    } else {
      op.order!.items.add(OrderItem(menuItemId: i.id, name: i.name));
    }

    op.orderChanged();

     */
  }

  _resetOrder() async {
    OrderProvider op = Provider.of<OrderProvider>(context, listen: false);
    op.clearOrder();
  }


}

