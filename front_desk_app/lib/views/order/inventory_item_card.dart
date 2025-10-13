

import 'package:flutter/material.dart';
import 'package:front_desk_app/model/inventory_item.dart';

class InventoryItemCard extends StatelessWidget {

  final InventoryItem item;
  final Function onSelect;

  const InventoryItemCard({required this.item, required this.onSelect});

  @override
  Widget build(BuildContext context) {

    //debugPrint("Drawing item ${widget.item.name} with image ${widget.item.image}");

    // Convert retail price to string (with 2 decimal place if needed)
    double price = item.retail;
    String priceStr = price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
    priceStr = "\$$priceStr";

    return GestureDetector(
      onTap: () {
        onSelect(item);
      },
      child: SizedBox(
        width:150,
        height:150,


        child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(item.imageURL),
                      fit: BoxFit.contain,
                    ),
                    border: Border.all(
                      color: const Color.fromARGB(30, 255, 255, 255),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))
                ),
                child:const SizedBox(height:150, width:150),
              ),
              Positioned(
                  bottom: 0,
                  left:0,
                  right:0,
                  child: Container(

                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.black.withAlpha(0),
                                Colors.black45,
                                Colors.black87
                              ]

                          )
                      ),
                      child: Center(child:Text(item.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                  offset: Offset(-2, -2),
                                  color: Colors.black
                              ),
                              Shadow(
                                  offset: Offset(2, -2),
                                  color: Colors.black
                              ),
                              Shadow(
                                  offset: Offset(-2, 2),
                                  color: Colors.black
                              ),
                              Shadow(
                                  offset: Offset(2, 2),
                                  color: Colors.black
                              ),
                            ]
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ))
                  )

              ),
              Positioned(
                  top: 0,
                  right:0,
                  child: Text(priceStr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                              offset: Offset(-2, -2),
                              color: Colors.black
                          ),
                          Shadow(
                              offset: Offset(2, -2),
                              color: Colors.black
                          ),
                          Shadow(
                              offset: Offset(-2, 2),
                              color: Colors.black
                          ),
                          Shadow(
                              offset: Offset(2, 2),
                              color: Colors.black
                          ),
                        ]
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )

              ),
            ]
        ),
      ),
    );

  }

}