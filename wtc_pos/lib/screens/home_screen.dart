import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../theme/wingnut_theme.dart';
import '../widgets/pin_dialog.dart';
import 'add_item_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openSettings(BuildContext context) async {
    final settings = context.read<AppSettings>();
    final granted = await PinDialog.show(
      context,
      title: 'Admin Access',
      subtitle: 'Enter the 4-digit PIN to access settings.',
      onVerify: (pin) => settings.verifyPin(pin),
    );
    if (granted && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final name = settings.salespersonName ?? '';

    return Scaffold(
      backgroundColor: WingnutTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo / wordmark
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WINGNUT',
                          style: TextStyle(
                            fontFamily: 'Vova',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: WingnutTheme.violet,
                            letterSpacing: 2.5,
                          ),
                        ),
                        Text(
                          'Trading Company',
                          style: TextStyle(
                            fontFamily: 'Vova',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: WingnutTheme.violet.withOpacity(0.6),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),

                    // Settings gear
                    IconButton(
                      onPressed: () => _openSettings(context),
                      icon: const Icon(Icons.settings_outlined,
                          color: WingnutTheme.textSecondary, size: 26),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Divider(color: WingnutTheme.border),
              const SizedBox(height: 28),

              // Greeting
              Text(
                'Hi, $name',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: WingnutTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "What would you like to do?",
                style: TextStyle(
                  fontSize: 16,
                  color: WingnutTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // New Order button
              _MenuCard(
                icon: CupertinoIcons.qrcode,
                label: 'New Order',
                description: 'Scan items and build a new order',
                color: WingnutTheme.violet,
                onTap: () {
                  final settings = context.read<AppSettings>();
                  final order = Order(
                    salespersonName: settings.salespersonName ?? '',
                  );
                  final api = ApiService(settings.baseUrl);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddItemScreen(order: order, api: api),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // View Orders button
              _MenuCard(
                icon: CupertinoIcons.doc_text_search,
                label: 'View Orders',
                description: 'Browse and review past orders',
                color: WingnutTheme.violetDark,
                onTap: () {
                  // TODO: navigate to orders list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon: View Orders')),
                  );
                },
              ),

              const Spacer(),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: Text(
                    'WTC Sales v1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: WingnutTheme.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}