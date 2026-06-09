import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_settings.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'services/printer_service.dart';
import 'theme/wingnut_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = AppSettings();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => PrinterService()),
      ],
      child: const WingnutSalesApp(),
    ),
  );
}

class WingnutSalesApp extends StatelessWidget {
  const WingnutSalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wingnut Sales',
      theme: WingnutTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const _RootRouter(),
    );
  }
}

/// Routes to SetupScreen or HomeScreen based on configuration state.
/// Watches AppSettings so it reacts immediately after setup completes.
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return settings.isConfigured
        ? const HomeScreen()
        : const SetupScreen();
  }
}