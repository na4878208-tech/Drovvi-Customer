import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/api_url.dart';
import 'package:logisticscustomer/constants/local_storage.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/fetch_order/place_order_modal.dart';

import '../calculate_quotes/calculate_quote_controller.dart';
import '../order_cache_provider.dart' show orderCacheProvider;

class PlaceOrderRepository {
  final Dio dio;
  final Ref ref;

  PlaceOrderRepository({required this.dio, required this.ref});

Future<Order> getOrderById(int orderId) async {
  try {
    // dio ko use karo apiClient ki jagah
    final response = await dio.get("${ApiUrls.orderDetails}/$orderId");

    if (response.data != null && response.data["data"] != null) {
      return Order.fromJson(response.data["data"]);
    } else {
      throw Exception("Order data not found");
    }
  } catch (e) {
    throw Exception("Failed to fetch order: $e");
  }
}

  // ✅ PLACE STANDARD ORDER
  Future<OrderResponse> placeStandardOrder({
    required StandardOrderRequestBody request,
  }) async {
    final url = ApiUrls.postPlaceOrder;

    final token = await LocalStorage.getToken() ?? "";
    if (token.isEmpty) {
      throw Exception("Token missing. Please login again.");
    }

    try {
      print("📤 Placing Standard Order...");
      
      // ✅ FIRST CHECK IF WE CAN CONVERT TO JSON
      try {
        print("Testing JSON conversion...");
        final requestJson = request.toJson();
        print("Request Body: ${jsonEncode(requestJson)}");
      } catch (jsonError) {
        print("❌ JSON Conversion Error: $jsonError");
        throw Exception("Failed to prepare request data: $jsonError");
      }

      final response = await dio.post(
        url,
        data: request.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          receiveTimeout: Duration(seconds: 30),
          sendTimeout: Duration(seconds: 30),
        ),
      );

      print("📌 API Status: ${response.statusCode}");

      final Map<String, dynamic> responseData;
      if (response.data is Map) {
        responseData = (response.data as Map).cast<String, dynamic>();
      } else {
        throw Exception("Invalid response format from server");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData["success"] == true) {
          return OrderResponse.fromJson(responseData);
        } else {
          throw Exception("Order placement failed: ${responseData["message"]}");
        }
      } else if (response.statusCode == 400) {
        final message = responseData["message"] ?? "Bad request";
        if (message.contains("insufficient", caseSensitive: false)) {
          final required = responseData["required"] ?? 0;
          final available = responseData["available"] ?? 0;
          throw Exception(
            "Insufficient wallet balance. Required: R$required, Available: R$available",
          );
        }
        throw Exception(message);
      } else if (response.statusCode == 422) {
        final errors = responseData["errors"] ?? {};
        String errorMsg = "Validation failed: ";
        if (errors is Map) {
          errors.forEach((key, value) {
            if (value is List) {
              errorMsg += "$key: ${value.join(", ")}. ";
            } else {
              errorMsg += "$key: $value. ";
            }
          });
        }
        throw Exception(errorMsg.trim());
      } else {
        throw Exception("Failed to place order: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("⛔ Dio Error: ${e.type}");
      print("Message: ${e.message}");
      print("Response: ${e.response?.data}");

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection timeout. Please check your internet.");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Server response timeout. Please try again.");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection. Please check your network.");
      }

