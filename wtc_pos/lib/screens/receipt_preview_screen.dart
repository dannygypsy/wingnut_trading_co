import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../services/printer_service.dart';
import '../services/receipt_helper.dart';
import '../theme/wingnut_theme.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final Order order;
  final bool isConfirmation;

  const ReceiptPreviewScreen({
    super.key,
    required this.order,
    this.isConfirmation = false,
  });

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  bool _printing = false;
  String? _printError;
  int _printCount = 0;

  Future<void> _print() async {
    final printerService = context.read<PrinterService>();
    final connected = await printerService.isConnected();
    if (!connected) {
      setState(() => _printError =
      'No printer connected. Go to Printer on the main menu.');
      return;
    }
    setState(() {
      _printing = true;
      _printError = null;
    });
    try {
      await printerService.printOrder(widget.order);
      setState(() {
        _printCount++;
        _printing = false;
      });
    } catch (e) {
      setState(() {
        _printError = e.toString();
        _printing = false;
      });
    }
  }

  void _done() {
    // Pop all the way back to home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final lines = ReceiptHelper.buildLines(widget.order);
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
        title: Text(widget.isConfirmation ? 'Order Confirmed' : 'Receipt Preview'),
        automaticallyImplyLeading: !widget.isConfirmation,
      ),
      body: Column(
        children: [
          // ── Receipt ──────────────────────────────────────
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
                      return Center(
                          child: Text(line.text, style: style(line.bold)));
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

          // ── Bottom bar ───────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: const BoxDecoration(
              color: WingnutTheme.surface,
              border: Border(top: BorderSide(color: WingnutTheme.border)),
            ),
            child: widget.isConfirmation
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Print button
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: ElevatedButton.icon(
                        onPressed: _printing ? null : _print,
                        icon: _printing
                            ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.print_outlined, size: 20),
                        label: Text('Print Receipt'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: _done,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
                if (_printError != null) ...[
                  const SizedBox(height: 8),
                  Text(_printError!,
                      style: const TextStyle(
                          fontSize: 12, color: WingnutTheme.danger),
                      textAlign: TextAlign.center),
                ],
              ],
            )
                : ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Order'),
            ),
          ),
        ],
      ),
    );
  }
}