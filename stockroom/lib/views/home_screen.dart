

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stockroom/provider/navigation_provider.dart';

import 'dashboard/dashboard_view.dart';
import 'inventory/inventory_view.dart';
import 'navigation_bubble.dart';
import 'orders/orders_view.dart';

class HomeScreen extends StatelessWidget {

  final TextStyle _titleStyle = const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold);
  final TextStyle _smallStyle = const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

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
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/wallpaper.webp"),
                  fit: BoxFit.cover,
                )
            ),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      NavigationBubble(
                        icon: FontAwesomeIcons.tags,
                        label: "INVENTORY",
                        route: "inventory",
                      ),
                      SizedBox(height: 20),
                      NavigationBubble(
                        icon: FontAwesomeIcons.shirtsinbulk,
                        label: "ORDERS",
                        route: "orders",
                      ),
                    ]
                  )
                ),
                Expanded(
                  child: _buildRightSide(navProvider.currentView),
                )
              ]
            )
          )
        )

    );
  }

  Widget _buildRightSide(String currentView) {
    switch (currentView) {
      case 'inventory':
        return InventoryView();
      case 'orders':
        return OrdersView();
      default:
        return DashboardView();
    }
  }


}