import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/printer_service.dart';
import '../services/receipt_helper.dart';
import '../models/order_model.dart';
import '../theme/wingnut_theme.dart';
import 'receipt_preview_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final ApiService api;

  const OrderDetailScreen(
      {super.key, required this.orderId, required this.api});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  bool _loading = true;
  String? _error;
  bool _updatingStatus = false;

  static const _statuses = [
    ('pending', 'Pending', Colors.orange),
    ('completed', 'Completed', Colors.teal),
    ('delivered', 'Delivered', Colors.green),
    ('canceled', 'Canceled', Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final order = await widget.api.getOrderDetail(widget.orderId);
      if (mounted) setState(() {
        _order = order;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _print() async {
    if (_order == null) return;
    final printerService = context.read<PrinterService>();
    final connected = await printerService.isConnected();
    if (!connected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'No printer connected. Go to Printer on the main menu.')),
        );
      }
      return;
    }
    final order = Order.fromDetailJson(_order!);
    await printerService.printOrder(order);
  }

  Future<void> _changeStatus(String newStatus) async {
    final current = _order?['status'] as String? ?? '';
    if (newStatus == current) return;

    // Confirm cancellation
    if (newStatus == 'canceled') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Cancel Order?'),
          content: const Text(
              'This will restore transfer inventory. This cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel Order',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _updatingStatus = true);
    try {
      await widget.api.updateOrderStatus(widget.orderId, newStatus);
      if (mounted) setState(() {
        _order!['status'] = newStatus;
        _updatingStatus = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _updatingStatus = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showStatusPicker() {
    final current = _order?['status'] as String? ?? 'pending';
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Change Status'),
        children: _statuses.map((s) {
          final selected = s.$1 == current;
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _changeStatus(s.$1);
            },
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: s.$3,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(s.$2,
                    style: TextStyle(
                        color: s.$3, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      appBar: AppBar(
        title: Text(_order == null
            ? ''
            : '#${(_order!['id'] as String).toUpperCase()}',
            style: const TextStyle(fontSize: 13, fontFamily: 'Courier')),
        actions: [
          if (_order != null)
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Print receipt',
              onPressed: _print,
            ),
        ],
      ),
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(color: WingnutTheme.violet))
          : _error != null
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                style: const TextStyle(
                    color: WingnutTheme.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _load, child: const Text('Retry')),
          ],
        ),
      )
          : _buildDetail(),
    );
  }

  Widget _buildDetail() {
    final o = _order!;
    final status = o['status'] as String? ?? 'pending';
    final payment = o['payment_method'] as String? ?? 'not paid';
    final total = (o['total'] as num? ?? 0).toDouble();
    final discount = (o['discount_percent'] as num? ?? 0).toDouble();
    final customer = o['customer'] as String? ?? '—';
    final salesperson = o['salesperson_name'] as String? ?? '—';
    final createdAt = o['created_at'] as String? ?? '';
    final items = o['items'] as List? ?? [];

    final subtotal = items.fold<double>(0, (sum, item) {
      final retail = (item['retail'] as num? ?? 0).toDouble();
      final qty = (item['quantity'] as num? ?? 1).toInt();
      final placements = item['placements'] as List? ?? [];
      final transferTotal = placements.fold<double>(
          0, (s, p) => s + (p['transfer_retail'] as num? ?? 0).toDouble());
      return sum + (retail + transferTotal) * qty;
    });

    String dateStr = '';
    try {
      dateStr = DateFormat('MMM d, yyyy h:mm a')
          .format(DateTime.parse(createdAt).toLocal());
    } catch (_) {}

    Color statusColor = Colors.orange;
    for (final s in _statuses) {
      if (s.$1 == status) { statusColor = s.$3; break; }
    }

    Color paymentColor;
    switch (payment.toLowerCase()) {
      case 'not paid': paymentColor = Colors.red; break;
      case 'comped':   paymentColor = Colors.orange; break;
      default:         paymentColor = Colors.green;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ──────────────────────────────────
          _Card(
            child: Column(
              children: [
                _InfoRow(label: 'Customer', value: customer),
                _InfoRow(label: 'Salesperson', value: salesperson),
                _InfoRow(label: 'Date', value: dateStr),
                _InfoRow(
                  label: 'Payment',
                  value: payment.toUpperCase(),
                  valueColor: paymentColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Status ───────────────────────────────────────
          _Card(
            child: Row(
              children: [
                const Text('Status',
                    style: TextStyle(
                        fontSize: 14, color: WingnutTheme.textSecondary)),
                const Spacer(),
                if (_updatingStatus)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: WingnutTheme.violet))
                else
                  GestureDetector(
                    onTap: _showStatusPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: statusColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: statusColor),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.expand_more,
                              color: statusColor, size: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Items ─────────────────────────────────────────
          const _SectionHeader('Items'),
          const SizedBox(height: 8),
          ...items.map((item) {
            final name = item['name'] as String? ?? '';
            final size = item['size'] as String? ?? '';
            final retail = (item['retail'] as num? ?? 0).toDouble();
            final qty = (item['quantity'] as num? ?? 1).toInt();
            final placements = item['placements'] as List? ?? [];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              if (size.isNotEmpty)
                                Text(sizeLabel(size),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: WingnutTheme.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${(retail * qty).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            if (qty > 1)
                              Text('$qty × \$${retail.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: WingnutTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    if (placements.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 6),
                      ...placements.map((p) {
                        final slot = p['slot'] as String? ?? '';
                        final transferName = p['transfer_name'] as String? ?? '';
                        final transferRetail = (p['transfer_retail'] as num? ?? 0).toDouble();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.circle,
                                  size: 6, color: WingnutTheme.violet),
                              const SizedBox(width: 8),
                              Text(slot,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: WingnutTheme.textSecondary)),
                              const Text(' → ',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: WingnutTheme.textSecondary)),
                              Expanded(
                                child: Text(transferName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: WingnutTheme.violetDark,
                                    )),
                              ),
                              if (transferRetail > 0)
                                Text(
                                  '\$${transferRetail.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: WingnutTheme.textSecondary),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 4),

          // ── Totals ────────────────────────────────────────
          _Card(
            child: Column(
              children: [
                if (discount > 0) ...[
                  _InfoRow(
                      label: 'Subtotal',
                      value: '\$${subtotal.toStringAsFixed(2)}'),
                  _InfoRow(
                      label: 'Discount (${discount.toStringAsFixed(0)}%)',
                      value: '-\$${(subtotal * discount / 100).toStringAsFixed(2)}',
                      valueColor: Colors.green),
                ],
                Row(
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WingnutTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WingnutTheme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: WingnutTheme.textSecondary)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? WingnutTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: WingnutTheme.textSecondary,
          letterSpacing: 0.8),
    );
  }
}