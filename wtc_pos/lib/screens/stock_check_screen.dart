import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../theme/wingnut_theme.dart';

class StockCheckScreen extends StatefulWidget {
  final ApiService api;

  const StockCheckScreen({super.key, required this.api});

  @override
  State<StockCheckScreen> createState() => _StockCheckScreenState();
}

class _StockCheckScreenState extends State<StockCheckScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();

  bool _scanning = true;
  bool _loading = false;
  String? _error;
  StockResult? _result;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _lookup(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty) return;

    debugPrint('Initiating stock check for code: $code');

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _scanning = false;
    });

    try {
      final result = await widget.api.checkStock(code);
      debugPrint('Lookup result for $code: $result');
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error during stock check for $code: $e');
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_scanning) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    _scannerController.stop();
    _lookup(barcode!.rawValue!);
  }

  void _reset() {
    setState(() {
      _scanning = true;
      _result = null;
      _error = null;
      _loading = false;
      _manualController.clear();
    });
    _scannerController.start();
  }

  void _submitManual() {
    final val = _manualController.text.trim();
    if (val.isNotEmpty) {
      FocusScope.of(context).unfocus();
      _lookup(val);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Check'),
        backgroundColor: WingnutTheme.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: WingnutTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scanner
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 220,
                  child: _scanning
                      ? MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  )
                      : Container(
                    color: Colors.black87,
                    child: Center(
                      child: _loading
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          : Icon(CupertinoIcons.qrcode,
                          size: 64,
                          color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Manual entry
              /*
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualController,
                      decoration: const InputDecoration(
                        hintText: 'WTC-XXXXXXXX or WTC-XXXXXXXX|2XL',
                        prefixIcon: Icon(Icons.edit_outlined),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _submitManual(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submitManual,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WingnutTheme.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(56, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.search),
                  ),
                ],
              ),

               */

              //const SizedBox(height: 24),

              if (_error != null) _ErrorCard(message: _error!),
              if (_result != null) _ResultCard(result: _result!),

              if (!_scanning && !_loading) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(CupertinoIcons.qrcode_viewfinder),
                  label: const Text('Scan Another'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: WingnutTheme.teal,
                    side: const BorderSide(color: WingnutTheme.teal, width: 1.5),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final StockResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final inStock = result.inStock;
    final remaining = result.remaining;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: inStock ? WingnutTheme.teal : WingnutTheme.danger,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: WingnutTheme.textPrimary,
            ),
          ),
          if (result.size.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              result.size,
              style: const TextStyle(
                  fontSize: 15, color: WingnutTheme.textSecondary),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            result.category,
            style: const TextStyle(
                fontSize: 13, color: WingnutTheme.textSecondary),
          ),
          const Divider(height: 28, color: WingnutTheme.border),
          Row(
            children: [
              Icon(
                inStock
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.xmark_circle_fill,
                color: inStock ? WingnutTheme.teal : WingnutTheme.danger,
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inStock ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: inStock ? WingnutTheme.teal : WingnutTheme.danger,
                    ),
                  ),
                  Text(
                    '$remaining unit${remaining == 1 ? '' : 's'} remaining',
                    style: const TextStyle(
                        fontSize: 13, color: WingnutTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WingnutTheme.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WingnutTheme.danger.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(CupertinoIcons.exclamationmark_circle,
              color: WingnutTheme.danger, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style:
              const TextStyle(color: WingnutTheme.danger, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}