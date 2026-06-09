import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/order_model.dart';
import '../theme/wingnut_theme.dart';
import '../services/api_service.dart';
import 'add_decals_screen.dart';
import 'order_receipt_screen.dart';
import 'search_results_screen.dart';

class AddItemScreen extends StatefulWidget {
  final Order order;
  final ApiService api;

  const AddItemScreen({super.key, required this.order, required this.api});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final MobileScannerController _scanner = MobileScannerController();
  final TextEditingController _searchController = TextEditingController();
  bool _scanned = false;
  bool _searching = false;
  String? _error;

  @override
  void dispose() {
    _scanner.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onQrDetected(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    // Only handle our WTC format
    if (!raw.contains('WTC-') || !raw.contains('N:')) return;

    setState(() => _scanned = true);
    _scanner.stop();

    final result = QrScanResult.fromQrString(raw);
    _proceedWithResult(result);
  }

  void _proceedWithResult(QrScanResult result) {
    if (result.isTransfer) {
      // Transfers shouldn't be scanned as a blank — show error
      setState(() {
        _scanned = false;
        _error = 'That\'s a transfer, not a product. Scan a shirt, hoodie, or other item.';
      });
      _scanner.start();
      return;
    }

    final item = OrderItem(
      blankId: result.id,
      blankName: result.name,
      size: result.size ?? '',
      placements: result.placementSlots
          .map((slot) => DecalPlacement(slot: slot))
          .toList(),
    );

    if (item.hasPlacementSlots) {
      _goToDecals(item);
    } else {
      _addToOrderAndGoToReceipt(item);
    }
  }

  void _goToDecals(OrderItem item) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AddDecalsScreen(
          order: widget.order,
          item: item,
          api: widget.api,
        ),
      ),
    );
  }

  void _addToOrderAndGoToReceipt(OrderItem item) {
    widget.order.items.add(item);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderReceiptScreen(
          order: widget.order,
          api: widget.api,
        ),
      ),
    );
  }

  Future<void> _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _error = null;
    });
    _scanner.stop();

    try {
      final results = await widget.api.searchInventory(query);
      if (!mounted) return;

      if (results.isEmpty) {
        setState(() {
          _error = 'No items found for "$query".';
          _searching = false;
        });
        _scanner.start();
        return;
      }

      final selected = await Navigator.of(context).push<InventorySearchResult>(
        MaterialPageRoute(
          builder: (_) => SearchResultsScreen(results: results),
        ),
      );

      if (!mounted) return;
      setState(() => _searching = false);

      if (selected != null) {
        _proceedWithResult(QrScanResult(
          id: selected.id,
          name: selected.name,
          size: selected.size,
          placementSlots: selected.placementSlots,
        ));
      } else {
        _scanner.start();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _searching = false;
      });
      _scanner.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFirstItem = widget.order.items.isEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: WingnutTheme.violet,
        title: Text(isFirstItem ? 'Scan Item' : 'Add Another Item'),
        leading: isFirstItem
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        )
            : IconButton(
          icon: const Icon(Icons.receipt_long_outlined),
          tooltip: 'Back to receipt',
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderReceiptScreen(
                order: widget.order,
                api: widget.api,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // QR scanner — takes most of the screen
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scanner,
                  onDetect: _onQrDetected,
                ),

                // Overlay frame
                Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: WingnutTheme.violetMid, width: 2.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                // Corner label
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Point camera at item tag',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ),

                // Error banner
                if (_error != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: WingnutTheme.danger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Searching spinner
                if (_searching)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: WingnutTheme.violetMid),
                    ),
                  ),
              ],
            ),
          ),

          // Manual lookup panel
          Container(
            color: WingnutTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Or search manually',
                  style: TextStyle(
                      fontSize: 12,
                      color: WingnutTheme.textSecondary,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _onSearch(),
                        decoration: const InputDecoration(
                          hintText: 'WTC-XXXXXXXX or "dragon sticker"',
                          prefixIcon: Icon(Icons.search,
                              color: WingnutTheme.textSecondary),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onSearch,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Icon(Icons.arrow_forward, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}