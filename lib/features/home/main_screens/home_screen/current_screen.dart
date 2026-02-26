import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logisticscustomer/constants/jwt.dart';
import 'package:logisticscustomer/constants/local_storage.dart';
import 'package:logisticscustomer/constants/session_expired.dart';

import 'package:logisticscustomer/export.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/main_order_create_screen.dart';
import 'package:logisticscustomer/features/home/main_screens/home_screen/home_controller.dart';
import 'package:logisticscustomer/features/home/main_screens/home_screen/view_all.dart';
import 'package:logisticscustomer/features/home/notification_screen.dart';
import 'package:logisticscustomer/features/home/orders_flow/ordr_tracking/order_tracking_screen.dart';
import 'package:logisticscustomer/services/notification_service.dart';

import 'package:shimmer/shimmer.dart';

import '../../../../constants/gps_location.dart';
import '../../Get_Profile/get_profile_controller.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _appBarShimmer(),
            const SizedBox(height: 16),
            _buttonShimmer(),
            const SizedBox(height: 16),
            _statsShimmer(),
            const SizedBox(height: 24),
            _sectionTitleShimmer(),
            const SizedBox(height: 12),
            _orderCardShimmer(),
            _orderCardShimmer(),
            _orderCardShimmer(),
            const SizedBox(height: 24),
            _sectionTitleShimmer(),
            const SizedBox(height: 12),
            _recentOrderShimmer(),
            _recentOrderShimmer(),
          ],
        ),
      ),
    );
  }
}

Widget _appBarShimmer() {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
    decoration: const BoxDecoration(color: AppColors.electricTeal),
    child: Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.6),
      child: Row(
        children: [
          const CircleAvatar(radius: 22, backgroundColor: Colors.white),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(width: 120, height: 14),
              const SizedBox(height: 6),
              _box(width: 90, height: 12),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buttonShimmer() {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: _box(height: 52, radius: 12),
    ),
  );
}

Widget _statsShimmer() {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _box(height: 60)),
                const SizedBox(width: 16),
                Expanded(child: _box(height: 60)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _box(height: 60)),
                const SizedBox(width: 16),
                Expanded(child: _box(height: 60)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _sectionTitleShimmer() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_box(width: 140, height: 16), _box(width: 60, height: 14)],
      ),
    ),
  );
}

Widget _orderCardShimmer() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(width: 140, height: 14),
            const SizedBox(height: 10),
            _box(width: 90, height: 12),
            const SizedBox(height: 8),
            _box(width: double.infinity, height: 12),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: _box(width: 90, height: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _recentOrderShimmer() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: _box(height: 60, radius: 12),
    ),
  );
}

