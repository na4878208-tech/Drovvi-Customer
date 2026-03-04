import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/common_widgets/custom_button.dart';
import 'package:logisticscustomer/common_widgets/custom_text.dart';
import 'package:logisticscustomer/constants/gap.dart';
import 'package:logisticscustomer/constants/session_expired.dart';
import 'package:logisticscustomer/features/home/wallet_flow/top_up/wallet_topup_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/colors.dart';
import '../../bottom_navbar/bottom_navbar_screen.dart';
import 'balance/balance_controller.dart';
import 'transaction_history/transaction_history_controller.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      // ignore: unused_result
      ref.refresh(walletBalanceControllerProvider);
      await ref
          .read(walletTransactionControllerProvider.notifier)
          .fetchTransactions();
    });
  }

  Future<void> _refreshWallet() async {
    try {
      await Future.wait(
        [
              ref.refresh(walletBalanceControllerProvider),
              ref
                  .read(walletTransactionControllerProvider.notifier)
                  .fetchTransactions(),
            ]
            as Iterable<Future>,
      );
    } catch (e) {
      debugPrint("Refresh Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: RefreshIndicator(
        color: AppColors.electricTeal,
        onRefresh: _refreshWallet,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // APPBAR
              Container(
                padding: const EdgeInsets.fromLTRB(6, 40, 16, 1),
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.electricTeal),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// 🔹 LEFT BACK ICON
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TripsBottomNavBarScreen(
                                      initialIndex: 3,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ),
                    ),

                    /// 🔹 CENTER TITLE
                    CustomText(
                      txt: "Wallet",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureWhite,
                    ),
                  ],
                ),
              ),

              // BALANCE SECTION
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final walletState = ref.watch(
                          walletBalanceControllerProvider,
                        );

                        return walletState.when(
                          loading: () => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: balanceShimmer(),
                          ),
                          error: (e, _) {
                            // debugPrint("Balance Error: $e");
                            return SessionExpiredScreen();
                            //  Text("Error: $e");
                          },
                          data: (wallet) {
                            final balance = wallet?.data.balance ?? 0;
                            final currency = wallet?.data.currency ?? "";

                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.mediumGray.withValues(
                                      alpha: 0.10,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        txt: "Available Balance",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const WalletTopUPScreen(),
                                            ),
                                          );

                                          if (result == true) {
                                            _refreshWallet();
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.add,
                                              color: AppColors.electricTeal,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            CustomText(
                                              txt: "Add Money",
                                              fontSize: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  gapH8,
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: _boxStyle,
                                    child: Row(
                                      children: [
                                        CustomText(
                                          txt: "$currency ",
                                          fontSize: 18,
                                          color: AppColors.electricTeal,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        const SizedBox(width: 12),
                                        CustomText(
                                          txt: "$balance",
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),

                    gapH24,

                    // TRANSACTION HISTORY
                    Consumer(
                      builder: (context, ref, _) {
                        final state = ref.watch(
                          walletTransactionControllerProvider,
                        );
                        final controller = ref.read(
                          walletTransactionControllerProvider.notifier,
                        );

                        return state.when(
                          loading: () => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Column(
                              children: List.generate(
                                7,
                                (_) => transactionShimmer(),
                              ),
                            ),
                          ),
                          error: (e, _) {
                            // debugPrint("Transaction Error: $e");
                            // return Text("Error: $e");
                            return SessionExpiredScreen();
                          },
                          data: (transactions) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bar_chart,
                                      color: AppColors.electricTeal,
                                    ),
                                    const SizedBox(width: 8),
                                    CustomText(
                                      txt: "Transaction History",
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),

                                ...transactions.map((tx) {
                                  final isDebit =
                                      tx.transactionType == "payment";

                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.pureWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDebit
                                            ? Colors.redAccent
                                            : Colors.green,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.mediumGray
                                              .withValues(alpha: 0.10),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(tx.description, style: _boldText),
                                        const SizedBox(height: 4),
                                        Text(tx.createdAt, style: _subText),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${isDebit ? '-' : '+'} ${tx.amount}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDebit
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),

                                if (controller.hasMore)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 60,
                                    ),
                                    child: CustomButton(
                                      text: "View All",
                                      onPressed: () {
                                        controller.fetchTransactions(
                                          loadMore: true,
                                        );
                                      },
                                      backgroundColor: AppColors.pureWhite,
                                      borderColor: AppColors.electricTeal,
                                      textColor: AppColors.darkText,
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- SHIMMER WIDGETS ----------------

Widget balanceShimmer() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 16, width: 120, color: Colors.grey[300]),
        gapH12,
        Container(height: 40, width: double.infinity, color: Colors.grey[300]),
      ],
    ),
  );
}

Widget transactionShimmer() {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 14, width: double.infinity, color: Colors.grey[300]),
        gapH8,
        Container(height: 12, width: 120, color: Colors.grey[300]),
        gapH8,
        Container(height: 16, width: 80, color: Colors.grey[300]),
      ],
    ),
  );
}

// ---------------- STYLES ----------------

const _boxStyle = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(12)),
  border: Border.fromBorderSide(BorderSide(color: AppColors.electricTeal)),
);

const _boldText = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);

const _subText = TextStyle(fontSize: 13, color: Colors.black54);
