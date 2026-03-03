import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/constants/gap.dart';
import 'package:logisticscustomer/constants/local_storage.dart';
import 'package:logisticscustomer/constants/session_expired.dart';
import 'package:logisticscustomer/features/authentication/login/login.dart';
import 'package:logisticscustomer/features/authentication/login/login_controller.dart';
import 'package:logisticscustomer/features/home/Edit_Profile/edit_profile_screen.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/pickup_location/pickup_modal.dart';

import '../../../common_widgets/custom_text.dart';
import '../../../constants/colors.dart';
import '../../../constants/gps_location.dart';
import '../../bottom_navbar/bottom_navbar_screen.dart';
import '../orders_flow/create_orders_screens/pickup_location/pickup_controller.dart';
import 'get_profile_controller.dart';

class GetProfileScreen extends ConsumerStatefulWidget {
  const GetProfileScreen({super.key});

  @override
  ConsumerState<GetProfileScreen> createState() => _GetProfileScreenState();
}

class _GetProfileScreenState extends ConsumerState<GetProfileScreen> {
  bool _didLoadOnce = false;
  int? selectedAddressId; // NEW

  AsyncValue<DefaultAddressModel> get defaultAddressState =>
      ref.watch(defaultAddressControllerProvider);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didLoadOnce) {
      _didLoadOnce = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(getProfileControllerProvider.notifier).loadProfile();
        ref
            .read(defaultAddressControllerProvider.notifier)
            .loadDefaultAddress();
        ref.read(allAddressControllerProvider.notifier).loadAllAddress();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(getProfileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: RotatedBox(
          quarterTurns: 2,
          child: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const TripsBottomNavBarScreen(initialIndex: 3),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.pureWhite,
            ),
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.electricTeal,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () {
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 25,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // --- Icon + Title ---
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

                              // --- Message ---
                              const Text(
                                "Are you sure you want to logout?",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 25),

                              // --- Buttons ---
                              Row(
                                children: [
                                  // CANCEL BUTTON
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppColors.electricTeal,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: AppColors.electricTeal,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  // LOGOUT BUTTON
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final msg = await ref
                                            .read(
                                              logoutControllerProvider.notifier,
                                            )
                                            .logoutUser();

                                        if (msg != null) {
                                          await LocalStorage.clearToken();

                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (_) => Login(),
                                            ),
                                            (route) => false,
                                          );

                                          AppSnackBar.showSuccess(context, msg);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.electricTeal,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child: const Text(
                                        "Logout",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
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
              },
              child: const Icon(
                Icons.logout,
                color: AppColors.pureWhite,
                size: 28,
              ),
            ),
          ),
        ],
      ),

      // 🔥 IMPORTANT FIX HERE
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, st) => SessionExpiredScreen(),

        data: (profile) {
          if (profile == null) {
            return const Center(child: Text("No Profile Data"));
          }

          final user = profile.data.user;
          final Color blueColor = AppColors.electricTeal;
          double screenHeight = MediaQuery.of(context).size.height;

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(height: 150, color: blueColor),

                    Positioned(
                      top: screenHeight * 0.1,
                      left: 20,
                      right: 20,
                      bottom: 25,
                      child: _buildInfoCard(),
                    ),

                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          _buildProfileImage(AppColors.electricTeal),
                          const SizedBox(height: 15),
                          Text(
                            user.name.isNotEmpty ? user.name : "N/A",
                            style: const TextStyle(
                              color: AppColors.darkText,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            width: 300,
                            margin: const EdgeInsets.only(top: 8),
                            height: 1,
                            color: AppColors.electricTeal,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Profile Image Widget ---
  Widget _buildProfileImage(Color primaryBlue) {
    final profileState = ref.watch(getProfileControllerProvider);

    // Loading State
    if (profileState.isLoading) {
      return const CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.subtleGray,
        child: CircularProgressIndicator(),
      );
    }

    // Error State
    if (profileState.hasError) {
      return const CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.subtleGray,
        child: Icon(Icons.error, color: Colors.red),
      );
    }

    // Data Loaded
    final profile = profileState.value;
    final customer = profile!.data.customer;

    final imageUrl = customer.profilePhoto;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.subtleGray,
          backgroundImage: imageUrl != null && imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : const AssetImage('assets/profile_pic.png') as ImageProvider,
        ),

        Container(
          decoration: BoxDecoration(
            color: primaryBlue,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.pureWhite, width: 2),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
            icon: Icon(Icons.edit, color: AppColors.pureWhite, size: 25),
          ),
        ),
      ],
    );
  }

  // --- Info Card Widget (Aapka White Container) ---
  Widget _buildInfoCard() {
    String formatDateOfBirth(String? rawDate) {
      if (rawDate == null || rawDate.isEmpty) return "N/A";

      try {
        final dateTime = DateTime.parse(rawDate);
        return DateFormat('dd MMM yyyy').format(dateTime);
        // Example: 01 Jan 1990
      } catch (e) {
        return "N/A";
      }
    }

    final profileState = ref.watch(getProfileControllerProvider);

    // 🔵 Loading State
    if (profileState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 🔴 Error State
    if (profileState.hasError) {
      return Container(
        padding: const EdgeInsets.all(30),
        child: const Text(
          "Failed to load profile",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    // 🟢 Data Loaded
    final profile = profileState.value!;
    final user = profile.data.user;
    final customer = profile.data.customer;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(25, 120, 25, 0),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        shrinkWrap: true,

        children: [
          const Text(
            'Personal Info',
            style: TextStyle(
              color: AppColors.electricTeal,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          // ✅ DOB
          _buildInfoRow(
            label: 'Date Of Birth',
            value: formatDateOfBirth(customer.dateOfBirth),
            showVerification: false,
          ),

          const SizedBox(height: 10),

          // ✅ Phone
          _buildInfoRow(
            label: 'Contact Number',
            value: user.phone,
            showVerification: false,
          ),
          const SizedBox(height: 10),

          // ✅ Email
          _buildInfoRow(
            label: 'Email',
            value: user.email,
            valueColor: Colors.black,
            showVerification: true,
          ),
          const SizedBox(height: 10),

          // ✅ Employee ID OR Customer ID (Based on API)
          _buildInfoRow(
            label: 'Customer ID',
            value: customer.id.toString(),
            showVerification: false,
          ),
          const SizedBox(height: 10),

          // Optional Data
          _buildInfoRow(
            label: 'City',
            value: customer.city ?? "N/A",
            showVerification: false,
          ),
          const SizedBox(height: 10),

          _buildInfoRow(
            label: 'Country',
            value: customer.country ?? "N/A",
            showVerification: false,
          ),
          const SizedBox(height: 10),

          /// LOCATION
          profileState.when(
            data: (_) {
              return FutureBuilder<String>(
                future: getCurrentCity(),
                builder: (_, snapshot) {
                  final city = snapshot.data ?? "Loading...";
                  return _locationRow(city);
                },
              );
            },
            loading: () => _loadingText(width: 90),
            error: (_, __) => _loadingText(width: 90),
          ),
          // defaultAddressUI(),
          gapH32,
        ],
      ),
    );
  }

  /// ================= HELPERS =================
  Widget _locationRow(String city) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(txt: "Address", fontSize: 14, color: AppColors.mediumGray),
        const SizedBox(height: 5),
        CustomText(
          txt: city,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ],
    );
  }

  Widget _loadingText({double width = 100}) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

// --- Reusable Info Row Widget (Yeh pehle jaisa hi rahega) ---
Widget _buildInfoRow({
  required String label,
  required String value,
  required bool showVerification,
  Color labelColor = AppColors.mediumGray,
  Color valueColor = AppColors.darkText,
}) {
  // ... (same implementation as before)
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(label, style: TextStyle(color: labelColor, fontSize: 14)),
          SizedBox(width: 10),
          if (showVerification)
            const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
      const SizedBox(height: 5),
      Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
