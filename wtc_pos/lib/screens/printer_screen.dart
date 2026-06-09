import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/printer_service.dart';
import '../theme/wingnut_theme.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterService>().startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final printer = context.watch<PrinterService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Printer')),
      body: Column(
        children: [
          // ── Status card ──────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WingnutTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WingnutTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Printer',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: WingnutTheme.textSecondary,
                        letterSpacing: 0.8)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      printer.connected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      color: printer.connected
                          ? Colors.green
                          : WingnutTheme.textSecondary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            printer.printer?.name ?? 'No printer selected',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            printer.connected ? 'Connected' : 'Disconnected',
                            style: TextStyle(
                              fontSize: 13,
                              color: printer.connected
                                  ? Colors.green
                                  : WingnutTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (printer.connected)
                      TextButton(
                        onPressed: printer.disconnect,
                        child: const Text('Disconnect',
                            style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Scan header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Available Devices',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: WingnutTheme.textSecondary,
                        letterSpacing: 0.8)),
                const Spacer(),
                TextButton.icon(
                  onPressed: printer.startScan,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Scan'),
                ),
              ],
            ),
          ),

          // ── Device list ──────────────────────────────────
          Expanded(
            child: StreamBuilder<List<BluetoothDevice>>(
              stream: printer.scanResults,
              initialData: const [],
              builder: (context, snapshot) {
                final devices = snapshot.data ?? [];

                if (devices.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bluetooth_searching,
                            size: 48, color: WingnutTheme.textSecondary),
                        SizedBox(height: 12),
                        Text('Scanning for devices...',
                            style: TextStyle(
                                color: WingnutTheme.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final device = devices[i];
                    final isSelected =
                        printer.printer?.address == device.address;
                    return Material(
                      color: isSelected
                          ? WingnutTheme.violetLight
                          : WingnutTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => printer.connect(device),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.print_outlined,
                                color: isSelected
                                    ? WingnutTheme.violet
                                    : WingnutTheme.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name ?? 'Unknown Device',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? WingnutTheme.violetDark
                                            : WingnutTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      device.address ?? '',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: WingnutTheme.textSecondary,
                                          fontFamily: 'Courier'),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: WingnutTheme.violet),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}