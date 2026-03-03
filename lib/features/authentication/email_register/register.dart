import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/features/authentication/email_register/email_register_controller.dart';
import 'package:logisticscustomer/features/support/terms_and_condition.dart';

import '../../../constants/validation_regx.dart';
import '../../../export.dart';
import '../../support/privicy_policy.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final emailFocus = FocusNode();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;

  @override
  void dispose() {
    _focusNode.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailRegisterState = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "DROVVI",
                  style: TextStyle(
                    color: AppColors.electricTeal,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.electricTeal,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please enter your Email ID to Sign Up.",
                  style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

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
                  validator: AppValidators.email,
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (val) =>
                          setState(() => isChecked = val ?? false),
                      activeColor: AppColors.electricTeal,
                      side: BorderSide(color: AppColors.electricTeal, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    Expanded(
                      child: Wrap(
                        children: [
                          const Text(
                            "By continuing, I confirm that I have read the ",
                            style: TextStyle(
                              color: AppColors.mediumGray,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TermsConditionWebViewScreen(
                                        title: "Terms of Service",
                                        url:
                                            "https://drovvi.com/terms-of-service",
                                      ),
                                ),
                              );
                            },
                            child: Text(
                              "Terms of Use",
                              style: TextStyle(
                                color: AppColors.electricTeal,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Text(
                            " and ",
                            style: TextStyle(
                              color: AppColors.mediumGray,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TermsPrivacyWebViewScreen(
                                        title: "Privacy Policy",
                                        url:
                                            "https://drovvi.com/privacy-policy",
                                      ),
                                ),
                              );
                            },
                            child: Text(
                              "Privacy Policy",
                              style: TextStyle(
                                color: AppColors.electricTeal,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // gapH64,
                gapH48,

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    isChecked: isChecked,
                    // text: "Sign Up",
                    text: emailRegisterState.isLoading
                        ? "Processing..."
                        : "Sign Up",
                    backgroundColor: AppColors.electricTeal,
                    borderColor: AppColors.electricTeal,
                    textColor: AppColors.pureWhite,

                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final email = emailController.text.trim();

                      await ref
                          .read(authControllerProvider.notifier)
                          .sendOtpToEmail(email);

                      final state = ref.read(authControllerProvider);

                      // SUCCESS → navigate
                      if (state is AsyncData && state.value != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerificationScreen(
                              emailRegisterModal: state.value!,
                            ),
                          ),
                        );
                      }

                      if (state is AsyncError) {
                        AppSnackBar.showError(context, "Email Already Exist!");
                      }
                    },
                  ),
                ),

                const SizedBox(height: 30),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already a Drovvi Member? ",
                      style: TextStyle(
                        color: AppColors.mediumGray,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: AppColors.electricTeal,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
