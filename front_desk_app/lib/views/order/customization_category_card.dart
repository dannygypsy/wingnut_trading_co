


import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:front_desk_app/provider/inventory_provider.dart';
import 'package:provider/provider.dart';
import 'inventory_item_card.dart';

class CustomizationCategoryCard extends StatelessWidget {

  final String position;
  final String type;
  final Function onItemSelected;

  const CustomizationCategoryCard({super.key, required this.type, required this.onItemSelected, required this.position});

  final TextStyle _titleStyle = const TextStyle(fontSize: 20, color: Colors.white);

  @override
  Widget build(BuildContext context) {

    final ip = Provider.of<InventoryProvider>(context, listen: false);

    List<Widget> itemCards = [];

    // Add a 'none' option for categories that are not required
    itemCards.add(InventoryItemCard(item: null, onSelect: (i) {
      onItemSelected(null, position);
    }));

    for (var i in ip.getItemsByType(type)) {
      itemCards.add(InventoryItemCard(item: i, onSelect: (i) {
        onItemSelected(i, position);
      }));
    }

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(50),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.white.withAlpha(100),
                        width: 2,
                      ),
                    ),
                    child: IntrinsicHeight(
                        child: Column(
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white.withAlpha(100),
                                        width: 2,
                                      ),
                                    ),

                                  ),
                                  child: Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Text(position, style: _titleStyle),

                                            )
                                        ),
                                      ]
                                  )
                              ),

                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Wrap(
                                          alignment: WrapAlignment.start,
                                          spacing: 8.0, // gap between adjacent chips
                                          runSpacing: 8.0, // gap between lines
                                          children: itemCards
                                      )
                                  )
                              )
                            ]
                        )
                    )
                )
            )
        )
    );
  }



}