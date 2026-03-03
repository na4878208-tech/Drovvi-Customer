import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/constants/colors.dart';
import 'package:logisticscustomer/constants/gap.dart';
import 'package:logisticscustomer/features/home/Get_Profile/get_profile_screen.dart';
import 'package:logisticscustomer/features/home/main_screens/more_container.dart';
import 'package:logisticscustomer/features/home/wallet_flow/wallet_screen.dart';
import 'package:logisticscustomer/features/support/customer_support.dart';
import 'package:logisticscustomer/features/support/terms_and_condition.dart';

import '../../support/privicy_policy.dart';

class BuyerMoreScreen extends ConsumerStatefulWidget {
  const BuyerMoreScreen({super.key});

  @override
  ConsumerState<BuyerMoreScreen> createState() => _BuyerMoreScreenState();
}

class _BuyerMoreScreenState extends ConsumerState<BuyerMoreScreen> {
  // ignore: unused_field
  bool _isLoadingSkeleton = true;
  bool _hasBenefits = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoadingSkeleton = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final showUpgradeCard = !_hasBenefits;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: AppColors.electricTeal,
        title: Text(
          "More",
          style: TextStyle(color: Colors.white),
          // style: AppStyles.buyerPrimaryTextStyle.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: buildToolsGrid(showUpgradeCard),
      ),
    );
  }

  Widget buildToolsGrid(bool showUpgradeCard) {
    return Column(
      children: [
        Expanded(
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
            ),
            children: [
              MoreOptionsContainer(
                text: "Profile",
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GetProfileScreen()),
                  );
                },
              ),
              MoreOptionsContainer(
                text: "Wallet",
                icon: Icons.account_balance_wallet_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WalletScreen()),
                  );
                },
              ),

              MoreOptionsContainer(
                text: "Terms &\nConditions",
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

              MoreOptionsContainer(
                text: "Customer Support",
                icon: Icons.support_agent_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerSupportScreen(),
                    ),
                  );
                },
              ),
              MoreOptionsContainer(
                text: "Privacy\nPolicy",
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
            ],
          ),
        ),

        const SizedBox.shrink(),
      ],
    );
  }
}
