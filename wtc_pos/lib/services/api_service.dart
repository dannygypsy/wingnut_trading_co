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

  /// Fetch order list
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await _dio.get('/api/wtc/pos/orders');
      return List<Map<String, dynamic>>.from(
          response.data['orders'] as List? ?? []);
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