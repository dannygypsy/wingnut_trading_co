import 'package:flutter/material.dart';
import 'package:front_desk_app/model/inventory_item.dart';

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

    // Convert retail price to string (with 2 decimal places if needed)
    double price = item!.retail ?? 0;
    String priceStr = price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
    priceStr = "\$$priceStr";

    int remaining = item!.remaining ?? 0;

    return GestureDetector(
      onTap: () {
        onSelect(item);
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
                      image: NetworkImage(item!.imageURL),
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
                        //gradient: LinearGradient(
                        //    begin: Alignment.topCenter,
                        //    end: Alignment.bottomCenter,
                        //    colors: <Color>[
                        //      Colors.black.withAlpha(0),
                        //      Colors.black45,
                        //      Colors.black87
                        //    ]
                        //)
                      ),
                      child: Center(
                        child: _buildStrokedText(
                          item!.name ?? 'Unknown',
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