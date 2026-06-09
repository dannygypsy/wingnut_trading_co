import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/order_model.dart';
import '../theme/wingnut_theme.dart';
import '../services/api_service.dart';
import 'add_item_screen.dart';

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
  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.order.customerName ?? '';
    _discountController.text = widget.order.discountPct > 0
        ? widget.order.discountPct.toStringAsFixed(0)
        : '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _syncFields() {
    widget.order.customerName = _nameController.text.trim().isEmpty
        ? null
        : _nameController.text.trim();
    final pct = double.tryParse(_discountController.text.trim()) ?? 0;
    widget.order.discountPct = pct.clamp(0, 100);
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

  Future<void> _submit() async {
    _syncFields();
    if (widget.order.items.isEmpty) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      final orderId = await widget.api.submitOrder(widget.order);
      if (!mounted) return;
      _showSuccess(orderId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = e.toString();
        _submitting = false;
      });
    }
  }

  void _showSuccess(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: Colors.green, size: 56),
            const SizedBox(height: 16),
            const Text('Order Submitted!',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Order #$orderId',
              style: const TextStyle(
                  fontSize: 13,
                  color: WingnutTheme.textSecondary,
                  fontFamily: 'Courier'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Pop dialog + receipt screen back to home
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add item',
            onPressed: _addAnotherItem,
          ),
        ],
      ),
      body: Column(
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
                    onPriceChanged: (v) {
                      setState(() => item.price = v);
                    },
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
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name (optional)',
                    prefixIcon: Icon(Icons.person_outline,
                        color: WingnutTheme.violet),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 12),

                // ── Discount ───────────────────────────────
                TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Discount %',
                    prefixIcon: Icon(Icons.local_offer_outlined,
                        color: WingnutTheme.violet),
                    suffixText: '%',
                  ),
                  onChanged: (_) => setState(() {}),
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

                if (_submitError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WingnutTheme.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: WingnutTheme.danger.withOpacity(0.3)),
                    ),
                    child: Text(
                      _submitError!,
                      style: const TextStyle(
                          color: WingnutTheme.danger, fontSize: 13),
                    ),
                  ),
                ],

                const SizedBox(height: 100), // space for button
              ],
            ),
          ),

          // ── Submit bar ────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: const BoxDecoration(
              color: WingnutTheme.surface,
              border: Border(top: BorderSide(color: WingnutTheme.border)),
            ),
            child: ElevatedButton(
              onPressed:
              (order.items.isEmpty || _submitting) ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
                  : Text(
                'Submit Order — \$${total.toStringAsFixed(2)}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item card ────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final OrderItem item;
  final int index;
  final ValueChanged<double> onPriceChanged;
  final VoidCallback onRemove;

  const _ItemCard({
    required this.item,
    required this.index,
    required this.onPriceChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                        Text(item.size,
                            style: const TextStyle(
                                fontSize: 12,
                                color: WingnutTheme.textSecondary)),
                    ],
                  ),
                ),
                // Price field
                SizedBox(
                  width: 90,
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      prefixText: '\$',
                      hintText: '0.00',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      isDense: true,
                    ),
                    controller: TextEditingController(
                      text: item.price > 0
                          ? item.price.toStringAsFixed(2)
                          : '',
                    ),
                    onChanged: (v) =>
                        onPriceChanged(double.tryParse(v) ?? 0),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: WingnutTheme.textSecondary, size: 20),
                  onPressed: onRemove,
                  tooltip: 'Remove item',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            // Decal placements
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
                        p.decalName ?? p.decalId ?? '',
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
    );
  }
}

// ── Total row ────────────────────────────────────────────────────────────────

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