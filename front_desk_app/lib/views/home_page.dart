

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {

  final TextStyle _titleStyle = const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold);
  final TextStyle _smallStyle = const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {

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
                              onTap: () {
                                debugPrint("SCAN");
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
                                    debugPrint("Menu selected");
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
                                    debugPrint("Menu selected");
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
                    )
                  ],
                )
            )
        )

    );
  }

}