

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_desk_app/provider/inventory_provider.dart';
import 'package:front_desk_app/provider/order_provider.dart';
import 'package:front_desk_app/util/comms.dart';
import 'package:front_desk_app/util/db.dart';
import 'package:front_desk_app/util/dialogs.dart';
import 'package:front_desk_app/views/order/order_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';

import 'printer/printer_page.dart';

class HomeScreen extends StatelessWidget {

  final TextStyle _titleStyle = const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold);
  final TextStyle _smallStyle = const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final op = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
        extendBodyBehindAppBar: true,

        appBar: AppBar(
          backgroundColor: const Color(0x00000000),
          title: Builder(
              builder: (BuildContext context) {
                //print("App is ${_controller.app.value.name}");
                return const Text("");
              }
          ),
          centerTitle: true,
        ),
        body: SizedBox.expand(
            child: Container(
                padding: const EdgeInsets.only(top: 150),
                decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/wallpaper.webp"),
                      fit: BoxFit.cover,
                    )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox.fromSize(
                      size: const Size(250, 250),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            //color: Colors.white.withAlpha(50),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(125),
                              border: Border.all(
                                color: Colors.white.withAlpha(100),
                                width: 5,
                              ),
                            ),
                            child: InkWell(
                              splashColor: Colors.green.withOpacity(0.5),
                              onTap: () async {
                                debugPrint("NEW ORDER");
                                await op.startNewOrder(createdBy: "Danny");
                                Navigator.push(context,MaterialPageRoute(builder: (context) => OrderPage()),);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(FontAwesomeIcons.shirtsinbulk, size: 100, color: Colors.black),
                                  Text("NEW ORDER", style: _titleStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height:50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.fromSize(
                          size: const Size(175, 175),
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(125),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(100),
                                    width: 5,
                                  ),
                                ),
                                child: InkWell(
                                  splashColor: Colors.green.withOpacity(0.5),
                                  onTap: () {
                                    debugPrint("Menu selected");
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(FontAwesomeIcons.clipboardList, size: 75, color: Colors.black),
                                      Text("Inventory", style: _smallStyle),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width:50),
                        SizedBox.fromSize(
                          size: const Size(175, 175),
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(125),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(100),
                                    width: 5,
                                  ),
                                ),
                                child: InkWell(
                                  splashColor: Colors.green.withOpacity(0.5),
                                  onTap: () {
                                    debugPrint("New  selected");
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(FontAwesomeIcons.tableList, size: 75, color: Colors.black),
                                      Text("Orders", style: _smallStyle),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width:50),
                        SizedBox.fromSize(
                          size: const Size(175, 175),
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(125),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(100),
                                    width: 5,
                                  ),
                                ),
                                child: InkWell(
                                  splashColor: Colors.green.withOpacity(0.5),
                                  onTap: () {
                                    debugPrint("Printer selected");
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => PrinterPage()),);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(FontAwesomeIcons.print, size: 75, color: Colors.black),
                                      Text("Printer", style: _smallStyle),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height:50),
                    SizedBox.fromSize(
                      size: const Size(100, 100),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            //color: Colors.white.withAlpha(50),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(125),
                              border: Border.all(
                                color: Colors.white.withAlpha(100),
                                width: 5,
                              ),
                            ),
                            child: InkWell(
                              splashColor: Colors.green.withOpacity(0.5),
                              onTap: () {
                                debugPrint("SYNC");
                                _syncData(context);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(FontAwesomeIcons.sync, size: 32, color: Colors.black),
                                  Text("SYNC", style: _smallStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            )
        )

    );
  }

  Future<void> _syncData(BuildContext context) async {
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,  // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,  // Prevent back button dismiss
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Syncing data...',
                    style: _smallStyle,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Implement your data synchronization logic here
      final results = await remoteGet('sync', {});

      // Dismiss loading overlay
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (results.success == false || results.data == null) {
        // Handle error
        if (context.mounted) {
          errorDialog(context, results.message);
        }
        debugPrint("Error during sync: ${results.message}");
        return;
      }

      Map m = results.data as Map<String, dynamic>;
      // Look for 'inventory', a List of inventory items
      List? inventoryList = m['inventory'] as List?;
      if (inventoryList != null) {
        // Process each inventory item
        for (var item in inventoryList) {
          // Assuming item is a Map<String, dynamic>
          Map<String, dynamic> inventoryItem = item as Map<String, dynamic>;
          // Here you would insert or update the inventory item in your local database

          Database db = await DatabaseHandler().initializeDB();
          // Clear the inventory table before inserting new data
          await db.insert(
            'inventory',
            {
              'id': inventoryItem['id'],
              'type': inventoryItem['type'],
              'name': inventoryItem['name'],
              'full_name': inventoryItem['full_name'],
              'category': inventoryItem['category'],
              'cost': inventoryItem['cost'],
              'retail': inventoryItem['retail'],
              'purchased_on': inventoryItem['purchased_on'],
              'num_purchased': inventoryItem['num_purchased'],
              'remaining': inventoryItem['remaining'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          debugPrint("Inventory item: $inventoryItem");
        }
      }

      // Force the provider to refresh its data
      InventoryProvider ip = Provider.of<InventoryProvider>(context, listen: false);
      await ip.refresh();

      if (context.mounted) {
        successDialog(context, "Data synchronized successfully");
      }

      debugPrint("Data synchronized");
    } catch (e) {
      // Dismiss loading overlay on error
      if (context.mounted) {
        Navigator.of(context).pop();
        errorDialog(context, "Sync failed: $e");
      }
    }
  }

}