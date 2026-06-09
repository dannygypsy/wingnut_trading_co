import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _keyName = 'salesperson_name';
  static const String _keyBaseUrl = 'base_url';

  // Hardcoded PIN — change before deploying
  static const String adminPin = '1234';

  String? _salespersonName;
  String _baseUrl = 'http://localhost:3001';

  String? get salespersonName => _salespersonName;
  String get baseUrl => _baseUrl;
  bool get isConfigured => _salespersonName != null && _salespersonName!.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _salespersonName = prefs.getString(_keyName);
    _baseUrl = prefs.getString(_keyBaseUrl) ?? 'http://localhost:3001';
    notifyListeners();
  }

  Future<void> setSalespersonName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    _salespersonName = name;
    notifyListeners();
  }

  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, url);
    _baseUrl = url;
    notifyListeners();
  }

  bool verifyPin(String pin) => pin == adminPin;
}