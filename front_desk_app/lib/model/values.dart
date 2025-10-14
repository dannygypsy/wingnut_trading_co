import 'package:flutter/material.dart';

class Values {
  static String version = "Unknown";
  static String build = "Unknown";


  static const String restAPIHost = "www.groop.zone";
  static const useSSL = true;

  //static const String restAPIHost = "192.168.68.54:3001";
  //static const useSSL = false;


  static String? authToken;
  static const String scriptFolder = "/api/wtc";
  static final navigatorKey = GlobalKey<NavigatorState>();

  static int printerWidth = 32;

  static bool locked = true;
}