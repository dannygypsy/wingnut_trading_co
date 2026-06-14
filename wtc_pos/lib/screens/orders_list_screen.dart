import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../services/api_service.dart';
import '../theme/wingnut_theme.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatefulWidget {
  final ApiService api;
  const OrdersListScreen({super.key, required this.api});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  DateTime _date = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_date);
  String get _dateLabel => DateFormat('MMM d, yyyy').format(_date);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await widget.api.getOrders(
        date: _dateStr,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
      if (mounted) setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: WingnutTheme.teal),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _date) {
      setState(() => _date = picked);
      _load();
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed': return Colors.teal;
      case 'delivered': return Colors.green;
      case 'canceled':  return Colors.red;
      default:          return Colors.orange;
    }
  }

  Color _paymentColor(String? method) {
    switch (method?.toLowerCase()) {
      case 'not paid': return Colors.red;
      case 'comped':   return Colors.orange;
      default:         return Colors.green;
    }
  }

  double _totalForDay() =>
      _orders.fold(0, (sum, o) => sum + (o['total'] as num? ?? 0).toDouble());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          // ── Filter bar ────────────────────────────────────
          Container(
            color: WingnutTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Date row
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: WingnutTheme.teal, size: 18),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Text(
                        _dateLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: WingnutTheme.teal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Prev / next day
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: WingnutTheme.textSecondary,
                      onPressed: () {
                        setState(() => _date =
                            _date.subtract(const Duration(days: 1)));
                        _load();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: _date.day == DateTime.now().day &&
                          _date.month == DateTime.now().month
                          ? WingnutTheme.border
                          : WingnutTheme.textSecondary,
                      onPressed: _date.day == DateTime.now().day &&
                          _date.month == DateTime.now().month
                          ? null
                          : () {
                        setState(() => _date =
                            _date.add(const Duration(days: 1)));
                        _load();
                      },
                    ),
                    const Spacer(),
                    // Today shortcut
                    if (_dateStr != DateFormat('yyyy-MM-dd').format(DateTime.now()))
                      TextButton(
                        onPressed: () {
                          setState(() => _date = DateTime.now());
                          _load();
                        },
                        child: const Text('Today'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Search
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Search by customer or order ID',
                    prefixIcon: const Icon(Icons.search,
                        color: WingnutTheme.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _load();
                      },
                    )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),

          // ── Summary bar ───────────────────────────────────
          if (!_loading && _orders.isNotEmpty)
            Container(
              color: WingnutTheme.tealLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_orders.length} order${_orders.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: WingnutTheme.tealDark),
                  ),
                  const Spacer(),
                  Text(
                    'Total: \$${_totalForDay().toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: WingnutTheme.tealDark),
                  ),
                ],
              ),
            ),

          // ── List ──────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(
                    color: WingnutTheme.teal))
                : _error != null
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: WingnutTheme.danger, size: 40),
                  const SizedBox(height: 12),
                  Text(_error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: WingnutTheme.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: _load,
                      child: const Text('Retry')),
                ],
              ),
            )
                : _orders.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 48,
                      color: WingnutTheme.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'No orders on $_dateLabel',
                    style: const TextStyle(
                        color: WingnutTheme.textSecondary),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _load,
              color: WingnutTheme.teal,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (context, i) =>
                    _OrderTile(order: _orders[i], api: widget.api),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order tile ────────────────────────────────────────────────────────────────

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  final ApiService api;
  const _OrderTile({required this.order, required this.api});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String? ?? 'pending';
    final payment = order['payment_method'] as String? ?? 'not paid';
    final total = (order['total'] as num? ?? 0).toDouble();
    final itemCount = (order['item_count'] as num? ?? 0).toInt();
    final customer = order['customer'] as String? ?? '—';
    final id = (order['id'] as String? ?? '').substring(0, 8).toUpperCase();
    final createdAt = order['created_at'] as String? ?? '';
    String dateStr = '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      dateStr = DateFormat('MMM d, yyyy h:mm a').format(dt);
    } catch (_) {}

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed': statusColor = Colors.teal; break;
      case 'delivered': statusColor = Colors.green; break;
      case 'canceled':  statusColor = Colors.red; break;
      default:          statusColor = Colors.orange;
    }

    Color paymentColor;
    switch (payment.toLowerCase()) {
      case 'not paid': paymentColor = Colors.red; break;
      case 'comped':   paymentColor = Colors.orange; break;
      default:         paymentColor = Colors.green;
    }

    return Material(
      color: WingnutTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              orderId: order['id'] as String,
              api: api,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WingnutTheme.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer name — bold, first line
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: WingnutTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: WingnutTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Full date
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 12,
                        color: WingnutTheme.textSecondary)),
                const SizedBox(height: 4),
                // Order ID + item count
                Row(
                  children: [
                    Text(
                      '#${(order['id'] as String? ?? '').toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'Courier',
                        color: WingnutTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.shopping_bag_outlined,
                        size: 12, color: WingnutTheme.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '$itemCount item${itemCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 11, color: WingnutTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Status + payment badges
                Row(
                  children: [
                    _Badge(label: status.toUpperCase(), color: statusColor),
                    const SizedBox(width: 8),
                    _Badge(label: payment.toUpperCase(), color: paymentColor),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        size: 16, color: WingnutTheme.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}