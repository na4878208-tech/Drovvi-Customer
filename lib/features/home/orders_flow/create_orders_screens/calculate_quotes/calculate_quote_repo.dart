import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/api_url.dart';
import 'package:logisticscustomer/constants/local_storage.dart';
import 'calculate_quote_modal.dart';


class CalculateQuoteRepository {
  final Dio dio;
  final Ref ref;

  CalculateQuoteRepository({required this.dio, required this.ref});

  // ✅ STANDARD QUOTE CALCULATION
  Future<QuoteData> calculateStandardQuote({
    required StandardQuoteRequest request,
  }) async {
    final url = ApiUrls.postCalculationStandard;
    return await _calculateQuote(url, request.toJson(), "STANDARD");
  }

  // ✅ MULTI-STOP QUOTE CALCULATION
  Future<QuoteData> calculateMultiStopQuote({
    required MultiStopQuoteRequest request,
  }) async {
    final url = ApiUrls.postCalculationMultiStop;
    return await _calculateQuote(url, request.toJson(), "MULTI-STOP");
  }

  // ✅ COMMON CALCULATION METHOD - SIRF BACKEND MESSAGE
  Future<QuoteData> _calculateQuote(
    String url,
    Map<String, dynamic> requestData,
    String type,
  ) async {
    final token = await LocalStorage.getToken() ?? "";
    if (token.isEmpty) {
      throw Exception("Token missing. Please login again.");
    }

    try {
      print("📤 Calculating $type Quote...");
      print("Request URL: $url");
      print("Request Body: ${jsonEncode(requestData)}");

      final response = await dio.post(
        url,
        data: requestData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          // ✅ Sab status codes accept karo (200, 400, 422 sab)
          validateStatus: (status) {
            return true; // Sab status codes accept karo
          },
        ),
      );

      print("📌 $type API Status: ${response.statusCode}");
      print("📌 $type API Response: ${jsonEncode(response.data)}");

      // Parse response data
      final Map<String, dynamic> responseData;
      if (response.data is Map) {
        responseData = (response.data as Map).cast<String, dynamic>();
      } else {
        throw Exception("Invalid response format from server");
      }

      // ✅ Agar success true hai to data return karo
      if (responseData["success"] == true) {
        return QuoteData.fromJson(responseData);
      } 
      
      // ✅ Agar success false hai to message throw karo
      else {
        final message = responseData["message"] ?? "Unknown error occurred";
        throw Exception(message); // 👈 SIRF BACKEND MESSAGE
      }
      
    } on DioException catch (e) {
      print("⛔ $type Dio Error: ${e.type}");
      print("Message: ${e.message}");
      
      // ✅ Agar response mein koi message hai to wo do
      if (e.response?.data != null) {
        try {
          final data = e.response!.data as Map<String, dynamic>;
          if (data["message"] != null) {
            throw Exception(data["message"]); // 👈 SIRF BACKEND MESSAGE
          }
        } catch (_) {
          // Ignore parsing errors
        }
      }

      // Handle connection errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Connection timeout. Please check your internet.");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection. Please check your network.");
      }

      throw Exception("Failed to connect to server. Please try again.");
    } catch (e) {
      print("⛔ $type General Error: $e");
      rethrow;
    }
  }
}