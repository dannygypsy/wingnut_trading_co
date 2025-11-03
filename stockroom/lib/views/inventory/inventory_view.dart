// lib/views/inventory_view.dart
import 'package:flutter/material.dart';
import 'package:stockroom/model/inventory_item.dart';
import 'package:stockroom/service/database.dart';

class InventoryView extends StatefulWidget {
  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  List<InventoryItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Database.instance.query(
        'SELECT * FROM wtc_inventory ORDER BY name',
      );

      setState(() {
        _items = results.map((row) => InventoryItem.fromMap(row)).toList();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading inventory: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = 'Failed to load inventory';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading inventory: $_error'),
            ElevatedButton(
              onPressed: _loadInventory,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text('No inventory items found'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inventory',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add new item
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Cost')),
                    DataColumn(label: Text('Retail')),
                    DataColumn(label: Text('Margin')),
                    DataColumn(label: Text('Remaining')),
                    DataColumn(label: Text('Total Purchased')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _items.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item.name)),
                        DataCell(Text(item.type)),
                        DataCell(Text(item.category)),
                        DataCell(Text('\$${item.cost.toStringAsFixed(2)}')),
                        DataCell(Text('\$${item.retail.toStringAsFixed(2)}')),
                        DataCell(Text('\$${item.profitMargin.toStringAsFixed(2)}')),
                        DataCell(
                          Text(
                            '${item.remaining}',
                            style: TextStyle(
                              color: item.remaining < 5 ? Colors.red : Colors.black,
                              fontWeight: item.remaining < 5 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        DataCell(Text('${item.numPurchased}')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  // TODO: Edit item
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () {
                                  // TODO: Delete item
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}