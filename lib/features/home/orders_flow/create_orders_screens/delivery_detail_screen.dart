import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/export.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/order_cache_provider.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/fetch_order/service_payment_screen.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/pickup_location/dropdown.dart';

import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/pickup_location/dropdown/product_type_controller.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/pickup_location/pickup_controller.dart';

class Step2Screen extends ConsumerStatefulWidget {
  const Step2Screen({super.key});

  @override
  ConsumerState<Step2Screen> createState() => _Step2ScreenState();
}

class _Step2ScreenState extends ConsumerState<Step2Screen> {
  // Multi-Stop Variables
  bool isMultiStopEnabled = false;
  List<RouteStop> routeStops = [];

  // Single Stop Variables (Existing)
  String? selectedCountry;
  String? countryError;
  String? selectedProductType;
  String? selectedProductTypeName;
  int? selectedProductTypeId;
  String? productTypeError;
  String? selectedPackageType;
  String? packageTypeError;
  String? selectedPackagingTypeName;
  int? selectedPackagingTypeId;
  String? packagingTypeError;

  // Text Controllers for product info
  final TextEditingController weightController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController declaredValueController = TextEditingController();

  // Dimensions variables
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  late FlutterGooglePlacesSdk places;

  String editorMode = "";
  bool showEditor = false;
  int selectedCardIndex = 0;
  String selectedAddress = "";

  // Single Stop Controllers
  final TextEditingController contactnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final TextEditingController contactnameDeliveryController =
      TextEditingController();
  final TextEditingController phoneDeliveryController = TextEditingController();
  final TextEditingController address1DeliveryController =
      TextEditingController();
  final TextEditingController address2DeliveryController =
      TextEditingController();
  final TextEditingController cityDeliveryController = TextEditingController();
  final TextEditingController stateDeliveryController = TextEditingController();
  final TextEditingController postalDeliveryController =
      TextEditingController();
  final TextEditingController emailDeliveryController = TextEditingController();
  final TextEditingController notesDeliveryController = TextEditingController();

  final FocusNode editlocationFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode locationFocus = FocusNode();
  final FocusNode contactnameFocus = FocusNode();

  bool _isFormFilled = false;
  bool showDimensionsFields = false;

  // Debounce timer for API calls
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    places = FlutterGooglePlacesSdk("AIzaSyBrF_4PwauOkQ_RS8iGYhAW1NIApp3IEf0");

    // Remove old listeners and setup new ones
    setupPickupListener();
    setupDeliveryListener();

