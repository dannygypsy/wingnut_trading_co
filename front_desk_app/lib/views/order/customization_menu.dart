

import 'package:flutter/material.dart';
import 'package:front_desk_app/provider/inventory_provider.dart';
import 'package:provider/provider.dart';

import 'customization_category_card.dart';

class CustomizationMenu extends StatelessWidget {
  final Function onSelect;
  final Function onDone;

  CustomizationMenu({required this.onSelect, required this.onDone});

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [
        CustomizationCategoryCard(position: 'Front', type: 'transfer', onItemSelected: onSelect),
        CustomizationCategoryCard(position: 'Back', type: 'transfer', onItemSelected: onSelect),
        // Done button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              onDone(); // Indicate done with customization
            },
            child: const Text('Done'),
          ),
        ),
      ],
    );;
  }
}