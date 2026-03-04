import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';

import 'package:logisticscustomer/features/authentication/email_register/email_register_modal.dart';
import 'package:logisticscustomer/features/authentication/otp/verify_otp_controller.dart';
import '../../../constants/validation_regx.dart';
import '../../../export.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final EmailRegisterModal emailRegisterModal;

  const VerificationScreen({Key? key, required this.emailRegisterModal})
    : super(key: key);

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  TextEditingController otpController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  int _seconds = 59;
  Timer? _timer;
  bool _isOtpFilled = false;
  String? _otpError; //  For showing validation error

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_seconds > 0) {
          setState(() => _seconds--);
        } else {
          timer.cancel();
        }
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
    final email = widget.emailRegisterModal.email;

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                    txt: "Verification code",
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
                      if (_otpError != null)
                        _otpError = null; // clear error on change
                    });
                  },
                ),
                if (_otpError != null)
                  Align(
                    alignment: Alignment.centerRight, //  move to right
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
                    text: "Next",
                    backgroundColor: AppColors.electricTeal,
                    borderColor: AppColors.electricTeal,
                    textColor: AppColors.pureWhite,
                    onPressed: () async {
                      final otp = otpController.text.trim();
                      final error = AppValidators.otp(otp);

                      if (error != null) {
                        setState(() => _otpError = error);
                        errorController?.add(ErrorAnimationType.shake);
                        return;
                      }

                      final email = widget.emailRegisterModal.email;
                      try {
                        await ref
                            .read(verifyOtpControllerProvider.notifier)
                            .verifyOtp(email, otp);

                        final state = ref.read(verifyOtpControllerProvider);
                        if (!mounted) return; //  Safe check

                        if (state is AsyncData && state.value != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreatePasswordScreen(
                                token: state.value!.verificationToken,
                              ),
                            ),
                          );
                        } else if (state is AsyncError) {
                          setState(
                            () => _otpError = "Worng OTP. please try again",
                          );
                          errorController?.add(ErrorAnimationType.shake);
                        }
                      } catch (_) {
                        if (mounted) {
                          setState(
                            () => _otpError = "Worng OTP. please try again",
                          );
                          errorController?.add(ErrorAnimationType.shake);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (_seconds == 0 && mounted) {
                      final email = widget.emailRegisterModal.email;

                      await ref
                          .read(resendOtpControllerProvider.notifier)
                          .resendOtp(email);

                      final state = ref.read(resendOtpControllerProvider);
                      if (state is AsyncData && state.value != null) {
                        setState(() {
                          _seconds = 59;
                        });
                        startTimer();
                        AppSnackBar.showSuccess(
                          context,
                          "OTP Resend Successfully",
                        );
                      } else if (state is AsyncError) {
                        AppSnackBar.showWarning(context, "Process");
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
