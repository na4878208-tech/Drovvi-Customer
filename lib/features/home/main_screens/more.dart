import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/colors.dart';
import 'package:logisticscustomer/features/home/Get_Profile/get_profile_screen.dart';
import 'package:logisticscustomer/features/home/main_screens/more_container.dart';
import 'package:logisticscustomer/features/home/wallet_flow/wallet_screen.dart';
import 'package:logisticscustomer/features/support/customer_support.dart';
import 'package:logisticscustomer/features/support/terms_and_condition.dart';

import '../../../constants/bottom_show.dart';
import '../../../constants/local_storage.dart';
import '../../authentication/login/login.dart';
import '../../authentication/login/login_controller.dart';
import '../../support/privicy_policy.dart';

class BuyerMoreScreen extends ConsumerStatefulWidget {
  const BuyerMoreScreen({super.key});

  @override
  ConsumerState<BuyerMoreScreen> createState() => _BuyerMoreScreenState();
}

class _BuyerMoreScreenState extends ConsumerState<BuyerMoreScreen> {
  bool _hasBenefits = false;

  @override
  Widget build(BuildContext context) {
    final showUpgradeCard = !_hasBenefits;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.electricTeal,
        title: const Text("More", style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                _showLogoutDialog();
              },
              child: const Icon(Icons.logout, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: buildToolsGrid(showUpgradeCard),
      ),
    );
  }

  /// ---------------- LOGOUT DIALOG ----------------
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.logout,
                        color: AppColors.electricTeal,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Are you sure you want to logout?",
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.electricTeal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: AppColors.electricTeal),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final msg = await ref
                                .read(logoutControllerProvider.notifier)
                                .logoutUser();

                            if (msg != null) {
                              await LocalStorage.clearToken();

                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => Login()),
                                (route) => false,
                              );

                              AppSnackBar.showSuccess(context, msg);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricTeal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.white),
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
      },
    );
  }

  /// ---------------- GRID ----------------
  Widget buildToolsGrid(bool showUpgradeCard) {
    return Column(
      children: [
        /// ROW 1
        Row(
          children: [
            Expanded(
              child: MoreOptionsContainer(
                text: "Profile",
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GetProfileScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MoreOptionsContainer(
                text: "Wallet",
                icon: Icons.account_balance_wallet_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WalletScreen()),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        /// ROW 2
        Row(
          children: [
            Expanded(
              child: MoreOptionsContainer(
                text: "Terms & Conditions",
                icon: Icons.description_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsConditionWebViewScreen(
                        title: "Terms of Service",
                        url: "https://drovvi.com/terms-of-service",
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MoreOptionsContainer(
                text: "Customer Support",
                icon: Icons.support_agent_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CustomerSupportScreen()),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        /// LAST CARD CENTER
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: MoreOptionsContainer(
              text: "Privacy Policy",
              icon: Icons.privacy_tip_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsPrivacyWebViewScreen(
                      title: "Privacy Policy",
                      url: "https://drovvi.com/privacy-policy",
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
