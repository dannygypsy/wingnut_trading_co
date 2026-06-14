import 'package:dio/dio.dart';
import '../models/order_model.dart';

class ApiService {
  late Dio _dio;

  ApiService(String baseUrl) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ));
  }

  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Look up full product detail by product ID (includes in_stock)
  Future<ProductDetail> lookupProduct(String productId) async {
    try {
      final response = await _dio.get(
        '/api/wtc/pos/inventory/lookup',
        queryParameters: {'pid': productId},
      );
      return ProductDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }

  /// Search inventory by WTC code or description (manual lookup)
  Future<List<ProductDetail>> searchInventory(String query) async {
    try {
      final response = await _dio.get(
        '/api/wtc/pos/inventory/search',
        queryParameters: {'q': query},
      );
      final List data = (response.data['results'] as List? ?? []);
      return data
          .map((j) => ProductDetail.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }

  /// Submit a completed order (server resolves product_ids to batch UUIDs)
  Future<String> submitOrder(Order order) async {
    try {
      final response =
      await _dio.post('/api/wtc/pos/orders', data: order.toJson());
      return (response.data['id'] ?? '').toString();
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _dio.patch('/api/wtc/pos/orders/$orderId/status',
          data: {'status': status});
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }

  /// Get order detail
  Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    try {
      final response = await _dio.get('/api/wtc/pos/orders/$orderId');
      return response.data['order'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }
  Future<List<Map<String, dynamic>>> getOrders({String? date, String? search}) async {
    try {
      final response = await _dio.get('/api/wtc/pos/orders', queryParameters: {
        if (date != null) 'date': date,
        if (search != null && search.isNotEmpty) 'search': search,
      });
      return List<Map<String, dynamic>>.from(
          response.data['orders'] as List? ?? []);
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }

  /// Check stock for a scanned QR value (e.g. WTC-XXXXXXXX or WTC-XXXXXXXX|2XL)
  Future<StockResult> checkStock(String pid) async {
    try {
      final detail = await _dio.get(
        '/api/wtc/pos/inventory/lookup',
        queryParameters: {'pid': pid},
      );
      final stock = await _dio.get(
        '/api/wtc/pos/inventory/stock',
        queryParameters: {'pid': pid},
      );
      final d = detail.data as Map<String, dynamic>;
      final s = stock.data as Map<String, dynamic>;
      return StockResult(
        name: d['name'] ?? '',
        size: d['size'] ?? '',
        category: d['category'] ?? '',
        remaining: int.tryParse(s['remaining'].toString()) ?? 0,
        inStock: s['in_stock'] == true || s['in_stock'] == 'true',
      );
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }

  String _friendlyError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Check your network.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Check the backend URL in Settings.';
    }
    return e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'An unexpected error occurred.';
  }
}

class StockResult {
  final String name;
  final String size;
  final String category;
  final int remaining;
  final bool inStock;

  StockResult({
    required this.name,
    required this.size,
    required this.category,
    required this.remaining,
    required this.inStock,
  });
}