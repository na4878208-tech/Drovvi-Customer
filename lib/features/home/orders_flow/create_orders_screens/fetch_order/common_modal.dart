// ✅ COMMON MODELS FOR ALL ORDER-RELATED CLASSES

// ✅ VEHICLE PRICING
class VehiclePricing {
  final double baseFare;
  final double distanceKm;
  final double distanceCost;
  final double weightCharge;
  final double addOnsTotal;
  final double subtotalA;
  final double systemServiceFee;
  final double ssfPercentage;
  final double subtotalB;
  final double serviceFee;
  final double serviceFeePercentage;
  final double tax;
  final double total;
  final double vehicleMultiplier;
  final double productMultiplier;
  final double packagingMultiplier;

  VehiclePricing({
    required this.baseFare,
    required this.distanceKm,
    required this.distanceCost,
    required this.weightCharge,
    required this.addOnsTotal,
    required this.subtotalA,
    required this.systemServiceFee,
    required this.ssfPercentage,
    required this.subtotalB,
    required this.serviceFee,
    required this.serviceFeePercentage,
    required this.tax,
    required this.total,
    required this.vehicleMultiplier,
    required this.productMultiplier,
    required this.packagingMultiplier,
  });

  factory VehiclePricing.fromJson(Map<String, dynamic> json) {
    return VehiclePricing(
      baseFare: (json['base_fare'] ?? 0).toDouble(),
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      distanceCost: (json['distance_cost'] ?? 0).toDouble(),
      weightCharge: (json['weight_charge'] ?? 0).toDouble(),
      addOnsTotal: (json['add_ons_total'] ?? 0).toDouble(),
      subtotalA: (json['subtotal_a'] ?? 0).toDouble(),
      systemServiceFee: (json['system_service_fee'] ?? 0).toDouble(),
      ssfPercentage: (json['ssf_percentage'] ?? 0).toDouble(),
      subtotalB: (json['subtotal_b'] ?? 0).toDouble(),
      serviceFee: (json['service_fee'] ?? 0).toDouble(),
      serviceFeePercentage: (json['service_fee_percentage'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      vehicleMultiplier: double.parse(json['vehicle_multiplier'].toString()),
      productMultiplier: double.parse(json['product_multiplier'].toString()),
      packagingMultiplier: double.parse(json['packaging_multiplier'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'distance_km': distanceKm,
      'distance_cost': distanceCost,
      'weight_charge': weightCharge,
      'add_ons_total': addOnsTotal,
      'subtotal_a': subtotalA,
      'system_service_fee': systemServiceFee,
      'ssf_percentage': ssfPercentage,
      'subtotal_b': subtotalB,
      'service_fee': serviceFee,
      'service_fee_percentage': serviceFeePercentage,
      'tax': tax,
      'total': total,
      'vehicle_multiplier': vehicleMultiplier,
      'product_multiplier': productMultiplier,
      'packaging_multiplier': packagingMultiplier,
    };
  }
}

// ✅ VEHICLE COMPANY
class VehicleCompany {
  final int id;
  final String name;

  VehicleCompany({
    required this.id,
    required this.name,
  });

  factory VehicleCompany.fromJson(Map<String, dynamic> json) {
    return VehicleCompany(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// ✅ VEHICLE DRIVER
class VehicleDriver {
  final int id;
  final String name;
  final double rating;

  VehicleDriver({
    required this.id,
    required this.name,
    required this.rating,
  });

  factory VehicleDriver.fromJson(Map<String, dynamic> json) {
    return VehicleDriver(
      id: json['id'],
      name: json['name'],
      rating: double.parse(json['rating'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
    };
  }
}

// ✅ QUOTE MODEL (For both calculation and order)
class Quote {
  final int vehicleId;
  final int vehicleTypeId;
  final String vehicleType;
  final String registrationNumber;
  final String make;
  final String model;
  final double capacityWeightKg;
  final double totalScore;
  final double matchingScore;
  final int depotScore;
  final int distanceScore;
  final int priceScore;
  final int suitabilityScore;
  final int driverScore;
  final int depotId;
  final String depotName;
  final String depotCity;
  final double depotDistanceKm;
  final bool isExclusive;
  final double utilizationPercent;
  final VehiclePricing pricing;
  final VehicleCompany company;
  final VehicleDriver driver;

  Quote({
    required this.vehicleId,
    required this.vehicleTypeId,
    required this.vehicleType,
    required this.registrationNumber,
    required this.make,
    required this.model,
    required this.capacityWeightKg,
    required this.totalScore,
    required this.matchingScore,
    required this.depotScore,
    required this.distanceScore,
    required this.priceScore,
    required this.suitabilityScore,
    required this.driverScore,
    required this.depotId,
    required this.depotName,
    required this.depotCity,
    required this.depotDistanceKm,
    required this.isExclusive,
    required this.utilizationPercent,
    required this.pricing,
    required this.company,
    required this.driver,
  });

  factory Quote.fromCompatibleVehicle(CompatibleVehicle vehicle) {
    return Quote(
      vehicleId: vehicle.vehicleId,
      vehicleTypeId: vehicle.vehicleTypeId,
      vehicleType: vehicle.vehicleTypeName,
      registrationNumber: vehicle.registrationNumber,
      make: vehicle.make,
      model: vehicle.model,
      capacityWeightKg: vehicle.capacityKg,
      totalScore: vehicle.totalScore,
      matchingScore: vehicle.matchingScore,
      depotScore: vehicle.depotScore,
      distanceScore: vehicle.distanceScore,
      priceScore: vehicle.priceScore,
      suitabilityScore: vehicle.suitabilityScore,
      driverScore: vehicle.driverScore,
      depotId: vehicle.depotId,
      depotName: vehicle.depotName,
      depotCity: vehicle.depotCity,
      depotDistanceKm: vehicle.depotDistanceKm,
      isExclusive: vehicle.isExclusive,
      utilizationPercent: vehicle.utilizationPercent,
      pricing: vehicle.pricing,
      company: vehicle.company,
      driver: vehicle.driver,
    );
  }
}

// ✅ COMPATIBLE VEHICLE (For quote calculation response)
class CompatibleVehicle {
  final int vehicleId;
  final int vehicleTypeId;
  final String vehicleTypeName;
  final String registrationNumber;
  final String make;
  final String model;
  final double capacityKg;
  final double capacityVolumeM3;
  final double totalScore;
  final double matchingScore;
  final int depotScore;
  final int distanceScore;
  final int priceScore;
  final int suitabilityScore;
  final int driverScore;
  final int depotId;
  final String depotName;
  final String depotCity;
  final double depotDistanceKm;
  final bool isExclusive;
  final double utilizationPercent;
  final VehiclePricing pricing;
  final VehicleCompany company;
  final VehicleDriver driver;

  CompatibleVehicle({
    required this.vehicleId,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
    required this.registrationNumber,
    required this.make,
    required this.model,
    required this.capacityKg,
    required this.capacityVolumeM3,
    required this.totalScore,
    required this.matchingScore,
    required this.depotScore,
    required this.distanceScore,
    required this.priceScore,
    required this.suitabilityScore,
    required this.driverScore,
    required this.depotId,
    required this.depotName,
    required this.depotCity,
    required this.depotDistanceKm,
    required this.isExclusive,
    required this.utilizationPercent,
    required this.pricing,
    required this.company,
    required this.driver,
  });

  factory CompatibleVehicle.fromJson(Map<String, dynamic> json) {
    return CompatibleVehicle(
      vehicleId: json['vehicle_id'],
      vehicleTypeId: json['vehicle_type_id'],
      vehicleTypeName: json['vehicle_type_name'],
      registrationNumber: json['registration_number'],
      make: json['make'],
      model: json['model'],
      capacityKg: double.parse(json['capacity_kg'].toString()),
      capacityVolumeM3: double.parse(json['capacity_volume_m3'].toString()),
      totalScore: (json['total_score'] ?? 0).toDouble(),
      matchingScore: (json['matching_score'] ?? 0).toDouble(),
      depotScore: json['depot_score'] ?? 0,
      distanceScore: json['distance_score'] ?? 0,
      priceScore: json['price_score'] ?? 0,
      suitabilityScore: json['suitability_score'] ?? 0,
      driverScore: json['driver_score'] ?? 0,
      depotId: json['depot_id']?? 0,
      depotName: json['depot_name'] ?? "",
      depotCity: json['depot_city']?? "",
      depotDistanceKm: (json['depot_distance_km'] ?? 0).toDouble(),
      isExclusive: json['is_exclusive'] ?? false,
      utilizationPercent: (json['utilization_percent'] ?? 0).toDouble(),
      pricing: VehiclePricing.fromJson(json['pricing']),
      company: VehicleCompany.fromJson(json['company']),
      driver: VehicleDriver.fromJson(json['driver']),
    );
  }
}