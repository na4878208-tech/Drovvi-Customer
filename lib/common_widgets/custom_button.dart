import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final bool? isChecked;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String text;

  const CustomButton({
    super.key,
    this.isChecked, // optional
    required this.onPressed,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.text = "",
  });

  @override
  Widget build(BuildContext context) {
    final bool active = isChecked ?? true; // agar null ho to true

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: active ? onPressed : null,
        style: ButtonStyle(
          // ignore: deprecated_member_use
          backgroundColor: MaterialStateProperty.all(
            active ? backgroundColor : Colors.white,
          ),
          // ignore: deprecated_member_use
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: borderColor, width: 2),
            ),
          ),
          // ignore: deprecated_member_use
          elevation: MaterialStateProperty.all(0),
          // ignore: deprecated_member_use
          overlayColor: MaterialStateProperty.all(
            // ignore: deprecated_member_use
            backgroundColor.withOpacity(0.1),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? textColor : borderColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}