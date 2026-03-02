// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:logisticscustomer/features/bottom_navbar/bottom_navbar_screen.dart';

// import '../../../../common_widgets/custom_text.dart';
// import '../../../../constants/colors.dart';
// import 'order_tracking_controller.dart';
// import 'order_tracking_model.dart';

// class OrderTrackingScreen extends ConsumerWidget {
//   final String trackingCode;

//   const OrderTrackingScreen({super.key, required this.trackingCode});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(orderTrackingControllerProvider(trackingCode));

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
      // appBar: AppBar(
      //   title: CustomText(txt: "Order Tracking"),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: AppColors.electricTeal,
      //   foregroundColor: Colors.white,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_outlined, size: 20),
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => TripsBottomNavBarScreen(initialIndex: 1),
      //         ),
      //       );
      //     },
      //   ),
      // ),
//       body: state.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text(e.toString())),
//         data: (model) {
//           final order = model!.data;

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 _statusHeader(order),
//                 const SizedBox(height: 20),
//                 _progressSection(order),
//                 const SizedBox(height: 20),

//                 /// 👇 ROUTE (SINGLE / MULTI)
//                 order.isMultiStop
//                     ? _multiStopTimeline(order.stops)
//                     : _singleRouteCard(order),

//                 const SizedBox(height: 20),
//                 _driverCard(order),
//                 const SizedBox(height: 20),
//                 _vehicleCard(order),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _statusHeader(order) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.electricTeal,
//             AppColors.electricTeal.withOpacity(0.7),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             order.orderNumber,
//             style: const TextStyle(color: Colors.white, fontSize: 13),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             order.statusLabel,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             "Tracking Code: ${order.trackingCode}",
//             style: const TextStyle(color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _progressSection(order) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Progress ${order.progressPercent}%",
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 8),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: LinearProgressIndicator(
//             value: order.progressPercent / 100,
//             minHeight: 10,
//             backgroundColor: Colors.grey[300],
//             color: AppColors.electricTeal,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _singleRouteCard(order) {
//     return _infoCard(
//       title: "Route Details",
//       subtitle: "Pickup & delivery information",
//       icon: Icons.route_outlined,
//       children: [
//         _routeRow(
//           label: "PICKUP",
//           value: order.pickupAddress ?? "",
//           icon: Icons.upload_rounded,
//           color: AppColors.electricTeal,
//           isLast: false,
//         ),
//         _routeRow(
//           label: "DELIVERY",
//           value: order.deliveryAddress ?? "",
//           icon: Icons.download_rounded,
//           color: Colors.green,
//           isLast: true,
//         ),
//       ],
//     );
//   }

//   Widget _multiStopTimeline(List<TrackOrderStop> stops) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: const [
//               Icon(Icons.timeline, color: AppColors.electricTeal),
//               SizedBox(width: 10),
//               Text(
//                 "Route Timeline",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           ...stops.map((stop) => _stopTile(stop)).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _stopTile(TrackOrderStop stop) {
//     Color statusColor;

//     switch (stop.status) {
//       case "completed":
//         statusColor = Colors.green;
//         break;
//       case "arrived":
//         statusColor = AppColors.electricTeal;
//         break;
//       case "skipped":
//         statusColor = Colors.orange;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: stop.isCurrent
//             ? AppColors.electricTeal.withOpacity(0.08)
//             : Colors.grey[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: statusColor.withOpacity(0.4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 12,
//                 backgroundColor: statusColor,
//                 child: Text(
//                   stop.sequence.toString(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 stop.type.toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: statusColor,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 stop.statusLabel,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: statusColor,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 8),
//           Text(
//             stop.contactName,
//             style: const TextStyle(fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             "${stop.address}, ${stop.city}",
//             style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//           ),

//           if (stop.arrivalTime != null) ...[
//             const SizedBox(height: 6),
//             Text(
//               "Arrived: ${stop.arrivalTime}",
//               style: const TextStyle(fontSize: 12),
//             ),
//           ],

//           if (stop.departureTime != null) ...[
//             const SizedBox(height: 4),
//             Text(
//               "Departed: ${stop.departureTime}",
//               style: const TextStyle(fontSize: 12),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _driverCard(order) {
//     final driver = order.driver;

//     return _infoCard(
//       title: "Driver Details",
//       subtitle: "Assigned driver information",
//       icon: Icons.person_outline,
//       children: [
//         /// Driver Header
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 26,
//               backgroundColor: AppColors.electricTeal.withOpacity(0.1),
//               child: Text(
//                 driver.name.isNotEmpty ? driver.name[0].toUpperCase() : "?",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.electricTeal,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     driver.name.isEmpty ? "-" : driver.name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(Icons.star, size: 16, color: Colors.amber.shade600),
//                       const SizedBox(width: 4),
//                       Text(
//                         driver.rating?.toString() ?? "-",
//                         style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             if (driver.phone.isNotEmpty)
//               InkWell(
//                 onTap: () {
//                   // implement call launch logic here
//                 },
//                 borderRadius: BorderRadius.circular(10),
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.call, color: Colors.green, size: 20),
//                 ),
//               ),
//           ],
//         ),

