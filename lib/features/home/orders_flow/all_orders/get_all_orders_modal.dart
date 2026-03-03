// lib/features/orders/models/get_all_orders_model.dart

String parseString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is num) return value.toString();
  return value.toString();
}

bool parseBoolFromInt(dynamic value) {
  if (value == 1) return true;
  if (value == 0) return false;
  return false;
}

class GetOrderResponse {
  final bool success;
  final List<AlOrder> data;
  final AlMeta pagination;

  GetOrderResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory GetOrderResponse.fromJson(Map<String, dynamic> json) {
    return GetOrderResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((e) => AlOrder.fromJson(e))
          .toList(),
      pagination: AlMeta.fromJson(json['pagination'] ?? {}),
    );
  }
}

class AlOrder {
  final int id;
  final String orderNumber;
  final String trackingCode;
  final String status;
  final String paymentStatus;
  final String paymentMethod;

  final bool isMultiStop;
  final int stopsCount;
  final List<OrderStop> stops;

  final ProductType productType;
  final PackagingType packagingType;

  final String totalWeightKg;
  final int itemQuantity;
  final String distanceKm;
  final String finalCost;
  final String estimatedCost;
  final String serviceFee;
  final String taxAmount;

  final String pickupAddress;
  final String pickupCity;
  final String deliveryAddress;
  final String deliveryCity;

  final AlVehicle vehicle;
  final AlDriver? driver;

  final String createdAt;

  AlOrder({
    required this.id,
    required this.orderNumber,
    required this.trackingCode,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.isMultiStop,
    required this.stopsCount,
    required this.stops,
    required this.productType,
    required this.packagingType,
    required this.totalWeightKg,
    required this.itemQuantity,
    required this.distanceKm,
    required this.finalCost,
    required this.estimatedCost,
    required this.serviceFee,
    required this.taxAmount,
    required this.pickupAddress,
    required this.pickupCity,
    required this.deliveryAddress,
    required this.deliveryCity,
    required this.vehicle,
    required this.driver,
    required this.createdAt,
  });

  factory AlOrder.fromJson(Map<String, dynamic> json) {
    return AlOrder(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      trackingCode: json['tracking_code'] ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',

      isMultiStop: parseBoolFromInt(json['is_multi_stop']),
      stopsCount: json['stops_count'] ?? 0,

      stops: (json['stops'] as List? ?? [])
          .map((e) => OrderStop.fromJson(e))
          .toList(),

      productType: ProductType.fromJson(json['product_type'] ?? {}),
      packagingType: PackagingType.fromJson(json['packaging_type'] ?? {}),

      totalWeightKg: parseString(json['total_weight_kg']),
      itemQuantity: json['item_quantity'] ?? 0,
      distanceKm: parseString(json['distance_km']),
      finalCost: parseString(json['final_cost']),
      estimatedCost: parseString(json['estimated_cost']),
      serviceFee: parseString(json['service_fee']),
      taxAmount: parseString(json['tax_amount']),

      pickupAddress: json['pickup_address'] ?? '',
      pickupCity: json['pickup_city'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryCity: json['delivery_city'] ?? '',

      vehicle: AlVehicle.fromJson(json['vehicle'] ?? {}),
      driver: json['driver'] != null ? AlDriver.fromJson(json['driver']) : null,

      createdAt: json['created_at'] ?? '',
    );
  }
}

class OrderStop {
  final int sequenceNumber;
  final String stopType;
  final String address;
  final String city;
  final String contactName;
  final String contactPhone;
  final int? quantity;
  final String? weightKg;
  final String status;

  OrderStop({
    required this.sequenceNumber,
    required this.stopType,
    required this.address,
    required this.city,
    required this.contactName,
    required this.contactPhone,
    required this.quantity,
    required this.weightKg,
    required this.status,
  });

  factory OrderStop.fromJson(Map<String, dynamic> json) {
    return OrderStop(
      sequenceNumber: json['sequence_number'] ?? 0,
      stopType: json['stop_type'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      quantity: json['quantity'],
      weightKg: parseString(json['weight_kg']),
      status: json['status'] ?? '',
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

class PackagingType {
  final int id;
  final String name;

  PackagingType({required this.id, required this.name});

  factory PackagingType.fromJson(Map<String, dynamic> json) {
    return PackagingType(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class AlVehicle {
  final int id;
  final String registrationNumber;
  final String make;
  final String model;
  final String type;

  AlVehicle({
    required this.id,
    required this.registrationNumber,
    required this.make,
    required this.model,
    required this.type,
  });

  factory AlVehicle.fromJson(Map<String, dynamic> json) {
    return AlVehicle(
      id: json['id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class AlDriver {
  final int id;
  final String name;
  final String phone;

  AlDriver({required this.id, required this.name, required this.phone});

  factory AlDriver.fromJson(Map<String, dynamic> json) {
    return AlDriver(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class AlMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const AlMeta({ 
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory AlMeta.fromJson(Map<String, dynamic> json) {
    return AlMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
