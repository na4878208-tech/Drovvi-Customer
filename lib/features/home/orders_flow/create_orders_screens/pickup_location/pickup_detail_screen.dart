// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logisticscustomer/export.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/order_cache_provider.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/pickup_location/dropdown.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/pickup_location/dropdown/product_type_controller.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/pickup_location/dropdown/product_type_modal.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/pickup_location/pickup_controller.dart';

class Step1Screen extends ConsumerStatefulWidget {
  const Step1Screen({super.key});

  @override
  ConsumerState<Step1Screen> createState() => _Step1ScreenState();
}

class _Step1ScreenState extends ConsumerState<Step1Screen> {
  String? selectedCountry;
  String? countryError;

  // New Product Type Variables
  String? selectedProductType;
  String? selectedProductTypeName;
  int? selectedProductTypeId;
  String? productTypeError;

  String? selectedPackageType;
  String? packageTypeError;
  // Packaging Type Variables
  String? selectedPackagingTypeName;
  int? selectedPackagingTypeId;
  String? packagingTypeError;

  List<String> staticCountries = ["Pakistan", "India", "USA", "UK", "UAE"];
  List<String> packageTypes = [
    "Box",
    "Envelope",
    "Tube",
    "Pallet",
    "Crate",
    "Bag",
    "Roll",
    "Other",
  ];

  // Text Controllers for product info
  final TextEditingController weightController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController declaredValueController = TextEditingController();
  // Dimensions variables
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  final FocusNode weightFocus = FocusNode();
  final FocusNode quantityFocus = FocusNode();
  final FocusNode declaredValueFocus = FocusNode();

  final FocusNode lengthFocus = FocusNode();
  final FocusNode widthFocus = FocusNode();
  final FocusNode heightFocus = FocusNode();

  void _validateFields() {
    // Product Type validation
    if (selectedProductTypeId == null) {
      productTypeError = "Please select a product type";
    } else {
      productTypeError = null;
    }

    // Packaging Type validation (changed from Package Type)
    if (selectedPackagingTypeId == null) {
      packagingTypeError = "Please select a packaging type";
    } else {
      packagingTypeError = null;
    }

    // Country validation
    if (selectedCountry == null || selectedCountry!.isEmpty) {
      countryError = "Please select a country";
    } else {
      countryError = null;
    }
  }

  late FlutterGooglePlacesSdk places;

  String editorMode = "";
  bool showEditor = false;
  int selectedCardIndex = 0;
  String selectedAddress = "";

  final TextEditingController contactnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalController = TextEditingController();

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

  final FocusNode editlocationFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode locationFocus = FocusNode();
  final FocusNode contactnameFocus = FocusNode();

  bool _isFormFilled = false;
  bool showDimensionsFields = false; // Added this

