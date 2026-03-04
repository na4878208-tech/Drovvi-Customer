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