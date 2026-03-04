import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logisticscustomer/constants/bottom_show.dart';
import 'package:logisticscustomer/features/authentication/register_successful.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/order_cache_provider.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/pickup_location/dropdown.dart';

import '../../../constants/validation_regx.dart';
import '../../../export.dart';
import 'set_up_profile_controller.dart';
import 'set_up_profile_modal.dart';

class SetUpProfile extends ConsumerStatefulWidget {
  final String verificationToken;
  // final bool isCompany;
  const SetUpProfile({
    super.key,
    required this.verificationToken,
    // required this.isCompany,
  });

  @override
  ConsumerState<SetUpProfile> createState() => _SetUpProfileState();
}

class _SetUpProfileState extends ConsumerState<SetUpProfile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  final FocusNode fullNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();

  final FocusNode mobileFocus = FocusNode();
  final FocusNode dobFocus = FocusNode();

  XFile? profileImage;
  final ImagePicker _picker = ImagePicker();

  bool isButtonEnabled = false;

  String? selectedCompanyId;
  String? selectedCompanyName;
  int? selectedCompanyType;
  String? companyError;

  //
  bool isCompany = false;

  @override
  void initState() {
    super.initState();
    fullNameController.addListener(_validateForm);
    lastNameController.addListener(_validateForm);
    addressController.addListener(_validateForm);

    mobileController.addListener(_validateForm);
    dobController.addListener(_validateForm);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();

    mobileController.dispose();
    dobController.dispose();
    fullNameFocus.dispose();
    lastNameFocus.dispose();
    addressFocus.dispose();

    mobileFocus.dispose();
    dobFocus.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid =
        fullNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        mobileController.text.isNotEmpty &&
        dobController.text.isNotEmpty &&
        AppValidators.name(fullNameController.text) == null &&
        AppValidators.name(lastNameController.text) == null &&
        AppValidators.name(addressController.text) == null &&
        AppValidators.phone(mobileController.text) == null &&
        AppValidators.dob(dobController.text) == null;

    if (isValid != isButtonEnabled) {
      setState(() {
        isButtonEnabled = isValid;
      });
    }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    //

    final state = ref.watch(setUpProfileControllerProvider);

    ref.listen<AsyncValue<SetUpProfileModel?>>(setUpProfileControllerProvider, (
      previous,
      next,
    ) {
      if (next is AsyncLoading) return;

      if (next is AsyncError) {
        AppSnackBar.showError(context, next.error.toString());
      }
      print("VERIFICATION TOKEN => ${widget.verificationToken}");

      if (next is AsyncData) {
        final data = next.value;

        if (data != null && data.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RegisterSuccessful()),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 35,
        title: Text(
          "Set Up Profile",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        foregroundColor: AppColors.pureWhite,
        backgroundColor: AppColors.electricTeal,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              RegisterAsSelector(
                onChanged: (value) {
                  setState(() {
                    isCompany = value;
                    if (!isCompany) {
                      selectedCompanyName = null;
                      selectedCompanyId = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 30),

              // Full Name
              CustomAnimatedTextField(
                controller: fullNameController,
                focusNode: fullNameFocus,
                labelText: "First Name",
                hintText: "First Name",
                prefixIcon: Icons.person_outline,
                iconColor: AppColors.electricTeal,
                borderColor: AppColors.electricTeal,
                textColor: AppColors.mediumGray,
                validator: (value) =>
                    AppValidators.name(value, fieldName: "First Name"),
              ),
              const SizedBox(height: 10),

              // Last Name
              CustomAnimatedTextField(
                controller: lastNameController,
                focusNode: lastNameFocus,
                labelText: "Last Name",
                hintText: "Last Name",
                prefixIcon: Icons.person_outline,
                iconColor: AppColors.electricTeal,
                borderColor: AppColors.electricTeal,
                textColor: AppColors.mediumGray,
                validator: (value) =>
                    AppValidators.name(value, fieldName: "Last Name"),
              ),

              // Company name
              if (isCompany)
                Consumer(
                  builder: (context, ref, child) {
                    final companyState = ref.watch(companyControllerProvider);

                    return companyState.when(
                      data: (data) {
                        final companyItems = data.getAllItems();

                        int? selectedIndex;
                        if (selectedCompanyId != null) {
                          selectedIndex = companyItems.indexWhere(
                            (item) => item.id == selectedCompanyId,
                          );
                          if (selectedIndex < 0) selectedIndex = 0;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropDownContainer(
                              fw: FontWeight.normal,
                              dialogueScreen: MaterialConditionPopupLeftIcon(
                                title: companyItems.isNotEmpty
                                    ? companyItems[selectedIndex ?? 0].name
                                    : '',
                                conditions: companyItems
                                    .map((e) => e.name)
                                    .toList(),
                                initialSelectedIndex: selectedIndex,
                              ),
                              text: selectedCompanyName ?? 'Select Company',
                              onItemSelected: (value) {
                                final selectedItem = companyItems.firstWhere(
                                  (element) => element.name == value,
                                );

                                setState(() {
                                  selectedCompanyName = selectedItem.name;
                                  companyError = null;
                                });

                                ref
                                    .read(orderCacheProvider.notifier)
                                    .saveValue(
                                      "selected_company_id",
                                      selectedItem.id.toString(),
                                    );
                                ref
                                    .read(orderCacheProvider.notifier)
                                    .saveValue(
                                      "selected_company_name",
                                      selectedItem.name,
                                    );
                                ref
                                    .read(orderCacheProvider.notifier)
                                    .saveValue(
                                      "selected_company_type",
                                      selectedItem.type,
                                    );
                              },
                            ),
                            if (companyError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  companyError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                      loading: () => Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (error, _) => Column(
                        children: [
                          const Text(
                            'Error loading companies',
                            style: TextStyle(color: Colors.red),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(companyControllerProvider.notifier)
                                  .loadCompanies();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),

              // Mobile
              CustomAnimatedTextField(
                controller: mobileController,
                focusNode: mobileFocus,
                labelText: "Phone Number",
                hintText: "Phone Number",
                prefixIcon: Icons.phone_outlined,
                iconColor: AppColors.electricTeal,
                borderColor: AppColors.electricTeal,
                textColor: AppColors.mediumGray,
                keyboardType: TextInputType.phone,
                validator: AppValidators.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 10),

              // Last Name
              CustomAnimatedTextField(
                controller: addressController,
                focusNode: addressFocus,
                labelText: "Address",
                hintText: "Address",
                prefixIcon: Icons.person_outline,
                iconColor: AppColors.electricTeal,
                borderColor: AppColors.electricTeal,
                textColor: AppColors.mediumGray,
                validator: (value) =>
                    AppValidators.name(value, fieldName: "Address"),
              ),
              const SizedBox(height: 10),

              // DOB
              CustomAnimatedTextField(
                controller: dobController,
                focusNode: dobFocus,
                labelText: "Date of Birth",
                hintText: "YYYY-MM-DD",
                prefixIcon: Icons.calendar_today_outlined,
                iconColor: AppColors.electricTeal,
                borderColor: AppColors.electricTeal,
                textColor: Colors.black87,
                keyboardType: TextInputType.datetime,
                validator: AppValidators.dob,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  color: AppColors.electricTeal,
                  onPressed: selectDate,
                ),
              ),
              // const SizedBox(height: 30),

              // Next Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: CustomButton(
                  isChecked: isButtonEnabled && state is! AsyncLoading,
                  text: state is AsyncLoading ? "Submitting..." : "Welcome!",
                  backgroundColor: AppColors.electricTeal,
                  borderColor: AppColors.electricTeal,
                  textColor: AppColors.pureWhite,
                  onPressed: isButtonEnabled && state is! AsyncLoading
                      ? () async {
                          if (!_formKey.currentState!.validate()) return;

                          await ref
                              .read(setUpProfileControllerProvider.notifier)
                              .completeProfile(
                                verificationToken: widget.verificationToken,
                                name: fullNameController.text.trim(),
                                phone: mobileController.text.trim(),
                                dob: dobController.text.trim(),
                                profilePhoto: profileImage != null
                                    ? File(profileImage!.path)
                                    : null,
                              );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///////////////////////
class RegisterAsSelector extends StatefulWidget {
  final ValueChanged<bool> onChanged; // true = company, false = individual

  const RegisterAsSelector({super.key, required this.onChanged});

  @override
  State<RegisterAsSelector> createState() => _RegisterAsSelectorState();
}

class _RegisterAsSelectorState extends State<RegisterAsSelector> {
  bool isCompanySelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "I am registering as",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildCard(
              title: "Individual",
              icon: Icons.person,
              isSelected: !isCompanySelected,
              onTap: () {
                setState(() => isCompanySelected = false);
                widget.onChanged(false);
              },
            ),
            const SizedBox(width: 12),
            _buildCard(
              title: "Company",
              icon: Icons.apartment,
              isSelected: isCompanySelected,
              onTap: () {
                setState(() => isCompanySelected = true);
                widget.onChanged(true);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.electricTeal.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.electricTeal : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 30, color: AppColors.electricTeal),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.electricTeal,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