//         const SizedBox(height: 22),

//         Divider(color: Colors.grey.shade200),

//         const SizedBox(height: 18),

//         /// Phone Row
//         _detailRow(
//           icon: Icons.phone_outlined,
//           label: "Phone",
//           value: driver.phone,
//         ),
//       ],
//     );
//   }

//   Widget _vehicleCard(order) {
//     final vehicle = order.vehicle;

//     return _infoCard(
//       title: "Vehicle Details",
//       subtitle: "Assigned vehicle information",
//       icon: Icons.local_shipping_outlined,
//       children: [
//         /// Vehicle Name
//         Text(
//           "${vehicle.make} ${vehicle.model}".trim().isEmpty
//               ? "-"
//               : "${vehicle.make} ${vehicle.model}",
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//         ),

//         const SizedBox(height: 18),

//         Divider(color: Colors.grey.shade200),

//         const SizedBox(height: 18),

//         _detailRow(
//           icon: Icons.category_outlined,
//           label: "Type",
//           value: vehicle.type,
//         ),

//         const SizedBox(height: 16),

//         _detailRow(
//           icon: Icons.confirmation_number_outlined,
//           label: "Registration",
//           value: vehicle.registration,
//         ),
//       ],
//     );
//   }

//   Widget _detailRow({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 18, color: Colors.grey.shade600),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value.isEmpty ? "-" : value,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _infoCard({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 18),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// HEADER
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppColors.electricTeal.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon, size: 20, color: AppColors.electricTeal),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           /// BODY
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget _routeRow({
//     required String label,
//     required String value,
//     required IconData icon,
//     required Color color,
//     required bool isLast,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// LEFT ICON + LINE
//         Column(
//           children: [
//             Container(
//               width: 28,
//               height: 28,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 14, color: color),
//             ),
//             if (!isLast)
//               Container(
//                 width: 2,
//                 height: 36,
//                 margin: const EdgeInsets.symmetric(vertical: 4),
//                 color: Colors.grey.shade300,
//               ),
//           ],
//         ),

//         const SizedBox(width: 14),

//         /// RIGHT CONTENT
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 18),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.4,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value.isEmpty ? "-" : value,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common_widgets/custom_text.dart';
import '../../../../constants/colors.dart';
import '../../../bottom_navbar/bottom_navbar_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String trackingCode;

  const OrderTrackingScreen({super.key, required this.trackingCode});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();

    /// ✅ Load webview ONLY if tracking code exists
    if (widget.trackingCode.isNotEmpty) {
      final url = "https://drovvi.com/track/${widget.trackingCode}";

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(txt: "Order Tracking"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.electricTeal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, size: 20),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const TripsBottomNavBarScreen(initialIndex: 1),
              ),
            );
          },
        ),
      ),

      /// ✅ BODY CONDITION
      body: widget.trackingCode.isEmpty
          ? const Center(
              child: Text(
                "No order track to select",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            )
          : WebViewWidget(controller: _controller!),
    );
  }
}