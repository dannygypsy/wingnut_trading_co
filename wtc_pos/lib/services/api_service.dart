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

  /// Search inventory by WTC code or description
  Future<List<InventorySearchResult>> searchInventory(String query) async {
    try {
      final response = await _dio.get(
        '/api/inventory/search',
        queryParameters: {'q': query},
      );
      final List data = response.data as List;
      return data
          .map((j) => InventorySearchResult.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }

  /// Decrement decal stock when scanned onto a placement
  Future<void> decrementDecal(String decalId) async {
    try {
      await _dio.patch('/api/inventory/$decalId/decrement');
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }

  /// Submit a completed order
  Future<String> submitOrder(Order order) async {
    try {
      final response = await _dio.post('/api/orders', data: order.toJson());
      return (response.data['id'] ?? '').toString();
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }

  /// Fetch order list
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await _dio.get('/api/orders');
      return List<Map<String, dynamic>>.from(response.data as List);
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
    return e.response?.data?['error'] ?? 'An unexpected error occurred.';
  }
}