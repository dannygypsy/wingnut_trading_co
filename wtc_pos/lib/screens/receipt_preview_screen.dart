import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../services/printer_service.dart';
import '../services/receipt_helper.dart';
import '../theme/wingnut_theme.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final Order order;

  const ReceiptPreviewScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final lines = ReceiptHelper.buildLines(order);
    final fontSize = (MediaQuery.of(context).size.width - 32) / 17;

    TextStyle style(bool bold) => TextStyle(
      fontSize: fontSize,
      color: Colors.black,
      fontFamily: 'MerchantCopy',
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      height: 0.8,
    );

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Receipt Preview'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lines.map((line) {
                    if (line.divider) {
                      return const Divider(color: Colors.black);
                    }
                    if (line.centered) {
                      return Center(child: Text(line.text, style: style(line.bold)));
                    }
                    return Text(
                      line.text,
                      style: style(line.bold),
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ── Bottom bar ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: const BoxDecoration(
              color: WingnutTheme.surface,
              border: Border(top: BorderSide(color: WingnutTheme.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final printerService = context.read<PrinterService>();
                      final connected = await printerService.isConnected();
                      if (!connected) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'No printer connected. Go to Printer on the main menu.'),
                            ),
                          );
                        }
                        return;
                      }
                      await printerService.printOrder(order);
                    },
                    icon: const Icon(Icons.print_outlined, size: 20),
                    label: const Text('Print Receipt'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}