bool parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

class OrderDetailsModel {
  final bool success;
  final String message;
  final OrderDetails order;

  OrderDetailsModel({
    required this.success,
    required this.message,
    required this.order,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      success: parseBool(json["success"]),
      message: json["message"] ?? "",
      order: OrderDetails.fromJson(json["data"] ?? {}),
    );
  }
}

class OrderStop {
  final int sequence;
  final String type; // pickup, waypoint, drop_off
  final String address;
  final String city;
  final String state;
  final String contactName;
  final String contactPhone;
  final int? quantity;
  final String? weightKg;
  final String status;
  final String? arrivalTime;
  final String? departureTime;
  final String? notes;

  OrderStop({
    required this.sequence,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.contactName,
    required this.contactPhone,
    this.quantity,
    this.weightKg,
    required this.status,
    this.arrivalTime,
    this.departureTime,
    this.notes,
  });

  factory OrderStop.fromJson(Map<String, dynamic> json) {
    return OrderStop(
      sequence: json["sequence_number"] ?? 0,
      type: json["stop_type"] ?? "",
      address: json["address"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      contactName: json["contact_name"] ?? "",
      contactPhone: json["contact_phone"] ?? "",
      quantity: json["quantity"],
      weightKg: json["weight_kg"]?.toString(),
      status: json["status"] ?? "",
      arrivalTime: json["arrival_time"],
      departureTime: json["departure_time"],
      notes: json["notes"],
    );
  }
}

class OrderDetails {
  final int id;
  final String orderNumber;
  final String trackingCode;
  final String status;
  final String paymentStatus;
  final ProductType productType;
  final PackagingType packagingType;
  final Vehicle vehicle;
  final Driver driver;
  final Pricing pricing;
  final List<OrderItem> items;
  final List<String> addOns;
  final String? specialInstructions;
  final Depot depot;
  final Pickup pickup;
  final Delivery delivery;
  final String createdAt;
  final String updatedAt;
  final bool isMultiStop;
  final List<OrderStop> stops;

  OrderDetails({
    required this.id,
    required this.orderNumber,
    required this.trackingCode,
    required this.status,
    required this.paymentStatus,
    required this.productType,
    required this.packagingType,
    required this.vehicle,
    required this.driver,
    required this.pricing,
    required this.items,
    required this.addOns,
    required this.specialInstructions,
    required this.depot,
    required this.pickup,
    required this.delivery,
    required this.createdAt,
    required this.updatedAt,
    required this.isMultiStop,
    required this.stops,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json["id"] ?? 0,
      orderNumber: json["order_number"] ?? "",
      trackingCode: json["tracking_code"] ?? "",
      status: json["status"] ?? "",
      paymentStatus: json["payment_status"] ?? "",
      productType: ProductType.fromJson(json["product_type"]),
      packagingType: PackagingType.fromJson(json["packaging_type"]),
      vehicle: Vehicle.fromJson(json["vehicle"] ?? {}),
      driver: Driver.fromJson(json["driver"]),
      pricing: Pricing.fromJson(json),
      items: (json["items"] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),

      isMultiStop: parseBool(json["is_multi_stop"]),

      stops: (json["stops"] as List? ?? [])
          .map((e) => OrderStop.fromJson(e))
          .toList(),

      addOns: const [],
      specialInstructions: json["special_instructions"],
      depot: Depot.fromJson(json["depot"] ?? {}),
      pickup: Pickup.fromJson(json),
      delivery: Delivery.fromJson(json),
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }
}

/// Sub Models

class ProductType {
  final String name;
  final String category;
  ProductType({required this.name, required this.category});
  factory ProductType.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return ProductType(name: "", category: "");
    }
    return ProductType(
      name: json["name"] ?? "",
      category: json["category"] ?? "",
    );
  }
}

class PackagingType {
  final String name;
  PackagingType({required this.name});
  factory PackagingType.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return PackagingType(name: "");
    }
    return PackagingType(name: json["name"] ?? "");
  }
}

class Vehicle {
  final String vehicleType;
  final String registration;
  final String make;
  final String model;
  final String? currentLatitude;
  final String? currentLongitude;

  Vehicle({
    required this.vehicleType,
    required this.registration,
    required this.make,
    required this.model,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    vehicleType: json["vehicle_type"] ?? "",
    registration: json["registration_number"] ?? "",
    make: json["make"] ?? "",
    model: json["model"] ?? "",
    currentLatitude: json["current_latitude"]?.toString(),
    currentLongitude: json["current_longitude"]?.toString(),
  );
}

class Driver {
  final String name;
  final String phone;
  final String rating;

  Driver({
    required this.name,
    required this.phone,
    required this.rating,
  });

