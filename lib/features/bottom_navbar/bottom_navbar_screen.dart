import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../home/main_screens/home_screen/current_screen.dart';
import '../home/main_screens/more.dart';
import '../home/orders_flow/all_orders/orders.dart';
import '../home/orders_flow/ordr_tracking/order_tracking_screen.dart';

class TripsBottomNavBarScreen extends StatefulWidget {
  final int initialIndex;
  final String? trackingCode; // ✅ add this

  const TripsBottomNavBarScreen({
    super.key,
    this.initialIndex = 0,
    this.trackingCode,
  });

  @override
  State<TripsBottomNavBarScreen> createState() =>
      _TripsBottomNavBarScreenState();
}
class _TripsBottomNavBarScreenState extends State<TripsBottomNavBarScreen> {
  late int _selectedIndex;

 Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const CurrentScreen();

      case 1:
        return const Orders();

      case 2:
        /// ✅ Tracking Screen Connected
        return OrderTrackingScreen(
          trackingCode: widget.trackingCode ?? "",
        );

      case 3:
        return const BuyerMoreScreen();

      default:
        return const CurrentScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 80,
        currentIndex: _selectedIndex,
        backgroundColor: AppColors.pureWhite,
        selectedItemColor: AppColors.electricTeal,
        unselectedItemColor: AppColors.mediumGray,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            label: "Tracking",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: "More",
          ),
        ],
      ),
    );
  }
}