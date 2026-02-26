import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/constants/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common_widgets/custom_button.dart';
import '../../../../main.dart';
import '../../order_successful.dart';
import '../all_orders/orders_controller.dart';
import '../create_orders_screens/calculate_quotes/calculate_quote_controller.dart';
import '../create_orders_screens/fetch_order/place_order_controller.dart'
    hide orderControllerProvider;
import '../create_orders_screens/fetch_order/place_order_modal.dart';
import '../create_orders_screens/order_cache_provider.dart';
import 'payment_method_model.dart';

class PaymentMethodModal extends ConsumerStatefulWidget {
  final PaymentData paymentData;

  const PaymentMethodModal({super.key, required this.paymentData});

  @override
  ConsumerState<PaymentMethodModal> createState() => _PaymentMethodModalState();
}

class _PaymentMethodModalState extends ConsumerState<PaymentMethodModal> {
  String selectedMethod = 'wallet'; // 'wallet', 'card', 'pay_later'
  bool get walletEnabled => widget.paymentData.wallet.sufficient;

  Future<void> _placeOrder(BuildContext context) async {
    try {
      final cache = ref.read(orderCacheProvider);

      // Payment method cache mein save karo
      ref
          .read(orderCacheProvider.notifier)
          .saveValue('payment_method', selectedMethod);
      print("🎯 Selected Payment Method: $selectedMethod");

      final repository = ref.read(placeOrderRepositoryProvider);
      OrderResponse orderResponse;

      final isMultiStop = cache["is_multi_stop_enabled"] == "true";
      final bestQuote = ref.read(bestQuoteProvider);
      if (bestQuote == null) throw Exception("Please select a quote first");

      // MULTI-STOP ORDER
      if (isMultiStop) {
        final quantity = cache["quantity"]?.toString();
        if (quantity == null ||
            quantity.isEmpty ||
            int.tryParse(quantity) == 0) {
          final stopsCount =
              int.tryParse(cache["route_stops_count"]?.toString() ?? "0") ?? 0;
          int totalQty = 0;
          double totalWeight = 0.0;
          for (int i = 1; i <= stopsCount; i++) {
            totalQty +=
                int.tryParse(cache["stop_${i}_quantity"]?.toString() ?? "1") ??
                1;
            totalWeight +=
                double.tryParse(
                  cache["stop_${i}_weight"]?.toString() ?? "50",
                ) ??
                50.0;
          }
          ref
              .read(orderCacheProvider.notifier)
              .saveValue("quantity", totalQty.toString());
          ref
              .read(orderCacheProvider.notifier)
              .saveValue("total_weight", totalWeight.toString());
        }
        final request = await repository.prepareMultiStopOrderData();
        if (request.quantity < 1 || request.weightPerItem < 0.01) ;
        orderResponse = await repository.placeMultiStopOrder(request: request);
      }
      // STANDARD ORDER
      else {
        final request = await repository.prepareStandardOrderData();
        orderResponse = await repository.placeStandardOrder(request: request);
      }

      if (!orderResponse.success) throw Exception(orderResponse.message);

      final order = orderResponse.data.order;

      // ✅ Print response and clear cache **before WebView**
      print("✅ Order created successfully: ${order.orderNumber}");
      ref.read(orderCacheProvider.notifier).clearCache();
      print("🗑️ Order cache cleared after order creation");

      // WALLET OR PAY LATER
      if (selectedMethod == 'wallet' || selectedMethod == 'pay_later') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessful(
              orderNumber: order.orderNumber,
              status: order.status,
              totalAmount: order.finalCost,
              createedAt: order.createdAt,
              distanceKm: order.distanceKm,
              finalCost: order.finalCost,
              trackingCode: order.trackingCode,
              totalWeightKg: order.totalWeightKg,
              paymentMethod: selectedMethod,
              paymentStatus: order.paymentStatus,
            ),
          ),
          (route) => false,
        );
      }
      // CARD PAYMENT
      else if (selectedMethod == 'card') {
        if (orderResponse.requiresPayment == true) {
          final payment = orderResponse.data.payment;
          if (payment != null && payment.checkoutUrl.isNotEmpty) {
            // WebView open karo **order already created hai, cache cleared hai**
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentWebViewScreen(
                  checkoutUrl: payment.checkoutUrl,
                  orderId: order.id,
                ),
              ),
            );
          } else {
            throw Exception("Payment URL not received from server");
          }
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OrderSuccessful(
                orderNumber: order.orderNumber,
                status: order.status,
                totalAmount: order.finalCost,
                createedAt: order.createdAt,
                distanceKm: order.distanceKm,
                finalCost: order.finalCost,
                trackingCode: order.trackingCode,
                totalWeightKg: order.totalWeightKg,
                paymentMethod: selectedMethod,
                paymentStatus: order.paymentStatus,
              ),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print("❌ Error placing order: $e");

      AppSnackBar.showError(context, "Payment failed : Please try again");

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(e.toString()),
      //     backgroundColor: Colors.red,
      //     duration: const Duration(seconds: 5),
      //   ),
      // );
    }
  }

  Widget paymentTile({
    required String method, // 'wallet', 'card', 'pay_later'
    required String title,
    required String subtitle,
    required IconData icon,
    bool enabled = true,
  }) {
    final isSelected = selectedMethod == method;

    return InkWell(
      onTap: enabled ? () => setState(() => selectedMethod = method) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.electricTeal : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.electricTeal),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderControllerProvider);
    final quoteState = ref.watch(quoteControllerProvider);
    final bestQuote = ref.watch(bestQuoteProvider);
    final hasQuotes =
        quoteState.value != null && quoteState.value!.quotes.isNotEmpty;
    final canPlaceOrder = hasQuotes && bestQuote != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Payment Methods",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.red,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 1. Wallet Payment
          paymentTile(
            method: 'wallet',
            title: "Wallet payment",
            subtitle: walletEnabled
                ? "Wallet balance available"
                : "Insufficient balance",
            icon: Icons.wallet,
            enabled: walletEnabled,
          ),

          const SizedBox(height: 10),

          // 2. Credit Card
          paymentTile(
            method: 'card',
            title: "Credit/Debit Card",
            subtitle: "Secure payment",
            icon: Icons.credit_card,
            enabled: true,
          ),

          const SizedBox(height: 10),

          // 3. Pay Later
          paymentTile(
            method: 'pay_later',
            title: "Pay Later",
            subtitle: "Pay at your convenience",
            icon: Icons.watch_later_outlined,
            enabled: true,
          ),

          const SizedBox(height: 24),

          // Place Order Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomButton(
              text: orderState.isLoading ? "Processing..." : "Place Order",
              backgroundColor: canPlaceOrder
                  ? AppColors.electricTeal
                  : AppColors.lightGrayBackground,
              borderColor: canPlaceOrder
                  ? AppColors.electricTeal
                  : AppColors.lightGrayBackground,
              textColor: canPlaceOrder
                  ? AppColors.pureWhite
                  : Colors.grey.shade600,
              onPressed: canPlaceOrder && !orderState.isLoading
                  ? () => _placeOrder(context)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String checkoutUrl;
  final int orderId; // 👈 add this
  final String reference;

  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
    this.orderId = 0, // 👈 default value
    this.reference = "",
  });

  @override
  ConsumerState<PaymentWebViewScreen> createState() =>
      _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('🚀 Page started: $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            print('✅ Page finished: $url');
            setState(() => _isLoading = false);
            _checkPaymentResult(url);
          },
          onWebResourceError: (error) {
            print('❌ WebView Error: ${error.description}');
          },
          onNavigationRequest: (request) {
            print('🔗 Navigation to: ${request.url}');
            _checkPaymentResult(request.url);
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            print('🔄 URL Changed: ${change.url}');
            if (change.url != null) {
              _checkPaymentResult(change.url!);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _checkPaymentResult(String url) async {
    final successPatterns = [
      'success',
      'thank-you',
      'thank_you',
      'completed',
      'payment-success',
      'checkout/success',
    ];

    for (var pattern in successPatterns) {
      if (url.toLowerCase().contains(pattern)) {
        if (_paymentCompleted) return;
        _paymentCompleted = true;

        try {
          print("🔄 Payment success detected, waiting for backend update...");

          final repository = ref.read(placeOrderRepositoryProvider);

          Order updatedOrder;
          int retryCount = 0;

          // ⏳ Retry max 5 times (every 1.5 sec)
          do {
            await Future.delayed(const Duration(milliseconds: 1500));
            updatedOrder = await repository.getOrderById(widget.orderId);

            print(
              "🔁 Retry $retryCount → Payment Status: ${updatedOrder.paymentStatus}",
            );

            retryCount++;
          } while (updatedOrder.paymentStatus.toLowerCase() != "paid" &&
              retryCount < 5);

          if (!mounted) return;

          rootNavigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => OrderSuccessful(
                orderNumber: updatedOrder.orderNumber,
                status: updatedOrder.status,
                totalAmount: updatedOrder.finalCost,
                createedAt: updatedOrder.createdAt,
                distanceKm: updatedOrder.distanceKm,
                finalCost: updatedOrder.finalCost,
                trackingCode: updatedOrder.trackingCode,
                totalWeightKg: updatedOrder.totalWeightKg,
                paymentMethod: "card",
                paymentStatus: updatedOrder.paymentStatus,
              ),
            ),
            (route) => false,
          );

          print("✅ Final Payment Status: ${updatedOrder.paymentStatus}");
        } catch (e) {
          print("❌ Error fetching updated order: $e");
        }

        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Payment Management",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),

            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],

        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     // Ask for confirmation before closing
        //     showDialog(
        //       context: context,
        //       builder: (context) => AlertDialog(
        //         title: const Text("Cancel Payment?"),
        //         content: const Text(
        //           "Are you sure you want to cancel the payment?",
        //         ),
        //         actions: [
        //           TextButton(
        //             onPressed: () => Navigator.pop(context),
        //             child: const Text("No"),
        //           ),
        //           TextButton(
        //             onPressed: () {
        //               Navigator.pop(context); // Close dialog
        //               Navigator.pop(context); // Close WebView
        //             },
        //             child: const Text("Yes"),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
      ),

      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.teal),
                  // SizedBox(height: 16),
                  // Text(
                  //   "Loading payment gateway...",
                  //   style: TextStyle(color: Colors.teal, fontSize: 16),
                  // ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
