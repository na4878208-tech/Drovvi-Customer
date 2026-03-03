import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/common_widgets/custom_text.dart';
import '../../../../constants/colors.dart';
import 'order_details_controller.dart';
import 'order_details_modal.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  String formatDate(String date) {
    final parsed = DateTime.parse(date).toLocal();
    return "${parsed.day}/${parsed.month}/${parsed.year}  ${parsed.hour}:${parsed.minute}";
  }

  void _showOtpBottomSheet(BuildContext context, order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Routes OTP",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              /// PICKUP OTP
              _otpTile(
                title: "Pickup OTP",
                code: order.pickupOtp.code,
                required: order.pickupOtp.required,
                verified: order.pickupOtp.verified,
              ),

              const SizedBox(height: 16),

              /// DELIVERY OTP
              _otpTile(
                title: "Delivery OTP",
                code: order.deliveryOtp.code,
                required: order.deliveryOtp.required,
                verified: order.deliveryOtp.verified,
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

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
                _buildOtpCard(context, order),
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
      'Assigned',
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
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: order.isMultiStop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              child: const Icon(
                                Icons.route_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Multi-Stop Route",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        /// TOTAL STOPS BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.limeGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${order.stops.length} Stops",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
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
                          child: const Icon(
                            Icons.route_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Route Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            /// CONDITION
            order.isMultiStop
                ? _buildMultiStopTimeline(order.stops)
                : _buildSingleTimeline(order),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleTimeline(order) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// LEFT TIMELINE COLUMN
          _timelineColumn(
            pickupColor: AppColors.electricTeal,
            deliveryColor: AppColors.limeGreen,
          ),

          /// RIGHT CARDS
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timelineCard(
                  title: "Pickup",
                  address: order.pickup.address,
                  cityState: "${order.pickup.city}, ${order.pickup.state}",
                  name: order.pickup.contactName,
                  phone: order.pickup.contactPhone,
                  color: AppColors.electricTeal,
                  icon: Icons.upload,
                ),

                const SizedBox(height: 32),

                _timelineCard(
                  title: "Delivery",
                  address: order.delivery.address,
                  cityState: "${order.delivery.city}, ${order.delivery.state}",
                  name: order.delivery.contactName,
                  phone: order.delivery.contactPhone,
                  color: AppColors.limeGreen,
                  icon: Icons.download,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiStopTimeline(List<OrderStop> stops) {
    if (stops.isEmpty) return const SizedBox();

    final ValueNotifier<bool> showAllNotifier = ValueNotifier(false);

    return ValueListenableBuilder<bool>(
      valueListenable: showAllNotifier,
      builder: (context, showAll, _) {
        final displayedStops = showAll ? stops : stops.take(2).toList();

        return Padding(
          padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TIMELINE ROW
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// LEFT TIMELINE
                    SizedBox(
                      width: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          /// VERTICAL LINE
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.electricTeal.withOpacity(0.3),
                                      AppColors.limeGreen.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// DOTS
                          ...List.generate(displayedStops.length, (index) {
                            final stop = displayedStops[index];

                            Color color;
                            IconData icon;

                            switch (stop.type) {
                              case 'pickup':
                                color = AppColors.electricTeal;
                                icon = Icons.upload;
                                break;
                              case 'drop_off':
                                color = Colors.red;
                                icon = Icons.download;
                                break;
                              default:
                                color = Colors.orange;
                                icon = Icons.location_on;
                            }

                            double topOffset = 90 + index * 210.0;

                            return Positioned(
                              top: topOffset,
                              child: _dot(
                                color,
                                size: 20,
                                glow: true,
                                icon: icon,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// RIGHT CARDS
                    Expanded(
                      child: Column(
                        children: List.generate(displayedStops.length, (index) {
                          final stop = displayedStops[index];

                          Color color;
                          IconData icon;

                          switch (stop.type) {
                            case 'pickup':
                              color = AppColors.electricTeal;
                              icon = Icons.upload;
                              break;
                            case 'drop_off':
                              color = Colors.red;
                              icon = Icons.download;
                              break;
                            default:
                              color = Colors.orange;
                              icon = Icons.location_on;
                          }

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == displayedStops.length - 1
                                  ? 0
                                  : 24,
                            ),
                            child: _timelineCard(
                              title: stop.type.toUpperCase(),
                              address: stop.address,
                              cityState: "${stop.city}, ${stop.state}",
                              name: stop.contactName,
                              phone: stop.contactPhone,
                              arrivedAt: stop.arrivalTime,
                              completedAt: stop.departureTime,
                              color: color,
                              icon: icon,
                              status: stop.status,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              /// SHOW MORE / SHOW LESS
              if (stops.length > 2)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showAllNotifier.value = !showAllNotifier.value;
                    },
                    child: Text(showAll ? "Show Less" : "Show More"),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _timelineColumn({
    required Color pickupColor,
    required Color deliveryColor,
  }) {
    return SizedBox(
      width: 40, // thoda wider for style
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient Vertical Line
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      pickupColor.withOpacity(0.3),
                      deliveryColor.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // PICKUP DOT
          Positioned(
            top: 80,
            child: _dot(pickupColor, size: 20, glow: true, icon: Icons.upload),
          ),

          // DELIVERY DOT
          Positioned(
            bottom: 85,
            child: _dot(
              deliveryColor,
              size: 20,
              glow: true,
              icon: Icons.download,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(
    Color color, {
    double size = 14,
    bool glow = false,
    IconData? icon,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: glow
            ? LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: glow ? null : color,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: icon != null
          ? Center(
              child: Icon(icon, color: Colors.white, size: size / 2),
            )
          : null,
    );
  }

  Widget _timelineCard({
    required String title,
    required String address,
    required String cityState,
    required String phone,
    required String name,
    required Color color,
    required IconData icon,
    String? arrivedAt,
    String? completedAt,
    String? status,
  }) {
    Color statusColor = Colors.grey;

    if (status != null) {
      switch (status.toLowerCase()) {
        case "arrived":
          statusColor = Colors.green;
          break;
        case "pending":
          statusColor = Colors.orange;
          break;
        case "completed":
          statusColor = Colors.blue;
          break;
        default:
          statusColor = Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50], // 👈 same as vehicle card
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08), // 👈 themed shadow
            blurRadius: 12,
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
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),

              if (status != null)
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
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          /// CONTACT NAME
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          /// PHONE
          Row(
            children: [
              const Icon(Icons.phone, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(phone, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// ADDRESS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "$address, $cityState",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ),

          if (arrivedAt != null || completedAt != null)
            const SizedBox(height: 12),

          /// TIME INFO
          if (arrivedAt != null)
            Row(
              children: [
                const Icon(Icons.access_time, size: 13, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  formatDate(arrivedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),

          if (completedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 13, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    formatDate(completedAt),
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
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
                  label: "Vehicle",
                  value:
                      "${order.vehicle.registration} (${order.vehicle.vehicleType})",
                  iconColor: Colors.orange,
                ),
                const Divider(height: 32, color: Colors.grey),
                _buildDetailItem(
                  icon: Icons.person_rounded,
                  label: "Driver",
                  value: "${order.driver.name} ( ${order.driver.phone} )",
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
          /// HEADER
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

          /// INNER CLEAN CONTAINER (Like Payment Breakdown)
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
                ...order.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Column(
                    children: [
                      _buildItemRow(
                        title: item.productName,
                        description: item.description,
                        weight: item.weight,
                        quantity: item.quantity,
                        dimensios: item.dimensions,
                        value: item.declaredValue,
                      ),

                      if (index != order.items.length - 1)
                        const Divider(height: 28, color: Colors.grey),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required String title,
    required String description,
    required dynamic weight,
    required dynamic quantity,
    required dynamic value,
    required dynamic dimensios,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// PRODUCT NAME
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 4),

        /// DESCRIPTION
        Text(
          description,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),

        const SizedBox(height: 10),

        /// META ROWS (Like Pricing)
        _buildMetaRow("Weight", "$weight kg"),
        _buildMetaRow("Quantity", "$quantity"),
        _buildMetaRow("Dimensios", "$dimensios"),
        _buildMetaRow("Value", "R $value"),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.electricTeal,
            ),
          ),
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
                  label: "Add-Ons Cost",
                  value: order.pricing.addOnsCost,
                ),
                _buildPricingRow(
                  label: "System Service Fee",
                  value: order.pricing.systemServiceFee,
                ),
                _buildPricingRow(label: "Tax", value: order.pricing.taxAmount),
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

  // -------------------- OTP CARD --------------------
  Widget _buildOtpCard(BuildContext context, order) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      AppColors.electricTeal.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Routes OTP",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricTeal,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              _showOtpBottomSheet(context, order);
            },
            child: const Text("View"),
          ),
        ],
      ),
    );
  }

  Widget _otpTile({
    required String title,
    required String? code,
    required bool required,
    required bool verified,
  }) {
    Color statusColor;

    if (!required) {
      statusColor = Colors.grey;
    } else if (verified) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 6),
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
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
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
                  !required
                      ? "Not Required"
                      : verified
                      ? "Verified"
                      : "Pending",
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
          Text(
            code ?? "----",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}