Widget _box({
  double width = double.infinity,
  double height = 12,
  double radius = 8,
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

//////////////////
class CurrentScreen extends ConsumerStatefulWidget {
  const CurrentScreen({super.key});

  @override
  ConsumerState<CurrentScreen> createState() => _CurrentScreenState();
}

class _CurrentScreenState extends ConsumerState<CurrentScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final token = await LocalStorage.getToken();

      if (token == null) return;

      final userId = getUserIdFromToken(token);
      if (userId == null) return;

      // await NotificationService.initialize(userId);

      await NotificationService.initialize();

      ref.read(dashboardControllerProvider.notifier).loadDashboard();
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() {
  //     ref.read(dashboardControllerProvider.notifier).loadDashboard();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);

    // final orderResponse = ref.watch(orderControllerProvider);

    return state.when(
      loading: () => const DashboardShimmer(),
      // error: (e, st) => Scaffold(body: Center(child: Text("Error: $e"))),
      error: (e, st) {
        // if (e.toString().contains("SESSION_EXPIRED")) {
        return SessionExpiredScreen();
        // }
        // return Scaffold(body: Center(child: Text("Error: $e")));
      },

      data: (dashboard) {
        final stats = dashboard.data.stats;

        return Scaffold(
          backgroundColor: AppColors.lightGrayBackground,
          appBar: DashboardAppBar(),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Create New Order Button ----
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainOrderCreateScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.electricTeal),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2,
                                color: AppColors.electricTeal,
                                size: 28,
                              ),
                              SizedBox(width: 10),
                              CustomText(
                                txt: "Create New Order",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Quick Stats
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            txt: "Quick Stats",
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.electricTeal,
                          ),

                          gapH4,

                          // Stats UI
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.electricTeal.withOpacity(0.12),
                                  AppColors.pureWhite,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _statRow(
                                  left: StatCardData(
                                    icon: Icons.receipt_long_rounded,
                                    amount: stats.totalOrders.toString(),
                                    label: "Total Orders",
                                    color: AppColors.electricTeal,
                                  ),
                                  right: StatCardData(
                                    icon: Icons.local_shipping_outlined,
                                    amount: stats.activeOrders.toString(),
                                    label: "Active",
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _statRow(
                                  left: StatCardData(
                                    icon: Icons.check_circle_outline,
                                    amount: stats.completedOrders.toString(),
                                    label: "Completed",
                                    color: Colors.green,
                                  ),
                                  right: StatCardData(
                                    icon: Icons.currency_exchange,
                                    // amount: "R :${stats.totalSpent}",
                                    amount:
                                        "R ${NumberFormat('#,###').format(stats.totalSpent)}",

                                    label: "Spent",
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          gapH24,

                          // ---- Active Orders ----
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    txt: "Active Orders",
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkText,
                                  ),
                                  const SizedBox(height: 4),
                                  CustomText(
                                    txt: "Currently ongoing deliveries",
                                    fontSize: 12,
                                    color: AppColors.mediumGray,
                                  ),
                                ],
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ActiveViewAll(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      CustomText(
                                        txt: "View All",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.electricTeal,
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 14,
                                        color: AppColors.electricTeal,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          gapH12,

                          // Active Orders ke tile me ye changes karein:
                          dashboard.data.activeOrders.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 30,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 10),
                                      CustomText(
                                        txt: "No active orders",
                                        fontSize: 14,
                                        color: AppColors.mediumGray,
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: dashboard.data.activeOrders.take(3).map((
                                    order,
                                  ) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: () {
                                        print("Order ID: ${order.id}");
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// Top Row (Order + Status Badge)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CustomText(
                                                  txt: order.orderNumber,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.darkText,
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .electricTeal
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: CustomText(
                                                    txt: order.status
                                                        .toUpperCase(),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.electricTeal,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 14),

                                            /// Route Section
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      size: 10,
                                                      color: AppColors
                                                          .electricTeal,
                                                    ),
                                                    Container(
                                                      width: 2,
                                                      height: 24,
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 14,
                                                      color: Colors.red,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        txt: order.pickupCity,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors.darkText,
                                                      ),
                                                      const SizedBox(height: 6),
                                                      CustomText(
                                                        txt: order.deliveryCity,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors.darkText,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Divider(
                                              color: Colors.grey.shade200,
                                            ),

                                            /// Bottom Row
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CustomText(
                                                  txt:
                                                      "Tracking: ${order.trackingCode}",
                                                  fontSize: 12,
                                                  color: AppColors.mediumGray,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            OrderTrackingScreen(
                                                              trackingCode: order
                                                                  .trackingCode,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      CustomText(
                                                        txt: "Track Order",
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .electricTeal,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Icon(
                                                        Icons.arrow_forward,
                                                        size: 12,
                                                        color: AppColors
                                                            .electricTeal,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                          gapH24,

                          // ---- Recent Orders ----
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                txt: "Recent Orders",
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.electricTeal,
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecentViewAll(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    CustomText(
                                      txt: "View All",
                                      color: AppColors.electricTeal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: AppColors.electricTeal,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          gapH4,

                          // Recent Orders
                          // Recent Orders ke tile me ye changes karein:
                          dashboard.data.recentOrders.isEmpty
                              ? Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.pureWhite,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: CustomText(
                                      txt: "no recent orders",
                                      fontSize: 14,
                                      color: AppColors.mediumGray,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: dashboard
                                      .data
                                      .recentOrders // <-- List<RecentOrder> object
                                      .take(3)
                                      .map((order) {
                                        // <-- 'order' ab RecentOrder type ka object hai
                                        // Status color set karne ke liye
                                        _getStatusColor(order.status);

                                        // Time format karne ke liye
                                        String formattedTime = DateFormat(
                                          'dd MMM yyyy • hh:mm a',
                                        ).format(order.createdAt);

                                        return buildOrderTile(
                                          order
                                              .orderNumber, // <-- DIRECT ACCESS
                                          order.status, // <-- DIRECT ACCESS
                                          formattedTime, // <-- Formatted time
                                        );
                                      })
                                      .toList(),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statRow({required StatCardData left, required StatCardData right}) {
    return Row(
      children: [
        Expanded(child: _statCard(left)),
        const SizedBox(width: 12),
        Expanded(child: _statCard(right)),
      ],
    );
  }

  Widget _statCard(StatCardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: 12),

          /// 🔥 FIX STARTS HERE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
                ),
              ],
            ),
          ),

          /// 🔥 FIX ENDS HERE
        ],
      ),
    );
  }

  // Helper method for status colors
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return AppColors.electricTeal;
      case 'in_transit':
        return AppColors.limeGreen;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.mediumGray;
    }
  }

  // Helper widget for recent orders
  Widget buildOrderTile(String orderNumber, String status, String time) {
    Color statusColor = _getStatusColor(status);
    IconData statusIcon = Icons.pending;
    String statusText = status;

    // Status ke hisaab se icon aur color set karein
    if (status.toLowerCase() == "completed") {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = "Delivered";
    } else if (status.toLowerCase() == "assigned") {
      statusColor = AppColors.electricTeal;
      statusIcon = Icons.local_shipping;
      statusText = "In Transit";
    } else if (status.toLowerCase() == "pending") {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = "Pending";
    } else if (status.toLowerCase() == "cancelled") {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = "Cancelled";
    }

    return GestureDetector(
      onTap: () {
        // Yahan order details screen pe navigate karein
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => OrderDetailsScreen(orderId: order.id),
        //   ),
        // );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.mediumGray.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomText(
                      txt: "Order: ",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.electricTeal,
                    ),
                    CustomText(
                      txt: orderNumber,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    SizedBox(width: 6),
                    CustomText(
                      txt: statusText.toUpperCase(),
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            CustomText(txt: time, fontSize: 12, color: AppColors.mediumGray),
          ],
        ),
      ),
    );
  }
}

// ================ SEPARATE APP BAR WIDGET ================
class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(82);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(getProfileControllerProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.electricTeal),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT SIDE
          Row(
            children: [
              _avatar(profileState),
              const SizedBox(width: 12),
              _userInfo(profileState),
            ],
          ),

          /// NOTIFICATION ICON (ALWAYS VISIBLE)
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationScreen()),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= AVATAR =================
  Widget _avatar(AsyncValue profileState) {
    return profileState.when(
      data: (profile) {
        final photo = profile?.data?.customer?.profilePhoto;
        return CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.mediumGray.withOpacity(0.4),
          backgroundImage: (photo != null && photo.isNotEmpty)
              ? NetworkImage(photo)
              : null,
          child: (photo == null || photo.isEmpty)
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        );
      },
      loading: () => _defaultAvatar(),
      error: (_, __) => _defaultAvatar(),
    );
  }

  Widget _defaultAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.mediumGray.withOpacity(0.4),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }

  /// ================= USER INFO =================
  Widget _userInfo(AsyncValue profileState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// NAME
        profileState.when(
          data: (profile) {
            final name = profile?.data?.user?.name;
            return CustomText(
              txt: name?.isNotEmpty == true ? "Hi, $name" : "Hi, Loading...",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.pureWhite,
            );
          },
          loading: () => _loadingText(width: 110),
          error: (_, __) => _loadingText(width: 110),
        ),

        const SizedBox(height: 4),

        /// LOCATION
        profileState.when(
          data: (_) {
            return FutureBuilder<String>(
              future: getCurrentCity(),
              builder: (_, snapshot) {
                final city = snapshot.data ?? "Loading...";
                return _locationRow(city);
              },
            );
          },
          loading: () => _loadingText(width: 90),
          error: (_, __) => _loadingText(width: 90),
        ),
      ],
    );
  }

  /// ================= HELPERS =================
  Widget _locationRow(String city) {
    return Row(
      children: [
        const Icon(Icons.location_pin, size: 16, color: Colors.white),
        const SizedBox(width: 4),
        CustomText(txt: city, color: Colors.white),
      ],
    );
  }

  Widget _loadingText({double width = 100}) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class StatCardData {
  final IconData icon;
  final String amount;
  final String label;
  final Color color;

  const StatCardData({
    required this.icon,
    required this.amount,
    required this.label,
    required this.color,
  });
}
