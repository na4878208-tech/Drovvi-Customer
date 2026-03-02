import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/constants/session_expired.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/main_order_create_screen.dart';
import 'package:logisticscustomer/features/home/orders_flow/all_orders/get_all_orders_modal.dart';
import 'package:logisticscustomer/features/home/orders_flow/all_orders/orders_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../export.dart';
import '../../../bottom_navbar/bottom_navbar_screen.dart';
import '../order details/order_details_screen.dart';
import 'pending_payment_method.dart';

class Orders extends ConsumerStatefulWidget {
  const Orders({super.key});

  @override
  ConsumerState<Orders> createState() => _OrdersState();
}

class _OrdersState extends ConsumerState<Orders> {
  late final ScrollController _scrollController;

  final List<String> _statusFilters = [
    'All',
    // 'Active',
    'Assigned',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        final state = ref.read(orderControllerProvider);

        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200 &&
            !state.isLoadingMore &&
            state.currentPage < state.meta.lastPage) {
          ref.read(orderControllerProvider.notifier).loadMoreOrders();
        }
      });

    Future.microtask(() {
      ref.read(orderControllerProvider.notifier).loadOrders();
    });
  }

  void _handlePayment(AlOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PaymentOptionsModal(order: order, ref: ref),
    );
  }

  // void _processPayment(AlOrder order) {
  //   // Payment processing logic yahan implement karein
  //   // Example: Payment gateway integration

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text("Processing payment for order ${order.orderNumber}"),
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );

  //   // After payment, refresh orders list
  //   Future.delayed(const Duration(seconds: 2), () {
  //     ref.read(orderControllerProvider.notifier).refreshOrders();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    ref.listen(orderControllerProvider, (previous, next) {
      // Jab orders empty hon aur loading false ho
      if (previous?.orders.isEmpty == true &&
          next.orders.isEmpty &&
          !next.isLoading) {
        ref.read(orderControllerProvider.notifier).loadOrders();
      }
    });
    final orderState = ref.watch(orderControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: Column(
        children: [
          // Custom AppBar
          _buildAppBar(),

          // Filter Chips
          _buildFilterChips(),

          // Orders List
          Expanded(
            child: _buildContent(orderState), // Changed this line
          ),
        ],
      ),
    );
  }

  // Build content based on state
  Widget _buildContent(OrderState state) {
    // 1️⃣ Error (session expired / unauthorized)
    if (state.error != null && state.orders.isEmpty) {
      return SessionExpiredScreen();
    }

    // 2️⃣ Initial loading (first API call)
    if (state.isLoading && state.orders.isEmpty) {
      return _buildLoadingState();
    }

    // 3️⃣ Empty state (no orders after loading)
    if (!state.isLoading && state.orders.isEmpty) {
      return _buildEmptyState();
    }

    // 4️⃣ Orders list (with pagination / refresh)
    return _buildOrdersList(state);
  }

  // Widget _buildContent(OrderState state) {
  //   // Show loading only when first loading and no data

  //   // Show error if any
  //   if (state.error != null) {
  //     // return _buildErrorState(state.error!);
  //     return SessionExpiredScreen();
  //   }

  //   if (state.isLoading && state.orders.isEmpty) {
  //     return _buildLoadingState();
  //   }

  //   // Show empty state if no orders
  //   if (state.orders.isEmpty) {
  //     return _buildEmptyState();
  //   }

  //   // Show orders list
  //   return _buildOrdersList(state);
  // }

  // Custom AppBar
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.electricTeal,
        // borderRadius: const BorderRadius.only(
        //   bottomLeft: Radius.circular(20),
        //   bottomRight: Radius.circular(20),
        // ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGray.withOpacity(0.2),
            blurRadius: 10,
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
              CustomText(
                txt: "My Orders",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.pureWhite,
              ),
              const SizedBox(height: 4),
              CustomText(
                txt: "Track and manage all your orders",
                fontSize: 14,
                color: AppColors.pureWhite.withOpacity(0.8),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainOrderCreateScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricTeal,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.pureWhite, width: 1.5),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Create Order", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Filter Chips
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: _statusFilters.map((filter) {
          bool isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: CustomText(
                txt: filter,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.pureWhite
                    : AppColors.electricTeal,
              ),
              selected: isSelected,
              selectedColor: AppColors.electricTeal,
              backgroundColor: AppColors.lightGrayBackground,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                // Filter orders when filter changes
                if (filter == 'All') {
                  ref.read(orderControllerProvider.notifier).loadOrders();
                } else if (filter == 'Active') {
                  // Active filter ke liye alag logic
                  ref
                      .read(orderControllerProvider.notifier)
                      .filterByStatus(filter);
                } else {
                  ref
                      .read(orderControllerProvider.notifier)
                      .filterByStatus(filter);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.electricTeal
                      : AppColors.electricTeal,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  // Loading State shimmer
  Widget _buildLoadingState() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _orderShimmerCard();
      },
    );
  }

  Widget _orderShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.electricTeal.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.electricTeal.withOpacity(0.1),
        highlightColor: AppColors.electricTeal.withOpacity(0.1),
        child: Column(
          children: [
            /// HEADER
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  _shimmerBox(width: 120, height: 14),
                  const Spacer(),
                  _shimmerBox(width: 70, height: 18, radius: 20),
                ],
              ),
            ),

            /// BODY
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _shimmerBox(height: 60, radius: 12),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _shimmerBox(width: 80, height: 12),
                      _shimmerBox(width: 80, height: 12),
                      _shimmerBox(width: 60, height: 12),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _shimmerBox(width: 70, height: 16),
                      _shimmerBox(width: 100, height: 12),
                    ],
                  ),
                ],
              ),
            ),

            /// FOOTER BUTTONS
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(child: _shimmerBox(height: 38, radius: 18)),
                  const SizedBox(width: 12),
                  Expanded(child: _shimmerBox(height: 38, radius: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({
    double width = double.infinity,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // shimmer end
  // Widget _buildLoadingState() {
  //   return ListView.builder(
  //     controller: _scrollController,
  //     padding: const EdgeInsets.all(12),
  //     itemCount: 6, // Skeleton items
  //     itemBuilder: (context, index) {
  //       return Container(
  //         margin: const EdgeInsets.only(bottom: 12),
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: AppColors.pureWhite,
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Column(
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   width: 60,
  //                   height: 20,
  //                   decoration: BoxDecoration(
  //                     color: AppColors.mediumGray.withOpacity(0.2),
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                 ),
  //                 const Spacer(),
  //                 Container(
  //                   width: 80,
  //                   height: 20,
  //                   decoration: BoxDecoration(
  //                     color: AppColors.mediumGray.withOpacity(0.2),
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 12),
  //             Row(
  //               children: [
  //                 Container(
  //                   width: 100,
  //                   height: 16,
  //                   decoration: BoxDecoration(
  //                     color: AppColors.mediumGray.withOpacity(0.2),
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                 ),
  //                 const Spacer(),
  //                 Container(
  //                   width: 60,
  //                   height: 16,
  //                   decoration: BoxDecoration(
  //                     color: AppColors.mediumGray.withOpacity(0.2),
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Error State
  // Widget _buildErrorState(String error) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.error_outline, size: 60, color: AppColors.mediumGray),
  //         const SizedBox(height: 16),
  //         CustomText(
  //           txt: "Oops! Something went wrong",
  //           fontSize: 18,
  //           fontWeight: FontWeight.w600,
  //           color: AppColors.darkText,
  //         ),
  //         const SizedBox(height: 8),
  //         // CustomText(
  //         //   txt: error,
  //         //   fontSize: 14,
  //         //   color: AppColors.mediumGray,
  //         //   align: TextAlign.center,
  //         // ),
  //         const SizedBox(height: 24),
  //         ElevatedButton(
  //           // onPressed: _refreshOrders,
  //           onPressed: () {
  //             Navigator.pushAndRemoveUntil(
  //               context,
  //               MaterialPageRoute(builder: (_) => const Login()),
  //               (route) => false,
  //             );
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: AppColors.electricTeal,
  //             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           child: const Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Icon(Icons.login_outlined, size: 20, color: Colors.white),
  //               SizedBox(width: 8),
  //               Text("Login Again", style: TextStyle(color: Colors.white)),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Orders List
  Widget _buildOrdersList(OrderState state) {
    // Filter orders based on selected filter
    List<AlOrder> filteredOrders = _filterOrders(state.orders);

    // Agar koi order nahi hai
    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(orderControllerProvider.notifier).refreshOrders();
      },
      child: Column(
        children: [
          // Show loading more indicator
          if (state.isLoadingMore)
            Padding(
              padding: const EdgeInsets.all(12),
              child: CircularProgressIndicator(color: AppColors.electricTeal),
            ),

          // Orders list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildOrderCard(order);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppColors.mediumGray.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          CustomText(
            txt: "No Orders Found",
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
          const SizedBox(height: 8),
          CustomText(
            txt: _selectedFilter == 'All'
                ? "You haven't placed any orders yet"
                : "No ${_selectedFilter.toLowerCase()} orders",
            fontSize: 14,
            color: AppColors.mediumGray,
          ),
          const SizedBox(height: 24),
          if (_selectedFilter == 'All')
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainOrderCreateScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricTeal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Create First Order",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Order Card
  Widget _buildOrderCard(AlOrder order) {
    String formattedDate = "—";
    if (order.createdAt != null && order.createdAt!.isNotEmpty) {
      try {
        formattedDate = DateFormat(
          'dd MMM yyyy • hh:mm a',
        ).format(DateTime.parse(order.createdAt!));
      } catch (_) {}
    }

    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.electricTeal.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// ================= HEADER =================
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            decoration: BoxDecoration(
              color: AppColors.electricTeal.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber ?? "",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if ((order.trackingCode ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              order.trackingCode!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.electricTeal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: order.trackingCode!),
                                );
                                AppSnackBar.showSuccess(
                                  context,
                                  "Tracking code copied",
                                );
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //     content: Text("Tracking code copied"),
                                //     duration: Duration(seconds: 1),
                                //   ),
                                // );
                              },
                              child: const Icon(Icons.copy, size: 12),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                /// RIGHT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _statusChip(order.statusText, statusColor),
                    if (order.isMultiStop == 1) ...[
                      const SizedBox(height: 6),
                      _miniChip("${order.stopsCount} Stops"),
                    ],
                  ],
                ),
              ],
            ),
          ),

          /// ================= BODY =================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              children: [
                /// ROUTE
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.electricTeal.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: order.isMultiStop == 1 && order.stops.isNotEmpty
                      ? _multiStopTimeline(order.stops)
                      : _singleTimeline(order),
                ),

                const SizedBox(height: 14),

                /// META
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (order.vehicle.vehicleType.isNotEmpty)
                      _iconText(
                        Icons.local_shipping,
                        order.vehicle.vehicleType,
                      ),
                    if (order.driver.name.isNotEmpty)
                      _iconText(Icons.person_outline, order.driver.name),
                    if (order.totalWeightKg != null &&
                        order.totalWeightKg!.isNotEmpty)
                      _iconText(
                        Icons.scale_outlined,
                        "${order.totalWeightKg} kg",
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                /// PRICE + DATE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "R ${order.finalCost ?? '--'}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.electricTeal,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// ================= FOOTER =================
          /// ================= FOOTER =================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: order.paymetstatus?.toLowerCase() == 'pending'
                ? ElevatedButton.icon(
                    onPressed: () {
                      // Payment karne ka logic yahan implement karein
                      _handlePayment(order);
                    },
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text("Pay Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.orange, // Pending payment ke liye orange color
                      foregroundColor: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TripsBottomNavBarScreen(initialIndex: 2, trackingCode: order.trackingCode,)
                              ),
                            );
                          },
                          icon: const Icon(Icons.map_outlined, size: 16),
                          label: const Text("Track"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.electricTeal,
                            side: BorderSide(color: AppColors.electricTeal),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailsScreen(orderId: order.id ?? 0),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: AppColors.pureWhite,
                          ),
                          label: const Text(
                            "Details",
                            style: TextStyle(color: AppColors.pureWhite),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricTeal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Padding(
          //   padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: OutlinedButton.icon(
          //           onPressed: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (_) => OrderTrackingScreen(
          //                   trackingCode: order.trackingCode ?? "",
          //                 ),
          //               ),
          //             );
          //           },
          //           icon: const Icon(Icons.map_outlined, size: 16),
          //           label: const Text("Track"),
          //           style: OutlinedButton.styleFrom(
          //             foregroundColor: AppColors.electricTeal,
          //             side: BorderSide(color: AppColors.electricTeal),
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(18),
          //             ),
          //             padding: const EdgeInsets.symmetric(vertical: 10),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: ElevatedButton.icon(
          //           onPressed: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (_) =>
          //                     OrderDetailsScreen(orderId: order.id ?? 0),
          //               ),
          //             );
          //           },
          //           icon: const Icon(Icons.remove_red_eye_outlined, size: 16,color: AppColors.pureWhite,),
          //           label: const Text("Details",style: TextStyle(color: AppColors.pureWhite,),),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: AppColors.electricTeal,
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(18),
          //             ),
          //             padding: const EdgeInsets.symmetric(vertical: 10),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _singleTimeline(AlOrder order) {
    return Column(
      children: [
        _timelineItem(
          title: "Pickup",
          value: order.pickupCity ?? "",
          icon: Icons.upload,
          color: AppColors.electricTeal,
          isLast: false,
        ),
        _timelineItem(
          title: "Delivery",
          value: order.deliveryCity ?? "",
          icon: Icons.download,
          color: AppColors.limeGreen,
          isLast: true,
        ),
      ],
    );
  }

  Widget _multiStopTimeline(List<OrderStop> stops) {
    return Column(
      children: List.generate(stops.length, (i) {
        final stop = stops[i];
        final isLast = i == stops.length - 1;

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

        return _timelineItem(
          title: stop.type.replaceAll('_', ' ').toUpperCase(),
          value: stop.city,
          subtitle: stop.address,
          icon: icon,
          color: color,
          isLast: isLast,
        );
      }),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _miniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _timelineItem({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 12, color: color),
            ),
            if (!isLast)
              Container(width: 2, height: 26, color: color.withOpacity(0.25)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.mediumGray),
        const SizedBox(width: 4),
        CustomText(txt: text, fontSize: 12, color: AppColors.mediumGray),
      ],
    );
  }

  // Helper Methods
  List<AlOrder> _filterOrders(List<AlOrder> orders) {
    if (_selectedFilter == 'All') {
      return orders;
    } else if (_selectedFilter == 'Active') {
      return orders.where((order) => order.isActive).toList();
    } else {
      return orders
          .where(
            (order) =>
                order.status.toLowerCase() == _selectedFilter.toLowerCase(),
          )
          .toList();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'assigned':
        return AppColors.electricTeal;
      case 'pending':
        return Colors.orange;
      case 'in_transit':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.mediumGray;
    }
  }
}