      rethrow;
    } catch (e) {
      print("⛔ General Error: $e");
      rethrow;
    }
  }

  // ✅ PLACE MULTI-STOP ORDER
  Future<OrderResponse> placeMultiStopOrder({
    required MultiStopOrderRequestBody request,
  }) async {
    final url = ApiUrls.postPlaceOrder;

    final token = await LocalStorage.getToken() ?? "";
    if (token.isEmpty) {
      throw Exception("Token missing. Please login again.");
    }

    try {
      print("📤 Placing Multi-Stop Order...");
      
      // ✅ FIRST CHECK IF WE CAN CONVERT TO JSON
      try {
        print("Testing JSON conversion...");
        final requestJson = request.toJson();
        print("Request Body: ${jsonEncode(requestJson)}");
      } catch (jsonError) {
        print("❌ JSON Conversion Error: $jsonError");
        throw Exception("Failed to prepare request data: $jsonError");
      }

      final response = await dio.post(
        url,
        data: request.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          receiveTimeout: Duration(seconds: 30),
          sendTimeout: Duration(seconds: 30),
        ),
      );

      print("📌 API Status: ${response.statusCode}");

      final Map<String, dynamic> responseData;
      if (response.data is Map) {
        responseData = (response.data as Map).cast<String, dynamic>();
      } else {
        throw Exception("Invalid response format from server");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData["success"] == true) {
          return OrderResponse.fromJson(responseData);
        } else {
          throw Exception("Order placement failed: ${responseData["message"]}");
        }
      } else if (response.statusCode == 400) {
        final message = responseData["message"] ?? "Bad request";
        if (message.contains("insufficient", caseSensitive: false)) {
          final required = responseData["required"] ?? 0;
          final available = responseData["available"] ?? 0;
          throw Exception(
            "Insufficient wallet balance. Required: R$required, Available: R$available",
          );
        }
        throw Exception(message);
      } else if (response.statusCode == 422) {
        final errors = responseData["errors"] ?? {};
        String errorMsg = "Validation failed: ";
        if (errors is Map) {
          errors.forEach((key, value) {
            if (value is List) {
              errorMsg += "$key: ${value.join(", ")}. ";
            } else {
              errorMsg += "$key: $value. ";
            }
          });
        }
        throw Exception(errorMsg.trim());
      } else {
        throw Exception("Failed to place order: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("⛔ Dio Error: ${e.type}");
      print("Message: ${e.message}");
      print("Response: ${e.response?.data}");

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection timeout. Please check your internet.");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Server response timeout. Please try again.");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection. Please check your network.");
      }

      rethrow;
    } catch (e) {
      print("⛔ General Error: $e");
      rethrow;
    }
  }

  // ✅ PREPARE STANDARD ORDER DATA
  Future<StandardOrderRequestBody> prepareStandardOrderData() async {
    final cache = ref.read(orderCacheProvider);
    final bestQuote = ref.read(bestQuoteProvider);

    if (bestQuote == null) {
      throw Exception("Please calculate and select a quote first");
    }

    // Get product and packaging IDs
    final productTypeId = int.tryParse(cache["selected_product_type_id"]?.toString() ?? "0") ?? 0;
    final packagingTypeId = int.tryParse(cache["selected_packaging_type_id"]?.toString() ?? "0") ?? 0;

    if (productTypeId == 0 || packagingTypeId == 0) {
      throw Exception("Product or packaging type not selected");
    }

    // Get quantity and weight
    final quantity = int.tryParse(cache["quantity"]?.toString() ?? "1") ?? 1;
    final weightStr = cache["total_weight"]?.toString() ?? "0";
    final weightPerItem = double.tryParse(weightStr) ?? 0.0;

    // Get coordinates
    final pickupLat = double.tryParse(cache["pickup_latitude"]?.toString() ?? "-26.2041") ?? -26.2041;
    final pickupLng = double.tryParse(cache["pickup_longitude"]?.toString() ?? "28.0473") ?? 28.0473;
    final deliveryLat = double.tryParse(cache["delivery_latitude"]?.toString() ?? "-26.1952") ?? -26.1952;
    final deliveryLng = double.tryParse(cache["delivery_longitude"]?.toString() ?? "28.0346") ?? 28.0346;

    // Get addresses
    final pickupAddress = cache["pickup_address1"]?.toString() ?? "";
    final pickupCity = cache["pickup_city"]?.toString() ?? "";
    final pickupState = cache["pickup_state"]?.toString() ?? "";
    final pickupPostal = cache["pickup_postal"]?.toString();
    final pickupContactName = cache["pickup_name"]?.toString() ?? "";
    final pickupContactPhone = cache["pickup_phone"]?.toString() ?? "";

    final deliveryAddress = cache["delivery_address1"]?.toString() ?? "";
    final deliveryCity = cache["delivery_city"]?.toString() ?? "";
    final deliveryState = cache["delivery_state"]?.toString() ?? "";
    final deliveryPostal = cache["delivery_postal"]?.toString();
    final deliveryContactName = cache["delivery_name"]?.toString() ?? "";
    final deliveryContactPhone = cache["delivery_phone"]?.toString() ?? "";

    // Get service type and add-ons
    final serviceType = cache["service_type_id"]?.toString() ?? "standard";
    final priority = cache["priority"]?.toString() ?? "medium";
    // final paymentMethod = cache["payment_method"]?.toString() ?? "wallet";
      final paymentMethod = cache['payment_method'] ?? 'wallet';
    
    final addOns = <String>[];
    final selectedAddons = cache["selected_addons"];
    if (selectedAddons is List) {
      for (var addon in selectedAddons) {
        if (addon is String) {
          addOns.add(addon);
        }
      }
    }

    final specialInstructions = cache["special_instructions"]?.toString();
    final declaredValue = double.tryParse(cache["declared_value"]?.toString() ?? "0") ?? 0.0;

    // Get dimensions
    final length = double.tryParse(cache["package_length"]?.toString() ?? "");
    final width = double.tryParse(cache["package_width"]?.toString() ?? "");
    final height = double.tryParse(cache["package_height"]?.toString() ?? "");

    // Prepare selected quote
    final selectedQuote = SelectedQuote(
      vehicleId: bestQuote.vehicleId,
      vehicleTypeId: bestQuote.vehicleTypeId,
      vehicleTypeName: bestQuote.vehicleType,
      registrationNumber: bestQuote.registrationNumber,
      make: bestQuote.make,
      model: bestQuote.model,
      capacityKg: bestQuote.capacityWeightKg,
      capacityVolumeM3: bestQuote.capacityWeightKg,
      totalScore: bestQuote.totalScore,
      matchingScore: bestQuote.totalScore,
      depotScore: bestQuote.depotScore.toInt() ,
      distanceScore: bestQuote.distanceScore.toInt() ,
      priceScore: bestQuote.priceScore.toInt(),
      suitabilityScore: bestQuote.suitabilityScore.toInt(),
      driverScore: bestQuote.driverScore.toInt(),
      depotId: bestQuote.depotId ,
      depotName: bestQuote.depotName ,
      depotCity: bestQuote.depotCity ,
      depotDistanceKm: bestQuote.depotDistanceKm ,
      isExclusive: bestQuote.isExclusive ,
      utilizationPercent: bestQuote.utilizationPercent,
      pricing: bestQuote.pricing,
      company: bestQuote.company,
      driver: bestQuote.driver,
    );

    // ✅ CREATE THE REQUEST OBJECT
    final request = StandardOrderRequestBody(
      productTypeId: productTypeId,
      packagingTypeId: packagingTypeId,
      quantity: quantity,
      weightPerItem: weightPerItem,
      selectedQuote: selectedQuote,
      pickupAddress: pickupAddress,
      pickupLatitude: pickupLat,
      pickupLongitude: pickupLng,
      pickupCity: pickupCity,
      pickupState: pickupState,
      pickupPostalCode: pickupPostal,
      pickupContactName: pickupContactName,
      pickupContactPhone: pickupContactPhone,
      deliveryAddress: deliveryAddress,
      deliveryLatitude: deliveryLat,
      deliveryLongitude: deliveryLng,
      deliveryCity: deliveryCity,
      deliveryState: deliveryState,
      deliveryPostalCode: deliveryPostal,
      deliveryContactName: deliveryContactName,
      deliveryContactPhone: deliveryContactPhone,
      serviceType: serviceType,
      priority: priority,
      paymentMethod: paymentMethod,
      addOns: addOns,
      specialInstructions: specialInstructions,
      declaredValue: declaredValue,
      length: length,
      width: width,
      height: height,
    );

    // ✅ DEBUG PRINT STATEMENTS
    print("📋 Preparing Standard Order Data...");
    print("Selected Quote JSON: ${jsonEncode(selectedQuote.toJson())}");
    print("Total Request Body: ${jsonEncode(request.toJson())}");

    return request;
  }



  // ✅ PREPARE MULTI-STOP ORDER DATA
