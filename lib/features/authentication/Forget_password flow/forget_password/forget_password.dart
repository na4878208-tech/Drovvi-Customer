import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/constants/validation_regx.dart';
import 'package:logisticscustomer/features/authentication/Forget_password%20flow/rest_verification_otp/rest_verification_otp.dart';
import '../../../../export.dart';
import 'forget_password_controller.dart';

class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({super.key});

  @override
  ConsumerState<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword> {
  final _formKey = GlobalKey<FormState>(); // ✅ ADD
  final emailFocus = FocusNode();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailFocus.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgotPasswordState = ref.watch(forgotPasswordControllerProvider);

    ref.listen(forgotPasswordControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (response) {
          if (response != null && response.success) {
            // ScaffoldMessenger.of(
            //   context,
            // ).showSnackBar(SnackBar(content: Text(response.message)));

            AppSnackBar.showSuccess(context, response.message);

            /// ✅ Navigate with EMAIL DATA
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestVerificationScreen(
                  forgotPasswordData: response.data, // FIX
                ),
              ),
            );
          }
        },
        error: (error, _) {
          AppSnackBar.showError(context, error.toString());
          // ScaffoldMessenger.of(
          //   context,
          // ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            // ✅ FORM WRAP
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// 🔙 Back
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Back",
                      style: TextStyle(
                        color: AppColors.electricTeal,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Text(
                  "Drovvi",
                  style: TextStyle(
                    color: AppColors.electricTeal,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                gapH32,

                Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.electricTeal,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Please enter your Register email\naddress to reset your password",
                  style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
                  textAlign: TextAlign.center,
                ),

                gapH20,

                /// 📧 Email Field
                CustomAnimatedTextField(
                  controller: emailController,
                  focusNode: emailFocus,
                  labelText: "Email ID",
                  hintText: "Email ID",
                  prefixIcon: Icons.email_outlined,
                  iconColor: AppColors.electricTeal,
                  borderColor: AppColors.electricTeal,
                  textColor: AppColors.mediumGray,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.email, // ✅ VALIDATION
                ),

                gapH64,

                /// ✅ BUTTON ALWAYS ACTIVE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    isChecked: !forgotPasswordState.isLoading,
                    text: forgotPasswordState.isLoading
                        ? "Sending..."
                        : "Submit",
                    backgroundColor: AppColors.electricTeal,
                    borderColor: AppColors.electricTeal,
                    textColor: AppColors.lightGrayBackground,
                    onPressed: forgotPasswordState.isLoading
                        ? null
                        : () {
                            final isValid = _formKey.currentState!.validate();
                            if (!isValid) return;

                            ref
                                .read(forgotPasswordControllerProvider.notifier)
                                .forgotPassword(
                                  email: emailController.text.trim(),
                                );
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
