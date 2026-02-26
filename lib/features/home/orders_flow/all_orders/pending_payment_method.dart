import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/local_storage.dart';
import 'package:logisticscustomer/features/home/orders_flow/all_orders/get_all_orders_modal.dart';
import 'package:logisticscustomer/features/home/orders_flow/all_orders/orders_controller.dart';
import 'package:http/http.dart' as http;
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/fetch_order/place_order_modal.dart';
import 'package:logisticscustomer/features/home/orders_flow/payment_method_orders/payment_method_screen.dart';
import 'dart:convert';
import '../../../../export.dart';



class PaymentOptionsModal extends ConsumerStatefulWidget {
  final AlOrder order;
  final WidgetRef ref;

  const PaymentOptionsModal({Key? key, required this.order, required this.ref})
    : super(key: key);

  @override
  ConsumerState<PaymentOptionsModal> createState() =>
      _PaymentOptionsModalState();
}

class _PaymentOptionsModalState extends ConsumerState<PaymentOptionsModal> {
  bool _isProcessing = false;
  String? _selectedMethod;
  String? _errorMessage;

  Future<void> _processWalletPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Replace with your actual API base URL
      final baseUrl = 'seedlink.skyguruu.com/api/v1/customer/payment';
      final url = Uri.parse('$baseUrl/orders/${widget.order.id}/pay-wallet');

      // Get token from your storage (adjust as per your auth implementation)
      // final token = await _getAuthToken();
      final token = await LocalStorage.getToken() ?? "";

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("Wallet Payment Response: $result");
        print("Wallet Payment Response Success: ${result['success']}");

        if (result['success'] == true) {
          // Success - show confirmation and refresh orders
          _showSuccessDialog('Payment successful via wallet!');

          // Refresh orders list
          widget.ref.read(orderControllerProvider.notifier).refreshOrders();

          // Close bottom sheet
          Navigator.pop(context);
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Payment failed';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processCardPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = 'seedlink.skyguruu.com/api/v1/customer/payment';
      final url = Uri.parse('$baseUrl/orders/${widget.order.id}/pay-card');

      // final token = await _getAuthToken();

      final token = await LocalStorage.getToken() ?? "";

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("card Payment Response: $result");
        print("card Payment Response Success: ${result['success']}");

        if (result['success'] == true) {
          if (result['requires_payment'] == true) {
            // Card payment requires webview for checkout
            final checkoutUrl = result['data']['payment']['checkout_url'];

            // Close bottom sheet first
            Navigator.pop(context);

            // Open webview for payment
            _openPaymentWebView(checkoutUrl, OrderResponse.fromJson(result));
          } else {
            // Direct success
            _showSuccessDialog('Payment successful via card!');
            widget.ref.read(orderControllerProvider.notifier).refreshOrders();
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Payment failed';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppColors.darkText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.electricTeal)),
          ),
        ],
      ),
    );
  }

  void _openPaymentWebView(String url, OrderResponse orderResponse) {
    final payment = orderResponse.data.payment;

    // double amount =
    //         double.tryParse(amountController.text) ?? 0;
    // if (amount <= 0) return;

    // 1️⃣ Hit API to get checkout URL
    // final response = await topUpController.topUp(amount: amount);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebViewScreen(
          checkoutUrl: payment!.checkoutUrl,
          reference: payment.reference,
           orderId: widget.order.id ?? 0 
          // orderId: order.id,
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payment Options",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.mediumGray),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "Order: ${widget.order.orderNumber}",
            style: TextStyle(fontSize: 16, color: AppColors.darkText),
          ),

          const SizedBox(height: 4),

          Text(
            "Amount: R ${widget.order.finalCost ?? '--'}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.electricTeal,
            ),
          ),

          const SizedBox(height: 24),

          // Payment Options
          Text(
            "Select Payment Method:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),

          const SizedBox(height: 16),

          // Wallet Option
          _buildPaymentOption(
            title: "Pay with Wallet",
            subtitle: "Instant payment from your wallet balance",
            icon: Icons.account_balance_wallet,
            iconColor: Colors.green,
            isSelected: _selectedMethod == 'wallet',
            onTap: () => setState(() => _selectedMethod = 'wallet'),
          ),

          const SizedBox(height: 12),

          // Card Option
          _buildPaymentOption(
            title: "Pay with Card",
            subtitle: "Credit/Debit card payment",
            icon: Icons.credit_card,
            iconColor: Colors.blue,
            isSelected: _selectedMethod == 'card',
            onTap: () => setState(() => _selectedMethod = 'card'),
          ),

          const SizedBox(height: 8),

          // Payment Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGrayBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.electricTeal,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Wallet payments are instant. Card payments will redirect to secure payment gateway.",
                    style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
                  ),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Pay Now Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing || _selectedMethod == null
                  ? null
                  : () {
                      if (_selectedMethod == 'wallet') {
                        _processWalletPayment();
                      } else if (_selectedMethod == 'card') {
                        _processCardPayment();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricTeal,
                foregroundColor: AppColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.pureWhite,
                      ),
                    )
                  : Text(
                      "Pay Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 16, color: AppColors.mediumGray),
              ),
            ),
          ),

          // Safe area for bottom
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.electricTeal.withOpacity(0.1)
              : AppColors.lightGrayBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.electricTeal : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: AppColors.mediumGray),
                  ),
                ],
              ),
            ),

            // Radio
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.electricTeal
                      : AppColors.mediumGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.electricTeal,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
