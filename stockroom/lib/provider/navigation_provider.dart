// lib/providers/navigation_provider.dart
import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  String _currentView = 'dashboard';

  String get currentView => _currentView;

  void navigateTo(String view) {
    _currentView = view;
    notifyListeners();
  }
}