import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../theme/wingnut_theme.dart';
import '../services/api_service.dart';
import '../services/printer_service.dart';
import 'add_item_screen.dart';
import 'add_decals_screen.dart';
import 'receipt_preview_screen.dart';

class OrderReceiptScreen extends StatefulWidget {
  final Order order;
  final ApiService api;

  const OrderReceiptScreen({super.key, required this.order, required this.api});

  @override
  State<OrderReceiptScreen> createState() => _OrderReceiptScreenState();
}

class _OrderReceiptScreenState extends State<OrderReceiptScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.order.customerName ?? '';
    _discountController.text = widget.order.discountPct > 0
        ? widget.order.discountPct.toStringAsFixed(0)
        : '';
    _notesController.text = widget.order.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncFields() {
    widget.order.customerName = _nameController.text.trim().isEmpty
        ? null
        : _nameController.text.trim();
    final pct = double.tryParse(_discountController.text.trim()) ?? 0;
    widget.order.discountPct = pct.clamp(0, 100);
    widget.order.notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
  }

  void _addAnotherItem() {
    _syncFields();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AddItemScreen(order: widget.order, api: widget.api),
      ),
    );
  }

  void _showItemActions(OrderItem item, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(item.blankName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  if (item.size.isNotEmpty)
                    Text(sizeLabel(item.size),
                        style: const TextStyle(
                            color: WingnutTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.attach_money, color: WingnutTheme.violet),
              title: const Text('Change Price'),
              onTap: () {
                Navigator.pop(context);
                _showPriceDialog(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exposure, color: WingnutTheme.violet),
              title: const Text('Change Quantity'),
              onTap: () {
                Navigator.pop(context);
                _showQuantityDialog(item);
              },
            ),
            if (item.hasPlacementSlots)
              ListTile(
                leading: const Icon(Icons.edit, color: WingnutTheme.violet),
                title: const Text('Edit Transfers'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddDecalsScreen(
                        order: widget.order,
                        item: item,
                        api: widget.api,
                        editMode: true,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove Item',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                setState(() => widget.order.items.removeAt(index));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPriceDialog(OrderItem item) {
    final controller =
    TextEditingController(text: item.price.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Price'),
        content: TextField(
          controller: controller,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(prefixText: '\$'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              if (v != null && v >= 0) {
                setState(() => item.price = v);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(OrderItem item) {
    final controller =
    TextEditingController(text: item.quantity.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Quantity'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = int.tryParse(controller.text);
              if (v != null && v > 0) {
                setState(() => item.quantity = v);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    _syncFields();
    if (widget.order.items.isEmpty) return;

    // Payment method required
    if (widget.order.paymentMethod == 'not paid') {
      _showErrorDialog('Please select a payment method before submitting.');
      return;
    }

    // Customer name required if any item has a transfer
    final hasTransfer = widget.order.items.any(
          (item) => item.placements.any((p) => p.hasDecal),
    );
    if (hasTransfer && (widget.order.customerName ?? '').isEmpty) {
      _showErrorDialog('Customer name is required for orders with transfers — they need to come back to pick it up.');
      return;
    }

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      final orderId = await widget.api.submitOrder(widget.order);
      if (!mounted) return;
      widget.order.id = orderId;
      // Navigate to receipt preview as the confirmation screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReceiptPreviewScreen(
            order: widget.order,
            isConfirmation: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cannot Submit'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String orderId) {}

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final subtotal = order.subtotal;
    final discountAmt = subtotal * (discount / 100);
    final total = subtotal - discountAmt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Cancel Order?'),
                content: const Text('This order will be discarded.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Keep'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                    },
                    child: const Text('Cancel Order',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add item',
            onPressed: _addAnotherItem,
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Items ──────────────────────────────────
                  ...order.items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return _ItemCard(
                      item: item,
                      index: i,
                      onTap: () => _showItemActions(item, i),
                      onRemove: () => setState(() => order.items.removeAt(i)),
                    );
                  }),

                  const SizedBox(height: 8),

                  // ── Add another ────────────────────────────
                  OutlinedButton.icon(
                    onPressed: _addAnotherItem,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Another Item'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── Customer name ──────────────────────────
                  Builder(builder: (context) {
                    final hasTransfer = order.items.any(
                          (item) => item.placements.any((p) => p.hasDecal),
                    );
                    return TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: hasTransfer
                            ? 'Customer Name *'
                            : 'Customer Name (optional)',
                        prefixIcon: const Icon(Icons.person_outline,
                            color: WingnutTheme.violet),
                      ),
                      onChanged: (_) => setState(() {}),
                    );
                  }),

                  const SizedBox(height: 12),

                  // ── Discount ───────────────────────────────
                  TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Discount %',
                      prefixIcon: Icon(Icons.local_offer_outlined,
                          color: WingnutTheme.violet),
                      suffixText: '%',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 12),

                  // ── Payment method ─────────────────────────
                  _PaymentSelector(
                    current: order.paymentMethod,
                    onChanged: (v) => setState(() => order.paymentMethod = v),
                  ),

                  const SizedBox(height: 12),

                  // ── Notes ──────────────────────────────────
                  TextField(
                    controller: _notesController,
                    maxLength: 512,
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Special instructions...',
                      prefixIcon: Icon(Icons.notes_outlined,
                          color: WingnutTheme.violet),
                      counterText: '',
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  // ── Totals ─────────────────────────────────
                  _TotalRow(label: 'Subtotal', amount: subtotal),
                  if (discount > 0) ...[
                    const SizedBox(height: 6),
                    _TotalRow(
                      label: 'Discount ($discount%)',
                      amount: -discountAmt,
                      color: Colors.green,
                    ),
                  ],
                  const SizedBox(height: 6),
                  _TotalRow(
                    label: 'Total',
                    amount: total,
                    bold: true,
                    large: true,
                  ),

                  const SizedBox(height: 100), // space for buttons
                ],
              ),
            ),

            // ── Bottom bar ────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              decoration: const BoxDecoration(
                color: WingnutTheme.surface,
                border: Border(top: BorderSide(color: WingnutTheme.border)),
              ),
              child: ElevatedButton(
                onPressed: (order.items.isEmpty || _submitting) ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Submit Order'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Item card ────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final OrderItem item;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ItemCard({
    required this.item,
    required this.index,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: WingnutTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WingnutTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.blankName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: WingnutTheme.textPrimary,
                          ),
                        ),
                        if (item.size.isNotEmpty)
                          Text(sizeLabel(item.size),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: WingnutTheme.textSecondary)),
                      ],
                    ),
                  ),
                  // Price / qty display
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${item.lineTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: WingnutTheme.textPrimary),
                      ),
                      if (item.quantity > 1)
                        Text(
                          '${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: WingnutTheme.textSecondary),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: WingnutTheme.textSecondary, size: 18),
                ],
              ),

              // Transfer placements
              if (item.placements.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...item.placements.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      Icon(
                        p.hasDecal ? Icons.circle : Icons.circle_outlined,
                        size: 8,
                        color: p.hasDecal
                            ? WingnutTheme.violet
                            : WingnutTheme.border,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        p.slot,
                        style: const TextStyle(
                            fontSize: 12,
                            color: WingnutTheme.textSecondary),
                      ),
                      if (p.hasDecal) ...[
                        const Text(' → ',
                            style: TextStyle(
                                fontSize: 12,
                                color: WingnutTheme.textSecondary)),
                        Text(
                          p.transferName ?? p.transferProductId ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: WingnutTheme.violetDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Payment selector ─────────────────────────────────────────────────────────

class _PaymentSelector extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  static const _options = [
    ('not paid', 'Not Paid', Colors.red),
    ('cash', 'Cash', Colors.green),
    ('venmo', 'Venmo', Colors.blue),
    ('cashapp', 'CashApp', Colors.green),
    ('zelle', 'Zelle', Colors.purple),
    ('comped', 'Comped', Colors.orange),
    ('other', 'Other', Colors.grey),
  ];

  const _PaymentSelector({required this.current, required this.onChanged});

  Color _colorFor(String method) {
    for (final o in _options) {
      if (o.$1 == method) return o.$3;
    }
    return Colors.grey;
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Payment Method'),
        children: _options.map((o) {
          final selected = o.$1 == current;
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onChanged(o.$1);
            },
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: o.$3,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(o.$2,
                    style: TextStyle(
                        color: o.$3, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(current);
    final label = _options
        .firstWhere((o) => o.$1 == current, orElse: () => _options.first)
        .$2;

    return GestureDetector(
      onTap: () => _showDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: WingnutTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: WingnutTheme.border),
        ),
        child: Row(
          children: [
            Icon(Icons.payment_outlined, color: WingnutTheme.violet, size: 20),
            const SizedBox(width: 12),
            Text('Payment',
                style: const TextStyle(
                    fontSize: 12, color: WingnutTheme.textSecondary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                color: WingnutTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Success dialog ────────────────────────────────────────────────────────────

class _SuccessDialog extends StatefulWidget {
  final String orderId;
  final Order order;
  final VoidCallback onDone;

  const _SuccessDialog({
    required this.orderId,
    required this.order,
    required this.onDone,
  });

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> {
  bool _printing = false;
  String? _printError;
  int _printCount = 0;

  Future<void> _print() async {
    final printerService = context.read<PrinterService>();
    final connected = await printerService.isConnected();
    if (!connected) {
      setState(() => _printError = 'No printer connected. Go to Printer on the main menu.');
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 56),
          const SizedBox(height: 16),
          const Text('Order Submitted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            widget.orderId,
            style: const TextStyle(
                fontSize: 13,
                color: WingnutTheme.textSecondary,
                fontFamily: 'Courier'),
          ),
          const SizedBox(height: 24),

          // Print button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _printing ? null : _print,
              icon: _printing
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.print_outlined, size: 20),
              label: Text(_printCount == 0
                  ? 'Print Receipt'
                  : 'Print Again ($_printCount printed)'),
            ),
          ),

          if (_printError != null) ...[
            const SizedBox(height: 8),
            Text(_printError!,
                style: const TextStyle(
                    fontSize: 12, color: WingnutTheme.danger),
                textAlign: TextAlign.center),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onDone,
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  final bool large;
  final Color? color;

  const _TotalRow({
    required this.label,
    required this.amount,
    this.bold = false,
    this.large = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: large ? 18 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color ?? WingnutTheme.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          '${amount < 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
          style: style,
        ),
      ],
    );
  }
}