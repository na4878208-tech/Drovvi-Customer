import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import '../../../../common_widgets/cuntom_textfield.dart';
import '../../../../common_widgets/custom_button.dart';
import '../../../../common_widgets/custom_text.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/validation_regx.dart';
import '../../login/login.dart';
import 'rest_password_controller.dart';
import 'rest_password_model.dart';

class RestPasswordScreen extends ConsumerStatefulWidget {
  final String token;
  const RestPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<RestPasswordScreen> createState() => _RestPasswordScreenState();
}

class _RestPasswordScreenState extends ConsumerState<RestPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final passwordFocus = FocusNode();
  final confrompasswordFocus = FocusNode();

  bool _obscureNewPass = true;
  bool _obscureConPass = true;

  bool _showNewPassEye = false;
  bool _showConPassEye = false;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(() {
      setState(() => _showNewPassEye = newPasswordController.text.isNotEmpty);
    });
    confirmPasswordController.addListener(() {
      setState(
        () => _showConPassEye = confirmPasswordController.text.isNotEmpty,
      );
    });
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// ✅ Listen to API response
    ref.listen<AsyncValue<RestPasswordModel?>>(restPasswordControllerProvider, (
      prev,
      next,
    ) {
      next.when(
        data: (data) {
          if (data != null && data.success) {
            print("✅ Reset Password Success: ${data.toJson()}");

            AppSnackBar.showSuccess(context, data.message);

            /// ✅ Navigate to Login Screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => Login()),
              (route) => false,
            );
          }
        },
        loading: () {},
        error: (err, st) {
          print("❌ Reset Password Error: $err");

          AppSnackBar.showError(context, err.toString());

        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                CustomText(
                  txt: "DROVVI",
                  color: AppColors.electricTeal,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 40),
                CustomText(
                  txt: "Reset Your Password",
                  color: AppColors.electricTeal,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 10),
                CustomText(
                  txt: "Set your new password so you can log in",
                  align: TextAlign.center,
                  color: AppColors.mediumGray,
                  fontSize: 14,
                  height: 1.5,
                ),
                const SizedBox(height: 35),

                CustomAnimatedTextField(
                  controller: newPasswordController,
                  focusNode: passwordFocus,
                  labelText: "New Password",
                  hintText: "New Password",
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureNewPass,
                  validator: AppValidators.newPassword,
                  suffixIcon: _showNewPassEye
                      ? IconButton(
                          icon: Icon(
                            _obscureNewPass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.darkText,
                          ),
                          onPressed: () => setState(
                            () => _obscureNewPass = !_obscureNewPass,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                CustomAnimatedTextField(
                  controller: confirmPasswordController,
                  focusNode: confrompasswordFocus,
                  labelText: "Confirm Password",
                  hintText: "Confirm Password",
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConPass,
                  validator: (val) => AppValidators.confirmPassword(
                    val,
                    newPasswordController.text,
                  ),
                  suffixIcon: _showConPassEye
                      ? IconButton(
                          icon: Icon(
                            _obscureConPass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.darkText,
                          ),
                          onPressed: () => setState(
                            () => _obscureConPass = !_obscureConPass,
                          ),
                        )
                      : null,
                ),

                const SizedBox(height: 64),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    text: "Submit",
                    backgroundColor: AppColors.electricTeal,
                    borderColor: AppColors.electricTeal,
                    textColor: AppColors.pureWhite,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final password = newPasswordController.text.trim();
                      final confirmPassword = confirmPasswordController.text
                          .trim();

                      /// ✅ Call reset password API
                      await ref
                          .read(restPasswordControllerProvider.notifier)
                          .resetPassword(
                            token: widget.token,
                            password: password,
                            confirmPassword: confirmPassword,
                          );
                    },
                  ),
                ),

                const SizedBox(height: 35),

                /// Password Policy
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Password Policy:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 10),
                      _PolicyItem(
                        text: "Length must between 8 to 20 character",
                      ),
                      _PolicyItem(
                        text: "A combination of upper and lower case letters.",
                      ),
                      _PolicyItem(text: "Contain letters and numbers"),
                      _PolicyItem(
                        text: "A special character such as @, #, !, * and \$",
                      ),
                    ],
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

/// Reusable Policy Item Widget
class _PolicyItem extends StatelessWidget {
  final String text;
  const _PolicyItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.electricTeal,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              txt: text,
              color: AppColors.mediumGray,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
