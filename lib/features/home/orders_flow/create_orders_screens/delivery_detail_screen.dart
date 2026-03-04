import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
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

  // Single Stop Variables
  String? selectedProductType;
  String? selectedProductTypeName;
  int? selectedProductTypeId;
  String? selectedPackageType;
  String? selectedPackagingTypeName;
  int? selectedPackagingTypeId;
  bool showDimensionsFields = false;

  // Text Controllers
  final TextEditingController weightController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController declaredValueController = TextEditingController();

  // Dimensions controllers
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  // Pickup controllers
  final TextEditingController contactnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Delivery controllers
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

  bool _isFormFilled = false;
  Timer? _debounce;

  late FlutterGooglePlacesSdk places;
  static const String _apiKey = "AIzaSyAvuqv3vjx8JCwe-dKXJWV_ggqraBqIFKs";

  // For live suggestions overlay
  OverlayEntry? _overlayEntry;
  final LayerLink _pickupLayerLink = LayerLink();
  final LayerLink _deliveryLayerLink = LayerLink();
  final List<LayerLink> _stopLayerLinks = [];

  // Har field ke liye alag-alag state variables
  bool _isSelectingSuggestion = false;
  List<AutocompletePrediction> _predictions = [];

  // Current active field ke liye variables
  String? _currentCachePrefix;
  TextEditingController? _currentAddressController;
  TextEditingController? _currentCityController;
  TextEditingController? _currentStateController;
  TextEditingController? _currentPostalController;

  @override
  void initState() {
    super.initState();

    places = FlutterGooglePlacesSdk(_apiKey);

    // Setup listeners for coordinates (background)
    setupPickupListener();
    setupDeliveryListener();

    // Load cached data
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkFormFilled();
      });
    });

    _addDimensionCacheListeners();
    _addCacheListeners();
  }

  void _initializeMultiStop() {
    setState(() {
      // Pehle existing links clear karo
      _stopLayerLinks.clear();
      routeStops.clear();

      // Stop 1 ke liye link add karo
      _stopLayerLinks.add(LayerLink());
      routeStops.add(
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
      );

      // Stop 2 ke liye link add karo
      _stopLayerLinks.add(LayerLink());
      routeStops.add(
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
      );

      _addMultiStopListeners();
    });
  }

  void _loadRouteStopsFromCache(Map<String, dynamic> cache) {
    final stopsCountStr = cache["route_stops_count"]?.toString() ?? "";
    if (stopsCountStr.isNotEmpty) {
      final stopsCount = int.tryParse(stopsCountStr) ?? 0;

      // Pehle existing links clear karo
      _stopLayerLinks.clear();
      routeStops.clear();

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

        // Har stop ke liye naya link add karo
        _stopLayerLinks.add(LayerLink());

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
        routeStops.add(stop);
      }

      _addMultiStopListeners();
    }
  }

  void _loadSingleStopData(Map<String, dynamic> cache) {
    // Load dimensions
    lengthController.text = cache["package_length"]?.toString() ?? "";
    widthController.text = cache["package_width"]?.toString() ?? "";
    heightController.text = cache["package_height"]?.toString() ?? "";

    // Load product type
    final savedProductTypeId = cache["selected_product_type_id"]?.toString();
    if (savedProductTypeId != null) {
      setState(() {
        selectedProductTypeId = int.tryParse(savedProductTypeId);
        selectedProductTypeName = cache["selected_product_type_name"]
            ?.toString();
      });
    }

    // Load package type
    selectedPackageType = cache["selected_package_type"]?.toString();

    // Load packaging type
    final savedPackagingTypeId = cache["selected_packaging_type_id"]
        ?.toString();
    if (savedPackagingTypeId != null) {
      setState(() {
        selectedPackagingTypeId = int.tryParse(savedPackagingTypeId);
        selectedPackagingTypeName = cache["selected_packaging_type_name"]
            ?.toString();
        showDimensionsFields =
            cache["selected_packaging_requires_dimensions"]?.toString() ==
            "true";
      });
    }

    // Load weight, quantity, declared value
    weightController.text = cache["total_weight"]?.toString() ?? "";
    quantityController.text = cache["quantity"]?.toString() ?? "";
    declaredValueController.text = cache["declared_value"]?.toString() ?? "";

    // Load pickup data
    contactnameController.text = cache["pickup_name"]?.toString() ?? "";
    phoneController.text = cache["pickup_phone"]?.toString() ?? "";
    address1Controller.text = cache["pickup_address1"]?.toString() ?? "";
    address2Controller.text = cache["pickup_address2"]?.toString() ?? "";
    cityController.text = cache["pickup_city"]?.toString() ?? "";
    stateController.text = cache["pickup_state"]?.toString() ?? "";
    postalController.text = cache["pickup_postal"]?.toString() ?? "";
    emailController.text = cache["pickup_email"]?.toString() ?? "";
    notesController.text = cache["pickup_notes"]?.toString() ?? "";

    // Load delivery data
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

  // LIVE SUGGESTIONS METHODS

  void setupAddressSearch({
    required TextEditingController addressController,
    required TextEditingController cityController,
    required TextEditingController stateController,
    required TextEditingController postalController,
    required String cachePrefix,
    required LayerLink layerLink,
  }) {
    // Remove old listener if any
    addressController.removeListener(
      () => _onAddressChanged(
        addressController,
        cityController,
        stateController,
        postalController,
        cachePrefix,
        layerLink,
      ),
    );

    // Add new listener with all parameters
    addressController.addListener(
      () => _onAddressChanged(
        addressController,
        cityController,
        stateController,
        postalController,
        cachePrefix,
        layerLink,
      ),
    );
  }

  void _onAddressChanged(
    TextEditingController addressController,
    TextEditingController cityController,
    TextEditingController stateController,
    TextEditingController postalController,
    String cachePrefix,
    LayerLink layerLink,
  ) {
    final input = addressController.text.trim();

    if (_isSelectingSuggestion) {
      return; // Agar suggestion select kar rahe hain to kuch mat karo
    }

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (input.isEmpty) {
        _removeOverlay();
        return;
      }

      try {
        final result = await places.findAutocompletePredictions(
          input,
          countries: ["ZA"], 
        );

        _predictions = result.predictions;

        if (_predictions.isNotEmpty && mounted) {
          // Store current field info for selection
          _currentAddressController = addressController;
          _currentCityController = cityController;
          _currentStateController = stateController;
          _currentPostalController = postalController;
          _currentCachePrefix = cachePrefix;

          _showSuggestionsOverlay(layerLink);
        } else {
          _removeOverlay();
        }
      } catch (e) {
        print("Search error: $e");
        _removeOverlay();
      }
    });
  }

  void _showSuggestionsOverlay(LayerLink link) {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: link,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                prediction.fullText,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: prediction.secondaryText.isNotEmpty
                                  ? Text(
                                      prediction.secondaryText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    )
                                  : null,
                              onTap: () => _selectSuggestion(prediction),
                            ),
                            if (index < _predictions.length - 1)
                              const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.power, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Powered by Google',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _selectSuggestion(AutocompletePrediction prediction) async {
    _isSelectingSuggestion = true;
    _removeOverlay();

    try {
      final detail = await places.fetchPlace(
        prediction.placeId,
        fields: [
          PlaceField.Address,
          PlaceField.AddressComponents,
          PlaceField.Location,
        ],
      );

      final components = detail.place?.addressComponents ?? [];
      String city = "", state = "", postal = "";

      for (final c in components) {
        print("Component: ${c.name}, Types: ${c.types}");
        if (c.types.contains("locality")) city = c.name;
        if (c.types.contains("administrative_area_level_1")) state = c.name;
        if (c.types.contains("postal_code")) postal = c.name;
      }

      if (mounted && _currentAddressController != null) {
        // Update fields
        _currentAddressController!.text =
            detail.place?.address ?? prediction.fullText;
        _currentCityController?.text = city;
        _currentStateController?.text = state;
        _currentPostalController?.text = postal;

        // Save coordinates
        final latLng = detail.place?.latLng;
        if (latLng != null && _currentCachePrefix != null) {
          ref
              .read(orderCacheProvider.notifier)
              .saveValue(
                "${_currentCachePrefix}_latitude",
                latLng.lat.toString(),
              );
          ref
              .read(orderCacheProvider.notifier)
              .saveValue(
                "${_currentCachePrefix}_longitude",
                latLng.lng.toString(),
              );
        }

        _checkFormFilled();
      }

      // Reset flag after a delay
      Future.delayed(const Duration(milliseconds: 300), () {
        _isSelectingSuggestion = false;
      });
    } catch (e) {
      print("Error fetching place details: $e");
      _isSelectingSuggestion = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching address details')),
        );
      }
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Get coordinates from address (for background listeners)
  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      final predictions = await places.findAutocompletePredictions(
        address,
        countries: ["ZA"],
      );

      if (predictions.predictions.isEmpty) return null;

      final placeId = predictions.predictions.first.placeId;
      final placeDetails = await places.fetchPlace(
        placeId,
        fields: [PlaceField.Location],
      );

      return placeDetails.place?.latLng;
    } catch (e) {
      print("Error getting coordinates: $e");
      return null;
    }
  }

  // Pickup listener for coordinates (background)
  void setupPickupListener() {
    address1Controller.addListener(() async {
      final input = address1Controller.text.trim();
      if (input.length < 3 || _isSelectingSuggestion) return;

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
          }
        } catch (e) {
          print("❌ Error getting pickup coordinates: $e");
        }
      });
    });
  }

  // Delivery listener for coordinates (background)
  void setupDeliveryListener() {
    address1DeliveryController.addListener(() async {
      final input = address1DeliveryController.text.trim();
      if (input.length < 3 || _isSelectingSuggestion) return;

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
          }
        } catch (e) {
          print("❌ Error getting delivery coordinates: $e");
        }
      });
    });
  }

  // Set stop coordinates (background)
  void _setStopCoordinates(String address, int stopIndex) async {
    if (address.length < 3 || _isSelectingSuggestion) return;

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
    weightController.addListener(() => _saveAndCheck());
    quantityController.addListener(() => _saveAndCheck());
    declaredValueController.addListener(() => _saveAndCheck());
    contactnameController.addListener(() => _saveAndCheck());
    phoneController.addListener(() => _saveAndCheck());
    address1Controller.addListener(() => _saveAndCheck());
    address2Controller.addListener(() => _saveAndCheck());
    cityController.addListener(() => _saveAndCheck());
    stateController.addListener(() => _saveAndCheck());
    postalController.addListener(() => _saveAndCheck());
    emailController.addListener(() => _saveAndCheck());
    notesController.addListener(() => _saveAndCheck());
    contactnameDeliveryController.addListener(() => _saveAndCheck());
    phoneDeliveryController.addListener(() => _saveAndCheck());
    address1DeliveryController.addListener(() => _saveAndCheck());
    address2DeliveryController.addListener(() => _saveAndCheck());
    cityDeliveryController.addListener(() => _saveAndCheck());
    stateDeliveryController.addListener(() => _saveAndCheck());
    postalDeliveryController.addListener(() => _saveAndCheck());
    emailDeliveryController.addListener(() => _saveAndCheck());
    notesDeliveryController.addListener(() => _saveAndCheck());
  }

  void _saveAndCheck() {
    _saveSingleStopData();
    _checkFormFilled();
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

      stop.contactName.addListener(() => _saveStopAndCheck(stop, stopIndex));
      stop.contactPhone.addListener(() => _saveStopAndCheck(stop, stopIndex));
      stop.quantity.addListener(() => _saveStopAndCheck(stop, stopIndex));
      stop.weight.addListener(() => _saveStopAndCheck(stop, stopIndex));
      stop.address.addListener(() {
        _saveStopAndCheck(stop, stopIndex);
        _setStopCoordinates(stop.address.text, stopIndex);
      });
      stop.city.addListener(() => _saveStopAndCheck(stop, stopIndex));
      stop.state.addListener(() => _saveStopAndCheck(stop, stopIndex));
      stop.postalCode.addListener(() => _saveStopAndCheck(stop, stopIndex));
      stop.contactEmail.addListener(() => _saveStopAndCheck(stop, stopIndex));
      stop.notes.addListener(() => _saveStopAndCheck(stop, stopIndex));
    }
  }

  void _saveStopAndCheck(RouteStop stop, int stopIndex) {
    final cache = ref.read(orderCacheProvider.notifier);
    cache.saveValue("stop_${stopIndex}_contact_name", stop.contactName.text);
    cache.saveValue("stop_${stopIndex}_contact_phone", stop.contactPhone.text);
    cache.saveValue("stop_${stopIndex}_quantity", stop.quantity.text);
    cache.saveValue("stop_${stopIndex}_weight", stop.weight.text);
    cache.saveValue("stop_${stopIndex}_address", stop.address.text);
    cache.saveValue("stop_${stopIndex}_city", stop.city.text);
    cache.saveValue("stop_${stopIndex}_state", stop.state.text);
    cache.saveValue("stop_${stopIndex}_postal_code", stop.postalCode.text);
    cache.saveValue("stop_${stopIndex}_contact_email", stop.contactEmail.text);
    cache.saveValue("stop_${stopIndex}_notes", stop.notes.text);
    _checkFormFilled();
  }

  void _addDimensionCacheListeners() {
    lengthController.addListener(() => _saveDimensionAndCheck());
    widthController.addListener(() => _saveDimensionAndCheck());
    heightController.addListener(() => _saveDimensionAndCheck());
  }

  void _saveDimensionAndCheck() {
    final cache = ref.read(orderCacheProvider.notifier);
    cache.saveValue("package_length", lengthController.text);
    cache.saveValue("package_width", widthController.text);
    cache.saveValue("package_height", heightController.text);
    _checkFormFilled();
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
          } else {
            isFilled = isFilled && basicFilled;
          }

          if (!isFilled) break;
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

  void _onNextPressed() {
    if (isMultiStopEnabled) {
      if (routeStops.length < 2) {
        AppSnackBar.showError(
          context,
          "Multi-stop route requires at least 2 stops",
        );
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
          return;
        }

        if (stop.stopType == StopType.pickup) {
          if (stop.quantity.text.trim().isEmpty ||
              stop.weight.text.trim().isEmpty) {
            AppSnackBar.showError(
              context,
              "Please enter quantity and weight for Pickup stop",
            );
            return;
          }
        }
      }

      _saveMultiStopData();
    } else {
      if (!_isFormFilled) {
        AppSnackBar.showError(context, "Please complete all form fields");
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
      cache.saveValue("stop_${stopIndex}_quantity", stop.quantity.text);
      cache.saveValue("stop_${stopIndex}_weight", stop.weight.text);

      if (stop.stopType == StopType.pickup) {
        cache.saveValue("pickup_name", stop.contactName.text);
        cache.saveValue("pickup_phone", stop.contactPhone.text);
        cache.saveValue("pickup_address1", stop.address.text);
        cache.saveValue("pickup_city", stop.city.text);
        cache.saveValue("pickup_state", stop.state.text);
        cache.saveValue("pickup_postal", stop.postalCode.text);
        cache.saveValue("pickup_email", stop.contactEmail.text);
        cache.saveValue("pickup_notes", stop.notes.text);
      } else if (stop.stopType == StopType.dropOff) {
        cache.saveValue("delivery_name", stop.contactName.text);
        cache.saveValue("delivery_phone", stop.contactPhone.text);
        cache.saveValue("delivery_address1", stop.address.text);
        cache.saveValue("delivery_city", stop.city.text);
        cache.saveValue("delivery_state", stop.state.text);
        cache.saveValue("delivery_postal", stop.postalCode.text);
        cache.saveValue("delivery_email", stop.contactEmail.text);
        cache.saveValue("delivery_notes", stop.notes.text);
      }
    }
  }

  void _saveSingleStopData() {
    final cache = ref.read(orderCacheProvider.notifier);

    cache.saveValue("pickup_name", contactnameController.text);
    cache.saveValue("pickup_phone", phoneController.text);
    cache.saveValue("pickup_address1", address1Controller.text);
    cache.saveValue("pickup_address2", address2Controller.text);
    cache.saveValue("pickup_city", cityController.text.trim());
    cache.saveValue("pickup_state", stateController.text.trim());
    cache.saveValue("pickup_postal", postalController.text);
    cache.saveValue("pickup_email", emailController.text);
    cache.saveValue("pickup_notes", notesController.text);

    cache.saveValue("delivery_name", contactnameDeliveryController.text);
    cache.saveValue("delivery_phone", phoneDeliveryController.text);
    cache.saveValue("delivery_address1", address1DeliveryController.text);
    cache.saveValue("delivery_address2", address2DeliveryController.text);
    cache.saveValue("delivery_city", cityDeliveryController.text.trim());
    cache.saveValue("delivery_state", stateDeliveryController.text.trim());
    cache.saveValue("delivery_postal", postalDeliveryController.text);
    cache.saveValue("delivery_email", emailDeliveryController.text);
    cache.saveValue("delivery_notes", notesDeliveryController.text);
  }

  void _addRouteStop() {
    setState(() {
      final newId = routeStops.length + 1;
      _stopLayerLinks.add(LayerLink());
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFormFilled());
  }

  void _addStopListeners(RouteStop stop, int index) {
    stop.contactName.addListener(() => _saveStopAndCheck(stop, index));
    stop.contactPhone.addListener(() => _saveStopAndCheck(stop, index));
    stop.address.addListener(() {
      _saveStopAndCheck(stop, index);
      _setStopCoordinates(stop.address.text, index);
    });
    stop.city.addListener(() => _saveStopAndCheck(stop, index));
    stop.state.addListener(() => _saveStopAndCheck(stop, index));
    stop.postalCode.addListener(() => _saveStopAndCheck(stop, index));
    stop.contactEmail.addListener(() => _saveStopAndCheck(stop, index));
    stop.notes.addListener(() => _saveStopAndCheck(stop, index));
    stop.quantity.addListener(() => _saveStopAndCheck(stop, index));
    stop.weight.addListener(() => _saveStopAndCheck(stop, index));
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
        _stopLayerLinks.removeAt(index);

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
      } else if (!value) {
        // Single mode mein jaate waqt stops clear karo
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
        routeStops.clear();
        _stopLayerLinks.clear();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFormFilled());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();

    // Dispose all controllers
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

  @override
  Widget build(BuildContext context) {
    // Setup address search for pickup and delivery (Standard mode)
    if (!isMultiStopEnabled) {
      // Pickup field setup
      setupAddressSearch(
        addressController: address1Controller,
        cityController: cityController,
        stateController: stateController,
        postalController: postalController,
        cachePrefix: "pickup",
        layerLink: _pickupLayerLink,
      );

      // Delivery field setup
      setupAddressSearch(
        addressController: address1DeliveryController,
        cityController: cityDeliveryController,
        stateController: stateDeliveryController,
        postalController: postalDeliveryController,
        cachePrefix: "delivery",
        layerLink: _deliveryLayerLink,
      );
    }

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
                        const SizedBox(height: 20),

                        if (!isMultiStopEnabled) ...[
                          _sectionTitle("PICKUP LOCATION"),
                          const SizedBox(height: 8),
                          _defaultAddressSection(),
                          const SizedBox(height: 20),
                          _sectionTitle("DELIVERY LOCATION"),
                          const SizedBox(height: 8),
                          _deliveryAddressSection(),
                        ] else ...[
                          _buildMultiStopUI(),
                        ],

                        const SizedBox(height: 16),
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
                    : Colors.transparent,
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
      child: Row(
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
                "Add multiple pickup/delivery points",
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
        ],
      ),
    );
  }

  Widget _buildMultiStopUI() {
    // Setup address search for each stop
    for (int i = 0; i < routeStops.length; i++) {
      final stop = routeStops[i];
      setupAddressSearch(
        addressController: stop.address,
        cityController: stop.city,
        stateController: stop.state,
        postalController: stop.postalCode,
        cachePrefix: "stop_${stop.id}",
        layerLink: _stopLayerLinks[i],
      );
    }

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
        const SizedBox(height: 8),
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
          const SizedBox(height: 16),
          _buildStopTypeDropdown(stop),
          const SizedBox(height: 24),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: stop.quantity,
                    label: stop.stopType == StopType.pickup
                        ? "Quantity*"
                        : "Quantity",
                    icon: Icons.numbers,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    controller: stop.weight,
                    label: stop.stopType == StopType.pickup
                        ? "Weight (kg)*"
                        : "Weight (kg)",
                    icon: Icons.scale,
                    isNumber: true,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Address field with its specific link
          CompositedTransformTarget(
            link: index < _stopLayerLinks.length
                ? _stopLayerLinks[index]
                : LayerLink(),
            child: _buildTextField(
              controller: stop.address,
              label: "Address*",
              icon: Icons.location_on,
              hintText: "Start typing to search...",
            ),
          ),
          const SizedBox(height: 16),
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
                  label: "State*",
                  icon: Icons.map,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: stop.postalCode,
                  label: "Postal Code",
                  icon: Icons.numbers,
                  isNumber: true,
                  maxLength: 5,
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
          const SizedBox(height: 16),
          _buildTextField(
            controller: stop.notes,
            label: "Notes",
            icon: Icons.note,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStopTypeDropdown(RouteStop stop) {
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
            conditions: StopType.values
                .map((type) => type.displayName)
                .toList(),
            initialSelectedIndex: StopType.values.indexOf(stop.stopType),
            enableSearch: false,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: contactnameController,
                  label: "Contact Name*",
                  icon: Icons.person,
                ),
              ),
              const SizedBox(width: 4),
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
          const SizedBox(height: 16),
          CompositedTransformTarget(
            link: _pickupLayerLink,
            child: _buildTextField(
              controller: address1Controller,
              label: "Pickup Address*",
              icon: Icons.location_on,
              hintText: "Start typing to search...",
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: cityController,
                  label: "City*",
                  icon: Icons.location_city_outlined,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildTextField(
                  controller: stateController,
                  label: "State*",
                  icon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: postalController,
                  label: "Postal Code",
                  icon: Icons.numbers,
                  isNumber: true,
                  maxLength: 5,
                ),
              ),
              const SizedBox(width: 4),
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
          const SizedBox(height: 16),
          _buildTextField(
            controller: notesController,
            label: "Notes",
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: contactnameDeliveryController,
                  label: "Contact Name*",
                  icon: Icons.person,
                ),
              ),
              const SizedBox(width: 4),
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
          const SizedBox(height: 16),
          CompositedTransformTarget(
            link: _deliveryLayerLink,
            child: _buildTextField(
              controller: address1DeliveryController,
              label: "Delivery Address*",
              icon: Icons.location_on,
              hintText: "Start typing to search...",
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: cityDeliveryController,
                  label: "City*",
                  icon: Icons.location_city_outlined,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildTextField(
                  controller: stateDeliveryController,
                  label: "State*",
                  icon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: postalDeliveryController,
                  label: "Postal Code",
                  icon: Icons.numbers,
                  isNumber: true,
                  maxLength: 5,
                ),
              ),
              const SizedBox(width: 4),
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
          const SizedBox(height: 16),
          _buildTextField(
            controller: notesDeliveryController,
            label: "Notes",
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
    String? hintText,
  }) {
    return CustomAnimatedTextField(
      controller: controller,
      focusNode: FocusNode(),
      labelText: label,
      hintText: hintText ?? label,
      prefixIcon: icon,
      iconColor: AppColors.electricTeal,
      borderColor: AppColors.electricTeal,
      textColor: AppColors.mediumGray,
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
          : [],
      validator: isEmail
          ? (value) {
              if (value == null || value.isEmpty) return null;
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              return emailRegex.hasMatch(value.trim()) ? null : "";
            }
          : null,
      onChanged: (value) => _checkFormFilled(),
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
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.electricTeal.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
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
