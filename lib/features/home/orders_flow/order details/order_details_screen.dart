import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/common_widgets/custom_text.dart';
import '../../../../constants/colors.dart';
import 'order_details_controller.dart';
import 'order_details_modal.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderDetailsControllerProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        title: CustomText(txt: "Order Details"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.electricTeal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.electricTeal),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: Colors.red.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  "Something went wrong",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final order = data!.order;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: 24),
                _buildOrderProgress(order.status, context),
                const SizedBox(height: 24),
                _buildRouteSection(order),
                const SizedBox(height: 20),
                _buildVehicleDriverSection(order),
                const SizedBox(height: 20),
                _buildOrderItemsSection(order),
                const SizedBox(height: 20),
                _buildPricingSection(order),
                const SizedBox(height: 20),
                if (order.specialInstructions != null)
                  _buildSpecialInstructions(order.specialInstructions!),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // -------------------- ORDER HEADER --------------------
  Widget _buildOrderHeader(order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.electricTeal.withOpacity(0.95),
            AppColors.electricTeal.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightBorder.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Number & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "#${order.orderNumber}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                    Text(
                      order.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Header Cards
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(
                icon: Icons.qr_code_rounded,
                title: "Tracking Code",
                value: order.trackingCode,
                gradient: AppColors.pureWhite,
              ),
              const SizedBox(height: 16),
              _buildHeaderCard(
                icon: Icons.payment_rounded,
                title: "Payment Status",
                value: order.paymentStatus,
                gradient: AppColors.pureWhite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard({
    required IconData icon,
    required String title,
    required String value,
    required Color gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.darkText, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- ORDER PROGRESS --------------------
  Widget _buildOrderProgress(String status, BuildContext context) {
    final statuses = [
      'pending',
      'confirmed',
      'picked',
      'in-transit',
      'completed',
    ];
    final currentIndex = statuses.indexOf(status.toLowerCase());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: AppColors.electricTeal,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Order Progress",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 6,
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6,
                margin: const EdgeInsets.only(top: 20),
                width:
                    (MediaQuery.of(context).size.width - 88) *
                    ((currentIndex + 1) / statuses.length),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.electricTeal,
                      AppColors.electricTeal.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: statuses.asMap().entries.map((entry) {
                  return Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: entry.key <= currentIndex
                              ? AppColors.electricTeal
                              : Colors.white,
                          border: Border.all(
                            color: entry.key <= currentIndex
                                ? AppColors.electricTeal
                                : Colors.grey[300]!,
                            width: 3,
                          ),
                          boxShadow: [
                            if (entry.key <= currentIndex)
                              BoxShadow(
                                color: AppColors.electricTeal.withOpacity(0.25),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: Icon(
                          _getStatusIcon(entry.value),
                          color: entry.key <= currentIndex
                              ? Colors.white
                              : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.value.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: entry.key <= currentIndex
                              ? FontWeight.bold
                              : FontWeight.w400,
                          color: entry.key <= currentIndex
                              ? AppColors.electricTeal
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------- ROUTE SECTION --------------------
  Widget _buildRouteSection(order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.electricTeal,
                      AppColors.electricTeal.withOpacity(0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.route_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                "Route Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// 👇 CONDITION
          order.isMultiStop
              ? _buildMultiStops(order.stops)
              : _buildSingleRoute(order),
        ],
      ),
    );
  }

  Widget _buildSingleRoute(order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStopCard(
          "Pickup",
          order.pickup.contactName,
          order.pickup.address,
          order.pickup.city,
          order.pickup.state,
          order.pickup.contactPhone,
        ),
        const SizedBox(height: 12),
        _buildStopCard(
          "Delivery",
          order.delivery.contactName,
          order.delivery.address,
          order.delivery.city,
          order.delivery.state,
          order.delivery.contactPhone,
        ),
      ],
    );
  }

  Widget _buildMultiStops(List<OrderStop> stops) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stops.map((stop) {
        final statusColor = _stopStatusColor(stop.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _stopTypeIcon(stop.type),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${stop.sequence}. ${stop.type.toUpperCase()}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stop.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// CONTACT
              Text(
                stop.contactName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),

              /// ADDRESS
              Text(
                "${stop.address}, ${stop.city}, ${stop.state}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 10),

              /// META INFO
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _infoChip(Icons.phone, stop.contactPhone),
                  if (stop.quantity != null)
                    _infoChip(Icons.inventory, "Qty: ${stop.quantity}"),
                  if (stop.weightKg != null)
                    _infoChip(Icons.scale, "${stop.weightKg} kg"),
                ],
              ),

              if (stop.arrivalTime != null || stop.departureTime != null)
                const SizedBox(height: 10),

              /// TIME INFO
              if (stop.arrivalTime != null)
                _timeRow("Arrival", stop.arrivalTime!),
              if (stop.departureTime != null)
                _timeRow("Departure", stop.departureTime!),

              if (stop.notes != null && stop.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "📝 ${stop.notes}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.electricTeal),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.electricTeal.withOpacity(0.08),
    );
  }

  Widget _timeRow(String label, String time) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            "$label: $time",
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard(
    String type,
    String contactName,
    String address,
    String city,
    String state,
    String contactPhone,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.electricTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            contactName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            "$address, $city, $state",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 2),
          Text(
            contactPhone,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // -------------------- VEHICLE & DRIVER --------------------
  Widget _buildVehicleDriverSection(order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.9),
                      Colors.orange.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Vehicle & Driver",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDetailItem(
                  icon: Icons.fire_truck_rounded,
                  label: "Vehicle Type",
                  value:
                      "${order.vehicle.make} ${order.vehicle.model} (${order.vehicle.registration})",
                  iconColor: Colors.orange,
                ),
                const Divider(height: 32, color: Colors.grey),
                _buildDetailItem(
                  icon: Icons.person_rounded,
                  label: "Driver",
                  value:
                      "${order.driver.name} (${order.driver.phone}) | Rating: ${order.driver.rating}",
                  iconColor: AppColors.electricTeal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- ORDER ITEMS --------------------
  Widget _buildOrderItemsSection(order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.9),
                      Colors.blue.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Order Items",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...order.items.map((item) {
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Weight: ${item.weight} kg | Quantity: ${item.quantity} | Value: R${item.declaredValue}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // -------------------- PRICING --------------------
  Widget _buildPricingSection(order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.9),
                      Colors.green.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Payment Breakdown",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildPricingRow(
                  label: "Distance (km)",
                  value: order.pricing.distanceKm,
                  showCurrency: false,
                ),
                _buildPricingRow(
                  label: "Estimated Cost",
                  value: order.pricing.estimatedCost,
                ),
                _buildPricingRow(
                  label: "Add-Ons Cost",
                  value: order.pricing.addOnsCost,
                ),
                _buildPricingRow(
                  label: "System Service Fee",
                  value: order.pricing.systemServiceFee,
                ),
                _buildPricingRow(
                  label: "Discount",
                  value: order.pricing.discount,
                ),
                const Divider(height: 32, color: Colors.grey),
                _buildPricingRow(
                  label: "Final Cost",
                  value: order.pricing.finalCost,
                  isTotal: true,
                ),
                _buildPricingRow(label: "Tax", value: order.pricing.taxAmount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- SPECIAL INSTRUCTIONS --------------------
  Widget _buildSpecialInstructions(String instructions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Special Instructions",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.orange[800],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            instructions,
            style: TextStyle(fontSize: 14, color: Colors.orange[900]),
          ),
        ],
      ),
    );
  }

  // -------------------- DETAIL ITEM --------------------
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------- PRICING ROW --------------------
  Widget _buildPricingRow({
    required String label,
    required dynamic value,
    bool isTotal = false,
    bool showCurrency = true, // 👈 NEW FLAG
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            showCurrency ? "R $value" : "$value", // 👈 CONDITION
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.green : AppColors.electricTeal,
            ),
          ),
        ],
      ),
    );
  }

  Color _stopStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;
      case "arrived":
        return Colors.blue;
      case "pending":
        return Colors.orange;
      case "skipped":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _stopTypeIcon(String type) {
    switch (type) {
      case "pickup":
        return Icons.upload_rounded;
      case "drop_off":
        return Icons.download_rounded;
      case "waypoint":
        return Icons.more_horiz_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'picked':
        return Colors.purple;
      case 'in-transit':
        return Colors.amber;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions_rounded;
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'picked':
        return Icons.inventory_2_rounded;
      case 'in-transit':
        return Icons.directions_car_rounded;
      case 'delivered':
        return Icons.verified_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}
