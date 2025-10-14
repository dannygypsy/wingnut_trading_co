import 'package:flutter/material.dart';
import 'package:front_desk_app/model/inventory_item.dart';
import 'package:front_desk_app/provider/inventory_provider.dart';
import 'package:provider/provider.dart';

class InventoryItemCard extends StatelessWidget {

  final InventoryItem? item;
  final Function(InventoryItem?) onSelect;

  const InventoryItemCard({super.key, required this.item, required this.onSelect});

  @override
  Widget build(BuildContext context) {

    if (item == null) {
      // 'None' option
      return GestureDetector(
        onTap: () {
          onSelect(null);
        },
        child: SizedBox(
          width: 150,
          height: 150,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromARGB(30, 255, 255, 255),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10))
            ),
            child: const Center(
              child: Text(
                'None',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
            ),
          ),
        ),
      );
    }

    // Listen to inventory changes to get real-time updates
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        // Get the latest version of this item from the provider
        InventoryItem? currentItem = inventoryProvider.items.firstWhere(
              (i) => i.id == item!.id,
          orElse: () => item!,
        );

        // Convert retail price to string (with 2 decimal places if needed)
        double price = currentItem.retail ?? 0;
        String priceStr = price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
        priceStr = "\$$priceStr";

        int remaining = currentItem.remaining ?? 0;

        return GestureDetector(
          onTap: () {
            onSelect(currentItem);
          },
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          image: NetworkImage(currentItem.imageURL),
                          fit: BoxFit.contain,
                        ),
                        border: Border.all(
                          color: const Color.fromARGB(30, 255, 255, 255),
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10))
                    ),
                    child: const SizedBox(height: 150, width: 150),
                  ),

                  // Item name at bottom with gradient background
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: _buildStrokedText(
                              currentItem.name ?? 'Unknown',
                              fontSize: 14,
                              maxLines: 3,
                            ),
                          )
                      )
                  ),
                  // # at top left
                  Positioned(
                    top: 5,
                    left: 5,
                    child: _buildStrokedText(
                      remaining.toString(),
                      fontSize: 14,
                      maxLines: 1,
                    ),
                  ),

                  // Price at top right
                  Positioned(
                    top: 5,
                    right: 5,
                    child: _buildStrokedText(
                      priceStr,
                      fontSize: 14,
                      maxLines: 1,
                    ),
                  ),
                ]
            ),
          ),
        );
      },
    );
  }

  // Helper method to create text with stroke/outline
  Widget _buildStrokedText(
      String text, {
        double fontSize = 14,
        int maxLines = 1,
        Color textColor = Colors.white,
        Color strokeColor = Colors.black,
        double strokeWidth = 4.0,
      }) {
    return Stack(
      children: [
        // Stroke (outline)
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        // Fill (main text)
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}