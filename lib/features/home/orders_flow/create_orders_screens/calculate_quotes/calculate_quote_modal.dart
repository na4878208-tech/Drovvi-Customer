import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/fetch_order/common_modal.dart';


// ✅ ERROR RESPONSE MODEL
// ✅ SIMPLIFIED ERROR RESPONSE MODEL
class QuoteErrorResponse {
  final bool success;
  final String message;
  final QuoteDebugInfo? debugInfo;

  QuoteErrorResponse({
    required this.success,
    required this.message,
    this.debugInfo,
  });

  factory QuoteErrorResponse.fromJson(Map<String, dynamic> json) {
    return QuoteErrorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error occurred',
      debugInfo: json['debug_info'] != null
          ? QuoteDebugInfo.fromJson(json['debug_info'])
          : null,
    );
  }

  @override
  String toString() {
    return message; // Sirf message return karo, kuch extra nahi
  }
}

// ✅ DEBUG INFO MODEL (Optional - agar aapko kuch extra chahiye to)
class QuoteDebugInfo {
  final double requiredCapacityKg;
  final double declaredValue;
  final Map<String, int> rejectionReasons;
  final List<AvailableCapacity> availableCapacities;

  QuoteDebugInfo({
    required this.requiredCapacityKg,
    required this.declaredValue,
    required this.rejectionReasons,
    required this.availableCapacities,
  });

  factory QuoteDebugInfo.fromJson(Map<String, dynamic> json) {
    return QuoteDebugInfo(
      requiredCapacityKg: (json['required_capacity_kg'] ?? 0).toDouble(),
      declaredValue: (json['declared_value'] ?? 0).toDouble(),
      rejectionReasons: Map<String, int>.from(json['rejection_reasons'] ?? {}),
      availableCapacities: (json['available_capacities'] as List? ?? [])
          .map((item) => AvailableCapacity.fromJson(item))
          .toList(),
    );
  }
}

class AvailableCapacity {
  final String registration;
  final String type;
  final double capacityKg;
  final double capacityTons;
  final String depot;

  AvailableCapacity({
    required this.registration,
    required this.type,
    required this.capacityKg,
    required this.capacityTons,
    required this.depot,
  });

  factory AvailableCapacity.fromJson(Map<String, dynamic> json) {
    return AvailableCapacity(
      registration: json['registration'] ?? '',
      type: json['type'] ?? '',
      capacityKg: (json['capacity_kg'] ?? 0).toDouble(),
      capacityTons: (json['capacity_tons'] ?? 0).toDouble(),
      depot: json['depot'] ?? '',
    );
  }
}
// ✅ STANDARD QUOTE REQUEST
class StandardQuoteRequest {
  final int productTypeId;
  final int packagingTypeId;
  final int? quantity;
  final double? weightPerItem;
  final bool isMultiStop;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupCity;
  final String pickupState;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String deliveryCity;
  final String deliveryState;
  final String serviceType;
  final List<String>? addOns;
  final double? declaredValue;
  final double? length;
  final double? width;
  final double? height;

  StandardQuoteRequest({
    required this.productTypeId,
    required this.packagingTypeId,
    this.quantity,
    this.weightPerItem,
    this.isMultiStop = false,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupCity,
    required this.pickupState,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.deliveryCity,
    required this.deliveryState,
    required this.serviceType,
    this.addOns,
    this.declaredValue,
    this.length,
    this.width,
    this.height,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'product_type_id': productTypeId,
      'packaging_type_id': packagingTypeId,
      'quantity': quantity,
      'weight_per_item': weightPerItem,
      'is_multi_stop': isMultiStop,
      'pickup_address': pickupAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_city': pickupCity,
      'pickup_state': pickupState,
      'delivery_address': deliveryAddress,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'delivery_city': deliveryCity,
      'delivery_state': deliveryState,
      'service_type': serviceType,
    };

    if (addOns != null && addOns!.isNotEmpty) {
      map['add_ons'] = addOns;
    }

    if (declaredValue != null && declaredValue! > 0) {
      map['declared_value'] = declaredValue;
    }

    if (length != null) map['length'] = length;
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;

    return map;
  }
}

// ✅ MULTI-STOP STOP REQUEST
class StopRequest {
  final int sequenceNumber;
  final String stopType;
  final String address;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String contactName;
  final String contactPhone;
  final int quantity;
  final double weight;
  final String? notes;

  StopRequest({
    required this.sequenceNumber,
    required this.stopType,
    required this.address,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.contactName,
    required this.contactPhone,
    required this.quantity,
    required this.weight,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'sequence_number': sequenceNumber,
      'stop_type': stopType,
      'address': address,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'quantity': quantity,
      'weight_kg': weight,
    };

    if (notes != null && notes!.isNotEmpty) {
      map['notes'] = notes;
    }

    return map;
  }
}

