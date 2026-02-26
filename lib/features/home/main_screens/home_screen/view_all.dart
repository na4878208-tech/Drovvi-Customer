// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:logisticscustomer/common_widgets/custom_text.dart';
// import 'package:logisticscustomer/constants/colors.dart';
// import 'package:logisticscustomer/features/home/create_orders_screens/main_order_create_screen.dart';
// import 'package:logisticscustomer/features/home/main_screens/home_screen/home_controller.dart';
// import 'package:logisticscustomer/features/home/main_screens/home_screen/home_modal.dart';

// class ActiveViewAll extends ConsumerStatefulWidget {
//   const ActiveViewAll({super.key});

//   @override
//   ConsumerState<ActiveViewAll> createState() => _ActiveViewAllState();
// }

// class _ActiveViewAllState extends ConsumerState<ActiveViewAll> {
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(dashboardControllerProvider);

//     return Scaffold(
//       backgroundColor: AppColors.lightGrayBackground,
//       appBar: AppBar(
//         backgroundColor: AppColors.electricTeal,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: Icon(Icons.arrow_back_rounded, color: AppColors.pureWhite),
//         ),
//         title: CustomText(
//           txt: "Active Orders",
//           color: AppColors.pureWhite,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//         centerTitle: true,
//       ),

//       body: state.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, st) => Center(child: Text("Error: $e")),
//         data: (dashboard) {
//           // Agar koi active order nahi hai
//           if (dashboard.data.activeOrders.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.local_shipping,
//                     size: 60,
//                     color: AppColors.mediumGray,
//                   ),
//                   SizedBox(height: 16),
//                   CustomText(
//                     txt: "No Active Orders",
//                     fontSize: 16,
//                     color: AppColors.mediumGray,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   SizedBox(height: 8),
//                   CustomText(
//                     txt: "Currently there are no active orders",
//                     fontSize: 14,
//                     color: AppColors.mediumGray.withOpacity(0.7),
//                   ),
//                   SizedBox(height: 24),
//                   // Create new order button
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => MainOrderCreateScreen(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.electricTeal,
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: CustomText(
//                       txt: "Create New Order",
//                       color: AppColors.pureWhite,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           // Active orders list
//           return ListView.builder(
//             padding: EdgeInsets.all(12),
//             itemCount: dashboard.data.activeOrders.length,
//             itemBuilder: (context, index) {
//               final order = dashboard.data.activeOrders[index];

//               // Time format karein
//               String formattedTime = DateFormat(
//                 'dd MMM yyyy • hh:mm a',
//               ).format(order.createdAt);

//               return _buildActiveOrderTile(
//                 context: context,
//                 order: order,
//                 formattedTime: formattedTime,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // Active order tile banane ka function
//   Widget _buildActiveOrderTile({
//     required BuildContext context,
//     required ActiveOrder order,
//     required String formattedTime,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         // Yahan order tracking ya details screen pe navigate karein
//         // print("Tracking Code: ${order.trackingCode}");
//         // print("Order ID: ${order.id}");

//         // Example: Track Order screen pe ja sakte hain
//         /*
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TrackOrderScreen(
//               trackingCode: order.trackingCode,
//             ),
//           ),
//         );
//         */
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: AppColors.pureWhite,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.mediumGray.withOpacity(0.1),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header - Order Number aur Status
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.electricTeal.withOpacity(0.05),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.receipt_long,
//                         size: 18,
//                         color: AppColors.electricTeal,
//                       ),
//                       SizedBox(width: 8),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CustomText(
//                             txt: "Order",
//                             fontSize: 12,
//                             color: AppColors.mediumGray,
//                           ),
//                           CustomText(
//                             txt: order.orderNumber,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.darkText,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),

//                   // Tracking Code
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       CustomText(
//                         txt: "Tracking Code",
//                         fontSize: 12,
//                         color: AppColors.mediumGray,
//                       ),
//                       CustomText(
//                         txt: order.trackingCode,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.electricTeal,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Body - Route Information
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Pickup Location
//                   Row(
//                     children: [
//                       Container(
//                         width: 24,
//                         height: 24,
//                         decoration: BoxDecoration(
//                           color: AppColors.electricTeal,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           Icons.location_on_outlined,
//                           size: 12,
//                           color: AppColors.pureWhite,
//                         ),
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CustomText(
//                               txt: "Pickup",
//                               fontSize: 12,
//                               color: AppColors.mediumGray,
//                             ),
//                             CustomText(
//                               txt: order.pickupCity,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.darkText,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Line connector
//                   Padding(
//                     padding: EdgeInsets.only(left: 11, top: 4, bottom: 4),
//                     child: Container(
//                       width: 2,
//                       height: 20,
//                       color: AppColors.mediumGray.withOpacity(0.3),
//                     ),
//                   ),

//                   // Delivery Location
//                   Row(
//                     children: [
//                       Container(
//                         width: 24,
//                         height: 24,
//                         decoration: BoxDecoration(
//                           color: AppColors.limeGreen,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           Icons.location_on_outlined,
//                           size: 12,
//                           color: AppColors.pureWhite,
//                         ),
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CustomText(
//                               txt: "Delivery",
//                               fontSize: 12,
//                               color: AppColors.mediumGray,
//                             ),
//                             CustomText(
//                               txt: order.deliveryCity,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.darkText,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 16),

//                   // Status aur Cost
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Status
//                       Row(
//                         children: [
//                           Container(
//                             width: 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               color: AppColors.electricTeal,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               CustomText(
//                                 txt: "Status",
//                                 fontSize: 12,
//                                 color: AppColors.mediumGray,
//                               ),
//                               CustomText(
//                                 txt: order.status.toUpperCase(),
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.electricTeal,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),

//                       // Cost
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           CustomText(
//                             txt: "Cost",
//                             fontSize: 12,
//                             color: AppColors.mediumGray,
//                           ),
//                           CustomText(
//                             txt: "R${order.finalCost}",
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.electricTeal,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 8),

//                   // Time
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.access_time,
//                         size: 14,
//                         color: AppColors.mediumGray,
//                       ),
//                       SizedBox(width: 6),
//                       CustomText(
//                         txt: "Created: $formattedTime",
//                         fontSize: 12,
//                         color: AppColors.mediumGray,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Footer - Track Order Button
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(
//                     color: AppColors.mediumGray.withOpacity(0.1),
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // View Details Button
//                   OutlinedButton(
//                     onPressed: () {
//                       // Order details dekhne ke liye
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: AppColors.electricTeal),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 8,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.remove_red_eye_outlined,
//                           size: 16,
//                           color: AppColors.electricTeal,
//                         ),
//                         SizedBox(width: 6),
//                         CustomText(
//                           txt: "View Details",
//                           color: AppColors.electricTeal,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Track Order Button
//                   ElevatedButton(
//                     onPressed: () {
//                       // Track order screen pe navigate karein
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.electricTeal,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 8,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.map_outlined,
//                           size: 16,
//                           color: AppColors.pureWhite,
//                         ),
//                         SizedBox(width: 6),
//                         CustomText(
//                           txt: "Track Order",
//                           color: AppColors.pureWhite,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// // Recent Orderss

// class RecentViewAll extends ConsumerStatefulWidget {
//   const RecentViewAll({super.key});

//   @override
//   ConsumerState<RecentViewAll> createState() => _RecentViewAllState();
// }

// class _RecentViewAllState extends ConsumerState<RecentViewAll> {
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(dashboardControllerProvider);

//     return state.when(
//       loading: () => Scaffold(
//         backgroundColor: AppColors.lightGrayBackground,
//         appBar: _buildAppBar(),
//         body: const Center(child: CircularProgressIndicator()),
//       ),

//       error: (e, st) => Scaffold(
//         backgroundColor: AppColors.lightGrayBackground,
//         appBar: _buildAppBar(),
//         body: Center(child: Text("Error: $e")),
//       ),

//       data: (dashboard) {
//         // Agar recent orders nahi hain
//         if (dashboard.data.recentOrders.isEmpty) {
//           return Scaffold(
//             backgroundColor: AppColors.lightGrayBackground,
//             appBar: _buildAppBar(),
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.inbox_outlined,
//                     size: 60,
//                     color: AppColors.mediumGray,
//                   ),
//                   SizedBox(height: 16),
//                   CustomText(
//                     txt: "No recent orders found",
//                     fontSize: 16,
//                     color: AppColors.mediumGray,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   SizedBox(height: 8),
//                   CustomText(
//                     txt: "Your recent orders will appear here",
//                     fontSize: 14,
//                     color: AppColors.mediumGray.withOpacity(0.7),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         return Scaffold(
//           backgroundColor: AppColors.lightGrayBackground,
//           appBar: _buildAppBar(),

//           body: ListView.builder(
//             padding: EdgeInsets.all(12),
//             itemCount: dashboard.data.recentOrders.length,
//             itemBuilder: (context, index) {
//               final order = dashboard.data.recentOrders[index];

//               // Time format karein
//               String formattedTime = DateFormat(
//                 'dd MMM yyyy • hh:mm a',
//               ).format(order.createdAt);

//               return _buildOrderTile(
//                 context: context,
//                 order: order,
//                 formattedTime: formattedTime,
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   // AppBar banane ka function
// AppBar _buildAppBar() {
//   return AppBar(
//     backgroundColor: AppColors.electricTeal,
//     elevation: 0,
//     leading: IconButton(
//       icon: Icon(Icons.arrow_back_rounded, color: AppColors.pureWhite),
//       onPressed: () => Navigator.pop(context),
//     ),
//     title: CustomText(
//       txt: "Recent Orders",
//       color: AppColors.pureWhite,
//       fontSize: 16,
//       fontWeight: FontWeight.bold,
//     ),
//     centerTitle: true,
//   );
// }

//   // Order tile banane ka function
//   Widget _buildOrderTile({
//     required BuildContext context,
//     required RecentOrder order,
//     required String formattedTime,
//   }) {
//     // Status ke hisaab se color aur icon set karein
//     Color statusColor = _getStatusColor(order.status);
//     IconData statusIcon = _getStatusIcon(order.status);
//     String statusText = _getStatusText(order.status);

//     return GestureDetector(
//       onTap: () {
//         // Yahan order details screen pe navigate karein
//         // Agar aapke paas order details screen nahi hai, to isko comment kar dein
//         /*
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OrderDetailsScreen(orderId: order.id),
//           ),
//         );
//         */
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 12),
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColors.pureWhite,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.mediumGray.withOpacity(0.1),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Order Number aur Status
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.receipt_long,
//                       size: 18,
//                       color: AppColors.electricTeal,
//                     ),
//                     SizedBox(width: 8),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         CustomText(
//                           txt: "Order Number",
//                           fontSize: 12,
//                           color: AppColors.mediumGray,
//                         ),
//                         CustomText(
//                           txt: order.orderNumber,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.darkText,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 // Status badge
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: statusColor.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(statusIcon, size: 14, color: statusColor),
//                       SizedBox(width: 4),
//                       CustomText(
//                         txt: statusText,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: statusColor,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(height: 16),

//             // Route information
//             Row(
//               children: [
//                 // Pickup
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.location_on_outlined,
//                             size: 14,
//                             color: AppColors.mediumGray,
//                           ),
//                           SizedBox(width: 4),
//                           CustomText(
//                             txt: "Pickup",
//                             fontSize: 12,
//                             color: AppColors.mediumGray,
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 4),
//                       CustomText(
//                         txt: order.pickupCity,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.darkText,
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Arrow
//                 // Padding(
//                 //   padding: EdgeInsets.symmetric(horizontal: 8),
//                 //   child: Icon(
//                 //     Icons.arrow_forward_rounded,
//                 //     size: 16,
//                 //     color: AppColors.mediumGray,
//                 //   ),
//                 // ),

//                 // Delivery
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           CustomText(
//                             txt: "Delivery",
//                             fontSize: 12,
//                             color: AppColors.mediumGray,
//                           ),
//                           SizedBox(width: 4),
//                           Icon(
//                             Icons.location_on_outlined,
//                             size: 14,
//                             color: AppColors.mediumGray,
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 4),
//                       CustomText(
//                         txt: order.deliveryCity,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.darkText,
//                         align: TextAlign.end,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(height: 12),

//             Divider(height: 1, color: AppColors.mediumGray.withOpacity(0.2)),
//             SizedBox(height: 12),

//             // Bottom row - details aur time
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Details section - takes 70% width
//                 Flexible(
//                   flex: 7,
//                   child: Wrap(
//                     spacing: 12,
//                     runSpacing: 4,
//                     children: [
//                       // Product Type
//                       if (order.productType != null &&
//                           order.productType!.isNotEmpty)
//                         Container(
//                           padding: EdgeInsets.only(right: 8),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.inventory_2_outlined,
//                                 size: 12,
//                                 color: AppColors.mediumGray,
//                               ),
//                               SizedBox(width: 4),
//                               Container(
//                                 constraints: BoxConstraints(maxWidth: 80),
//                                 child: CustomText(
//                                   txt: order.productType!,
//                                   fontSize: 11,
//                                   color: AppColors.mediumGray,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                       // Weight
//                       if (order.totalWeightKg != null &&
//                           order.totalWeightKg!.isNotEmpty)
//                         Container(
//                           padding: EdgeInsets.only(right: 8),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.scale_outlined,
//                                 size: 12,
//                                 color: AppColors.mediumGray,
//                               ),
//                               SizedBox(width: 4),
//                               CustomText(
//                                 txt: "${order.totalWeightKg} kg",
//                                 fontSize: 11,
//                                 color: AppColors.mediumGray,
//                               ),
//                             ],
//                           ),
//                         ),

//                       // Cost
//                       if (order.finalCost != null &&
//                           order.finalCost!.isNotEmpty)
//                         Container(
//                           padding: EdgeInsets.only(right: 8),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.currency_rupee,
//                                 size: 12,
//                                 color: AppColors.mediumGray,
//                               ),
//                               SizedBox(width: 4),
//                               CustomText(
//                                 txt: "R${order.finalCost}",
//                                 fontSize: 11,
//                                 color: AppColors.mediumGray,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//                 // Time section - takes 30% width
//                 Flexible(
//                   flex: 3,
//                   child: CustomText(
//                     txt: formattedTime,
//                     fontSize: 11,
//                     color: AppColors.mediumGray,
//                     align: TextAlign.end,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper functions for status
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'assigned':
//         return AppColors.electricTeal;
//       case 'in_transit':
//         return Colors.blue;
//       case 'pending':
//         return Colors.orange;
//       case 'completed':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return AppColors.mediumGray;
//     }
//   }

//   IconData _getStatusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case 'assigned':
//         return Icons.local_shipping;
//       case 'in_transit':
//         return Icons.directions_car;
//       case 'pending':
//         return Icons.pending;
//       case 'completed':
//         return Icons.check_circle;
//       case 'cancelled':
//         return Icons.cancel;
//       default:
//         return Icons.help_outline;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status.toLowerCase()) {
//       case 'assigned':
//         return "Assigned";
//       case 'in_transit':
//         return "In Transit";
//       case 'pending':
//         return "Pending";
//       case 'completed':
//         return "Completed";
//       case 'cancelled':
//         return "Cancelled";
//       default:
//         return status;
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/main_order_create_screen.dart';
import 'package:logisticscustomer/features/home/main_screens/home_screen/home_controller.dart';
import 'package:logisticscustomer/features/home/orders_flow/ordr_tracking/order_tracking_screen.dart';
import '../../../../export.dart';
import '../../orders_flow/order details/order_details_screen.dart';

/// ===============================================================
/// ACTIVE ORDERS
/// ===============================================================
class ActiveViewAll extends ConsumerStatefulWidget {
  const ActiveViewAll({super.key});

  @override
  ConsumerState<ActiveViewAll> createState() => _ActiveViewAllState();
}

class _ActiveViewAllState extends ConsumerState<ActiveViewAll> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: _buildAppBar(context, "Active Orders"),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (dashboard) {
          if (dashboard.data.activeOrders.isEmpty) {
            return _emptyActiveState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: dashboard.data.activeOrders.length,
            itemBuilder: (_, index) {
              final order = dashboard.data.activeOrders[index];
              final time = DateFormat(
                'dd MMM yyyy • hh:mm a',
              ).format(order.createdAt);

              return OrderCard(
                orderId: order.id,
                orderNumber: order.orderNumber,
                trackingCode: order.trackingCode,
                pickupCity: order.pickupCity,
                deliveryCity: order.deliveryCity,
                status: order.status,
                cost: order.finalCost.toString(),
                time: time,
                isActive: true,
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyActiveState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 64, color: AppColors.electricTeal),
          gapH12,
          CustomText(
            txt: "No Active Orders",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.mediumGray,
          ),
          const SizedBox(height: 8),
          CustomText(
            txt: "Create a new order to get started",
            fontSize: 14,
            color: AppColors.mediumGray.withOpacity(0.7),
          ),
          gapH12,
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MainOrderCreateScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: CustomText(
                fontSize: 14,
                txt: "Create New Order",
                color: AppColors.pureWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// RECENT ORDERS
/// ===============================================================
class RecentViewAll extends ConsumerStatefulWidget {
  const RecentViewAll({super.key});

  @override
  ConsumerState<RecentViewAll> createState() => _RecentViewAllState();
}

class _RecentViewAllState extends ConsumerState<RecentViewAll> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: _buildAppBar(context, "Recent Orders"),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (dashboard) {
          if (dashboard.data.recentOrders.isEmpty) {
            return _emptyRecentState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: dashboard.data.recentOrders.length,
            itemBuilder: (_, index) {
              final order = dashboard.data.recentOrders[index];
              final time = DateFormat(
                'dd MMM yyyy • hh:mm a',
              ).format(order.createdAt);

              return OrderCard(
                orderId: order.id,
                orderNumber: order.orderNumber,
                pickupCity: order.pickupCity,
                deliveryCity: order.deliveryCity,
                status: order.status,
                cost: order.finalCost ?? "",
                time: time,
                isActive: false,
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyRecentState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppColors.electricTeal),
          const SizedBox(height: 16),
          CustomText(
            txt: "No Recent Orders",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.mediumGray,
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// REUSABLE ORDER CARD (USED BY BOTH ACTIVE & RECENT)
/// ===============================================================
class OrderCard extends StatelessWidget {
  final int orderId;
  final String orderNumber;
  final String? trackingCode;
  final String pickupCity;
  final String deliveryCity;
  final String status;
  final String cost;
  final String time;
  final bool isActive;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.orderNumber,
    this.trackingCode,
    required this.pickupCity,
    required this.deliveryCity,
    required this.status,
    required this.cost,
    required this.time,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
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
          /// HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.electricTeal.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      txt: "Order #",
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                    CustomText(
                      txt: orderNumber,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),

                    /// TRACKING CODE
                    if (trackingCode != null && trackingCode!.isNotEmpty)
                      const SizedBox(height: 6),
                    if (trackingCode != null && trackingCode!.isNotEmpty)
                      Row(
                        children: [
                          CustomText(
                            txt: "Track Order : ",
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mediumGray,
                          ),
                          CustomText(
                            txt: trackingCode!,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.electricTeal,
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: trackingCode!),
                              );
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //     content: Text("Tracking code copied"),
                              //     duration: Duration(seconds: 1),
                              //   ),
                              // );

                              AppSnackBar.showSuccess(
                                context,
                                "Tracking code copied",
                              );
                            },
                            child: const Icon(
                              Icons.copy, // 📄📄 double page feel
                              size: 14,
                              color: AppColors.electricTeal,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      CustomText(
                        txt: status.toUpperCase(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// BODY
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _routeRow(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      txt: "R$cost",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.electricTeal,
                    ),
                    CustomText(
                      txt: time,
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// FOOTER
          if (isActive)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrderDetailsScreen(orderId: orderId),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.electricTeal,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(
                        Icons.remove_red_eye,
                        size: 16,
                        color: AppColors.electricTeal,
                      ),
                      label: const Text(
                        "Details",
                        style: TextStyle(color: AppColors.electricTeal),
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
                                builder: (_) => OrderTrackingScreen(
                                  trackingCode: trackingCode!,
                                ),
                              ),
                            );
                          },
                      icon: const Icon(
                        Icons.map_outlined,
                        size: 16,
                        color: AppColors.pureWhite,
                      ),
                      label: const Text(
                        "Track",
                        style: TextStyle(color: AppColors.pureWhite),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'assigned':
        return Icons.local_shipping;
      case 'pending':
        return Icons.pending;
      case 'in_transit':
        return Icons.directions_car;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Widget _routeRow() {
    return Row(
      children: [
        Column(
          children: [
            _dot(AppColors.electricTeal),
            Container(
              width: 2,
              height: 28,
              color: AppColors.mediumGray.withOpacity(0.3),
            ),
            _dot(AppColors.limeGreen),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _routeText("Pickup", pickupCity),
              const SizedBox(height: 12),
              _routeText("Delivery", deliveryCity),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routeText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(txt: label, fontSize: 12, color: AppColors.mediumGray),
        CustomText(txt: value, fontSize: 15, fontWeight: FontWeight.w600),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in_transit':
        return Colors.blue;
      default:
        return AppColors.electricTeal;
    }
  }
}

/// ===============================================================
/// COMMON APP BAR
/// ===============================================================
AppBar _buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: AppColors.electricTeal,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_rounded, color: AppColors.pureWhite),
      onPressed: () => Navigator.pop(context),
    ),
    title: CustomText(
      txt: title,
      color: AppColors.pureWhite,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    centerTitle: true,
  );
}