  @override
  void initState() {
    super.initState();

    places = FlutterGooglePlacesSdk("AIzaSyBrF_4PwauOkQ_RS8iGYhAW1NIApp3IEf0");

    // setupPickupListener();
    // setupDeliveryListener();

    // LOAD CACHED DATA
    Future.microtask(() {
      final cache = ref.read(
        orderCacheProvider,
      ); // Moved this to top - FIXED ISSUE 1
      selectedAddress = cache["default_selected_address"] ?? "";

      // Load dimensions from cache
      final savedLength = cache["package_length"];
      final savedWidth = cache["package_width"];
      final savedHeight = cache["package_height"];
      if (savedLength != null) lengthController.text = savedLength;
      if (savedWidth != null) widthController.text = savedWidth;
      if (savedHeight != null) heightController.text = savedHeight;

      ref.read(defaultAddressControllerProvider.notifier).loadDefaultAddress();
      ref.read(allAddressControllerProvider.notifier).loadAllAddress();
      ref.read(productTypeControllerProvider.notifier).loadProductTypes();
      ref.read(packagingTypeControllerProvider.notifier).loadPackagingTypes();

      // Load product type from cache
      final savedProductTypeId = cache["selected_product_type_id"];
      final savedProductTypeName = cache["selected_product_type_name"];

      if (savedProductTypeId != null) {
        setState(() {
          selectedProductTypeId = int.tryParse(savedProductTypeId);
          selectedProductTypeName = savedProductTypeName;
        });
      }

      // Load package type from cache
      final savedPackageType = cache["selected_package_type"];
      if (savedPackageType != null) {
        setState(() {
          selectedPackageType = savedPackageType;
        });
      }

      // Load packaging type from cache
      final savedPackagingTypeId = cache["selected_packaging_type_id"];
      final savedPackagingTypeName = cache["selected_packaging_type_name"];
      final savedRequiresDimensions =
          cache["selected_packaging_requires_dimensions"];

      if (savedPackagingTypeId != null) {
        setState(() {
          selectedPackagingTypeId = int.tryParse(savedPackagingTypeId);
          selectedPackagingTypeName = savedPackagingTypeName;

          // Check if dimensions should be shown - FIXED ISSUE 2
          if (savedRequiresDimensions != null) {
            showDimensionsFields = savedRequiresDimensions == "true";
          }
        });
      }

      // Load product info from cache
      final savedWeight = cache["total_weight"];
      final savedQuantity = cache["quantity"];
      final savedDeclaredValue = cache["declared_value"];

      if (savedWeight != null) weightController.text = savedWeight;
      if (savedQuantity != null) quantityController.text = savedQuantity;
      if (savedDeclaredValue != null) {
        declaredValueController.text = savedDeclaredValue;
      }

      // Load pickup info from cache
      contactnameController.text = cache["pickup_name"] ?? "";
      phoneController.text = cache["pickup_phone"] ?? "";
      address1Controller.text = cache["pickup_address1"] ?? "";
      address2Controller.text = cache["pickup_address2"] ?? "";
      cityController.text = cache["pickup_city"] ?? "";
      stateController.text = cache["pickup_state"] ?? "";
      postalController.text = cache["pickup_postal"] ?? "";

      // Load delivery info from cache
      contactnameDeliveryController.text = cache["delivery_name"] ?? "";
      phoneDeliveryController.text = cache["delivery_phone"] ?? "";
      address1DeliveryController.text = cache["delivery_address1"] ?? "";
      address2DeliveryController.text = cache["delivery_address2"] ?? "";
      cityDeliveryController.text = cache["delivery_city"] ?? "";
      stateDeliveryController.text = cache["delivery_state"] ?? "";
      postalDeliveryController.text = cache["delivery_postal"] ?? "";
    });

    _addDimensionCacheListeners();
    // LISTENERS FOR CACHING
    _addCacheListeners(); // Added this
  }
  void _addCacheListeners() {
    // Product info listeners
    weightController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("total_weight", weightController.text);
      _checkFormFilled();
      _calculatePriceWithWeight(weightController.text);
      _updateTotalWeightBasedOnQuantity(); // ADDED THIS
    });

    quantityController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("quantity", quantityController.text);
      _checkFormFilled();
      _updateTotalWeightBasedOnQuantity(); // ADDED THIS
    });

    declaredValueController.addListener(() {
      ref
          .read(orderCacheProvider.notifier)
          .saveValue("declared_value", declaredValueController.text);
      _checkFormFilled();
    });

    // Pickup listeners
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

    // Delivery listeners
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
  }

  void _checkFormFilled() {
    final cache = ref.read(orderCacheProvider);
    final weight = cache["total_weight"] ?? "";
    final quantity = cache["quantity"] ?? "";
    final declaredValue = cache["declared_value"] ?? "";

    bool isFilled =
        selectedProductTypeId != null &&
        selectedPackagingTypeId != null &&
        selectedPackageType != null &&
        weight.isNotEmpty &&
        quantity.isNotEmpty &&
        declaredValue.isNotEmpty &&
        contactnameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        address1Controller.text.isNotEmpty &&
        address2Controller.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        postalController.text.isNotEmpty &&
        contactnameDeliveryController.text.isNotEmpty &&
        phoneDeliveryController.text.isNotEmpty &&
        address1DeliveryController.text.isNotEmpty &&
        address2DeliveryController.text.isNotEmpty &&
        cityDeliveryController.text.isNotEmpty &&
        stateDeliveryController.text.isNotEmpty &&
        postalDeliveryController.text.isNotEmpty;

    // Check dimensions if required
    if (showDimensionsFields) {
      isFilled =
          isFilled &&
          lengthController.text.isNotEmpty &&
          widthController.text.isNotEmpty &&
          heightController.text.isNotEmpty;
    }

    if (isFilled != _isFormFilled) {
      setState(() => _isFormFilled = isFilled);
    }
  }

  void _calculatePrice(double valueMultiplier) {
    final cache = ref.read(orderCacheProvider);
    final weightStr = cache["total_weight"];
    final weight = double.tryParse(weightStr ?? "0") ?? 0;

    if (weight > 0) {
      _calculatePriceWithWeight(weight.toString(), valueMultiplier);
    }
  }

  void _calculatePriceWithWeight(String weightStr, [double? multiplier]) {
    final weight = double.tryParse(weightStr) ?? 0;
    if (weight <= 0) return;

    double valueMultiplier = multiplier ?? 1.0;

    if (multiplier == null) {
      final cache = ref.read(orderCacheProvider);
      final savedMultiplier = cache["selected_product_value_multiplier"];
      valueMultiplier = double.tryParse(savedMultiplier ?? "1.0") ?? 1.0;
    }

    double baseRatePerKg = 0;
    double calculatedPrice = weight * baseRatePerKg * valueMultiplier;

    ref
        .read(orderCacheProvider.notifier)
        .saveValue("calculated_price", calculatedPrice.toStringAsFixed(2));
  }

  // NEW METHOD: Update total weight based on quantity
  void _updateTotalWeightBasedOnQuantity() {
    final weightText = weightController.text;
    final quantityText = quantityController.text;

    if (weightText.isNotEmpty && quantityText.isNotEmpty) {
      // ignore: unused_local_variable
      final weight = double.tryParse(weightText) ?? 0;
      final quantity = int.tryParse(quantityText) ?? 1;

      // Auto-calculate only if packaging type has fixed weight
      if (selectedPackagingTypeId != null &&
          selectedPackagingTypeId! > 0 &&
          quantity > 0) {
        // We'll update the calculation card via setState
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    weightFocus.dispose();
    quantityFocus.dispose();
    declaredValueFocus.dispose();

    lengthFocus.dispose();
    widthFocus.dispose();
    heightFocus.dispose();

    //

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

    contactnameDeliveryController.dispose();
    phoneDeliveryController.dispose();
    address1DeliveryController.dispose();
    address2DeliveryController.dispose();
    cityDeliveryController.dispose();
    stateDeliveryController.dispose();
    postalDeliveryController.dispose();

    weightController.dispose();
    quantityController.dispose();
    declaredValueController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 16,
                      right: 16,
                      left: 16,
                    ),
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
                            CustomText(
                              txt: "Product & Packaging Information",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        gapH16,

                        // PRODUCT TYPE DROPDOWN
                        Consumer(
                          builder: (context, ref, child) {
                            final productTypeState = ref.watch(
                              productTypeControllerProvider,
                            );

                            return productTypeState.when(
                              data: (categories) {
                                // Create lists for dialog with headers
                                final dialogItems = <String>[];
                                final isHeaderList = <bool>[];
                                final productItems =
                                    <
                                      ProductTypeItem
                                    >[]; // Only products (no headers)

                                for (final category in categories) {
                                  // Add category header
                                  dialogItems.add(category.categoryLabel);
                                  isHeaderList.add(true);

                                  // Add products
                                  for (final product in category.products) {
                                    dialogItems.add(product.name);
                                    isHeaderList.add(false);
                                    productItems.add(product);
                                  }
                                }

                                // Find initial selected index in dialog items
                                int? initialSelectedIndexInDialog;
                                if (selectedProductTypeId != null &&
                                    productItems.isNotEmpty) {
                                  final selectedProduct = productItems
                                      .firstWhere(
                                        (item) =>
                                            item.id == selectedProductTypeId,
                                        orElse: () => productItems.first,
                                      );

                                  // Find index in dialog items (need to consider headers)
                                  for (int i = 0; i < dialogItems.length; i++) {
                                    if (dialogItems[i] ==
                                        selectedProduct.name) {
                                      initialSelectedIndexInDialog = i;
                                      break;
                                    }
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropDownContainer(
                                      fw: FontWeight.normal,
                                      dialogueScreen:
                                          MaterialConditionPopupLeftIcon(
                                            title:
                                                selectedProductTypeId != null &&
                                                    productItems.isNotEmpty
                                                ? productItems
                                                      .firstWhere(
                                                        (item) =>
                                                            item.id ==
                                                            selectedProductTypeId,
                                                        orElse: () =>
                                                            productItems.first,
                                                      )
                                                      .name
                                                : '',
                                            conditions: dialogItems,
                                            isHeaderList: isHeaderList,
                                            initialSelectedIndex:
                                                initialSelectedIndexInDialog,
                                            enableSearch: true,
                                          ),
                                      text:
                                          selectedProductTypeId != null &&
                                              productItems.isNotEmpty
                                          ? productItems
                                                .firstWhere(
                                                  (item) =>
                                                      item.id ==
                                                      selectedProductTypeId,
                                                  orElse: () =>
                                                      productItems.first,
                                                )
                                                .name
                                          : 'Select Product Type',
                                      onItemSelected: (value) {
                                        // Make sure we're not selecting a header
                                        final indexInDialog = dialogItems
                                            .indexOf(value);
                                        if (indexInDialog != -1 &&
                                            !isHeaderList[indexInDialog]) {
                                          final selectedItem = productItems
                                              .firstWhere(
                                                (element) =>
                                                    element.name == value,
                                              );

                                          setState(() {
                                            selectedProductTypeId =
                                                selectedItem.id;
                                            selectedProductTypeName =
                                                selectedItem.name;
                                            productTypeError = null;
                                          });

                                          ref
                                              .read(orderCacheProvider.notifier)
                                              .saveValue(
                                                "selected_product_type_id",
                                                selectedItem.id.toString(),
                                              );
                                          ref
                                              .read(orderCacheProvider.notifier)
                                              .saveValue(
                                                "selected_product_type_name",
                                                selectedItem.name,
                                              );
                                          ref
                                              .read(orderCacheProvider.notifier)
                                              .saveValue(
                                                "selected_product_value_multiplier",
                                                selectedItem.baseValueMultiplier
                                                    .toString(),
                                              );

                                          _validateFields();
                                          _calculatePrice(
                                            selectedItem.baseValueMultiplier,
                                          );
                                        }
                                      },
                                    ),
                                    if (productTypeError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          left: 4,
                                        ),
                                        child: Text(
                                          productTypeError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                              loading: () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.lightBorder,
                                      ),
                                      color: AppColors.pureWhite,
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Loading product types...',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              error: (error, stackTrace) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red),
                                      color: AppColors.pureWhite,
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Error loading product types',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        ref
                                            .read(
                                              productTypeControllerProvider
                                                  .notifier,
                                            )
                                            .loadProductTypes();
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        gapH8,

                        // PACKAGE TYPE DROPDOWN
                        Consumer(
                          builder: (context, ref, child) {
                            final packagingTypeState = ref.watch(
                              packagingTypeControllerProvider,
                            );

                            return packagingTypeState.when(
                              data: (packagingItems) {
                                int? selectedIndex;
                                if (selectedPackagingTypeId != null) {
                                  selectedIndex = packagingItems.indexWhere(
                                    (item) =>
                                        item.id == selectedPackagingTypeId,
                                  );
                                  if (selectedIndex < 0) selectedIndex = 0;
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropDownContainer(
                                      fw: FontWeight.normal,
                                      dialogueScreen:
                                          MaterialConditionPopupLeftIcon2(
                                            title: packagingItems.isNotEmpty
                                                ? packagingItems[selectedIndex ??
                                                          0]
                                                      .name
                                                : '',
                                            conditions: packagingItems
                                                .map((e) => e.name)
                                                .toList(),
                                            items:
                                                packagingItems, // Pass items for search
                                            initialSelectedIndex: selectedIndex,
                                            enableSearch: true,
                                          ),
                                      text:
                                          selectedPackagingTypeId != null &&
                                              packagingItems.isNotEmpty
                                          ? packagingItems
                                                .firstWhere(
                                                  (item) =>
                                                      item.id ==
                                                      selectedPackagingTypeId,
                                                  orElse: () =>
                                                      packagingItems.first,
                                                )
                                                .name
                                          : 'Select Packaging Type',
                                      onItemSelected: (value) {
                                        final selectedItem = packagingItems
                                            .firstWhere(
                                              (element) =>
                                                  element.name == value,
                                            );

                                        setState(() {
                                          selectedPackagingTypeId =
                                              selectedItem.id;
                                          selectedPackagingTypeName =
                                              selectedItem.name;
                                          packagingTypeError = null;
                                          showDimensionsFields =
                                              selectedItem.requiresDimensions;

                                          // AUTOMATIC WEIGHT FILL - FIXED ISSUE
                                          if (selectedItem.fixedWeightKg !=
                                              null) {
                                            weightController.text = selectedItem
                                                .fixedWeightKg!
                                                .toStringAsFixed(2);
                                          }
                                        });

                                        // Save to cache
                                        ref
                                            .read(orderCacheProvider.notifier)
                                            .saveValue(
                                              "selected_packaging_type_id",
                                              selectedItem.id.toString(),
                                            );
                                        ref
                                            .read(orderCacheProvider.notifier)
                                            .saveValue(
                                              "selected_packaging_type_name",
                                              selectedItem.name,
                                            );
                                        ref
                                            .read(orderCacheProvider.notifier)
                                            .saveValue(
                                              "selected_packaging_handling_multiplier",
                                              selectedItem.handlingMultiplier
                                                  .toString(),
                                            );
                                        ref
                                            .read(orderCacheProvider.notifier)
                                            .saveValue(
                                              "selected_packaging_requires_dimensions",
                                              selectedItem.requiresDimensions
                                                  .toString(),
                                            );

                                        if (selectedItem.fixedWeightKg !=
                                            null) {
                                          ref
                                              .read(orderCacheProvider.notifier)
                                              .saveValue(
                                                "selected_packaging_fixed_weight_kg",
                                                selectedItem.fixedWeightKg
                                                    .toString(),
                                              );
                                        }

                                        if (selectedItem.typicalCapacityKg !=
                                            null) {
                                          ref
                                              .read(orderCacheProvider.notifier)
                                              .saveValue(
                                                "selected_packaging_typical_capacity_kg",
                                                selectedItem.typicalCapacityKg
                                                    .toString(),
                                              );
                                        }

                                        if (!selectedItem.requiresDimensions) {
                                          lengthController.clear();
                                          widthController.clear();
                                          heightController.clear();
                                        }

                                        _validateFields();
                                        _calculatePriceWithWeight(
                                          weightController.text,
                                        ); // Calculate price
                                      },
                                    ),

                                    if (packagingTypeError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          left: 4,
                                        ),
                                        child: Text(
                                          packagingTypeError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },

                              loading: () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.lightBorder,
                                      ),
                                      color: AppColors.pureWhite,
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Loading packaging types...',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              error: (error, stackTrace) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red),
                                      color: AppColors.pureWhite,
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Error loading packaging types',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        ref
                                            .read(
                                              packagingTypeControllerProvider
                                                  .notifier,
                                            )
                                            .loadPackagingTypes();
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        gapH24,

                        gapH4,
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                focusNode: weightFocus,
                                controller: weightController,
                                isNumber: true,
                                label: "Total Weight (kg)",
                                icon: Icons.scale,
                              ),
                            ),
                            gapW8,
                            Expanded(
                              child: _buildTextField(
                                focusNode: quantityFocus,
                                controller: quantityController,
                                label: "Quantity",
                                isNumber: true,
                                icon: Icons.numbers,
                              ),
                            ),
                          ],
                        ),

                        _buildTextField(
                          focusNode: declaredValueFocus,
                          controller: declaredValueController,
                          label: "Declared Value (R)",
                          isNumber: true,
                          icon: Icons.attach_money,
                        ),

                        // DIMENSIONS FIELDS
                        if (showDimensionsFields) ...[
                          // SizedBox(height: 6),
                          Text(
                            "Package Dimensions (cm)",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              gapH12,
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      focusNode: lengthFocus,
                                      controller: lengthController,
                                      isNumber: true,
                                      label: "Length (cm)",
                                      icon: Icons.straighten,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _buildTextField(
                                      focusNode: widthFocus,
                                      controller: widthController,
                                      isNumber: true,
                                      label: "Width (cm)",
                                      icon: Icons.width_normal,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      focusNode: heightFocus,
                                      controller: heightController,
                                      isNumber: true,
                                      label: "Height (cm)",
                                      icon: Icons.height,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],

                        gapH8,

                        // CALCULATION CARD
                        _buildCalculationCard(),

                        gapH16,
                      ],
                    ),
                  ),
                  gapH20,

                  // Default Address
                  // _defaultAddressSection(),

                  // Default address end
                  gapH16,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CALCULATION CARD WIDGET
  Widget _buildCalculationCard() {
    double itemWeight = double.tryParse(weightController.text) ?? 0;

    if (selectedPackagingTypeId != null && selectedPackagingTypeId! > 0) {
      final packagingState = ref.watch(packagingTypeControllerProvider);
      packagingState.when(
        data: (items) {
          final selectedItem = items.firstWhere(
            (item) => item.id == selectedPackagingTypeId,
            orElse: () => PackagingTypeItem(
              id: 0,
              name: '',
              description: '',
              fixedWeightKg: null,
              requiresDimensions: false,
              typicalCapacityKg: null,
              handlingMultiplier: 1.0,
              icon: 'box',
            ),
          );

          if (selectedItem.fixedWeightKg != null) {
            itemWeight = selectedItem.fixedWeightKg!;
          }
        },
        loading: () {},
        error: (error, stackTrace) {},
      );
    }

    int quantity = int.tryParse(quantityController.text) ?? 1;
    double totalWeight = itemWeight * quantity;

    String loadType = "Light Load";
    Color loadColor = Colors.black;

    if (totalWeight >= 100) {
      loadType = "Heavy Load";
      loadColor = Colors.redAccent;
    } else if (totalWeight >= 50) {
      loadType = "Medium Load";
      loadColor = const Color.fromARGB(255, 228, 206, 9);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGray.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            border: Border.all(color: AppColors.electricTeal.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              /// 🔥 Gradient Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.electricTeal,
                      AppColors.electricTeal.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.calculate, color: Colors.white, size: 20),
                        SizedBox(width: 4),
                        Text(
                          "Package Calculation",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        loadType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: loadColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _modernCalculationRow(
                      icon: Icons.scale,
                      label: "Item Weight",
                      value: "${itemWeight.toStringAsFixed(2)} kg",
                    ),

                    _modernCalculationRow(
                      icon: Icons.confirmation_number_outlined,
                      label: "Quantity",
                      value: quantity.toString(),
                    ),

                    // const SizedBox(height: 4),
                    Divider(color: AppColors.lightGrayBackground),

                    // const SizedBox(height: 12),

                    /// ⭐ Highlight Total Weight
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.electricTeal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory, color: AppColors.electricTeal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Total Weight",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          Text(
                            "${totalWeight.toStringAsFixed(2)} kg",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.electricTeal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (selectedProductTypeName != null ||
                        selectedPackagingTypeName != null) ...[
                      // const SizedBox(height: 16),
                      Divider(color: AppColors.lightGrayBackground),
                      // const SizedBox(height: 8),
                    ],

                    if (selectedProductTypeName != null)
                      _infoChipRow(
                        icon: Icons.category,
                        text: selectedProductTypeName!,
                        color: Colors.blue,
                      ),

                    if (selectedPackagingTypeName != null)
                      _infoChipRow(
                        icon: Icons.inventory_2_outlined,
                        text: selectedPackagingTypeName!,
                        color: Colors.orange,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernCalculationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.electricTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.electricTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.darkGray),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChipRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,

    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return CustomAnimatedTextField(
      controller: controller,
      // focusNode: FocusNode(),
      focusNode: focusNode,
      labelText: label,
      hintText: label,
      prefixIcon: icon,
      iconColor: AppColors.electricTeal,
      borderColor: AppColors.electricTeal,
      textColor: AppColors.mediumGray,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : <TextInputFormatter>[],
    );
  }
}
