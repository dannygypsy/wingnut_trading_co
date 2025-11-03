

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

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
            child: Text("Stuff goes here")
          )
        )

    );
  }


}