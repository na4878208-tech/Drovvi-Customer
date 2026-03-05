import 'package:flutter/material.dart';
import 'package:logisticscustomer/constants/colors.dart';

class MoreOptionsContainer2 extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const MoreOptionsContainer2({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Center(
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Center(
            // ⭐ CARD CONTENT CENTER
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // ⭐ VERTICAL CENTER
              crossAxisAlignment:
                  CrossAxisAlignment.center, // ⭐ HORIZONTAL CENTER
              children: [
                /// ICON
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.electricTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.electricTeal, size: 26),
                ),

                const SizedBox(height: 10),

                /// TEXT
                Text(
                  text,
                  textAlign: TextAlign.center, // ⭐ TEXT CENTER
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class MoreOptionsContainer extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const MoreOptionsContainer({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// ICON
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.electricTeal.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.electricTeal, size: 30),
            ),

            const SizedBox(height: 14),

            /// TEXT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
