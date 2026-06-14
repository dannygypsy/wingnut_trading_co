import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/printer_service.dart';
import '../theme/wingnut_theme.dart';
import '../widgets/pin_dialog.dart';
import 'add_item_screen.dart';
import 'orders_list_screen.dart';
import 'printer_screen.dart';
import 'settings_screen.dart';
import 'stock_check_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      setState(() => _version = info.version);
    });
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: WingnutTheme.teal,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Trading Company',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: WingnutTheme.teal.withOpacity(0.6),
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

              const Divider(color: WingnutTheme.border),
              const SizedBox(height: 20),

              // New Order button
              _MenuCard(
                icon: CupertinoIcons.qrcode,
                label: 'New Order',
                description: 'Scan items and build a new order',
                color: WingnutTheme.tealMid,
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
                icon: CupertinoIcons.shopping_cart,
                label: 'View Orders',
                description: 'Browse and review past orders',
                color: WingnutTheme.teal,
                onTap: () {
                  final settings = context.read<AppSettings>();
                  final api = ApiService(settings.baseUrl);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrdersListScreen(api: api),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Stock Check button
              _MenuCard(
                icon: CupertinoIcons.search,
                label: 'Stock Check',
                description: 'Scan an item to check availability',
                color: WingnutTheme.tealDark,
                onTap: () {
                  final settings = context.read<AppSettings>();
                  final api = ApiService(settings.baseUrl);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StockCheckScreen(api: api),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Printer
              Consumer<PrinterService>(
                builder: (context, printerService, _) {
                  final connected = printerService.connected;
                  return _MenuCard(
                    icon: CupertinoIcons.printer,
                    label: 'Printer',
                    description: connected
                        ? 'Connected: ${printerService.printer?.name ?? ''}'
                        : 'No printer connected',
                    color: connected ? Colors.green[700]! : Colors.blueGrey[600]!,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PrinterScreen()),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Wingnut Sales v$_version',
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
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