import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/features/authentication/login/login_controller.dart';

import '../../../constants/validation_regx.dart';
import '../../../export.dart';
import '../../bottom_navbar/bottom_navbar_screen.dart';
import '../Forget_password flow/forget_password/forget_password.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final emailFocus = FocusNode();
  // final FocusNode _focusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();
  final passwordFocus = FocusNode();
  bool _obscureNewPass = true;

  bool _showNewPassEye = false;
  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();
    PasswordController.addListener(_passwordListener);
    emailController.addListener(_checkFormFilled); // jab email change ho
    PasswordController.addListener(_checkFormFilled); // jab password change ho
  }

  void _passwordListener() {
    final shouldShow = PasswordController.text.isNotEmpty;
    if (shouldShow != _showNewPassEye) {
      setState(() => _showNewPassEye = shouldShow);
    }
  }

  ///  check karega ki dono fields filled hain ya nahi
  void _checkFormFilled() {
    final isFilled =
        emailController.text.isNotEmpty && PasswordController.text.isNotEmpty;

    if (isFilled != _isFormFilled) {
      setState(() => _isFormFilled = isFilled);
    }
  }

  // bool isChecked = false;

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    emailController.dispose();
    PasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);

    final Color inactiveColor = AppColors.mediumGray;
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
              gapH32,
              Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.electricTeal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please enter your email or password to Sign In.",
                style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              gapH20,

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
              gapH20,

              /// New Password Field
              CustomAnimatedTextField(
                controller: PasswordController,
                focusNode: passwordFocus,
                labelText: "Password",
                hintText: "Password",
                prefixIcon: Icons.lock_outline,
                iconColor: AppColors.electricTeal,
                borderColor: AppColors.electricTeal,
                textColor: AppColors.mediumGray,
                obscureText: _obscureNewPass,
                validator: AppValidators.password,
                suffixIcon: _showNewPassEye
                    ? IconButton(
                        icon: Icon(
                          _obscureNewPass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPass = !_obscureNewPass;
                          });
                        },
                      )
                    : null,
              ),

              gapH20,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPassword(),
                        ),
                      );
                    },
                    child: CustomText(
                      txt: "Forgot Password",
                      color: AppColors.electricTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // gapH64,
              gapH32,

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  isChecked: _isFormFilled && !loginState.isLoading,

                  text: loginState.isLoading ? "Signing In..." : "Sign In",

                  backgroundColor: (_isFormFilled && !loginState.isLoading)
                      ? AppColors.electricTeal
                      : inactiveColor,

                  borderColor: AppColors.electricTeal,
                  textColor: AppColors.lightGrayBackground,

                  onPressed: (_isFormFilled && !loginState.isLoading)
                      ? () async {
                          final email = emailController.text.trim();
                          final password = PasswordController.text.trim();

                          await ref
                              .read(loginControllerProvider.notifier)
                              .login(email, password);

                          final state = ref.read(loginControllerProvider);

                          if (state is AsyncData && state.value != null) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TripsBottomNavBarScreen(
                                  initialIndex: 0,
                                ),
                              ),
                              (route) => false,
                            );
                          } else if (state is AsyncError) {
                            AppSnackBar.showError(
                              context,
                              "Invalid email or password",
                            );
                          }
                        }
                      : null,
                ),
              ),
              gapH32,

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account",
                    style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppColors.electricTeal,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.electricTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
