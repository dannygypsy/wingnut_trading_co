

import 'package:flutter/material.dart';
import 'package:front_desk_app/model/inventory_item.dart';
import 'package:front_desk_app/provider/inventory_provider.dart';
import 'package:front_desk_app/views/order/inventory_category_card.dart';
import 'package:provider/provider.dart';

class InventoryMenu extends StatelessWidget {
  final Function(InventoryItem?) onSelect;

  InventoryMenu({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    InventoryProvider ip = Provider.of<InventoryProvider>(context, listen: false);

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

    return ListView.builder(
      itemCount: cats.length,
      itemBuilder: (BuildContext context, int index) {
        return InventoryCategoryCard(type: cats[index], onItemSelected: onSelect);
      }
    );


  }
}