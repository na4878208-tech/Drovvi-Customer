import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/features/home/Get_Profile/get_profile_screen.dart';
import '../../../export.dart';
import '../../../common_widgets/cuntom_textfield.dart';
import '../../../common_widgets/custom_button.dart';
import '../../bottom_navbar/bottom_navbar_screen.dart';
import 'edit_profile_controller.dart';
import 'edit_profile_modal.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode dobFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();

  bool _isPrefilled = false;
  bool isChecked = false;
  XFile? profileImage;
  final ImagePicker _picker = ImagePicker();

  void checkFields() {
    setState(() {
      isChecked =
          nameController.text.isNotEmpty &&
          dobController.text.isNotEmpty &&
          phoneController.text.isNotEmpty;
    });
  }

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profileImage = image;
      });
    }
  }

  Future<void> selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dobController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      checkFields();
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.addListener(checkFields);
    dobController.addListener(checkFields);
    phoneController.addListener(checkFields);

    // Fetch profile on init
    Future.microtask(
      () => ref.read(editProfileControllerProvider.notifier).getProfile(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    nameFocus.dispose();
    dobFocus.dispose();
    phoneFocus.dispose();
    super.dispose();
  }

  void prefillFields(UpdateProfileModel profile) {
    nameController.text = profile.user.name;
    phoneController.text = profile.user.phone;
    dobController.text = profile.customer.dateOfBirth ?? "";
    checkFields();
  }

  @override
  Widget build(BuildContext context) {
    final editProfileState = ref.watch(editProfileControllerProvider);
    final editProfileController = ref.read(
      editProfileControllerProvider.notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 45,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const GetProfileScreen(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        backgroundColor: AppColors.electricTeal,
        foregroundColor: AppColors.pureWhite,
      ),
      body: editProfileState.when(
        data: (profile) {
          if (!_isPrefilled && profile != null) {
            prefillFields(profile);
            _isPrefilled = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: pickProfileImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.electricTeal,
                            width: 2.5,
                          ),
                          color: profileImage == null
                              ? AppColors.electricTeal.withOpacity(0.4)
                              : Colors.transparent,
                          image: profileImage != null
                              ? DecorationImage(
                                  image: FileImage(File(profileImage!.path)),
                                  fit: BoxFit.cover,
                                )
                              : (profile?.customer.profilePhoto != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          profile!.customer.profilePhoto!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                        ),
                        child:
                            profileImage == null &&
                                profile?.customer.profilePhoto == null
                            ? const Icon(
                                Icons.person_outlined,
                                color: AppColors.pureWhite,
                                size: 28,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Profile Picture",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Name
                CustomAnimatedTextField(
                  controller: nameController,
                  focusNode: nameFocus,
                  labelText: "Name",
                  hintText: "Name",
                  prefixIcon: Icons.person_outline,
                  iconColor: AppColors.electricTeal,
                  borderColor: AppColors.electricTeal,
                  textColor: AppColors.mediumGray,
                ),
                const SizedBox(height: 10),

                // Phone
                CustomAnimatedTextField(
                  controller: phoneController,
                  focusNode: phoneFocus,
                  labelText: "Phone Number",
                  hintText: "Phone Number",
                  prefixIcon: Icons.phone_outlined,
                  iconColor: AppColors.electricTeal,
                  borderColor: AppColors.electricTeal,
                  textColor: AppColors.mediumGray,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),

                // Date of Birth
                CustomAnimatedTextField(
                  controller: dobController,
                  focusNode: dobFocus,
                  labelText: "Date of Birth",
                  hintText: "YYYY-MM-DD",
                  prefixIcon: Icons.calendar_today_outlined,
                  iconColor: AppColors.electricTeal,
                  borderColor: AppColors.electricTeal,
                  textColor: AppColors.mediumGray,
                  readOnly: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    color: AppColors.electricTeal,
                    onPressed: selectDate,
                  ),
                ),
                const SizedBox(height: 30),

                // Update Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: CustomButton(
                    isChecked: isChecked,
                    text: "Update",
                    backgroundColor: AppColors.electricTeal,
                    borderColor: AppColors.electricTeal,
                    textColor: AppColors.lightGrayBackground,
                    onPressed: isChecked
                        ? () async {
                            await editProfileController.updateProfile(
                              name: nameController.text,
                              phone: phoneController.text,
                              dob: dobController.text,
                              image: profileImage != null
                                  ? File(profileImage!.path)
                                  : null,
                            );

                            final result = ref
                                .read(editProfileControllerProvider)
                                .value;

                            if (result != null && result.success) {
                              AppSnackBar.showSuccess(
                                context,
                                result.message ?? "Updated successfully",
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TripsBottomNavBarScreen(
                                        initialIndex: 3,
                                      ),
                                ),
                              );
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
