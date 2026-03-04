// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:logisticscustomer/common_widgets/custom_button.dart';
// import 'package:logisticscustomer/common_widgets/custom_text.dart';
// import 'package:logisticscustomer/constants/colors.dart';
// import 'package:logisticscustomer/constants/gap.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   final MapController _mapController = MapController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightGrayBackground,
//       appBar: AppBar(
//         title: const Text(
//           "Track Order",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 45,
//         backgroundColor: AppColors.electricTeal,
//         foregroundColor: AppColors.pureWhite,
//       ),
//       body: Column(
//         children: [
//           // --- Flexible Map + Details ---
//           Expanded(
//             child: Stack(
//               children: [
//                 // MAP FULL HEIGHT
//                 FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(minZoom: 5, maxZoom: 18),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                       userAgentPackageName: 'com.example.logisticdriverapp',
//                     ),
//                   ],
//                 ),

//                 // DETAILS PANEL
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: DraggableScrollableSheet(
//                     initialChildSize: 0.35, // start height fraction
//                     minChildSize: 0.1, // minimum collapsed
//                     maxChildSize: 0.9, // max expanded
//                     builder: (context, scrollController) {
//                       return Container(
//                         padding: const EdgeInsets.only(left: 15,right: 15, top: 20),
//                         decoration: BoxDecoration(
//                           color: AppColors.pureWhite,
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(20),
//                             topRight: Radius.circular(20),
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppColors.subtleGray,
//                               blurRadius: 10,
//                               offset: const Offset(0, -2),
//                             ),
//                           ],
//                         ),
//                         child: ListView(
//                           controller: scrollController,
//                           children: [
//                             // Status
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.circle,
//                                   color: AppColors.electricTeal,
//                                   size: 12,
//                                 ),
//                                 SizedBox(width: 8),
//                                 CustomText(
//                                   txt: "In Transit",
//                                   fontSize: 17,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.darkText,
//                                 ),
//                               ],
//                             ),
//                             gapH12,

//                             // ETA / Distance
//                             Container(
//                               padding: const EdgeInsets.all(20),
//                               decoration: BoxDecoration(
//                                 color: AppColors.lightGrayBackground,
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 children: [
//                                   _summaryItem("ETA", "15 minutes"),
//                                   _verticalDivider(),
//                                   _summaryItem("Distance", "3.2 km"),
//                                 ],
//                               ),
//                             ),
//                             gapH12,

//                             // Driver Info
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 10,
//                                 horizontal: 14,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.lightGrayBackground,
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: Column(
//                                 children: [
//                                   _collectionRow(
//                                     Icons.person,
//                                     "Driver: John D.",
//                                   ),
//                                   _divider(),
//                                   _collectionRow(Icons.phone, "12345678909"),
//                                   _divider(),
//                                   _collectionRow(Icons.star, "4.8 rating"),
//                                   _divider(),
//                                   _collectionRow(Icons.local_taxi, "ABC-1234"),
//                                   _divider(),
//                                   _collectionRow(Icons.all_inbox, "Process"),
//                                   _divider(),
//                                   _collectionRow(
//                                     Icons.check_circle,
//                                     "Order Confirmed",
//                                   ),
//                                   _divider(),
//                                   _collectionRow(
//                                     Icons.check_circle,
//                                     "Driver Assigned",
//                                   ),
//                                   _divider(),
//                                   _collectionRow(
//                                     Icons.check_circle,
//                                     "Picked up",
//                                   ),
//                                   _divider(),
//                                   _collectionRow(
//                                     Icons.access_time,
//                                     "Delivery Pending",
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             gapH16,

//                             // Buttons
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: CustomButton(
//                                     text: "Contact Support",
//                                     backgroundColor: AppColors.electricTeal,
//                                     borderColor: AppColors.electricTeal,
//                                     textColor: AppColors.pureWhite,
//                                     onPressed: () {},
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: CustomButton(
//                                     text: "Cancel Order",
//                                     backgroundColor:
//                                         AppColors.lightGrayBackground,
//                                     borderColor: AppColors.electricTeal,
//                                     textColor: AppColors.electricTeal,
//                                     onPressed: () {},
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             gapH20,
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _summaryItem(String value, String label) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: AppColors.electricTeal,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 13, color: AppColors.darkText),
//         ),
//       ],
//     );
//   }

//   Widget _verticalDivider() {
//     return Container(width: 2, height: 32, color: AppColors.electricTeal);
//   }

//   Widget _collectionRow(IconData icon, String amount) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Icon(icon, size: 22, color: AppColors.electricTeal),
//           CustomText(
//             txt: amount,
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: AppColors.darkText,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _divider() {
//     return Divider(color: AppColors.subtleGray, thickness: 1, height: 1);
//   }
// }
