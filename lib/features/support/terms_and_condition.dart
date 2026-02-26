import 'package:flutter/material.dart';
import 'package:logisticscustomer/constants/colors.dart';

class TermsPrivacyScreen extends StatelessWidget {
  final String title;
  final String content;

  const TermsPrivacyScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        backgroundColor: AppColors.electricTeal,
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.pureWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: RotatedBox(
          quarterTurns: 2,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.pureWhite,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.electricTeal,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5, // line height for readability
                ),
              ),
              const SizedBox(height: 30),

              // Center(
              //   child: ElevatedButton(
              //     onPressed: () => Navigator.pop(context),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.electricTeal,
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 50,
              //         vertical: 15,
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //     child: const Text(
              //       "Close",
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontWeight: FontWeight.bold,
              //         fontSize: 16,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
