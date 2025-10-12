import 'package:flutter/material.dart';

class Values {
  static String version = "Unknown";
  static String build = "Unknown";


  static const String restAPIHost = "www.groop.zone";
  static const useSSL = true;

  // static const String restAPIHost = "127.0.0.1:3001";
  // static const useSSL = false;


  static String? authToken;
  static const String scriptFolder = "/api/wtc_desk";
  static final navigatorKey = GlobalKey<NavigatorState>();
}