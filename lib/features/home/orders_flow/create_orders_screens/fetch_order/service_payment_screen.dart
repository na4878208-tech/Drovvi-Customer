import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/common_widgets/custom_button.dart';
import 'package:logisticscustomer/common_widgets/custom_text.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/constants/colors.dart';

import 'package:logisticscustomer/constants/gap.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/calculate_quotes/calculate_quote_controller.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/calculate_quotes/calculate_quote_modal.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/fetch_order/common_modal.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/fetch_order/order_types/add_ons/add_ons_controller.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/fetch_order/order_types/add_ons/add_ons_modal.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/fetch_order/order_types/service_type/service_type_controller.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/fetch_order/place_order_controller.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/order_cache_provider.dart';

import '../../payment_method_orders/payment_method_controller.dart';
import '../../payment_method_orders/payment_method_model.dart';
import '../../payment_method_orders/payment_method_screen.dart';
import '../../payment_method_orders/paymet_result.dart';
// Update StopRequest model to include contact info

class ServicePaymentScreen extends ConsumerStatefulWidget {
  const ServicePaymentScreen({super.key});

  @override
  ConsumerState<ServicePaymentScreen> createState() =>
      _ServicePaymentScreenState();
}

class _ServicePaymentScreenState extends ConsumerState<ServicePaymentScreen> {
  String? selectedServiceTypeId;
  String? selectedServiceTypeName;
  String paymentMethod = "wallet";
  String priority = "normal";
  String specialInstructions = "";
  double declaredValue = 0.0;

  // Quote calculation variables
  bool hasCalculatedQuotes = false;
  bool isLoadingQuotes = false;
  String? quoteError;

  // Multi-stop storage variables
  List<Map<String, String>> multiStopLocations = [];

  // ✅ ADD THESE PROVIDERS
  final selectedAddonsProvider = StateProvider<List<String>>((ref) => []);

  final selectedTotalAmountProvider = StateProvider<double>((ref) => 0.0);

  // final selectedAddonsProvider = StateProvider<List<String>>((ref) => []);

  final selectedAddOnsWithCostProvider =
      StateProvider<List<Map<String, dynamic>>>((ref) => []);