// ✅ MULTI-STOP QUOTE REQUEST
class MultiStopQuoteRequest {
  final int productTypeId;
  final int packagingTypeId;
  final bool isMultiStop;
  final List<StopRequest> stops;
  final String serviceType;
  final List<String>? addOns;
  final double? declaredValue;
  final int? quantity;
  final double? weightPerItem;
  final double? length; // ✅ ADD THIS
  final double? width; // ✅ ADD THIS
  final double? height; // ✅ ADD THIS

  MultiStopQuoteRequest({
    required this.productTypeId,
    required this.packagingTypeId,
    this.isMultiStop = true,
    required this.stops,
    required this.serviceType,
    this.addOns,
    this.declaredValue,
    this.quantity,
    this.weightPerItem,
    this.length, // ✅ ADD THIS
    this.width, // ✅ ADD THIS
    this.height, // ✅ ADD THIS
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'product_type_id': productTypeId,
      'packaging_type_id': packagingTypeId,
      'is_multi_stop': isMultiStop,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'service_type': serviceType,
    };

    if (addOns != null && addOns!.isNotEmpty) {
      map['add_ons'] = addOns;
    }

    if (declaredValue != null && declaredValue! > 0) {
      map['declared_value'] = declaredValue;
    }

    if (quantity != null && quantity! > 0) {
      map['quantity'] = quantity;
    }

    if (weightPerItem != null && weightPerItem! > 0) {
      map['weight_per_item'] = weightPerItem;
    }

    // ✅ ADD DIMENSIONS
    if (length != null) map['length'] = length;
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    

    return map;
  }
}

// ✅ QUOTE RESPONSE MODELS
class QuoteData {
  final ProductType? productType;
  final PackagingType? packagingType;
  final bool isMultiStop;
  final int? stopsCount;
  final int? quantity;
  final double baseWeightKg;
  final double stopsWeightKg;
  final double totalWeightKg;
  final double? distanceKm;
  final String serviceType;
  final List<CompatibleVehicle> compatibleVehicles;
  final List<NearbyDepot> nearbyDepots;

  QuoteData({
    this.productType,
    this.packagingType,
    required this.isMultiStop,
    this.stopsCount,
    this.quantity,
    required this.baseWeightKg,
    required this.stopsWeightKg,
    required this.totalWeightKg,
    this.distanceKm,
    required this.serviceType,
    required this.compatibleVehicles,
    required this.nearbyDepots,
  });

  // Get quotes list
  List<Quote> get quotes {
    return compatibleVehicles
        .map((vehicle) => Quote.fromCompatibleVehicle(vehicle))
        .toList();
  }

  factory QuoteData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return QuoteData(
      productType: data['product_type'] != null
          ? ProductType.fromJson(data['product_type'])
          : null,
      packagingType: data['packaging_type'] != null
          ? PackagingType.fromJson(data['packaging_type'])
          : null,
      isMultiStop: data['is_multi_stop'] ?? false,
      stopsCount: data['stops_count'],
      quantity: data['quantity'],
      baseWeightKg: (data['base_weight_kg'] ?? 0).toDouble(),
      stopsWeightKg: (data['stops_weight_kg'] ?? 0).toDouble(),
      totalWeightKg: (data['total_weight_kg'] ?? 0).toDouble(),
      distanceKm: data['distance_km'] != null
          ? data['distance_km'].toDouble()
          : null,
      serviceType: data['service_type'] ?? 'standard',
      compatibleVehicles: (data['compatible_vehicles'] as List)
          .map((vehicle) => CompatibleVehicle.fromJson(vehicle))
          .toList(),
      nearbyDepots: (data['nearby_depots'] as List)
          .map((depot) => NearbyDepot.fromJson(depot))
          .toList(),
    );
  }
}

class ProductType {
  final int id;
  final String name;
  final String category;

  ProductType({required this.id, required this.name, required this.category});

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id'],
      name: json['name'],
      category: json['category'],
    );
  }
}

class PackagingType {
  final int id;
  final String name;
  final double? fixedWeightKg;

  PackagingType({
    required this.id,
    required this.name,
    required this.fixedWeightKg,
  });

  factory PackagingType.fromJson(Map<String, dynamic> json) {
    return PackagingType(
      id: json['id'],
      name: json['name'],
      // fixedWeightKg: double.parse(json['fixed_weight_kg'].toString()),
      fixedWeightKg: json['fixed_weight_kg'] != null
          ? double.tryParse(json['fixed_weight_kg'].toString())
          : null,
    );
  }
}

class NearbyDepot {
  final int id;
  final String name;
  final String city;
  final double distanceKm;
  final int vehicleCount;

  NearbyDepot({
    required this.id,
    required this.name,
    required this.city,
    required this.distanceKm,
    required this.vehicleCount,
  });

  factory NearbyDepot.fromJson(Map<String, dynamic> json) {
    return NearbyDepot(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      vehicleCount: json['vehicle_count'] ?? 0,
    );
  }
}