    // LOAD CACHED DATA
    Future.microtask(() {
      final cache = ref.read(orderCacheProvider);

      // Load multi-stop setting
      final savedMultiStop = cache["is_multi_stop_enabled"];
      if (savedMultiStop != null) {
        setState(() {
          isMultiStopEnabled = savedMultiStop == "true";
        });
      }

      // Load route stops from cache
      _loadRouteStopsFromCache(cache);

      // Load single stop data
      _loadSingleStopData(cache);

      // Initialize multi-stop if enabled
      if (isMultiStopEnabled && routeStops.isEmpty) {
        _initializeMultiStop();
      }

      ref.read(defaultAddressControllerProvider.notifier).loadDefaultAddress();
      ref.read(allAddressControllerProvider.notifier).loadAllAddress();
      ref.read(productTypeControllerProvider.notifier).loadProductTypes();
      ref.read(packagingTypeControllerProvider.notifier).loadPackagingTypes();

      // Check form initially
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkFormFilled();
      });
    });

    _addDimensionCacheListeners();
    _addCacheListeners();
  }

  void _initializeMultiStop() {
    setState(() {
      routeStops = [
        RouteStop(
          id: 1,
          stopType: StopType.pickup,
          contactName: TextEditingController(),
          contactPhone: TextEditingController(),
          address: TextEditingController(),
          city: TextEditingController(),
          state: TextEditingController(),
          postalCode: TextEditingController(),
          contactEmail: TextEditingController(),
          notes: TextEditingController(),
          weight: TextEditingController(),
          quantity: TextEditingController(),
        ),
        RouteStop(
          id: 2,
          stopType: StopType.dropOff,
          contactName: TextEditingController(),
          contactPhone: TextEditingController(),
          address: TextEditingController(),
          city: TextEditingController(),
          state: TextEditingController(),
          postalCode: TextEditingController(),
          contactEmail: TextEditingController(),
          notes: TextEditingController(),
          weight: TextEditingController(),
          quantity: TextEditingController(),
        ),
      ];

      _addMultiStopListeners();
    });
  }

  void _loadRouteStopsFromCache(Map<String, dynamic> cache) {
    final stopsCountStr = cache["route_stops_count"]?.toString() ?? "";
    if (stopsCountStr.isNotEmpty) {
      final stopsCount = int.tryParse(stopsCountStr) ?? 0;

      List<RouteStop> loadedStops = [];

      for (int i = 1; i <= stopsCount; i++) {
        final stopTypeStr = cache["stop_${i}_type"]?.toString() ?? "";
        StopType stopType;

        try {
          stopType = StopType.values.firstWhere(
            (type) => type.toString() == stopTypeStr,
          );
        } catch (e) {
          stopType = i == 1 ? StopType.pickup : StopType.dropOff;
        }

        final stop = RouteStop(
          id: i,
          stopType: stopType,
          contactName: TextEditingController(
            text: cache["stop_${i}_contact_name"]?.toString() ?? "",
          ),
          contactPhone: TextEditingController(
            text: cache["stop_${i}_contact_phone"]?.toString() ?? "",
          ),
          address: TextEditingController(
            text: cache["stop_${i}_address"]?.toString() ?? "",
          ),
          city: TextEditingController(
            text: cache["stop_${i}_city"]?.toString() ?? "",
          ),
          state: TextEditingController(
            text: cache["stop_${i}_state"]?.toString() ?? "",
          ),
          postalCode: TextEditingController(
            text: cache["stop_${i}_postal_code"]?.toString() ?? "",
          ),
          contactEmail: TextEditingController(
            text: cache["stop_${i}_contact_email"]?.toString() ?? "",
          ),
          notes: TextEditingController(
            text: cache["stop_${i}_notes"]?.toString() ?? "",
          ),
          quantity: TextEditingController(
            text: cache["stop_${i}_quantity"]?.toString() ?? "",
          ),
          weight: TextEditingController(
            text: cache["stop_${i}_weight"]?.toString() ?? "",
          ),
        );
        loadedStops.add(stop);
      }

      if (loadedStops.isNotEmpty) {
        setState(() {
          routeStops = loadedStops;
        });

        _addMultiStopListeners();
      }
    }
  }

  void _loadSingleStopData(Map<String, dynamic> cache) {
    selectedAddress = cache["default_selected_address"]?.toString() ?? "";

    final savedLength = cache["package_length"]?.toString();
    final savedWidth = cache["package_width"]?.toString();
    final savedHeight = cache["package_height"]?.toString();
    if (savedLength != null) lengthController.text = savedLength;
    if (savedWidth != null) widthController.text = savedWidth;
    if (savedHeight != null) heightController.text = savedHeight;

    final savedProductTypeId = cache["selected_product_type_id"]?.toString();
    final savedProductTypeName = cache["selected_product_type_name"]
        ?.toString();

    if (savedProductTypeId != null) {
      setState(() {
        selectedProductTypeId = int.tryParse(savedProductTypeId);
        selectedProductTypeName = savedProductTypeName;
      });
    }

    final savedPackageType = cache["selected_package_type"]?.toString();
    if (savedPackageType != null) {
      setState(() {
        selectedPackageType = savedPackageType;
      });
    }

    final savedPackagingTypeId = cache["selected_packaging_type_id"]
        ?.toString();
    final savedPackagingTypeName = cache["selected_packaging_type_name"]
        ?.toString();
    final savedRequiresDimensions =
        cache["selected_packaging_requires_dimensions"]?.toString();

    if (savedPackagingTypeId != null) {
      setState(() {
        selectedPackagingTypeId = int.tryParse(savedPackagingTypeId);
        selectedPackagingTypeName = savedPackagingTypeName;

        if (savedRequiresDimensions != null) {
          showDimensionsFields = savedRequiresDimensions == "true";
        }
      });
    }

    final savedWeight = cache["total_weight"]?.toString();
    final savedQuantity = cache["quantity"]?.toString();
    final savedDeclaredValue = cache["declared_value"]?.toString();

    if (savedWeight != null) weightController.text = savedWeight;
    if (savedQuantity != null) quantityController.text = savedQuantity;
    if (savedDeclaredValue != null) {
      declaredValueController.text = savedDeclaredValue;
    }

    contactnameController.text = cache["pickup_name"]?.toString() ?? "";
    phoneController.text = cache["pickup_phone"]?.toString() ?? "";
    address1Controller.text = cache["pickup_address1"]?.toString() ?? "";
    address2Controller.text = cache["pickup_address2"]?.toString() ?? "";
    cityController.text = cache["pickup_city"]?.toString() ?? "";
    stateController.text = cache["pickup_state"]?.toString() ?? "";
    postalController.text = cache["pickup_postal"]?.toString() ?? "";
    emailController.text = cache["pickup_email"]?.toString() ?? "";
    notesController.text = cache["pickup_notes"]?.toString() ?? "";

    contactnameDeliveryController.text =
        cache["delivery_name"]?.toString() ?? "";
    phoneDeliveryController.text = cache["delivery_phone"]?.toString() ?? "";
    address1DeliveryController.text =
        cache["delivery_address1"]?.toString() ?? "";
    address2DeliveryController.text =
        cache["delivery_address2"]?.toString() ?? "";
    cityDeliveryController.text = cache["delivery_city"]?.toString() ?? "";
    stateDeliveryController.text = cache["delivery_state"]?.toString() ?? "";
    postalDeliveryController.text = cache["delivery_postal"]?.toString() ?? "";
    emailDeliveryController.text = cache["delivery_email"]?.toString() ?? "";
    notesDeliveryController.text = cache["delivery_notes"]?.toString() ?? "";
  }

  // ✅ FIXED: Pickup Listener with proper API call
  void setupPickupListener() {
    address1Controller.addListener(() async {
      final input = address1Controller.text.trim();
      if (input.length < 3) return;

      // Debounce to avoid too many API calls
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () async {
        try {
          final latLng = await _getCoordinatesFromAddress(input);

          if (latLng != null) {
            ref
                .read(orderCacheProvider.notifier)
                .saveValue("pickup_latitude", latLng.lat.toString());
            ref
                .read(orderCacheProvider.notifier)
                .saveValue("pickup_longitude", latLng.lng.toString());

            print("✅ Pickup Coordinates: ${latLng.lat}, ${latLng.lng}");
          } else {
            print("❌ No coordinates found for: $input");
          }
        } catch (e) {
          print("❌ Error getting pickup coordinates: $e");
        }
      });
    });
  }

  // ✅ FIXED: Delivery Listener with proper API call
  void setupDeliveryListener() {
    address1DeliveryController.addListener(() async {
      final input = address1DeliveryController.text.trim();
      if (input.length < 3) return;

      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () async {
        try {
          final latLng = await _getCoordinatesFromAddress(input);

          if (latLng != null) {
            ref
                .read(orderCacheProvider.notifier)
                .saveValue("delivery_latitude", latLng.lat.toString());
            ref
                .read(orderCacheProvider.notifier)
                .saveValue("delivery_longitude", latLng.lng.toString());

            print("✅ Delivery Coordinates: ${latLng.lat}, ${latLng.lng}");
          } else {
            print("❌ No coordinates found for: $input");
          }
        } catch (e) {
          print("❌ Error getting delivery coordinates: $e");
        }
      });
    });
  }

  // ✅ NEW: Common method to get coordinates from address using Google Places API
  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      final predictions = await places.findAutocompletePredictions(
        address,
        countries: ["ZA"],
      );

      if (predictions.predictions.isEmpty) {
        return null;
      }

      final placeId = predictions.predictions.first.placeId;
      final placeDetails = await places.fetchPlace(
        placeId,
        fields: [PlaceField.Location],
      );

      if (placeDetails.place?.latLng != null) {
        final lat = placeDetails.place!.latLng!.lat;
        final lng = placeDetails.place!.latLng!.lng;

        if (lat != 0.0 && lng != 0.0) {
          return LatLng(lat: lat, lng: lng); // ✅ YEH SAHI HAI
        }
      }

      return null;
    } catch (e) {
      print("❌ Error in _getCoordinatesFromAddress: $e");
      return null;
    }
  }

  // ✅ FIXED: Set stop coordinates using Google API
  void _setStopCoordinates(String address, int stopIndex) async {
    if (address.length < 3) return;

    try {
      final latLng = await _getCoordinatesFromAddress(address);

      if (latLng != null) {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue("stop_${stopIndex}_latitude", latLng.lat.toString());
        ref
            .read(orderCacheProvider.notifier)
            .saveValue("stop_${stopIndex}_longitude", latLng.lng.toString());

        print("✅ Stop $stopIndex Coordinates: ${latLng.lat}, ${latLng.lng}");
      } else {
        print("❌ No coordinates found for stop $stopIndex: $address");
        // Don't save any coordinates - let it be empty
      }
    } catch (e) {
      print("❌ Error getting stop coordinates: $e");
    }
  }

  void _addCacheListeners() {
    _addSingleStopListeners();

    if (isMultiStopEnabled) {
      _addMultiStopListeners();
    }
  }

  void _addSingleStopListeners() {
    weightController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("total_weight", weightController.text);
      _checkFormFilled();
    });

    quantityController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("quantity", quantityController.text);
      _checkFormFilled();
    });

    declaredValueController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("declared_value", declaredValueController.text);
      _checkFormFilled();
    });

    contactnameController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("pickup_name", contactnameController.text);
      _checkFormFilled();
    });

    phoneController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("pickup_phone", phoneController.text);
      _checkFormFilled();
    });

    address1Controller.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("pickup_address1", address1Controller.text);
      _checkFormFilled();
    });

    address2Controller.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("pickup_address2", address2Controller.text);
      _checkFormFilled();
    });

    cityController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("pickup_city", cityController.text);
      _checkFormFilled();
    });

    stateController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("pickup_state", stateController.text);
      _checkFormFilled();
    });

    postalController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("pickup_postal", postalController.text);
      _checkFormFilled();
    });

    emailController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("pickup_email", emailController.text);
      _checkFormFilled();
    });

    notesController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("pickup_notes", notesController.text);
      _checkFormFilled();
    });

    contactnameDeliveryController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("delivery_name", contactnameDeliveryController.text);
      _checkFormFilled();
    });

    phoneDeliveryController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("delivery_phone", phoneDeliveryController.text);
      _checkFormFilled();
    });

    address1DeliveryController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("delivery_address1", address1DeliveryController.text);
      _checkFormFilled();
    });

    address2DeliveryController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("delivery_address2", address2DeliveryController.text);
      _checkFormFilled();
    });

    cityDeliveryController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("delivery_city", cityDeliveryController.text);
      _checkFormFilled();
    });

    stateDeliveryController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("delivery_state", stateDeliveryController.text);
      _checkFormFilled();
    });

    postalDeliveryController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("delivery_postal", postalDeliveryController.text);
      _checkFormFilled();
    });

    emailDeliveryController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("delivery_email", emailDeliveryController.text);
      _checkFormFilled();
    });

    notesDeliveryController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("delivery_notes", notesDeliveryController.text);
      _checkFormFilled();
    });
  }

  void _addMultiStopListeners() {
    ref
        .read(orderCacheProvider.notifier)
        .saveValue("route_stops_count", routeStops.length.toString());

    for (int i = 0; i < routeStops.length; i++) {
      final stop = routeStops[i];
      final stopIndex = i + 1;

      ref
          .read(orderCacheProvider.notifier)
          .saveValue("stop_${stopIndex}_type", stop.stopType.toString());

      stop.contactName.addListener(() {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue("stop_${stopIndex}_contact_name", stop.contactName.text);
        _checkFormFilled();
      });

      stop.contactPhone.addListener(() {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue(
              "stop_${stopIndex}_contact_phone",
              stop.contactPhone.text,
            );
        _checkFormFilled();
      });

      stop.quantity.addListener(() {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue("stop_${stopIndex}_quantity", stop.quantity.text);
        _checkFormFilled();
      });

      stop.weight.addListener(() {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue("stop_${stopIndex}_weight", stop.weight.text);
        _checkFormFilled();
      });

      stop.address.addListener(() {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue("stop_${stopIndex}_address", stop.address.text);
        _checkFormFilled();

        // Get coordinates for this stop
        _setStopCoordinates(stop.address.text, stopIndex);
      });

      stop.city.addListener(() {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue("stop_${stopIndex}_city", stop.city.text);
        _checkFormFilled();
      });

      stop.state.addListener(() {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue("stop_${stopIndex}_state", stop.state.text);
        _checkFormFilled();
      });

      stop.postalCode.addListener(() {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue("stop_${stopIndex}_postal_code", stop.postalCode.text);
        _checkFormFilled();
      });

      stop.contactEmail.addListener(() {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue(
              "stop_${stopIndex}_contact_email",
              stop.contactEmail.text,
            );
        _checkFormFilled();
      });

      stop.notes.addListener(() {
        ref
            .read(orderCacheProvider.notifier)
            .saveValue("stop_${stopIndex}_notes", stop.notes.text);
        _checkFormFilled();
      });
    }
  }

  void _checkFormFilled() {
    bool isFilled;

    if (isMultiStopEnabled) {
      if (routeStops.isEmpty) {
        isFilled = false;
      } else {
        isFilled = true;
        for (final stop in routeStops) {
          bool basicFilled =
              stop.contactName.text.trim().isNotEmpty &&
              stop.contactPhone.text.trim().isNotEmpty &&
              stop.address.text.trim().isNotEmpty &&
              stop.city.text.trim().isNotEmpty &&
              stop.postalCode.text.trim().isNotEmpty &&
              stop.contactEmail.text.trim().isNotEmpty &&
              stop.state.text.trim().isNotEmpty;

          if (stop.stopType == StopType.waypoint) {
            isFilled = isFilled && basicFilled;
          } else if (stop.stopType == StopType.pickup) {
            isFilled =
                isFilled &&
                basicFilled &&
                stop.quantity.text.trim().isNotEmpty &&
                stop.weight.text.trim().isNotEmpty;
          } else if (stop.stopType == StopType.dropOff) {
            isFilled = isFilled && basicFilled;
          }

          if (!isFilled) {
            break;
          }
        }
      }
    } else {
      isFilled =
          contactnameController.text.trim().isNotEmpty &&
          phoneController.text.trim().isNotEmpty &&
          address1Controller.text.trim().isNotEmpty &&
          cityController.text.trim().isNotEmpty &&
          stateController.text.trim().isNotEmpty &&
          postalController.text.trim().isNotEmpty &&
          emailController.text.trim().isNotEmpty &&
          //
          contactnameDeliveryController.text.trim().isNotEmpty &&
          phoneDeliveryController.text.trim().isNotEmpty &&
          address1DeliveryController.text.trim().isNotEmpty &&
          cityDeliveryController.text.trim().isNotEmpty &&
          postalDeliveryController.text.trim().isNotEmpty &&
          emailDeliveryController.text.trim().isNotEmpty &&
          stateDeliveryController.text.trim().isNotEmpty;
    }

    if (isFilled != _isFormFilled) {
      setState(() => _isFormFilled = isFilled);
    }
  }

  // Next button handler
  void _onNextPressed() {
    if (isMultiStopEnabled) {
      if (routeStops.length < 2) {
        AppSnackBar.showError(
          context,
          "Multi-stop route requires at least 2 stops",
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Multi-stop route requires at least 2 stops"),
        //     backgroundColor: Colors.red,
        //   ),
        // );
        return;
      }

      for (final stop in routeStops) {
        if (stop.contactName.text.trim().isEmpty ||
            stop.contactPhone.text.trim().isEmpty ||
            stop.address.text.trim().isEmpty ||
            stop.city.text.trim().isEmpty ||
            stop.postalCode.text.trim().isEmpty ||
            stop.contactEmail.text.trim().isEmpty ||
            stop.state.text.trim().isEmpty) {
          AppSnackBar.showError(
            context,
            "Please complete all basic stop information",
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text("Please complete all basic stop information"),
          //     backgroundColor: Colors.red,
          //   ),
          // );
          return;
        }

        if (stop.stopType == StopType.waypoint) {
          continue;
        } else if (stop.stopType == StopType.pickup) {
          if (stop.quantity.text.trim().isEmpty ||
              stop.weight.text.trim().isEmpty) {
            AppSnackBar.showError(
              context,
              "Please enter quantity and weight for Pickup stop",
            );

            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //       "Please enter quantity and weight for Pickup stop",
            //     ),
            //     backgroundColor: Colors.red,
            //   ),
            // );
            return;
          }
        } else if (stop.stopType == StopType.dropOff) {
          print("DropOff stop - quantity/weight optional");
        }
      }

      _saveMultiStopData();
    } else {
      if (!_isFormFilled) {
        AppSnackBar.showError(context, "Please complete all form fields");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Please complete all form fields"),
        //     backgroundColor: Colors.red,
        //   ),
        // );
        return;
      }

      _saveSingleStopData();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServicePaymentScreen()),
    );
  }

  void _saveMultiStopData() {
    final cache = ref.read(orderCacheProvider.notifier);

    cache.saveValue("route_stops_count", routeStops.length.toString());

    for (int i = 0; i < routeStops.length; i++) {
      final stop = routeStops[i];
      final stopIndex = i + 1;

      cache.saveValue("stop_${stopIndex}_type", stop.stopType.toString());
      cache.saveValue("stop_${stopIndex}_contact_name", stop.contactName.text);
      cache.saveValue(
        "stop_${stopIndex}_contact_phone",
        stop.contactPhone.text,
      );
      cache.saveValue("stop_${stopIndex}_address", stop.address.text);
      cache.saveValue("stop_${stopIndex}_city", stop.city.text);
      cache.saveValue("stop_${stopIndex}_state", stop.state.text);
      cache.saveValue("stop_${stopIndex}_postal_code", stop.postalCode.text);
      cache.saveValue(
        "stop_${stopIndex}_contact_email",
        stop.contactEmail.text,
      );
      cache.saveValue("stop_${stopIndex}_notes", stop.notes.text);

      if (stop.stopType == StopType.waypoint) {
        cache.saveValue("stop_${stopIndex}_quantity", "");
        cache.saveValue("stop_${stopIndex}_weight", "");
      } else {
        cache.saveValue("stop_${stopIndex}_quantity", stop.quantity.text);
        cache.saveValue("stop_${stopIndex}_weight", stop.weight.text);
      }

      if (stop.stopType == StopType.pickup) {
        cache.saveValue("pickup_name", stop.contactName.text);
        cache.saveValue("pickup_phone", stop.contactPhone.text);
        cache.saveValue("pickup_address1", stop.address.text);
        cache.saveValue("pickup_city", stop.city.text);
        cache.saveValue("pickup_state", stop.state.text);
        cache.saveValue("pickup_postal", stop.postalCode.text);
        cache.saveValue("pickup_email", stop.contactEmail.text);
        cache.saveValue("pickup_notes", stop.notes.text);
        cache.saveValue("contact_name", stop.contactName.text);
        cache.saveValue("contact_phone", stop.contactPhone.text);
      } else if (stop.stopType == StopType.dropOff) {
        cache.saveValue("delivery_name", stop.contactName.text);
        cache.saveValue("delivery_phone", stop.contactPhone.text);
        cache.saveValue("delivery_address1", stop.address.text);
        cache.saveValue("delivery_city", stop.city.text);
        cache.saveValue("delivery_state", stop.state.text);
        cache.saveValue("delivery_postal", stop.postalCode.text);
        cache.saveValue("delivery_email", stop.contactEmail.text);
        cache.saveValue("delivery_notes", stop.notes.text);
        cache.saveValue("delivery_contact_name", stop.contactName.text);
        cache.saveValue("delivery_contact_phone", stop.contactPhone.text);
      }
    }
  }

  void _saveSingleStopData() {
    final cache = ref.read(orderCacheProvider.notifier);

    cache.saveValue("pickup_name", contactnameController.text);
    cache.saveValue("pickup_phone", phoneController.text);
    cache.saveValue("pickup_address1", address1Controller.text);
    cache.saveValue("pickup_city", cityController.text.trim());
    cache.saveValue("pickup_state", stateController.text.trim());
    cache.saveValue("pickup_email", emailController.text);
    cache.saveValue("pickup_notes", notesController.text);

    cache.saveValue("delivery_name", contactnameDeliveryController.text);
    cache.saveValue("delivery_phone", phoneDeliveryController.text);
    cache.saveValue("delivery_address1", address1DeliveryController.text);
    cache.saveValue("delivery_city", cityDeliveryController.text.trim());
    cache.saveValue("delivery_state", stateDeliveryController.text.trim());
    cache.saveValue("delivery_email", emailDeliveryController.text);
    cache.saveValue("delivery_notes", notesDeliveryController.text);

    if (address2Controller.text.isNotEmpty) {
      cache.saveValue("pickup_address2", address2Controller.text);
    }
    if (postalController.text.isNotEmpty) {
      cache.saveValue("pickup_postal", postalController.text);
    }
    if (address2DeliveryController.text.isNotEmpty) {
      cache.saveValue("delivery_address2", address2DeliveryController.text);
    }
    if (postalDeliveryController.text.isNotEmpty) {
      cache.saveValue("delivery_postal", postalDeliveryController.text);
    }
  }

  void _addRouteStop() {
    setState(() {
      final newId = routeStops.length + 1;
      final newStop = RouteStop(
        id: newId,
        stopType: StopType.waypoint,
        contactName: TextEditingController(),
        contactPhone: TextEditingController(),
        address: TextEditingController(),
        city: TextEditingController(),
        state: TextEditingController(),
        postalCode: TextEditingController(),
        contactEmail: TextEditingController(),
        notes: TextEditingController(),
        quantity: TextEditingController(),
        weight: TextEditingController(),
      );

      routeStops.add(newStop);
      _addStopListeners(newStop, newId);
    });

    ref
        .read(orderCacheProvider.notifier)
        .saveValue("route_stops_count", routeStops.length.toString());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFormFilled();
    });
  }

  void _addStopListeners(RouteStop stop, int index) {
    stop.contactName.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("stop_${index}_contact_name", stop.contactName.text);
      _checkFormFilled();
    });

    stop.contactPhone.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("stop_${index}_contact_phone", stop.contactPhone.text);
      _checkFormFilled();
    });

    stop.address.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("stop_${index}_address", stop.address.text);
      _checkFormFilled();
      _setStopCoordinates(stop.address.text, index);
    });

    stop.city.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("stop_${index}_city", stop.city.text);
      _checkFormFilled();
    });

    stop.state.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("stop_${index}_state", stop.state.text);
      _checkFormFilled();
    });

    stop.postalCode.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("stop_${index}_postal_code", stop.postalCode.text);
      _checkFormFilled();
    });

    stop.contactEmail.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("stop_${index}_contact_email", stop.contactEmail.text);
      _checkFormFilled();
    });

    stop.notes.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("stop_${index}_notes", stop.notes.text);
      _checkFormFilled();
    });
  }

  void _removeRouteStop(int index) {
    if (routeStops.length > 2) {
      setState(() {
        final removedStop = routeStops[index];
        removedStop.contactName.dispose();
        removedStop.contactPhone.dispose();
        removedStop.address.dispose();
        removedStop.city.dispose();
        removedStop.state.dispose();
        removedStop.postalCode.dispose();
        removedStop.contactEmail.dispose();
        removedStop.notes.dispose();
        removedStop.quantity.dispose();
        removedStop.weight.dispose();

        routeStops.removeAt(index);

        for (int i = 0; i < routeStops.length; i++) {
          routeStops[i].id = i + 1;
        }
      });

      ref
          .read(orderCacheProvider.notifier)
          .saveValue("route_stops_count", routeStops.length.toString());
      _checkFormFilled();
    }
  }

  void _toggleMultiStop(bool value) {
    setState(() {
      isMultiStopEnabled = value;
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("is_multi_stop_enabled", value.toString());

      if (value && routeStops.isEmpty) {
        _initializeMultiStop();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFormFilled();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();

    editlocationFocus.dispose();
    contactnameFocus.dispose();
    locationFocus.dispose();
    phoneFocus.dispose();

    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();

    contactnameController.dispose();
    phoneController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalController.dispose();
    emailController.dispose();
    notesController.dispose();

    contactnameDeliveryController.dispose();
    phoneDeliveryController.dispose();
    address1DeliveryController.dispose();
    address2DeliveryController.dispose();
    cityDeliveryController.dispose();
    stateDeliveryController.dispose();
    postalDeliveryController.dispose();
    emailDeliveryController.dispose();
    notesDeliveryController.dispose();

    weightController.dispose();
    quantityController.dispose();
    declaredValueController.dispose();

    for (final stop in routeStops) {
      stop.contactName.dispose();
      stop.contactPhone.dispose();
      stop.address.dispose();
      stop.city.dispose();
      stop.state.dispose();
      stop.postalCode.dispose();
      stop.contactEmail.dispose();
      stop.notes.dispose();
      stop.quantity.dispose();
      stop.weight.dispose();
    }

    super.dispose();
  }

  void _addDimensionCacheListeners() {
    lengthController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("package_length", lengthController.text);
      _checkFormFilled();
    });

    widthController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("package_width", widthController.text);
      _checkFormFilled();
    });

    heightController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("package_height", heightController.text);
      _checkFormFilled();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color inactiveColor = Colors.transparent;
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMultiStopToggleContainer(),
                        gapH20,

                        if (!isMultiStopEnabled) ...[
                          _sectionTitle("PICKUP LOCATION"),
                          gapH8,
                          _defaultAddressSection(),
                          gapH20,
                          _sectionTitle("DELIVERY LOCATION"),
                          gapH8,
                          _deliveryAddressSection(),
                        ] else ...[
                          _buildMultiStopUI(),
                        ],

                        gapH16,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.electricTeal)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: CustomButton(
                text: "Next",
                backgroundColor: _isFormFilled
                    ? AppColors.electricTeal
                    : inactiveColor,
                borderColor: AppColors.electricTeal,
                textColor: _isFormFilled
                    ? AppColors.pureWhite
                    : AppColors.electricTeal,
                onPressed: _isFormFilled ? _onNextPressed : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiStopToggleContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGray.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enable Multi-Stop Route?",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Add multiple pickup/delivery points for this order",
                    style: TextStyle(fontSize: 10, color: AppColors.mediumGray),
                  ),
                ],
              ),

              Flexible(
                child: PremiumSwitch(
                  value: isMultiStopEnabled,
                  onChanged: _toggleMultiStop,
                ),
              ),

              //  Switch(
              //   value: isMultiStopEnabled,
              //   onChanged: _toggleMultiStop,
              //   activeColor: AppColors.electricTeal,
              // ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiStopUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle("Route Stops"),
            ElevatedButton.icon(
              onPressed: _addRouteStop,
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Stop"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        gapH8,
        ...routeStops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;
          return _buildRouteStopCard(stop, index);
        }).toList(),
      ],
    );
  }

  Widget _buildRouteStopCard(RouteStop stop, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGray.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stop ${stop.id}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              if (routeStops.length > 2)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeRouteStop(index),
                ),
            ],
          ),
          gapH16,
          _buildStopTypeDropdown(stop),
          gapH24,
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: stop.contactName,
                  label: "Contact Name*",
                  icon: Icons.person,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: stop.contactPhone,
                  label: "Contact Phone*",
                  icon: Icons.phone,
                  isNumber: true,
                  maxLength: 11,
                ),
              ),
            ],
          ),
          if (stop.stopType != StopType.waypoint) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: stop.quantity,
                    label: stop.stopType == StopType.pickup
                        ? "Quantity*"
                        : "Quantity (Optional)",
                    icon: Icons.numbers,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    controller: stop.weight,
                    label: stop.stopType == StopType.pickup
                        ? "Weight per Item (kg)*"
                        : "Weight per Item (kg)*",
                    icon: Icons.scale,
                    isNumber: true,
                  ),
                ),
              ],
            ),
          ],
          _buildTextField(
            controller: stop.address,
            label: "Address*",
            icon: Icons.location_on,
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: stop.city,
                  label: "City*",
                  icon: Icons.location_city,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: stop.state,
                  label: "State/Province*",
                  icon: Icons.map,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: stop.postalCode,
                  label: "Postal Code",
                  icon: Icons.numbers,
                  isNumber: true,
                  maxLength: 4,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: stop.contactEmail,
                  label: "Email",
                  icon: Icons.email,
                  isEmail: true,
                ),
              ),
            ],
          ),
          _buildTextField(
            controller: stop.notes,
            label: "Notes / Special Instructions",
            icon: Icons.note,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStopTypeDropdown(RouteStop stop) {
    final stopTypes = StopType.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Stop Type*",
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mediumGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        DropDownContainer(
          fw: FontWeight.normal,
          dialogueScreen: MaterialConditionPopupLeftIcon(
            title: stop.stopType.displayName,
            conditions: stopTypes.map((type) => type.displayName).toList(),
            initialSelectedIndex: stopTypes.indexOf(stop.stopType),
            enableSearch: stopTypes.length > 10,
          ),
          text: stop.stopType.displayName,
          onItemSelected: (value) {
            final selectedStopType = StopType.values.firstWhere(
              (type) => type.displayName == value,
            );

            setState(() {
              stop.stopType = selectedStopType;

              if (selectedStopType == StopType.waypoint) {
                stop.quantity.clear();
                stop.weight.clear();
              }
            });

            ref
                .read(orderCacheProvider.notifier)
                .saveValue("stop_${stop.id}_type", selectedStopType.toString());
            _checkFormFilled();
          },
        ),
      ],
    );
  }

  Widget _defaultAddressSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGray.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH12,
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: contactnameController,
                  label: "Contact Name*",
                  icon: Icons.person,
                ),
              ),
              gapW4,
              Expanded(
                child: _buildTextField(
                  controller: phoneController,
                  label: "Contact Phone*",
                  icon: Icons.phone_android,
                  isNumber: true,
                  maxLength: 11,
                ),
              ),
            ],
          ),
          _buildTextField(
            controller: address1Controller,
            label: "Pickup Address*",
            icon: Icons.location_on,
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: cityController,
                  label: "City*",
                  icon: Icons.location_city_outlined,
                ),
              ),
              gapW4,
              Expanded(
                child: _buildTextField(
                  controller: stateController,
                  label: "State/Province*",
                  icon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: postalController,
                  label: "Postal Code",
                  icon: Icons.numbers,
                  isNumber: true,
                  maxLength: 4,
                ),
              ),
              gapW4,
              Expanded(
                child: _buildTextField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email,
                  isEmail: true,
                ),
              ),
            ],
          ),
          _buildTextField(
            controller: notesController,
            label: "Notes / Special Instructions",
            icon: Icons.note,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _deliveryAddressSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGray.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH12,
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: contactnameDeliveryController,
                  label: "Contact Name*",
                  icon: Icons.person,
                ),
              ),
              gapW4,
              Expanded(
                child: _buildTextField(
                  controller: phoneDeliveryController,
                  label: "Contact Phone*",
                  icon: Icons.phone_android,
                  isNumber: true,
                  maxLength: 11,
                ),
              ),
            ],
          ),
          _buildTextField(
            controller: address1DeliveryController,
            label: "Delivery Address*",
            icon: Icons.location_on,
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: cityDeliveryController,
                  label: "City*",
                  icon: Icons.location_city_outlined,
                ),
              ),
              gapW4,
              Expanded(
                child: _buildTextField(
                  controller: stateDeliveryController,
                  label: "State/Province*",
                  icon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: postalDeliveryController,
                  label: "Postal Code",
                  icon: Icons.numbers,
                  isNumber: true,
                  maxLength: 4,
                ),
              ),
              gapW4,
              Expanded(
                child: _buildTextField(
                  controller: emailDeliveryController,
                  label: "Email",
                  icon: Icons.email,
                  isEmail: true,
                ),
              ),
            ],
          ),
          _buildTextField(
            controller: notesDeliveryController,
            label: "Notes / Special Instructions",
            icon: Icons.note,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isEmail = false,
    bool isNumber = false,
    int maxLines = 1,
    int? maxLength,
  }) {
    return CustomAnimatedTextField(
      controller: controller,
      focusNode: FocusNode(),
      labelText: label,
      hintText: label,
      prefixIcon: icon,
      iconColor: AppColors.electricTeal,
      borderColor: AppColors.electricTeal,
      textColor: AppColors.mediumGray,
      // keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      keyboardType: isNumber
          ? TextInputType.number
          : isEmail
          ? TextInputType.emailAddress
          : TextInputType.text,

      inputFormatters: isNumber
          ? [
              FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ]
          : const [],
      validator: isEmail
          ? (value) {
              if (value == null || value.isEmpty) return null;

              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );

              if (!emailRegex.hasMatch(value.trim())) {
                return "";
              }

              return null;
            }
          : null,
      // validator: isEmail
      //     ? (value) {
      //         if (value == null || value.isEmpty) return null;

      //         if (!value.contains('@') || !value.contains('.')) {
      //           return "";
      //         }
      //         return null;
      //       }
      //     : null,

      // inputFormatters: isNumber
      //     ? [FilteringTextInputFormatter.digitsOnly]
      //     : <TextInputFormatter>[],
      onChanged: (value) {
        _checkFormFilled();
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.darkText,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class RouteStop {
  int id;
  StopType stopType;
  TextEditingController contactName;
  TextEditingController contactPhone;
  TextEditingController address;
  TextEditingController city;
  TextEditingController state;
  TextEditingController postalCode;
  TextEditingController contactEmail;
  TextEditingController notes;
  TextEditingController quantity;
  TextEditingController weight;

  RouteStop({
    required this.id,
    required this.stopType,
    required this.contactName,
    required this.contactPhone,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.contactEmail,
    required this.notes,
    required this.quantity,
    required this.weight,
  });
}

enum StopType {
  pickup('Pickup'),
  waypoint('Waypoint'),
  dropOff('Drop-off');

  final String displayName;
  const StopType(this.displayName);
}

class PremiumSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PremiumSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 58,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: value
              ? LinearGradient(
                  colors: [
                    AppColors.electricTeal,
                    AppColors.electricTeal.withOpacity(0.7),
                  ],
                )
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade300],
                ),
          boxShadow: [
            if (value)
              BoxShadow(
                color: AppColors.electricTeal.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