  final declaredValueProvider = StateProvider<double>((ref) => 0.0);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceTypeControllerProvider.notifier).loadServiceTypes();
      ref.read(addOnsControllerProvider.notifier).loadAddOns();
      _loadCachedData();
      _loadMultiStopData();
    });
  }

  // Load multi-stop data from cache
  void _loadMultiStopData() {
    final cache = ref.read(orderCacheProvider);
    final isMultiStop = cache["is_multi_stop_enabled"] == "true";

    if (!isMultiStop) return;

    final stopsCount =
        int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;

    print("🔍 Loading multi-stop data...");
    print("Stops count: $stopsCount");

    List<Map<String, String>> loadedStops = [];

    for (int i = 1; i <= stopsCount; i++) {
      final name = cache["stop_${i}_contact_name"]?.toString() ?? "Name N/A";
      final phone = cache["stop_${i}_contact_phone"]?.toString() ?? "Phone N/A";
      final address = cache["stop_${i}_address"]?.toString() ?? "Address N/A";
      final city = cache["stop_${i}_city"]?.toString() ?? "City N/A";
      final state = cache["stop_${i}_state"]?.toString() ?? "State N/A";
      final stopTypeStr = cache["stop_${i}_type"]?.toString() ?? "";

      String stopType = "Waypoint";
      Color color = Colors.grey;

      if (stopTypeStr.contains("pickup")) {
        stopType = "Pickup";
        color = AppColors.electricTeal;
      } else if (stopTypeStr.contains("dropOff")) {
        stopType = "Delivery";
        color = Colors.orange;
      } else {
        stopType = "Waypoint ${i - 1}";
        color = Colors.blue;
      }

      loadedStops.add({
        'index': i.toString(),
        'name': name,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'stopType': stopType,
        'color': color.value.toString(),
      });
    }

    if (loadedStops.isNotEmpty) {
      setState(() {
        multiStopLocations = loadedStops;
      });
      print("✅ Loaded ${multiStopLocations.length} multi-stop locations");
    }
  }

  void _loadCachedData() {
    final cache = ref.read(orderCacheProvider);
    final savedServiceTypeId = cache["service_type_id"];

    if (savedServiceTypeId != null) {
      selectedServiceTypeId = savedServiceTypeId;
    } else {
      final defaultServiceType = ref.read(defaultServiceTypeProvider);
      if (defaultServiceType != null) {
        selectedServiceTypeId = defaultServiceType.id;
        selectedServiceTypeName = defaultServiceType.name;
      }
    }

    // Load existing data
    paymentMethod = cache["payment_method"] ?? "wallet";
    priority = cache["priority"] ?? "normal";
    specialInstructions = cache["special_instructions"] ?? "";

    if (cache["selected_addons"] != null) {
      final savedAddons = List<String>.from(cache["selected_addons"]);
      ref.read(selectedAddonsProvider.notifier).state = savedAddons;
    }

    if (cache["declared_value"] != null) {
      declaredValue =
          double.tryParse(cache["declared_value"].toString()) ?? 0.0;
    }

    setState(() {});
  }

  // void _printMultiStopDebugInfo() {
  //   final cache = ref.read(orderCacheProvider);
  //   print("🔍 DEBUG MULTI-STOP DATA:");

  //   // Check if multi-stop enabled
  //   print("is_multi_stop_enabled: ${cache["is_multi_stop_enabled"]}");

  //   // Check stops count
  //   final stopsCount =
  //       int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;
  //   print("Stops Count: $stopsCount");

  //   // Print each stop data
  //   for (int i = 1; i <= stopsCount; i++) {
  //     print("\nStop $i:");
  //     print("  Type: ${cache["stop_${i}_type"]}");
  //     print("  Contact Name: ${cache["stop_${i}_contact_name"]}");
  //     print("  Phone: ${cache["stop_${i}_contact_phone"]}");
  //     print("  Address: ${cache["stop_${i}_address"]}");
  //     print("  City: ${cache["stop_${i}_city"]}");
  //     print("  State: ${cache["stop_${i}_state"]}");
  //     print("  Latitude: ${cache["stop_${i}_latitude"]}");
  //     print("  Longitude: ${cache["stop_${i}_longitude"]}");
  //     print("  Quantity: ${cache["stop_${i}_quantity"]}");
  //     print("  Weight: ${cache["stop_${i}_weight"]}");
  //   }
  // }

  // ServicePaymentScreen class ke andar, _printMultiStopDebugInfo() ke baad ye functions add karo:

  void _validateMultiStopDataBeforeQuote() {
    final cache = ref.read(orderCacheProvider);
    final isMultiStop = cache["is_multi_stop_enabled"] == "true";

    if (!isMultiStop) return;

    print("🔍 VALIDATING MULTI-STOP DATA:");

    final stopsCount =
        int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;
    print("Stops Count: $stopsCount");

    // Minimum 2 stops required
    if (stopsCount < 2) {
      throw Exception("Multi-stop route requires at least 2 stops");
    }

    // Check each stop
    for (int i = 1; i <= stopsCount; i++) {
      final city = cache["stop_${i}_city"]?.toString() ?? "";
      final state = cache["stop_${i}_state"]?.toString() ?? "";

      if (city.isEmpty) {
        throw Exception("Stop $i: City is required");
      }
      if (state.isEmpty) {
        throw Exception("Stop $i: State is required");
      }
    }

    // Check required fields
    if (cache["selected_product_type_id"] == null) {
      throw Exception("Please select a product type");
    }
    if (cache["selected_packaging_type_id"] == null) {
      throw Exception("Please select a packaging type");
    }
    if (selectedServiceTypeId == null) {
      throw Exception("Please select a service type");
    }

    print("✅ Multi-stop data validation passed!");
  }

  // void _printDebugInfo() {
  //   final cache = ref.read(orderCacheProvider);
  //   final isMultiStop = cache["is_multi_stop_enabled"] == "true";

  //   print("🔍 DEBUG BEFORE RETRY:");
  //   print("Multi-stop: $isMultiStop");
  //   print("Service Type Selected: ${selectedServiceTypeId ?? 'NOT SELECTED'}");
  //   print("Product Type ID: ${cache["selected_product_type_id"]}");
  //   print("Packaging Type ID: ${cache["selected_packaging_type_id"]}");

  //   if (isMultiStop) {
  //     final stopsCount =
  //         int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;
  //     print("Stops Count: $stopsCount");

  //     for (int i = 1; i <= stopsCount; i++) {
  //       print("\nStop $i:");
  //       print("City: ${cache["stop_${i}_city"]}");
  //       print("State: ${cache["stop_${i}_state"]}");
  //       print("Quantity: ${cache["stop_${i}_quantity"]}");
  //       print("Weight: ${cache["stop_${i}_weight"]}");
  //     }
  //   }
  // }

  Future<void> _getSmartQuotes() async {
    if (isLoadingQuotes) return;

    setState(() {
      isLoadingQuotes = true;
      quoteError = null;
    });

    try {
      final cache = ref.read(orderCacheProvider);

      // ✅ DEBUG BEFORE
      _debugCacheData();

      // ✅ FIRST VALIDATE DATA
      _validateMultiStopDataBeforeQuote();

      // Check if multi-stop is enabled
      final isMultiStop = cache["is_multi_stop_enabled"] == "true";

      // Get product and packaging data
      final productTypeId = cache["selected_product_type_id"];
      final packagingTypeId = cache["selected_packaging_type_id"];
      final totalWeight = cache["total_weight"];

      if (productTypeId == null || packagingTypeId == null) {
        throw Exception("Please select product and packaging type");
      }

      if (selectedServiceTypeId == null) {
        throw Exception("Please select a service type");
      }

      // ✅ GET ADD-ONS FROM PROVIDER
      final selectedAddons = ref.read(selectedAddonsProvider);

      if (isMultiStop) {
        // Multi-stop calculation
        await _calculateMultiStopQuotes(
          productTypeId: int.parse(productTypeId),
          packagingTypeId: int.parse(packagingTypeId),
          selectedAddons: selectedAddons, // ✅ Use provider value
        );
        // ✅ DEBUG AFTER
        _debugCacheData();
      } else {
        // Standard calculation
        final weight = double.tryParse(totalWeight ?? "0") ?? 0;
        if (weight <= 0) {
          throw Exception("Please enter valid total weight");
        }

        await _calculateStandardQuotes(
          productTypeId: int.parse(productTypeId),
          packagingTypeId: int.parse(packagingTypeId),
          weightPerItem: weight,
          selectedAddons: selectedAddons, // ✅ Use provider value
        );
      }

      setState(() {
        hasCalculatedQuotes = true;
        isLoadingQuotes = false;
      });
    } catch (e) {
      setState(() {
        quoteError = e.toString();
        isLoadingQuotes = false;
      });
      print("❌ Error getting quotes: $e");
    }
  }

  // UPDATED: Standard Quotes Calculation
  Future<void> _calculateStandardQuotes({
    required int productTypeId,
    required int packagingTypeId,
    required double weightPerItem,
    required List<String> selectedAddons,
  }) async {
    final cache = ref.read(orderCacheProvider);

    // Get pickup and delivery info
    final pickupCity = cache["pickup_city"]?.toString().trim() ?? "";
    final pickupState = cache["pickup_state"]?.toString().trim() ?? "";
    final deliveryCity = cache["delivery_city"]?.toString().trim() ?? "";
    final deliveryState = cache["delivery_state"]?.toString().trim() ?? "";
    final pickupAddress = cache["pickup_address1"]?.toString() ?? "";
    final deliveryAddress = cache["delivery_address1"]?.toString() ?? "";

    // Get coordinates
    final pickupLat =
        double.tryParse(cache["pickup_latitude"]?.toString() ?? "-26.2041") ??
        -26.2041;
    final pickupLng =
        double.tryParse(cache["pickup_longitude"]?.toString() ?? "28.0473") ??
        28.0473;
    final deliveryLat =
        double.tryParse(cache["delivery_latitude"]?.toString() ?? "-26.1952") ??
        -26.1952;
    final deliveryLng =
        double.tryParse(cache["delivery_longitude"]?.toString() ?? "28.0346") ??
        28.0346;

    // Get service type
    final serviceType = selectedServiceTypeId ?? "standard";

    // Get declared value
    final declaredValueStr = cache["declared_value"]?.toString() ?? "0";
    final declaredValue = double.tryParse(declaredValueStr) ?? 0.0;

    // Get quantity from cache
    final quantity =
        int.tryParse(cache["quantity"]?.toString() ?? "1") ?? 1; // ✅ ADD THIS

    // Get dimensions
    final dimensions = _getDimensionsFromCache(cache);

    // Validate required fields
    if (pickupCity.isEmpty ||
        pickupState.isEmpty ||
        deliveryCity.isEmpty ||
        deliveryState.isEmpty) {
      throw Exception("Please complete pickup and delivery information");
    }

    try {
      await ref
          .read(quoteControllerProvider.notifier)
          .calculateStandardQuote(
            productTypeId: productTypeId,
            packagingTypeId: packagingTypeId,
            quantity: quantity, // ✅ ADD THIS
            weightPerItem: weightPerItem,
            pickupAddress: pickupAddress,
            pickupLatitude: pickupLat,
            pickupLongitude: pickupLng,
            pickupCity: pickupCity,
            pickupState: pickupState,
            deliveryAddress: deliveryAddress,
            deliveryLatitude: deliveryLat,
            deliveryLongitude: deliveryLng,
            deliveryCity: deliveryCity,
            deliveryState: deliveryState,
            serviceType: serviceType,
            declaredValue: declaredValue,
            addOns: selectedAddons,
            length: dimensions['length'],
            width: dimensions['width'],
            height: dimensions['height'],
          );

      setState(() {
        hasCalculatedQuotes = true;
        isLoadingQuotes = false;
      });

      print("✅ Standard quotes calculation completed!");
    } catch (e) {
      print("❌ Error in calculateStandardQuotes: $e");
      rethrow;
    }
  }

  // UPDATED: Multi-Stop Quotes Calculation
  // _calculateMultiStopQuotes() function ko update karo:

  Future<void> _calculateMultiStopQuotes({
    required int productTypeId,
    required int packagingTypeId,
    required List<String> selectedAddons,
  }) async {
    final cache = ref.read(orderCacheProvider);

    print("🔍 MULTI-STOP CACHE DATA:");
    print("Product Type ID: ${cache["selected_product_type_id"]}");
    print("Packaging Type ID: ${cache["selected_packaging_type_id"]}");
    print("Service Type ID: ${selectedServiceTypeId}");
    print("Stops Count: ${cache["route_stops_count"]}");

    final stopsCount =
        int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;

    if (stopsCount < 2) {
      throw Exception("Multi-stop route requires at least 2 stops");
    }

    final stops = <StopRequest>[];
    int totalQuantity = 0;
    double totalWeight = 0.0;

    for (int i = 1; i <= stopsCount; i++) {
      final stopTypeStr = cache["stop_${i}_type"]?.toString() ?? "";
      final city = cache["stop_${i}_city"]?.toString().trim() ?? "";
      final state = cache["stop_${i}_state"]?.toString().trim() ?? "";

      if (city.isEmpty || state.isEmpty) {
        throw Exception("Stop $i: Please enter City and State");
      }

      // Coordinates
      String lat, lng;
      if (city.toLowerCase().contains("cape town")) {
        lat = "-33.9249";
        lng = "18.4241";
      } else if (city.toLowerCase().contains("johannesburg") ||
          city.toLowerCase().contains("joburg")) {
        lat = "-26.2041";
        lng = "28.0473";
      } else if (city.toLowerCase().contains("durban")) {
        lat = "-29.8587";
        lng = "31.0218";
      } else if (city.toLowerCase().contains("pretoria")) {
        lat = "-25.7479";
        lng = "28.2293";
      } else {
        lat = "-26.2041";
        lng = "28.0473";
      }

      // ✅ API format mein stop type convert karo
      String apiStopType;
      if (stopTypeStr.contains("pickup")) {
        apiStopType = "pickup";
      } else if (stopTypeStr.contains("dropOff")) {
        apiStopType = "drop_off";
      } else {
        apiStopType = "waypoint";
      }

      // ✅ Quantity aur weight ke liye variables
      int quantity = 0;
      double weight = 0.0;

      // ✅ Waypoint ke liye quantity/weight skip
      if (apiStopType == "waypoint") {
        print("Stop $i is Waypoint - Skipping quantity/weight");
      }
      // ✅ Pickup ke liye quantity/weight REQUIRED
      else if (apiStopType == "pickup") {
        final quantityStr = cache["stop_${i}_quantity"]?.toString();
        final weightStr = cache["stop_${i}_weight"]?.toString();

        print(
          "Stop $i (Pickup) - Raw quantity: '$quantityStr', Raw weight: '$weightStr'",
        );

        if (quantityStr == null || quantityStr.isEmpty) {
          throw Exception("Stop $i (Pickup): Please enter quantity");
        }

        if (weightStr == null || weightStr.isEmpty) {
          throw Exception("Stop $i (Pickup): Please enter weight per item");
        }

        final parsedQuantity = int.tryParse(quantityStr);
        if (parsedQuantity == null || parsedQuantity <= 0) {
          throw Exception(
            "Stop $i (Pickup): Invalid quantity. Please enter a positive number.",
          );
        }

        final parsedWeight = double.tryParse(weightStr);
        if (parsedWeight == null || parsedWeight <= 0) {
          throw Exception(
            "Stop $i (Pickup): Invalid weight. Please enter a positive number.",
          );
        }

        quantity = parsedQuantity;
        weight = parsedWeight;

        totalQuantity += quantity;
        totalWeight += (weight * quantity);
      }
      // ✅ DropOff ke liye quantity/weight OPTIONAL
      else if (apiStopType == "drop_off") {
        final quantityStr = cache["stop_${i}_quantity"]?.toString();
        final weightStr = cache["stop_${i}_weight"]?.toString();

        print(
          "Stop $i (DropOff) - Raw quantity: '$quantityStr', Raw weight: '$weightStr'",
        );

        // Agar quantity di hai to parse karo, warna default 0
        if (quantityStr != null && quantityStr.isNotEmpty) {
          final parsedQuantity = int.tryParse(quantityStr);
          if (parsedQuantity != null && parsedQuantity > 0) {
            quantity = parsedQuantity;
          }
        }

        // Agar weight di hai to parse karo, warna default 0
        if (weightStr != null && weightStr.isNotEmpty) {
          final parsedWeight = double.tryParse(weightStr);
          if (parsedWeight != null && parsedWeight > 0) {
            weight = parsedWeight;
          }
        }

        // Agar quantity aur weight dono diye hain to total mein add karo
        if (quantity > 0 && weight > 0) {
          totalQuantity += quantity;
          totalWeight += (weight * quantity);
        }
      }

      stops.add(
        StopRequest(
          sequenceNumber: i,
          stopType: apiStopType,
          address:
              cache["stop_${i}_address"]?.toString() ?? "Address not provided",
          city: city,
          state: state,
          latitude: double.parse(lat),
          longitude: double.parse(lng),
          contactName:
              cache["stop_${i}_contact_name"]?.toString() ?? "Contact N/A",
          contactPhone:
              cache["stop_${i}_contact_phone"]?.toString() ?? "Phone N/A",
          quantity: quantity,
          weight: weight,
          notes: cache["stop_${i}_notes"]?.toString(),
        ),
      );
    }

    // ✅ Validate - Kam se kam ek pickup mein quantity/weight hona chahiye
    final hasPickupWithItems = stops.any(
      (s) => s.stopType == "pickup" && s.quantity > 0 && s.weight > 0,
    );

    if (!hasPickupWithItems) {
      throw Exception("At least one pickup stop must have quantity and weight");
    }

    // ✅ Calculate average weight per item
    double weightPerItem = 0.0;
    if (totalQuantity > 0) {
      weightPerItem = totalWeight / totalQuantity;
    }

    print("📊 WEIGHT CALCULATION:");
    print("Total Quantity: $totalQuantity");
    print("Total Weight: $totalWeight");
    print("Average Weight Per Item: $weightPerItem");

    // Save to cache
    ref
        .read(orderCacheProvider.notifier)
        .saveValue("quantity", totalQuantity.toString());
    ref
        .read(orderCacheProvider.notifier)
        .saveValue("total_weight", totalWeight.toString());

    final serviceType = selectedServiceTypeId ?? "standard";
    final declaredValueStr = cache["declared_value"]?.toString() ?? "0";
    final declaredValue = double.tryParse(declaredValueStr) ?? 0.0;
    final dimensions = _getDimensionsFromCache(cache);

    try {
      await ref
          .read(quoteControllerProvider.notifier)
          .calculateMultiStopQuote(
            productTypeId: productTypeId,
            packagingTypeId: packagingTypeId,
            stops: stops,
            quantity: totalQuantity,
            weightPerItem: weightPerItem,
            serviceType: serviceType,
            declaredValue: declaredValue,
            addOns: selectedAddons,
            length: dimensions['length'],
            width: dimensions['width'],
            height: dimensions['height'],
          );
    } catch (e) {
      print("❌ MULTI-STOP ERROR DETAILS:");
      print("Error Type: ${e.runtimeType}");
      print("Error Message: $e");
      rethrow;
    }
  }

  Map<String, double?> _getDimensionsFromCache(Map<String, dynamic> cache) {
    final length = cache["package_length"]?.toString();
    final width = cache["package_width"]?.toString();
    final height = cache["package_height"]?.toString();

    return {
      'length': length != null ? double.tryParse(length) : null,
      'width': width != null ? double.tryParse(width) : null,
      'height': height != null ? double.tryParse(height) : null,
    };
  }

  void _onServiceTypeChanged(String newType, String? name, double multiplier) {
    print("✅ Service Type Selected:");
    print("   - Value: $newType");
    print("   - Name: $name");
    print("   - Multiplier: $multiplier");

    setState(() {
      selectedServiceTypeId = newType;
      selectedServiceTypeName = name;
    });

    ref.read(orderCacheProvider.notifier).saveValue("service_type_id", newType);
    if (name != null) {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("service_type_name", name);
    }
    ref
        .read(orderCacheProvider.notifier)
        .saveValue("service_multiplier", multiplier.toString());

    // Recalculate quotes if already calculated
    if (hasCalculatedQuotes) {
      _getSmartQuotes();
    }
  }

  // Add-on toggle function
  void _toggleAddOn(String addOnValue, double cost) {
    final selectedAddons = ref.read(selectedAddonsProvider);
    final selectedWithCost = ref.read(selectedAddOnsWithCostProvider);

    if (selectedAddons.contains(addOnValue)) {
      ref.read(selectedAddonsProvider.notifier).state = selectedAddons
          .where((v) => v != addOnValue)
          .toList();

      ref.read(selectedAddOnsWithCostProvider.notifier).state = selectedWithCost
          .where((e) => e['id'] != addOnValue)
          .toList();
    } else {
      ref.read(selectedAddonsProvider.notifier).state = [
        ...selectedAddons,
        addOnValue,
      ];

      ref.read(selectedAddOnsWithCostProvider.notifier).state = [
        ...selectedWithCost,
        {'id': addOnValue, 'cost': cost},
      ];
    }

    ref
        .read(orderCacheProvider.notifier)
        .saveValue("selected_addons", ref.read(selectedAddonsProvider));

    if (hasCalculatedQuotes) {
      _getSmartQuotes();
    }
  }

  // Open Add-ons Modal
  void _openAddOnsModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 80,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final addOnsState = ref.watch(addOnsControllerProvider);

              return addOnsState.when(
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => const SizedBox(
                  height: 200,
                  child: Center(child: Text("Failed to load add-ons")),
                ),
                data: (addOnItems) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Select Add-ons",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Grid
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            itemCount: addOnItems.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.80,
                                ),
                            itemBuilder: (context, index) {
                              return _addonModalCard(item: addOnItems[index]);
                            },
                          ),
                        ),
                      ),
                      // Bottom Action
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricTeal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Done",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Payment Modal
  Future<PaymentResult?> showPaymentMethodModal(
    BuildContext context,
    PaymentData paymentData,
  ) {
    return showModalBottomSheet<PaymentResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return PaymentMethodModal(paymentData: paymentData);
      },
    );
  }

  // Check if all required data is available for quote calculation
  bool _isDataReadyForQuotes() {
    final cache = ref.read(orderCacheProvider);

    // Check basic requirements
    if (cache["selected_product_type_id"] == null ||
        cache["selected_packaging_type_id"] == null ||
        cache["total_weight"] == null) {
      return false;
    }

    // Check if multi-stop or single-stop data is available
    final isMultiStop = cache["is_multi_stop_enabled"] == "true";

    if (isMultiStop) {
      // Check multi-stop data
      final stopsCount =
          int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;
      if (stopsCount < 2) return false;

      for (int i = 1; i <= stopsCount; i++) {
        if (cache["stop_${i}_city"] == null ||
            cache["stop_${i}_state"] == null) {
          return false;
        }
      }
    } else {
      // Check single-stop data
      if (cache["pickup_city"] == null ||
          cache["pickup_state"] == null ||
          cache["delivery_city"] == null ||
          cache["delivery_state"] == null) {
        return false;
      }
    }

    return true;
  }

  // Validate before calculating quotes
  String? _validateBeforeQuotes() {
    if (!_isDataReadyForQuotes()) {
      return "Please complete all previous steps before calculating quotes";
    }

    if (selectedServiceTypeId == null) {
      return "Please select a service type";
    }

    return null;
  }

  void _debugCacheData() {
    final cache = ref.read(orderCacheProvider);
    final isMultiStop = cache["is_multi_stop_enabled"] == "true";

    print("\n🔍 DEBUG CACHE DATA:");
    print("is_multi_stop_enabled: $isMultiStop");

    // Standard order keys
    print("\nSTANDARD ORDER KEYS:");
    print(
      "quantity: ${cache["quantity"]} (Type: ${cache["quantity"]?.runtimeType})",
    );
    print(
      "total_weight: ${cache["total_weight"]} (Type: ${cache["total_weight"]?.runtimeType})",
    );

    if (isMultiStop) {
      print("\nMULTI-STOP KEYS:");
      final stopsCount =
          int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;
      print("route_stops_count: $stopsCount");

      for (int i = 1; i <= stopsCount; i++) {
        print("\nStop $i:");
        print("  quantity: ${cache["stop_${i}_quantity"]}");
        print("  weight: ${cache["stop_${i}_weight"]}");
      }
    }

    print("\n🔍 CACHE ALL KEYS:");
    cache.forEach((key, value) {
      if (key.contains("quantity") || key.contains("weight")) {
        print("  $key = $value (Type: ${value.runtimeType})");
      }
    });
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final quoteState = ref.watch(quoteControllerProvider);
    final bestQuote = ref.watch(bestQuoteProvider);
    final orderState = ref.watch(orderControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        backgroundColor: AppColors.electricTeal,
        elevation: 0,
        leading: RotatedBox(
          quarterTurns: 2,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_forward_rounded, color: AppColors.pureWhite),
          ),
        ),
        title: CustomText(
          txt: "New Order",
          color: AppColors.pureWhite,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gapH4,
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Route Overview Section
                  Consumer(
                    builder: (context, ref, child) {
                      final cache = ref.watch(orderCacheProvider);
                      final isMultiStop =
                          cache["is_multi_stop_enabled"] == "true";

                      if (isMultiStop) {
                        return _buildMultiStopRouteOverview();
                      } else {
                        return _buildStandardRouteOverview();
                      }
                    },
                  ),

                  gapH16,

                  // Service Options Section
                  Column(
                    children: [
                      _sectionTitle(Icons.local_shipping, "Service Options"),
                      const SizedBox(height: 10),
                      Consumer(
                        builder: (context, ref, child) {
                          final serviceTypeState = ref.watch(
                            serviceTypeControllerProvider,
                          );
                          return serviceTypeState.when(
                            data: (serviceItems) => Column(
                              children: serviceItems.map((service) {
                                final basePrice = 100.0;
                                final calculatedPrice =
                                    basePrice * service.priceMultiplier;
                                final priceText = service.priceMultiplier > 1.0
                                    ? "(+R${(calculatedPrice - basePrice).toStringAsFixed(0)})"
                                    : "(R${calculatedPrice.toStringAsFixed(0)})";
                                return _serviceOption(
                                  selected:
                                      selectedServiceTypeId == service.value,
                                  title: service.label,
                                  subtitle: "${service.description} $priceText",
                                  value: service.value,
                                  icon: service.getIconData(),
                                  multiplier: service.priceMultiplier,
                                );
                              }).toList(),
                            ),
                            loading: () => _buildLoadingContainer(
                              "Loading service options...",
                            ),
                            error: (error, stackTrace) => _buildErrorContainer(
                              "Failed to load service options",
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  gapH16,

                  // Add-ons Section
                  Consumer(
                    builder: (context, ref, child) {
                      final addOnsState = ref.watch(addOnsControllerProvider);
                      return addOnsState.when(
                        data: (addOnItems) => _buildAddOnsSection(addOnItems),
                        loading: () => _buildAddOnsLoading(),
                        error: (error, stackTrace) => _buildAddOnsError(),
                      );
                    },
                  ),

                  gapH16,

                  // GET SMART QUOTES BUTTON
                  _buildGetQuotesButton(),

                  // Quote Error Display
                  if (quoteError != null) _buildQuoteError(),

                  gapH16,

                  // PAYMENT SUMMARY SECTION
                  if (hasCalculatedQuotes) _buildPaymentSummary(quoteState),

                  gapH16,

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final isOrderLoading = orderState.isLoading;
                        final hasQuotes =
                            hasCalculatedQuotes &&
                            quoteState.value != null &&
                            quoteState.value!.quotes.isNotEmpty;

                        bool canPlaceOrder = hasQuotes && bestQuote != null;

                        return CustomButton(
                          text: "Payment Method",
                          backgroundColor: canPlaceOrder
                              ? AppColors.electricTeal
                              : AppColors.lightGrayBackground,
                          borderColor: AppColors.electricTeal,
                          textColor: canPlaceOrder
                              ? AppColors.pureWhite
                              : AppColors.electricTeal,
                          onPressed: canPlaceOrder && !isOrderLoading
                              ? () async {
                                  // ✅ Read total amount safely
                                  final totalAmount = ref.read(
                                    selectedTotalAmountProvider,
                                  );

                                  await ref
                                      .read(
                                        paymentCheckControllerProvider.notifier,
                                      )
                                      .checkPayment(amount: totalAmount);

                                  final paymentState = ref.read(
                                    paymentCheckControllerProvider,
                                  );

                                  paymentState.when(
                                    data: (data) async {
                                      if (data != null && data.success) {
                                        final paymentResult =
                                            await showPaymentMethodModal(
                                              context,
                                              data.data,
                                            );

                                        if (paymentResult == null) return;

                                        // 🔥 Ab yahan tumhare pass final payment method hai
                                        print(
                                          "METHOD: ${paymentResult.method}",
                                        );
                                        print("TOKEN: ${paymentResult.token}");
                                      }
                                    },
                                    loading: () {},
                                    error: (e, _) {
                                      Text("Payment check failed");

                                      AppSnackBar.showError(
                                        context,
                                        "Payment check failed",
                                      );
                                      print("Payment check failed: $e");

                                      // ScaffoldMessenger.of(
                                      //   context,
                                      // ).showSnackBar(
                                      //   SnackBar(content: Text(e.toString())),
                                      // );
                                    },
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                  ),

                  // // Place Order Button
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20),
                  //   child: Consumer(
                  //     builder: (context, ref, child) {
                  //       final isOrderLoading = orderState.isLoading;
                  //       final hasQuotes =
                  //           hasCalculatedQuotes &&
                  //           quoteState.value != null &&
                  //           quoteState.value!.quotes.isNotEmpty;

                  //       bool canPlaceOrder = hasQuotes && bestQuote != null;

                  //       return CustomButton(
                  //         text: isOrderLoading
                  //             ? "Placing Order..."
                  //             : "Place Order",
                  //         backgroundColor: canPlaceOrder
                  //             ? AppColors.electricTeal
                  //             : AppColors.lightGrayBackground,
                  //         borderColor: canPlaceOrder
                  //             ? AppColors.electricTeal
                  //             : AppColors.electricTeal,
                  //         textColor: canPlaceOrder
                  //             ? AppColors.pureWhite
                  //             : AppColors.electricTeal,
                  //         onPressed: canPlaceOrder && !isOrderLoading
                  //             ? () => _place12Order(context)
                  //             : null,
                  //       );
                  //     },
                  //   ),
                  // ),
                  gapH12,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Multi-Stop Route Overview Widget
  Widget _buildMultiStopRouteOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.route, color: AppColors.electricTeal),
            const SizedBox(width: 8),
            CustomText(
              txt: "Multi-Stop Route",
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.electricTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${multiStopLocations.length} Stops",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricTeal,
                ),
              ),
            ),
          ],
        ),
        gapH8,

        // Route Timeline
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.electricTeal.withOpacity(0.12),
                      AppColors.electricTeal.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: AppColors.electricTeal,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Route Overview",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // BODY - Timeline
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (int i = 0; i < multiStopLocations.length; i++)
                      _buildTimelineStop(
                        index: i,
                        total: multiStopLocations.length,
                        stop: multiStopLocations[i],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build individual timeline stop
  Widget _buildTimelineStop({
    required int index,
    required int total,
    required Map<String, String> stop,
  }) {
    final isFirst = index == 0;
    final isLast = index == total - 1;
    final stopType = stop['stopType'] ?? 'Stop';
    final color = Color(
      int.tryParse(stop['color'] ?? '0xFF000000') ?? 0xFF000000,
    );

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and dot
            Column(
              children: [
                // Top connector (not for first)
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 20,
                    color: AppColors.mediumGray.withOpacity(0.3),
                  ),

                // Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // Bottom connector (not for last)
                if (!isLast)
                  Container(
                    width: 2,
                    height: 20,
                    color: AppColors.mediumGray.withOpacity(0.3),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Stop details
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stop header with number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stopType,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          "Stop ${index + 1}",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Address
                    Text(
                      stop['address'] ?? 'No Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // City/State
                    Text(
                      "${stop['city'] ?? 'City'} • ${stop['state'] ?? 'State'}",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Contact info
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.mediumGray,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${stop['name']} • ${stop['phone']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Standard Route Overview Widget
  Widget _buildStandardRouteOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pickup Section
        Row(
          children: [
            Icon(Icons.bar_chart, color: AppColors.electricTeal),
            const SizedBox(width: 8),
            CustomText(
              txt: "Pick Up",
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        gapH8,
        _buildPickupSection(),
        gapH16,

        // Delivery Section
        Row(
          children: [
            Icon(Icons.bar_chart, color: AppColors.electricTeal),
            const SizedBox(width: 8),
            CustomText(
              txt: "Delivery",
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        gapH8,
        _buildDeliverySection(),
      ],
    );
  }

  Widget _buildPickupSection() {
    return Consumer(
      builder: (context, ref, child) {
        final cache = ref.watch(orderCacheProvider);
        final isMultiStop = cache["is_multi_stop_enabled"] == "true";

        String pickupName;
        String pickupPhone;
        String pickupAddress;
        String pickupCity;
        String pickupState;

        if (isMultiStop) {
          pickupName =
              cache["stop_1_contact_name"] ??
              cache["pickup_name"] ??
              "Name N/A";
          pickupPhone =
              cache["stop_1_contact_phone"] ??
              cache["pickup_phone"] ??
              "Phone N/A";
          pickupAddress =
              cache["stop_1_address"] ??
              cache["pickup_address1"] ??
              "No Address";
          pickupCity =
              cache["stop_1_city"] ?? cache["pickup_city"] ?? "City N/A";
          pickupState =
              cache["stop_1_state"] ?? cache["pickup_state"] ?? "State N/A";
        } else {
          pickupName = cache["pickup_name"] ?? "Name N/A";
          pickupPhone = cache["pickup_phone"] ?? "Phone N/A";
          pickupAddress = cache["pickup_address1"] ?? "No Address";
          pickupCity = cache["pickup_city"] ?? "City N/A";
          pickupState = cache["pickup_state"] ?? "State N/A";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.electricTeal.withOpacity(0.12),
                      AppColors.electricTeal.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.store_mall_directory,
                      size: 18,
                      color: AppColors.electricTeal,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Pickup Location",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // BODY
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TIMELINE
                    Column(
                      children: [
                        _dot(AppColors.electricTeal),
                        Container(
                          width: 2,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.electricTeal.withOpacity(0.4),
                                AppColors.mediumGray.withOpacity(0.2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            txt: pickupAddress,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            txt: "$pickupCity • $pickupState",
                            fontSize: 12,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              CustomText(
                                txt: "$pickupName • $pickupPhone",
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mediumGray,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliverySection() {
    return Consumer(
      builder: (context, ref, child) {
        final cache = ref.watch(orderCacheProvider);
        final isMultiStop = cache["is_multi_stop_enabled"] == "true";
        final stopsCount =
            int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;

        String deliveryName;
        String deliveryPhone;
        String deliveryAddress;
        String deliveryCity;
        String deliveryState;

        if (isMultiStop && stopsCount > 0) {
          final lastStopIndex = stopsCount;
          deliveryName =
              cache["stop_${lastStopIndex}_contact_name"] ??
              cache["delivery_name"] ??
              "Name N/A";
          deliveryPhone =
              cache["stop_${lastStopIndex}_contact_phone"] ??
              cache["delivery_phone"] ??
              "Phone N/A";
          deliveryAddress =
              cache["stop_${lastStopIndex}_address"] ??
              cache["delivery_address1"] ??
              "No Address";
          deliveryCity =
              cache["stop_${lastStopIndex}_city"] ??
              cache["delivery_city"] ??
              "City N/A";
          deliveryState =
              cache["stop_${lastStopIndex}_state"] ??
              cache["delivery_state"] ??
              "State N/A";
        } else {
          deliveryName = cache["delivery_name"] ?? "Name N/A";
          deliveryPhone = cache["delivery_phone"] ?? "Phone N/A";
          deliveryAddress = cache["delivery_address1"] ?? "No Address";
          deliveryCity = cache["delivery_city"] ?? "City N/A";
          deliveryState = cache["delivery_state"] ?? "State N/A";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.14),
                      Colors.orange.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Delivery Location",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // BODY
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 2,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.mediumGray.withOpacity(0.25),
                                AppColors.limeGreen.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                        _dot(AppColors.limeGreen),
                      ],
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            txt: deliveryAddress,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            txt: "$deliveryCity • $deliveryState",
                            fontSize: 12,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              CustomText(
                                txt: "$deliveryName • $deliveryPhone",
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mediumGray,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // Get Smart Quotes Button
  Widget _buildGetQuotesButton() {
    final validationError = _validateBeforeQuotes();
    final isDisabled = validationError != null || isLoadingQuotes;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: isDisabled ? null : _getSmartQuotes,
            icon: isLoadingQuotes
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.calculate, size: 24),
            label: Text(
              isLoadingQuotes
                  ? "Calculating Quotes..."
                  : hasCalculatedQuotes
                  ? "Recalculate Quotes"
                  : "Get Smart Quotes",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled
                  ? Colors.grey[400]
                  : AppColors.electricTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
          ),
          if (validationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                validationError,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[700],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  // Quote Error Display
  // Quote Error Display - IMPROVED VERSION
  // Widget _buildQuoteError() {
  //   // Parse error message to extract meaningful info
  //   String errorMessage = quoteError ?? "Unknown error";
  //   String? compatibilityMessage;

  //   if (errorMessage.contains("No vehicle types compatible with") ||
  //       errorMessage.contains("compatible")) {
  //     final RegExp regex = RegExp(r'compatible with (.*?)(?:\.|$)');
  //     final match = regex.firstMatch(errorMessage);
  //     if (match != null) {
  //       final productName = match.group(1) ?? "selected product";
  //       compatibilityMessage = "No vehicles available for '$productName'";
  //     } else {
  //       compatibilityMessage = "No compatible vehicles found";
  //     }

  //     errorMessage = errorMessage.replaceAll(
  //       RegExp(r'Exception: |throwable: |DioError: '),
  //       '',
  //     );
  //   }

  //   final bool isCompatibilityIssue = compatibilityMessage != null;

  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     padding: const EdgeInsets.all(18),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF4F9F9),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: const Color(0xFF00B3A4).withOpacity(0.25)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 12,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         /// 🔹 HEADER
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(10),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF00B3A4).withOpacity(0.12),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: const Icon(
  //                 Icons.local_shipping_outlined,
  //                 color: Color(0xFF00B3A4),
  //                 size: 22,
  //               ),
  //             ),
  //             const SizedBox(width: 14),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     isCompatibilityIssue
  //                         ? "Service Not Available"
  //                         : "Unable to Generate Quote",
  //                     style: const TextStyle(
  //                       fontSize: 17,
  //                       fontWeight: FontWeight.w700,
  //                       color: Color(0xFF1E2A2A),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     isCompatibilityIssue
  //                         ? compatibilityMessage!
  //                         : "Please review shipment details and try again.",
  //                     style: TextStyle(
  //                       fontSize: 13.5,
  //                       color: Colors.grey[700],
  //                       height: 1.4,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),

  //         const SizedBox(height: 18),

  //         /// 🔹 ERROR DETAILS BOX
  //         Container(
  //           padding: const EdgeInsets.all(14),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //             border: Border.all(color: Colors.grey.shade200),
  //           ),
  //           child: Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Icon(
  //                 Icons.info_outline,
  //                 size: 18,
  //                 color: Colors.orange.shade700,
  //               ),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: Text(
  //                   errorMessage.isNotEmpty
  //                       ? errorMessage
  //                       : "Please fill in the required fields correctly.",
  //                   style: TextStyle(
  //                     fontSize: 13.5,
  //                     color: Colors.grey[800],
  //                     height: 1.5,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         if (errorMessage.contains("product_type_id"))
  //           Padding(
  //             padding: const EdgeInsets.only(top: 10),
  //             child: Text(
  //               "Tip: This shipment type may not be supported in the selected region.",
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 color: Colors.grey[600],
  //                 fontStyle: FontStyle.italic,
  //               ),
  //             ),
  //           ),

  //         const SizedBox(height: 20),

  //         /// 🔹 ACTION BUTTONS
  //         Row(
  //           children: [
  //             Expanded(
  //               child: OutlinedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 style: OutlinedButton.styleFrom(
  //                   foregroundColor: const Color(0xFF00B3A4),
  //                   side: const BorderSide(color: Color(0xFF00B3A4)),
  //                   padding: const EdgeInsets.symmetric(vertical: 14),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   "Edit Details",
  //                   style: TextStyle(fontWeight: FontWeight.w600),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   _getSmartQuotes();
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xFF00B3A4),
  //                   foregroundColor: Colors.white,
  //                   padding: const EdgeInsets.symmetric(vertical: 14),
  //                   elevation: 0,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   "Try Again",
  //                   style: TextStyle(fontWeight: FontWeight.w600),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildQuoteError() {
    // Sirf error message le lo, kuch mat karo
    String errorMessage = quoteError ?? "Unknown error";

    // Sirf "Exception: " prefix hatao agar ho to
    errorMessage = errorMessage.replaceAll('Exception: ', '');
    errorMessage = errorMessage.replaceAll('DioError: ', '');
    errorMessage = errorMessage.replaceAll('throwable: ', '');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00B3A4).withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B3A4).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFF00B3A4),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Unable to Generate Quote",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E2A2A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Please review shipment details and try again.",
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// 🔹 ERROR DETAILS BOX - Backend message yahan dikhega
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage, // 👈 DIRECT BACKEND MESSAGE
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Agar koi weight-related error hai to tip dikhao (optional)
          if (errorMessage.toLowerCase().contains('weight') ||
              errorMessage.toLowerCase().contains('kg'))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "Tip: Try adjusting the weight or splitting your shipment",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 20),

          /// 🔹 ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00B3A4),
                    side: const BorderSide(color: Color(0xFF00B3A4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Edit Details",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _getSmartQuotes();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B3A4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Payment Summary Widget
  Widget _buildPaymentSummary(AsyncValue<QuoteData?> quoteState) {
    return Consumer(
      builder: (context, ref, child) {
        final bestQuote = ref.watch(bestQuoteProvider);
        final quoteState = ref.watch(quoteControllerProvider);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Column(
            children: [
              // Header with Icon
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.electricTeal.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  border: Border.all(
                    color: AppColors.electricTeal.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: AppColors.electricTeal,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Payment Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Content
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  border: Border.all(
                    color: AppColors.mediumGray.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: quoteState.when(
                  data: (quoteData) {
                    if (quoteData == null) {
                      return _buildNoQuotesState("No quote data received");
                    }

                    if (quoteData.quotes.isEmpty) {
                      return _buildNoQuotesState(
                        "No quotes available for your request",
                      );
                    }

                    if (bestQuote == null && quoteData.quotes.isNotEmpty) {
                      // Auto-select the first quote
                      final firstQuote = quoteData.quotes.first;
                      return _buildQuoteDetails(firstQuote, quoteData);
                    }

                    return _buildQuoteDetails(bestQuote!, quoteData);
                  },
                  loading: () => _buildLoadingState(),
                  error: (e, st) => _buildErrorState(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // No Quotes State
  Widget _buildNoQuotesState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 48, color: AppColors.mediumGray),
          const SizedBox(height: 16),
          Text(
            "No Quotes Available",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _getSmartQuotes,
            child: const Text("Try Again"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricTeal,
            ),
          ),
        ],
      ),
    );
  }

  // Quote Details Widget
  Widget _buildQuoteDetails(Quote quote, QuoteData quoteData) {
    final pricing = quote.pricing;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedTotalAmountProvider.notifier).state = pricing.total;
    });

    return Consumer(
      builder: (context, ref, _) {
        // ✅ SAVE total globally
        // ref.read(selectedTotalAmountProvider.notifier).state = pricing.total;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quote Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Best Quote Selected",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${quote.company.name} • ${quote.vehicleType}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.electricTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          "${quote.totalScore.toStringAsFixed(1)}% Match",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.electricTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Vehicle Details
              _buildQuoteDetailCard(
                icon: Icons.directions_car,
                title: "Vehicle Details",
                children: [
                  _buildDetailRow("Type", quote.vehicleType),
                  _buildDetailRow("Capacity", "${quote.capacityWeightKg}kg"),
                  _buildDetailRow("Registration", quote.registrationNumber),
                  _buildDetailRow(
                    "Driver",
                    "${quote.driver.name} (⭐ ${quote.driver.rating})",
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Pricing Breakdown
              _buildQuoteDetailCard(
                icon: Icons.attach_money,
                title: "Pricing Breakdown",
                children: [
                  _buildPriceRow("Base Fare", pricing.baseFare),
                  _buildPriceRow("Distance Cost", pricing.distanceCost),
                  if (pricing.weightCharge > 0)
                    _buildPriceRow("Weight Charge", pricing.weightCharge),
                  if (pricing.addOnsTotal > 0)
                    _buildPriceRow("Add-ons Total", pricing.addOnsTotal),
                  const Divider(height: 20),
                  _buildPriceRow(
                    "Service Fee",
                    pricing.serviceFee,
                    isBold: true,
                  ),
                  _buildPriceRow("Tax", pricing.tax, isBold: true),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.electricTeal.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.electricTeal.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          "R${pricing.total.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.electricTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Distance Info
              if (quoteData.distanceKm != null && quoteData.distanceKm! > 0)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.map, size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Estimated Distance",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${quoteData.distanceKm!.toStringAsFixed(1)} km",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Product & Packaging Info
              if (quoteData.productType != null ||
                  quoteData.packagingType != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.inventory, size: 20, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (quoteData.productType != null)
                              Text(
                                "Product: ${quoteData.productType!.name}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[800],
                                ),
                              ),
                            if (quoteData.packagingType != null)
                              Text(
                                "Packaging: ${quoteData.packagingType!.name}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[800],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // View All Quotes Button
              Container(
                margin: const EdgeInsets.only(top: 16),
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showAllQuotes(quoteData);
                  },
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: Text("View All Quotes (${quoteData.quotes.length})"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.electricTeal),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAllQuotes(QuoteData quoteData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.electricTeal,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "All Available Quotes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Quotes List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quoteData.quotes.length,
                  itemBuilder: (context, index) {
                    final quote = quoteData.quotes[index];
                    final isBest =
                        ref.read(bestQuoteProvider)?.vehicleId ==
                        quote.vehicleId;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isBest
                              ? AppColors.electricTeal
                              : Colors.grey[300]!,
                          width: isBest ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.electricTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.local_shipping,
                            size: 30,
                            color: AppColors.electricTeal,
                          ),
                        ),
                        title: Text(
                          quote.vehicleType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "${quote.company.name} • ${quote.driver.name}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${quote.totalScore.toStringAsFixed(1)}% Match",
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "R${quote.pricing.total.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.electricTeal,
                              ),
                            ),
                            if (isBest)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.electricTeal,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "BEST",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuoteDetailCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.electricTeal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkText,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "R${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkText,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.electricTeal,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Loading quotes...",
            style: TextStyle(fontSize: 16, color: AppColors.mediumGray),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            "Failed to load quotes",
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _getSmartQuotes,
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _serviceOption({
    required bool selected,
    required String title,
    required String subtitle,
    required String value,
    IconData? icon,
    double multiplier = 1.0,
  }) {
    return GestureDetector(
      onTap: () => _onServiceTypeChanged(value, title, multiplier),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.electricTeal
                : AppColors.mediumGray.withOpacity(0.4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? AppColors.electricTeal
                  : AppColors.mediumGray.withOpacity(0.4),
            ),
            const SizedBox(width: 12),
            if (icon != null)
              Icon(
                icon,
                color: selected ? AppColors.electricTeal : Colors.grey,
                size: 20,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          txt: title,
                          fontSize: 15,
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (multiplier > 1.0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.electricTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '×${multiplier.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.electricTeal,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    txt: subtitle,
                    fontSize: 13,
                    color: AppColors.mediumGray,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add-ons section
  Widget _buildAddOnsSection(List<AddOnItem> addOnsItems) {
    print("✅ Service Type Selected:");
    print("   - Name: $addOnsItems");
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _openAddOnsModal(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.electricTeal, width: 1.2),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.electricTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add_circle_outline,
                              color: AppColors.electricTeal,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Add-ons",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              "Optional extras",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Right side indicator
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.electricTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${addOnsItems.length} options",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.electricTeal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Selected Summary
            Consumer(
              builder: (context, ref, child) {
                final selectedAddons = ref.watch(selectedAddonsProvider);
                final selectedWithCost = ref.watch(
                  selectedAddOnsWithCostProvider,
                );

                if (selectedAddons.isEmpty) {
                  return const SizedBox();
                }

                double totalAddonsCost = 0;
                for (var item in selectedWithCost) {
                  totalAddonsCost += item['cost'] ?? 0.0;
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.electricTeal.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.electricTeal.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.electricTeal,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Selected (${selectedAddons.length})",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "R${totalAddonsCost.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.electricTeal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _addonModalCard({required AddOnItem item}) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedAddons = ref.watch(selectedAddonsProvider);
        final declaredValue = ref.watch(declaredValueProvider);

        final isSelected = selectedAddons.contains(item.value);
        final dynamicCost = item.calculateCost(declaredValue);
        final isPercentage = item.priceType == 'percentage';
        final basePrice = item.price;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              _toggleAddOn(item.value, dynamicCost);
            },
            splashColor: AppColors.electricTeal.withOpacity(0.2),
            highlightColor: AppColors.electricTeal.withOpacity(0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                border: Border.all(
                  color: isSelected
                      ? AppColors.electricTeal
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.electricTeal.withOpacity(0.2)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: isSelected ? 15 : 8,
                    offset: const Offset(0, 4),
                    spreadRadius: isSelected ? 0.5 : 0,
                  ),
                ],
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.electricTeal.withOpacity(0.03),
                          AppColors.electricTeal.withOpacity(0.01),
                        ],
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Selection Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.electricTeal.withOpacity(0.9),
                                    AppColors.electricTeal,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.electricTeal.withOpacity(
                                      0.4,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            item.getIconData(),
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.electricTeal
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.electricTeal
                                : Colors.grey.shade400,
                            width: isSelected ? 0 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.electricTeal.withOpacity(
                                      0.5,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                AppColors.electricTeal.withOpacity(0.9),
                                AppColors.electricTeal,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : AppColors.electricTeal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: AppColors.electricTeal.withOpacity(0.2),
                              width: 1,
                            ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "R${dynamicCost.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.electricTeal,
                          ),
                        ),
                        if (isPercentage)
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text(
                              "(${item.price.toStringAsFixed(0)}%)",
                              style: TextStyle(
                                fontSize: 9,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.9)
                                    : AppColors.electricTeal.withOpacity(0.7),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Original Price (if different)
                  if (isPercentage && basePrice > 0 && dynamicCost != basePrice)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Base: R${basePrice.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddOnsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.electricTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.electricTeal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Add-ons",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        "Loading options...",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddOnsError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.error_outline, color: Colors.red, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add-ons",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    "Failed to load",
                    style: TextStyle(fontSize: 11, color: Colors.red.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  // Add-ons section end

  // Service Options Section
  Widget _buildLoadingContainer(String text) {
    return Column(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.mediumGray.withOpacity(0.4)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(text),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Service Options Section
  Widget _buildErrorContainer(String text) {
    return Column(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Text(text, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () {
              ref
                  .read(serviceTypeControllerProvider.notifier)
                  .loadServiceTypes();
            },
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.electricTeal, size: 22),
        const SizedBox(width: 8),
        CustomText(
          txt: title,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ],
    );
  }
}
