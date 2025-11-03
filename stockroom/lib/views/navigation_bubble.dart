
// lib/widgets/navigation_bubble.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stockroom/provider/navigation_provider.dart';

class NavigationBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const NavigationBubble({
    Key? key,
    required this.icon,
    required this.label,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final bool isActive = navProvider.currentView == route;

    return SizedBox.fromSize(
      size: const Size(150, 150),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(125),
              border: Border.all(
                color: isActive ? Colors.teal : Colors.black,
                width: 5,
              ),
            ),
            child: InkWell(
              splashColor: Colors.teal.withOpacity(0.5),
              onTap: () {
                navProvider.navigateTo(route);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 50, color: Colors.black),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}