  factory Driver.fromJson(dynamic json) {
  if (json == null || json is! Map<String, dynamic>) {
    return Driver(name: "", phone: "", rating: "");
  }

  return Driver(
    name: json["name"] ?? json["user"]?["name"] ?? "",
    phone: json["phone"] ?? json["user"]?["phone"] ?? "",
    rating: json["rating"]?.toString() ?? "",
  );
}
}

class Pricing {
  final String distanceKm;
  final String estimatedCost;
  final String finalCost;
  final String taxAmount;
  final String systemServiceFee;
  final String addOnsCost;
  final int discount;

  Pricing({
    required this.distanceKm,
    required this.estimatedCost,
    required this.finalCost,
    required this.taxAmount,
    required this.systemServiceFee,
    required this.addOnsCost,
    required this.discount,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) => Pricing(
    distanceKm: json["distance_km"]?.toString() ?? "0",
    estimatedCost: json["estimated_cost"]?.toString() ?? "0",
    finalCost: json["final_cost"]?.toString() ?? "0",
    taxAmount: json["tax_amount"]?.toString() ?? "0",
    // systemServiceFee: json["system_service_fee"]?.toString() ?? "0",\
    systemServiceFee: json["service_fee"]?.toString() ?? "0",
    addOnsCost: json["add_ons_cost"]?.toString() ?? "0",
    discount: int.tryParse(json["discount"]?.toString() ?? "0") ?? 0,
  );
}

class OrderItem {
  final String productName;
  final String description;
  final String weight;
  final String declaredValue;
  final int quantity;

  OrderItem({
    required this.productName,
    required this.description,
    required this.weight,
    required this.declaredValue,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productName: json["product_name"] ?? "",
    description: json["description"] ?? "",
    weight: json["weight_kg"]?.toString() ?? "",
    declaredValue: json["declared_value"]?.toString() ?? "",
    quantity: json["quantity"] ?? 0,
  );

  // factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
  //   productName: json["product_name"] ?? "",
  //   description: json["description"] ?? "",
  //   weight: json["weight_kg"] ?? "",
  //   declaredValue: json["declared_value"] ?? "",
  //   quantity: json["quantity"] ?? 0,
  // );
}

class Depot {
  final String name;
  final String city;
  final String address;

  Depot({required this.name, required this.city, required this.address});

  factory Depot.fromJson(Map<String, dynamic> json) => Depot(
    name: json["name"] ?? "",
    city: json["city"] ?? "",
    address: json["address"] ?? "",
  );
}

class Pickup {
  final String contactName;
  final String contactPhone;
  final String address;
  final String city;
  final String state;
  final String? latitude;
  final String? longitude;

  Pickup({
    required this.contactName,
    required this.contactPhone,
    required this.address,
    required this.city,
    required this.state,
    this.latitude,
    this.longitude,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) {
    final pickup = json["pickup"] ?? {};

    return Pickup(
      contactName: pickup["contact_name"] ?? "",
      contactPhone: pickup["contact_phone"] ?? "",
      address: pickup["address"] ?? "",
      city: pickup["city"] ?? "",
      state: pickup["state"] ?? "",
      latitude: pickup["latitude"]?.toString(),
      longitude: pickup["longitude"]?.toString(),
    );
  }

  // factory Pickup.fromJson(Map<String, dynamic> json) => Pickup(
  //   contactName: json["pickup_contact_name"] ?? "",
  //   contactPhone: json["pickup_contact_phone"] ?? "",
  //   address: json["pickup_address"] ?? "",
  //   city: json["pickup_city"] ?? "",
  //   state: json["pickup_state"] ?? "",
  //   latitude: json["pickup_latitude"]?.toString(),
  //   longitude: json["pickup_longitude"]?.toString(),
  // );
}

class Delivery {
  final String contactName;
  final String contactPhone;
  final String address;
  final String city;
  final String state;
  final String? latitude;
  final String? longitude;

  Delivery({
    required this.contactName,
    required this.contactPhone,
    required this.address,
    required this.city,
    required this.state,
    this.latitude,
    this.longitude,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    final delivery = json["delivery"] ?? {};

    return Delivery(
      contactName: delivery["contact_name"] ?? "",
      contactPhone: delivery["contact_phone"] ?? "",
      address: delivery["address"] ?? "",
      city: delivery["city"] ?? "",
      state: delivery["state"] ?? "",
      latitude: delivery["latitude"]?.toString(),
      longitude: delivery["longitude"]?.toString(),
    );
  }

  // factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
  //   contactName: json["delivery_contact_name"] ?? "",
  //   contactPhone: json["delivery_contact_phone"] ?? "",
  //   address: json["delivery_address"] ?? "",
  //   city: json["delivery_city"] ?? "",
  //   state: json["delivery_state"] ?? "",
  //   latitude: json["delivery_latitude"]?.toString(),
  //   longitude: json["delivery_longitude"]?.toString(),
  // );
}
