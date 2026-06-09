import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/order_model.dart';
import '../theme/wingnut_theme.dart';
import '../services/api_service.dart';
import 'order_receipt_screen.dart';

class AddDecalsScreen extends StatefulWidget {
  final Order order;
  final OrderItem item;
  final ApiService api;

  const AddDecalsScreen({
    super.key,
    required this.order,
    required this.item,
    required this.api,
  });

  @override
  State<AddDecalsScreen> createState() => _AddDecalsScreenState();
}

class _AddDecalsScreenState extends State<AddDecalsScreen> {
  // Which slot is currently being scanned (null = none)
  int? _scanningSlotIndex;
  final MobileScannerController _scanner = MobileScannerController();
  String? _scanError;
  bool _decrementing = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  void _startScanForSlot(int index) {
    setState(() {
      _scanningSlotIndex = index;
      _scanError = null;
    });
  }

  void _cancelScan() {
    _scanner.stop();
    setState(() {
      _scanningSlotIndex = null;
      _scanError = null;
    });
  }

  Future<void> _onDecalDetected(BarcodeCapture capture) async {
    if (_scanningSlotIndex == null || _decrementing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    if (!raw.toUpperCase().startsWith('WTC-')) return;

    setState(() => _decrementing = true);
    _scanner.stop();

    try {
      // Look up the product
      final detail = await widget.api.lookupProduct(raw.trim());

      if (!detail.isTransfer) {
        setState(() {
          _scanError = 'That\'s not a transfer. Please scan a transfer label.';
          _decrementing = false;
        });
        _scanner.start();
        return;
      }

      if (!detail.inStock) {
        if (!mounted) return;
        setState(() {
          _scanError = 'No stock remaining for "${detail.name}".';
          _decrementing = false;
        });
        _scanner.start();
        return;
      }

      if (!mounted) return;

      // Assign transfer to slot and add its retail to item price
      final slot = widget.item.placements[_scanningSlotIndex!];
      slot.transferProductId = detail.productId;
      slot.transferName = detail.name;
      slot.transferRetail = detail.retail;
      widget.item.price += detail.retail;

      setState(() {
        _scanningSlotIndex = null;
        _decrementing = false;
        _scanError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanError = e.toString();
        _decrementing = false;
      });
      _scanner.start();
    }
  }

  void _clearSlot(int index) {
    setState(() {
      final slot = widget.item.placements[index];
      widget.item.price -= slot.transferRetail;
      slot.transferProductId = null;
      slot.transferName = null;
      slot.transferRetail = 0.0;
    });
  }

  void _done() {
    widget.order.items.add(widget.item);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            OrderReceiptScreen(order: widget.order, api: widget.api),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final placements = widget.item.placements;
    final filledCount = placements.where((p) => p.hasDecal).length;

    return PopScope(
      canPop: _scanningSlotIndex == null,
      onPopInvoked: (didPop) {
        if (!didPop) _cancelScan();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_scanningSlotIndex == null
              ? 'Add Decals'
              : 'Scan Decal — ${placements[_scanningSlotIndex!].slot}'),
          leading: IconButton(
            icon: Icon(
                _scanningSlotIndex != null ? Icons.close : Icons.arrow_back),
            onPressed:
            _scanningSlotIndex != null ? _cancelScan : () => Navigator.of(context).pop(),
          ),
        ),
        body: _scanningSlotIndex != null
            ? _buildScanner()
            : _buildSlotList(placements, filledCount),
      ),
    );
  }

  Widget _buildSlotList(List<DecalPlacement> placements, int filledCount) {
    return Column(
      children: [
        // Item header
        Container(
          width: double.infinity,
          color: WingnutTheme.violetLight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.blankName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: WingnutTheme.violetDark,
                ),
              ),
              if (widget.item.size.isNotEmpty)
                Text(
                  sizeLabel(widget.item.size),
                  style: const TextStyle(
                      fontSize: 13, color: WingnutTheme.textSecondary),
                ),
            ],
          ),
        ),

        // Progress indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(
            children: [
              Text(
                '$filledCount of ${placements.length} placement${placements.length == 1 ? '' : 's'} filled',
                style: const TextStyle(
                    fontSize: 13, color: WingnutTheme.textSecondary),
              ),
              const Spacer(),
              Text(
                'Tap a slot to scan',
                style: const TextStyle(
                    fontSize: 13, color: WingnutTheme.textSecondary),
              ),
            ],
          ),
        ),

        // Slot list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: placements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final placement = placements[i];
              return _SlotTile(
                placement: placement,
                onScan: () => _startScanForSlot(i),
                onClear: placement.hasDecal ? () => _clearSlot(i) : null,
              );
            },
          ),
        ),

        // Done button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: ElevatedButton(
            onPressed: _done,
            child: Text(filledCount == 0
                ? 'Continue Without Decals'
                : 'Done — Add to Order'),
          ),
        ),
      ],
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scanner,
          onDetect: _onDecalDetected,
        ),

        // Viewfinder
        Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              border:
              Border.all(color: WingnutTheme.violetMid, width: 2.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // Label
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Scan decal for: ${widget.item.placements[_scanningSlotIndex!].slot}',
                style:
                const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),

        // Error
        if (_scanError != null)
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WingnutTheme.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _scanError!,
                style:
                const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Loading overlay
        if (_decrementing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: WingnutTheme.violetMid),
                  SizedBox(height: 12),
                  Text('Checking stock...',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  final DecalPlacement placement;
  final VoidCallback onScan;
  final VoidCallback? onClear;

  const _SlotTile({
    required this.placement,
    required this.onScan,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final filled = placement.hasDecal;
    return Material(
      color: filled ? WingnutTheme.violetLight : WingnutTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: filled ? null : onScan,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Slot status icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: filled
                      ? WingnutTheme.violet
                      : WingnutTheme.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  filled ? Icons.check : Icons.qr_code_scanner,
                  color: filled ? Colors.white : WingnutTheme.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placement.slot,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: filled
                            ? WingnutTheme.violetDark
                            : WingnutTheme.textPrimary,
                      ),
                    ),
                    if (filled && placement.transferName != null)
                      Text(
                        placement.transferName!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: WingnutTheme.textSecondary),
                      )
                    else
                      const Text(
                        'Tap to scan transfer',
                        style: TextStyle(
                            fontSize: 13,
                            color: WingnutTheme.textSecondary),
                      ),
                  ],
                ),
              ),
              if (filled && onClear != null)
                IconButton(
                  icon: const Icon(Icons.close,
                      color: WingnutTheme.textSecondary, size: 18),
                  onPressed: onClear,
                  tooltip: 'Clear slot',
                )
              else if (!filled)
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: WingnutTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}