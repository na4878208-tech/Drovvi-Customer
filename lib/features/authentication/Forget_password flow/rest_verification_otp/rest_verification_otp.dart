import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import '../../../../constants/validation_regx.dart';
import '../../../../export.dart';
import '../forget_password/forget_password_model.dart';
import '../rest_password/rest_password.dart';
import 'rest_verification_otp_controller.dart';
import 'rest_verification_otp_model.dart';

class RestVerificationScreen extends ConsumerStatefulWidget {
  final ForgotPasswordData forgotPasswordData;
  const RestVerificationScreen({super.key, required this.forgotPasswordData});

  @override
  ConsumerState<RestVerificationScreen> createState() =>
      _RestVerificationScreenState();
}

class _RestVerificationScreenState
    extends ConsumerState<RestVerificationScreen> {
  TextEditingController otpController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  int _seconds = 59;
  Timer? _timer;
  bool _isOtpFilled = false;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    errorController?.close();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.forgotPasswordData.email;

    /// ✅ LISTEN FOR OTP VERIFY STATE
    ref.listen<AsyncValue<VerifyResetOtpModel?>>(
      verifyResetOtpControllerProvider,
      (previous, next) {
        next.when(
          data: (data) {
            if (data != null && data.success) {
              print("✅ VerifyReset OTP Response: ${data.message}");

              /// ✅ NAVIGATE TO CREATE PASSWORD
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RestPasswordScreen(token: data.data.resetToken),
                ),
              );
            }
          },
          loading: () {},
          error: (err, st) {
            print("❌ VerifyReset OTP Error: $err");
            setState(() => _otpError = "Wrong OTP. Please try again");
            errorController?.add(ErrorAnimationType.shake);
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// BACK
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

                const SizedBox(height: 20),
                CustomText(
                  txt: "DROVVI",
                  color: AppColors.electricTeal,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 30),
                CustomText(
                  txt: "Enter Verification Code",
                  color: AppColors.electricTeal,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 10),
                CustomText(
                  txt:
                      "Please enter the 6-digit code we sent\nto your registered email address.",
                  align: TextAlign.center,
                  color: AppColors.mediumGray,
                  fontSize: 14,
                  height: 1.5,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      txt: email,
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    txt: "Reset Verification Code",
                    color: _otpError != null
                        ? Colors.red
                        : AppColors.electricTeal,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: otpController,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  autoDismissKeyboard: true,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 45,
                    inactiveColor: _otpError != null
                        ? Colors.red
                        : AppColors.electricTeal.withOpacity(0.3),
                    selectedColor: _otpError != null
                        ? Colors.red
                        : AppColors.electricTeal,
                    activeColor: _otpError != null
                        ? Colors.red
                        : AppColors.electricTeal,
                    activeFillColor: AppColors.pureWhite,
                    inactiveFillColor: AppColors.pureWhite,
                    selectedFillColor: AppColors.pureWhite,
                    borderWidth: 1.5,
                  ),
                  animationDuration: const Duration(milliseconds: 200),
                  enableActiveFill: true,
                  onChanged: (value) {
                    setState(() {
                      _isOtpFilled = value.length == 6;
                      _otpError = null;
                    });
                  },
                ),

                if (_otpError != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _otpError!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    isChecked: _isOtpFilled,
                    text: "Submit",
                    backgroundColor: AppColors.electricTeal,
                    borderColor: AppColors.electricTeal,
                    textColor: AppColors.pureWhite,
                    onPressed: !_isOtpFilled
                        ? null
                        : () async {
                            final otp = otpController.text.trim();
                            final error = AppValidators.otp(otp);

                            if (error != null) {
                              setState(() => _otpError = error);
                              errorController?.add(ErrorAnimationType.shake);
                              return;
                            }

                            /// ✅ CALL API
                            await ref
                                .read(verifyResetOtpControllerProvider.notifier)
                                .verifyResetOtp(email, otp);
                          },
                  ),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (_seconds == 0) {
                      await ref
                          .read(resendResetOtpControllerProvider.notifier)
                          .resendResetOtp(email);

                      final state = ref.read(resendResetOtpControllerProvider);

                      if (state is AsyncData) {
                        print(
                          "✅ Resend OTP Response: ${state.value?.message})}",
                        );
                        setState(() => _seconds = 59);
                        startTimer();
                        AppSnackBar.showSuccess(
                          context,
                          "OTP resent successfully",
                        );
                      }
                    }
                  },
                  child: CustomText(
                    txt: _seconds > 0
                        ? "Resend - 00:${_seconds.toString().padLeft(2, '0')}"
                        : "Resend Code",
                    color: _seconds == 0
                        ? AppColors.electricTeal
                        : AppColors.mediumGray,
                    fontSize: 14,
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
