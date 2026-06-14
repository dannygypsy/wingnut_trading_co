import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../theme/wingnut_theme.dart';

class SearchResultsScreen extends StatelessWidget {
  final List<ProductDetail> results;

  const SearchResultsScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${results.length} Result${results.length == 1 ? '' : 's'}'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final item = results[i];
          return Material(
            color: WingnutTheme.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(item),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: WingnutTheme.tealLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.checkroom_outlined,
                          color: WingnutTheme.teal, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: WingnutTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (item.size != null) ...[
                                _Chip(item.size!),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child:
                                Text(
                                  item.productId,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: WingnutTheme.textSecondary,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                              )
                            ],
                          ),
                          // Price
                          if (item.retail != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Price: \$${item.retail!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: WingnutTheme.textSecondary),
                            ),
                          ],
                          if (item.placementSlots.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Placements: ${item.placementSlots.join(', ')}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: WingnutTheme.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: WingnutTheme.textSecondary),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: WingnutTheme.tealLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: WingnutTheme.tealDark,
        ),
      ),
    );
  }
}