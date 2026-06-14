import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../theme/wingnut_theme.dart';
import '../widgets/pin_dialog.dart';
import 'settings_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  Future<void> _beginSetup(BuildContext context) async {
    final settings = context.read<AppSettings>();
    final granted = await PinDialog.show(
      context,
      title: 'Device Setup',
      subtitle: 'Enter the admin PIN to configure this device.',
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
      backgroundColor: WingnutTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/ponyLogo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'WINGNUT',
                style: TextStyle(
                  fontFamily: 'Vova',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: WingnutTheme.teal,
                  letterSpacing: 3,
                ),
              ),
              const Text(
                'Trading Company',
                style: TextStyle(
                  fontFamily: 'Vova',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: WingnutTheme.textSecondary,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 48),

              const Text(
                'Setup Required',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: WingnutTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This device hasn\'t been configured yet. An admin PIN is required to set it up.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: WingnutTheme.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              ElevatedButton.icon(
                onPressed: () => _beginSetup(context),
                icon: const Icon(Icons.lock_open_outlined, size: 20),
                label: const Text('Configure This Device'),
              ),

              const Spacer(),

              Text(
                'WTC Sales v1.0',
                style: TextStyle(
                  fontSize: 12,
                  color: WingnutTheme.textSecondary.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}