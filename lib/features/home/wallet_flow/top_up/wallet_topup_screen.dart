import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/common_widgets/custom_text.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/export.dart';
import 'package:logisticscustomer/features/home/orders_flow/payment_method_orders/payment_method_screen.dart';
import '../../../../common_widgets/cuntom_textfield.dart';
import '../../../../common_widgets/custom_button.dart';
import '../../../../constants/colors.dart';
import 'wallet_topup_controller.dart';

class WalletTopUPScreen extends ConsumerStatefulWidget {
  const WalletTopUPScreen({super.key});

  @override
  ConsumerState<WalletTopUPScreen> createState() => _WalletTopUPScreenState();
}

class _WalletTopUPScreenState extends ConsumerState<WalletTopUPScreen> {
  final TextEditingController amountController = TextEditingController(
    text: "100",
  );

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topUpState = ref.watch(walletTopUpControllerProvider);
    final topUpController = ref.read(walletTopUpControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          txt: "Add Money to Wallet",
          color: AppColors.pureWhite,
          fontSize: 18,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.pureWhite,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            gapH20,
            CustomAnimatedTextField(
              controller: amountController,
              focusNode: FocusNode(),
              labelText: "Amount to Add",
              hintText: "Enter amount",
              prefixIcon: Icons.attach_money,
              iconColor: AppColors.electricTeal,
              borderColor: AppColors.electricTeal,
              textColor: AppColors.mediumGray,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomButton(
                text: "Pay with YOCO",
                backgroundColor: AppColors.electricTeal,
                borderColor: AppColors.electricTeal,
                textColor: AppColors.lightGrayBackground,
                onPressed: () async {
                  double amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) return;

                  // 1️⃣ Hit API to get checkout URL
                  final response = await topUpController.topUp(amount: amount);
                  if (response != null) {
                    // 2️⃣ Open WebView for checkout
                    // final result = await Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => YocoPaymentWebView(
                    //       checkoutUrl: response.data.checkoutUrl,
                    //       reference: response.data.reference,
                    //     ),
                    //   ),
                    // );

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentWebViewScreen(
                          // checkoutUrl: payment!.checkoutUrl,
                          checkoutUrl: response.data.checkoutUrl,

                          // reference: payment.reference,
                          reference: response.data.reference,

                          // orderId: widget.order.id ?? 0,
                          orderId:
                              0, // Pass 0 or any dummy value since it's not used in wallet top-up
                          // orderId: order.id,
                        ),
                      ),
                    );

                    // 3️⃣ Show result
                    if (result != null && result['success'] == true) {
                      AppSnackBar.showSuccess(context, "Payment Successful!");

                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text("Payment Successful!"),
                      //     backgroundColor: Colors.green,
                      //   ),
                      // );
                    } else {
                      print("Wallet Payment failed : Please try again $result");
                      AppSnackBar.showError(
                        context,
                        "Wallet Payment failed : Please try again",
                      );

                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text(result?['message'] ?? "Payment failed"),
                      //     backgroundColor: Colors.red,
                      //   ),
                      // );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            if (topUpState.isLoading)
              const CircularProgressIndicator(color: AppColors.electricTeal),
          ],
        ),
      ),
    );
  }
}
