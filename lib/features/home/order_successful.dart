import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logisticscustomer/features/bottom_navbar/bottom_navbar_screen.dart';
import '../../constants/colors.dart';
import 'package:lottie/lottie.dart';

class OrderSuccessful extends StatelessWidget {
  final String orderNumber;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final double totalWeightKg;
  final String trackingCode;
  final double distanceKm;
  final double finalCost;
  final String createedAt;

  const OrderSuccessful({
    super.key,
    required this.totalAmount,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalWeightKg,
    required this.trackingCode,
    required this.distanceKm,
    required this.finalCost,
    required this.createedAt,
  });

  String _formatDate(String rawDate) {
    try {
      DateTime parsedDate = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return rawDate; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showShipmentDetails = paymentMethod != "card";
    final String formattedDate = _formatDate(createedAt);
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Lottie.asset(
                  "assets/Success.json",
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                  repeat: false,
                  animate: true,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Order Placed Successfully!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 20),

              // Order Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mediumGray.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.electricTeal.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: AppColors.electricTeal,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Order Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Divider(color: AppColors.lightGrayBackground, thickness: 1),

                    const SizedBox(height: 15),

                    /// Reusable Row Builder
                    _buildDetailRow("Order Number", orderNumber),
                    _buildDetailRow("Tracking Code", trackingCode),

                    if (showShipmentDetails) ...[
                      _buildDetailRow(
                        "Weight",
                        "${totalWeightKg.toStringAsFixed(2)} kg",
                      ),
                      _buildDetailRow(
                        "Distance",
                        "${distanceKm.toStringAsFixed(2)} km",
                      ),
                    ],

                    _buildDetailRow(
                      "Status",
                      status,
                      valueColor: AppColors.electricTeal,
                    ),

                    _buildDetailRow(
                      "Payment Status",
                      paymentStatus,
                      valueColor: AppColors.electricTeal,
                    ),

                    _buildDetailRow(
                      "Total Amount",
                      "R${totalAmount.toStringAsFixed(2)}",
                    ),

                    _buildDetailRow("Payment Method", paymentMethod),

                    _buildDetailRow("Created At", formattedDate),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TripsBottomNavBarScreen(initialIndex: 2, trackingCode: trackingCode,),
                            ),
                          );
                        },
                        child: const Text(
                          "Track Order",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.electricTeal,
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TripsBottomNavBarScreen(initialIndex: 0),
                            ),
                          );
                        },
                        child: Text(
                          "Back to Home",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.electricTeal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildDetailRow(String title, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: TextStyle(fontSize: 14, color: AppColors.darkGray),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.darkText,
            ),
          ),
        ),
      ],
    ),
  );
}
