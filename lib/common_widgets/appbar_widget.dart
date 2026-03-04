import 'package:flutter/material.dart';
import 'package:logisticscustomer/export.dart';
import 'package:logisticscustomer/features/home/notification_screen.dart';

class BuyerAppBarWidget extends StatelessWidget {
  const BuyerAppBarWidget({
    super.key,
    required this.controller,
    required this.segmentControlValue,
    required this.segmentCallback,
    required this.tabController,
  });

  final TextEditingController controller;
  final int segmentControlValue;
  final TabController tabController;
  final void Function(int) segmentCallback;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // statusBarColor: Color(0xFF1A56DB),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: AppBar(
        backgroundColor: AppColors.electricTeal,
        toolbarHeight: 200,
        elevation: 0,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    CustomText(
                      txt: "Hello John",
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText(
                      txt: "4 trips to do",

                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: 0, top: 10),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            TabBar(
              controller: tabController,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 6.0, color: Colors.white),
                insets: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Current"),
                Tab(text: "Completed"),
                Tab(text: "Future"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
