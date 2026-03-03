// lib/features/orders/repositories/order_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/api_url.dart';
import 'package:logisticscustomer/constants/dio.dart';
import 'package:logisticscustomer/constants/local_storage.dart';
import 'package:logisticscustomer/features/home/orders_flow/all_orders/get_all_orders_modal.dart';

class OrderRepository {
  final Dio dio;
  final Ref ref;

  OrderRepository({required this.dio, required this.ref});

  Future<GetOrderResponse> getAllOrders({
    int page = 1,
    int perPage = 10,
    String? status,
  }) async {
    try {
      final url = ApiUrls.getOrders;
      final token = await LocalStorage.getToken() ?? "";

      // Query parameters
      final Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': perPage,
      };

      if (status != null && status != 'All') {
        queryParams['status'] = status.toLowerCase();
      }

      print("Fetching orders with params: $queryParams");

      final response = await dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
        queryParameters: queryParams,
      );

      print("Orders API Response Status: ${response.statusCode}");
      print("Orders API Response Data: ${response.data}");

      if (response.statusCode == 200) {
        return GetOrderResponse.fromJson(response.data);
      } else {
        throw Exception("Failed to load orders: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      print("Response: ${e.response?.data}");
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      print("Error loading orders: $e");
      throw Exception("Failed to load orders");
    }
  }

  // Load more orders for pagination
  Future<GetOrderResponse> loadMoreOrders(int page) async {
    return getAllOrders(page: page);
  }

  // Get orders by status
  Future<GetOrderResponse> getOrdersByStatus(
    String status, {
    int page = 1,
    int perPage = 10,
  }) async {
    return getAllOrders(page: page, perPage: perPage, status: status);
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(dio: ref.watch(dioProvider), ref: ref);
});
