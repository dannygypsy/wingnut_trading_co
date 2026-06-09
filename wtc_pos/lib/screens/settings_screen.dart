import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../theme/wingnut_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppSettings>();
    _nameController =
        TextEditingController(text: settings.salespersonName ?? '');
    _urlController = TextEditingController(text: settings.baseUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salesperson name is required.')),
      );
      return;
    }

    final settings = context.read<AppSettings>();
    await settings.setSalespersonName(name);
    if (url.isNotEmpty) await settings.setBaseUrl(url);

    if (mounted) {
      setState(() => _saved = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Section header
            const Text(
              'Device Setup',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: WingnutTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // Name field
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Salesperson Name',
                hintText: 'e.g. Sarah',
                prefixIcon:
                Icon(Icons.person_outline, color: WingnutTheme.violet),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This name will appear on all orders from this device.',
              style: TextStyle(
                  fontSize: 12, color: WingnutTheme.textSecondary),
            ),

            const SizedBox(height: 28),
            const Text(
              'Connection',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: WingnutTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // URL field
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Backend URL',
                hintText: 'http://192.168.1.x:3001',
                prefixIcon:
                Icon(Icons.wifi_outlined, color: WingnutTheme.violet),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The address of your wingnut-web server on the local network.',
              style: TextStyle(
                  fontSize: 12, color: WingnutTheme.textSecondary),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _save,
              child: _saved
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 20),
                  SizedBox(width: 8),
                  Text('Saved'),
                ],
              )
                  : const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}