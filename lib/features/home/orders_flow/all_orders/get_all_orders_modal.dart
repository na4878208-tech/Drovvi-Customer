// lib/features/orders/models/get_all_orders_modal.dart

String parseString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is num) return value.toString();
  if (value is Map) return value['name']?.toString() ?? '';
  return value.toString();
}

class GetOrderResponse {
  final bool success;
  final String message;
  final AllOrderData data;
  final AlMeta meta;

  GetOrderResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory GetOrderResponse.fromJson(Map<String, dynamic> json) {
    return GetOrderResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AllOrderData.fromJsonList(json['data'] ?? []),
      meta: AlMeta.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class AllOrderData {
  final List<AlOrder> orders;

  AllOrderData({required this.orders});

  factory AllOrderData.fromJsonList(List list) {
    return AllOrderData(orders: list.map((e) => AlOrder.fromJson(e)).toList());
  }
  Map<String, dynamic> toJson() {
    return {'orders': orders.map((e) => e.toJson()).toList()};
  }
}

class OrderStop {
  final int sequence;
  final String type;
  final String address;
  final String city;
  final String contactName;
  final String contactPhone;
  final int quantity;
  final String weightKg;
  final String status;

  OrderStop({
    required this.sequence,
    required this.type,
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
      sequence: json['sequence_number'] ?? 0,
      type: json['stop_type'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      quantity: json['quantity'] ?? 0,
      weightKg: json['weight_kg'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class AlOrder {
  final int? id;
  final String? orderNumber;
  final String? trackingCode;
  final String? paymetstatus;
  final int stopsCount;
  final List<OrderStop> stops;
  final String status;
  final int? isMultiStop;
  final String? productType;
  final String? packagingType;
  final String? totalWeightKg;
  final String? pickupCity;
  final String? deliveryCity;
  final String? distanceKm;
  final String? finalCost;
  final int? matchingScore;
  final AlVehicle vehicle;
  final AlDriver driver;
  final String? createdAt;

  AlOrder({
    required this.id,
    required this.orderNumber,
    required this.trackingCode,
    required this.paymetstatus,
    required this.status,
    required this.isMultiStop,
    required this.stopsCount,
    required this.stops,
    this.productType,
    this.packagingType,
    this.totalWeightKg,
    required this.pickupCity,
    required this.deliveryCity,
    this.distanceKm,
    this.finalCost,
    this.matchingScore,
    required this.vehicle,
    required this.driver,
    required this.createdAt,
  });

  factory AlOrder.fromJson(Map<String, dynamic> json) {
    return AlOrder(
      id: json['id'],
      orderNumber: json['order_number'] ?? '',
      trackingCode: json['tracking_code'],
      status: json['status'] ?? '',
      paymetstatus: json['payment_status'] ?? '',
      isMultiStop: json['is_multi_stop'] ?? 0,
      stopsCount: json['stops_count'] ?? 0,

      stops: (json['stops'] as List? ?? [])
          .map((e) => OrderStop.fromJson(e))
          .toList(),

      productType: parseString(json['product_type']),
      packagingType: parseString(json['packaging_type']),
      totalWeightKg: json['total_weight_kg'],
      pickupCity: json['pickup_city'] ?? '',
      deliveryCity: json['delivery_city'] ?? '',
      distanceKm: parseString(json['distance_km']),
      finalCost: parseString(json['final_cost']),
      matchingScore: json['matching_score'],

      vehicle: AlVehicle.fromJson(json['vehicle'] ?? {}),
      driver: json['driver'] != null
          ? AlDriver.fromJson(json['driver'])
          : AlDriver.empty(),

      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'tracking_code': trackingCode,
      'status': status,
      'is_multi_stop': isMultiStop,
      'product_type': productType,
      'packaging_type': packagingType,
      'total_weight_kg': totalWeightKg,
      'pickup_city': pickupCity,
      'delivery_city': deliveryCity,
      'distance_km': distanceKm,
      'final_cost': finalCost,
      'matching_score': matchingScore,
      'vehicle': vehicle.toJson(),
      'driver': driver.toJson(),
      'created_at': createdAt,
    };
  }

  // Helper method for status color
  String get statusColor {
    switch (status) {
      case 'completed':
        return 'green';
      case 'assigned':
        return 'blue';
      case 'pending':
        return 'orange';
      case 'in_transit':
        return 'purple';
      default:
        return 'gray';
    }
  }

  // Helper method for status text
  String get statusText {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'assigned':
        return 'Assigned';
      case 'pending':
        return 'Pending';
      case 'in_transit':
        return 'In Transit';
      default:
        return status;
    }
  }

  // Check if order is active
  bool get isActive => status != 'completed';
}

class AlVehicle {
  final String registrationNumber;
  final String vehicleType;

  AlVehicle({required this.registrationNumber, required this.vehicleType});

  factory AlVehicle.fromJson(Map<String, dynamic> json) {
    return AlVehicle(
      registrationNumber: json['registration_number'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
    );
  }

  factory AlVehicle.empty() {
    return AlVehicle(registrationNumber: '', vehicleType: '');
  }
  Map<String, dynamic> toJson() {
    return {
      'registration_number': registrationNumber,
      'vehicle_type': vehicleType,
    };
  }
}

class AlDriver {
  final String name;
  final String phone;
  final String rating;

  AlDriver({required this.name, required this.phone, required this.rating});

  factory AlDriver.fromJson(Map<String, dynamic> json) {
    return AlDriver(
      name: json['user']?['name'] ?? '',
      phone: json['phone'] ?? '',
      rating: json['rating'] ?? '',
    );
  }

  factory AlDriver.empty() {
    return AlDriver(name: '', phone: '', rating: '');
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone, 'rating': rating};
  }
}

class AlMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const AlMeta({
    // <-- 'const' keyword add karein
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory AlMeta.fromJson(Map<String, dynamic> json) {
    return AlMeta(
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
    };
  }
}