// ✅ PREPARE MULTI-STOP ORDER DATA - COMPLETELY FIXED
Future<MultiStopOrderRequestBody> prepareMultiStopOrderData() async {
  final cache = ref.read(orderCacheProvider);
  final bestQuote = ref.read(bestQuoteProvider);

  if (bestQuote == null) {
    throw Exception("Please calculate and select a quote first");
  }

  // Get product and packaging IDs
  final productTypeId = int.tryParse(cache["selected_product_type_id"]?.toString() ?? "0") ?? 0;
  final packagingTypeId = int.tryParse(cache["selected_packaging_type_id"]?.toString() ?? "0") ?? 0;

  if (productTypeId == 0 || packagingTypeId == 0) {
    throw Exception("Product or packaging type not selected");
  }
  
  final quantityStr = cache["quantity"]?.toString() ?? "1";
  final weightStr = cache["total_weight"]?.toString() ?? "0";
  
  int totalQuantity = int.tryParse(quantityStr) ?? 1;
  double totalWeight = double.tryParse(weightStr) ?? 0.0;

  print("📊 MULTI-STOP VALUES FROM CACHE:");
  print("cache['quantity'] = $quantityStr -> totalQuantity = $totalQuantity");
  print("cache['total_weight'] = $weightStr -> totalWeight = $totalWeight");

  // ✅ FALLBACK: Agar cache mein nahi hai, to calculate from stops
  if (totalQuantity == 0 || totalWeight == 0) {
    print("⚠️  Cache values are 0, calculating from stops...");
    
    final stopsCount = int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;
    totalQuantity = 0;
    totalWeight = 0.0;
    
    for (int i = 1; i <= stopsCount; i++) {
      final qty = int.tryParse(cache["stop_${i}_quantity"]?.toString() ?? "1") ?? 1;
      final weight = double.tryParse(cache["stop_${i}_weight"]?.toString() ?? "50") ?? 50.0;
      
      totalQuantity += qty;
      totalWeight += weight;
    }
    
    print("Calculated from stops: Qty=$totalQuantity, Weight=$totalWeight");
  }

  // ✅ ENSURE MINIMUM VALUES
  if (totalQuantity < 1) {
    print("⚠️  Quantity $totalQuantity < 1, setting to 1");
    totalQuantity = 1;
  }
  
  if (totalWeight < 0.01) {
    print("⚠️  Weight $totalWeight < 0.01, setting to 0.01");
    totalWeight = 0.01;
  }

  print("✅ FINAL VALUES: Qty=$totalQuantity, Weight=$totalWeight");

  // Prepare stops (ONLY ADDRESS/CONTACT INFO)
  final stopsCount = int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;
  final stops = <OrderStop>[];
  
  for (int i = 1; i <= stopsCount; i++) {
    final stopTypeStr = cache["stop_${i}_type"]?.toString() ?? "";
    
    String stopType;
    if (stopTypeStr.contains("pickup")) {
      stopType = "pickup";
    } else if (stopTypeStr.contains("dropOff")) {
      stopType = "drop_off";
    } else {
      stopType = "waypoint";
    }

    // Get coordinates
    final lat = double.tryParse(cache["stop_${i}_latitude"]?.toString() ?? "-26.2041") ?? -26.2041;
    final lng = double.tryParse(cache["stop_${i}_longitude"]?.toString() ?? "28.0473") ?? 28.0473;

    final stop = OrderStop(
      sequenceNumber: i,
      stopType: stopType,
      address: cache["stop_${i}_address"]?.toString() ?? "",
      city: cache["stop_${i}_city"]?.toString() ?? "",
      state: cache["stop_${i}_state"]?.toString() ?? "",
      latitude: lat,
      longitude: lng,
      contactName: cache["stop_${i}_contact_name"]?.toString() ?? "",
      contactPhone: cache["stop_${i}_contact_phone"]?.toString() ?? "",
      
      // ✅ IMPORTANT: Set quantity and weight to values from stops
      quantity: int.tryParse(cache["stop_${i}_quantity"]?.toString() ?? "1") ?? 1,
      weight: double.tryParse(cache["stop_${i}_weight"]?.toString() ?? "50") ?? 50.0,
      
      notes: cache["stop_${i}_notes"]?.toString(),
    );

    stops.add(stop);
  }

  // ✅ Calculate weight per item (SAME AS STANDARD ORDER)
  final weightPerItem = totalQuantity > 0 ? totalWeight / totalQuantity : totalWeight;

  // Get service type and add-ons
  final serviceType = cache["service_type_id"]?.toString() ?? "standard";
  final priority = cache["priority"]?.toString() ?? "medium";
  final paymentMethod = cache["payment_method"]?.toString() ?? "wallet";
  
  final addOns = <String>[];
  final selectedAddons = cache["selected_addons"];
  if (selectedAddons is List) {
    for (var addon in selectedAddons) {
      if (addon is String) {
        addOns.add(addon);
      }
    }
  }

  final specialInstructions = cache["special_instructions"]?.toString();
  final declaredValue = double.tryParse(cache["declared_value"]?.toString() ?? "0") ?? 0.0;

  // Prepare selected quote
  final selectedQuote = SelectedQuote(
    vehicleId: bestQuote.vehicleId,
    vehicleTypeId: bestQuote.vehicleTypeId,
    vehicleTypeName: bestQuote.vehicleType,
    registrationNumber: bestQuote.registrationNumber,
    make: bestQuote.make,
    model: bestQuote.model,
    capacityKg: bestQuote.capacityWeightKg,
    capacityVolumeM3: bestQuote.capacityWeightKg,
    totalScore: bestQuote.totalScore,
    matchingScore: bestQuote.matchingScore,
    depotScore: bestQuote.depotScore ,
    distanceScore: bestQuote.distanceScore ,
    priceScore: bestQuote.priceScore ,
    suitabilityScore: bestQuote.suitabilityScore ,
    driverScore: bestQuote.driverScore ,
    depotId: bestQuote.depotId ,
    depotName: bestQuote.depotName,
    depotCity: bestQuote.depotCity ,
    depotDistanceKm: bestQuote.depotDistanceKm ,
    isExclusive: bestQuote.isExclusive ,
    utilizationPercent: bestQuote.utilizationPercent ,
    pricing: bestQuote.pricing,
    company: bestQuote.company,
    driver: bestQuote.driver,
  );

  // ✅ CREATE THE REQUEST OBJECT
  final request = MultiStopOrderRequestBody(
    productTypeId: productTypeId,
    packagingTypeId: packagingTypeId,
    quantity: totalQuantity,
    weightPerItem: weightPerItem,
    isMultiStop: true,
    selectedQuote: selectedQuote,
    stops: stops,
    serviceType: serviceType,
    priority: priority,
    paymentMethod: paymentMethod,
    addOns: addOns,
    specialInstructions: specialInstructions,
    declaredValue: declaredValue,
  );

  // ✅ DEBUG PRINT
  print("📋 MULTI-STOP ORDER DATA PREPARED:");
  print("Quantity: $totalQuantity");
  print("Weight Per Item: $weightPerItem");
  print("Stops Count: ${stops.length}");

  return request;
}


}