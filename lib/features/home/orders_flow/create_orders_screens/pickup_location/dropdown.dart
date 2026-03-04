//
import 'package:flutter/material.dart';
import 'package:logisticscustomer/common_widgets/custom_text.dart';
import 'package:logisticscustomer/constants/colors.dart';
import 'package:logisticscustomer/features/home/orders_flow/create_orders_screens/pickup_location/dropdown/product_type_modal.dart';

class DropDownContainer extends StatefulWidget {
  final String text;
  final Widget dialogueScreen;
  final FontWeight fw;
  final ValueChanged<String>? onItemSelected; // Callback for selection
  final bool? isIconVisible;
  final Color? textColor;

  const DropDownContainer({
    super.key,
    required this.text,
    required this.dialogueScreen,
    this.fw = FontWeight.w600,
    this.onItemSelected,
    this.isIconVisible = true,
    this.textColor,
  });

  @override
  State<DropDownContainer> createState() => _DropDownContainerState();
}

class _DropDownContainerState extends State<DropDownContainer> {
  String? selectedText;

  Future<String?> _showDropDownDialog(BuildContext context) async {
    // Show dialog and return the result directly
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(child: widget.dialogueScreen);
      },
    );

    if (result != null) {
      setState(() {
        selectedText = result; // Update the UI with the selected text
      });

      if (widget.onItemSelected != null) {
        widget.onItemSelected!(result); // Call the callback if provided
      }
    }

    return result; // Return the selected result
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await _showDropDownDialog(context);
        if (result != null) {
          // Handle the result outside if needed
          print('Selected value: $result');
        }
      },
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 15),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedText != null
                ? AppColors.electricTeal
                : AppColors.lightBorder,
          ),
          color: selectedText != null
              ? AppColors.pureWhite
              : AppColors.pureWhite,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CustomText(
                    txt: selectedText ?? widget.text,
                    // style: addTextStyle(
                    fontSize: 16,
                    color: widget.textColor ?? AppColors.darkText,
                    fontWeight: FontWeight.w500,
                    // ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            if (widget.isIconVisible == true)
              IconButton(
                onPressed: () async {
                  final result = await _showDropDownDialog(context);
                  if (result != null) {
                    print('Selected: $result');
                  }
                },
                icon: Icon(Icons.keyboard_arrow_down_outlined),
              ),
          ],
        ),
      ),
    );
  }
}

class MaterialConditionPopupLeftIcon extends StatefulWidget {
  final List<String>? conditions;
  final List<bool>? isHeaderList; // New: List to identify headers

  final String? title;
  final Function? onSelect;
  final BorderRadiusGeometry? borderRadius;
  final double height;
  final double verticalPadding;
  final int? initialSelectedIndex;
  final Function(String)? onItemSelected;
  final bool enableSearch;

  const MaterialConditionPopupLeftIcon({
    super.key,
    this.conditions,
    this.isHeaderList, // New parameter
    this.title,
    this.onSelect,
    this.borderRadius,
    this.height = 50,
    this.verticalPadding = 0,
    this.initialSelectedIndex,
    this.onItemSelected,
    this.enableSearch = false,
  });

  @override
  State<MaterialConditionPopupLeftIcon> createState() =>
      _MaterialConditionPopupLeftIconState();
}

class _MaterialConditionPopupLeftIconState
    extends State<MaterialConditionPopupLeftIcon> {
  int? selectedIndex;
  List<String>? filteredConditions;
  List<bool>? filteredIsHeader; // Store filtered headers info
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredConditions = widget.conditions;
    filteredIsHeader = widget.isHeaderList;
    searchController.addListener(_filterConditions);
    selectedIndex = widget.initialSelectedIndex;
  }

  @override
  void didUpdateWidget(MaterialConditionPopupLeftIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.conditions != oldWidget.conditions ||
        widget.initialSelectedIndex != oldWidget.initialSelectedIndex) {
      filteredConditions = widget.conditions;
      filteredIsHeader = widget.isHeaderList;
      selectedIndex = widget.initialSelectedIndex;
    }
  }

  void _filterConditions() {
    if (widget.enableSearch && widget.isHeaderList != null) {
      String query = searchController.text.toLowerCase();
      if (query.isEmpty) {
        setState(() {
          filteredConditions = widget.conditions;
          filteredIsHeader = widget.isHeaderList;
        });
      } else {
        final List<String> tempConditions = [];
        final List<bool> tempIsHeader = [];

        for (int i = 0; i < widget.conditions!.length; i++) {
          // If it's a header and next items belong to this category
          if (widget.isHeaderList![i]) {
            // Check if any item in this category matches search
            bool hasMatchInCategory = false;
            for (int j = i + 1; j < widget.conditions!.length; j++) {
              if (widget.isHeaderList![j]) break; // Next header reached
              if (widget.conditions![j].toLowerCase().contains(query)) {
                hasMatchInCategory = true;
                break;
              }
            }

            if (hasMatchInCategory) {
              // Include header
              tempConditions.add(widget.conditions![i]);
              tempIsHeader.add(true);

              // Include matching items
              for (int j = i + 1; j < widget.conditions!.length; j++) {
                if (widget.isHeaderList![j]) break;
                if (widget.conditions![j].toLowerCase().contains(query)) {
                  tempConditions.add(widget.conditions![j]);
                  tempIsHeader.add(false);
                }
              }
            }
          }
        }

        setState(() {
          filteredConditions = tempConditions;
          filteredIsHeader = tempIsHeader;
        });
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bluetextColor = isDarkMode ? Colors.white : AppColors.darkText;

    return Container(
      padding: const EdgeInsets.only(left: 4, right: 6, top: 4),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Optional search bar
          if (widget.enableSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

          // Options list
          Flexible(
            child: ListView.builder(
              itemCount: filteredConditions?.length ?? 0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final isHeader =
                    filteredIsHeader != null &&
                    filteredIsHeader!.length > index &&
                    filteredIsHeader![index];

                int? selectedIndex = this.selectedIndex;
                final isSelected =
                    !isHeader &&
                    selectedIndex != null &&
                    selectedIndex >= 0 &&
                    widget.conditions != null &&
                    selectedIndex < widget.conditions!.length &&
                    filteredConditions![index] ==
                        widget.conditions![selectedIndex];

                return InkWell(
                  onTap: isHeader
                      ? null
                      : () {
                          // Headers are not clickable
                          if (widget.conditions != null) {
                            final originalIndex = widget.conditions!.indexOf(
                              filteredConditions![index],
                            );
                            setState(() {
                              this.selectedIndex = originalIndex;
                            });

                            if (widget.onItemSelected != null) {
                              widget.onItemSelected!(
                                widget.conditions![originalIndex],
                              );
                            } else {
                              Navigator.pop(
                                context,
                                widget.conditions![originalIndex],
                              );
                            }
                          }
                        },

                  child: Container(
                    height: widget.height,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: widget.verticalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: isHeader
                          ? AppColors.lightBorder.withOpacity(
                              0.3,
                            ) // Different color for headers
                          : (isSelected
                                ? AppColors.electricTeal.withOpacity(0.08)
                                : Colors.white),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.mediumGray.withOpacity(0.20),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (!isHeader) // Only show icon for non-header items
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? Colors.green
                                : (isDarkMode
                                      ? Colors.white38
                                      : Colors.black38),
                            size: 20,
                          ),
                        if (!isHeader) const SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            txt: filteredConditions![index],
                            fontSize: isHeader ? 14 : 16,
                            color: isHeader
                                ? AppColors
                                      .electricTeal // Different color for headers
                                : (isSelected ? bluetextColor : Colors.black),
                            fontWeight: isHeader
                                ? FontWeight.bold
                                : (isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

///

class MaterialConditionPopupLeftIcon2 extends StatefulWidget {
  final List<String>? conditions;
  final List<PackagingTypeItem>? items; // Add this for search
  final String? title;
  final Function? onSelect;
  final BorderRadiusGeometry? borderRadius;
  final double height;
  final double verticalPadding;
  final int? initialSelectedIndex;
  final Function(String)? onItemSelected;
  final bool enableSearch;

  const MaterialConditionPopupLeftIcon2({
    super.key,
    this.conditions,
    this.items, // New parameter
    this.title,
    this.onSelect,
    this.borderRadius,
    this.height = 50,
    this.verticalPadding = 0,
    this.initialSelectedIndex,
    this.onItemSelected,
    this.enableSearch = false,
  });

  @override
  State<MaterialConditionPopupLeftIcon2> createState() =>
      _MaterialConditionPopupLeftIcon2State();
}

class _MaterialConditionPopupLeftIcon2State
    extends State<MaterialConditionPopupLeftIcon2> {
  int? selectedIndex;
  List<String> filteredConditions = [];
  List<PackagingTypeItem>? filteredItems; // For item-based search
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredConditions = widget.conditions ?? [];
    filteredItems = widget.items;
    searchController.addListener(_filterConditions);
    selectedIndex = widget.initialSelectedIndex;
  }

  @override
  void didUpdateWidget(MaterialConditionPopupLeftIcon2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.conditions != oldWidget.conditions ||
        widget.items != oldWidget.items ||
        widget.initialSelectedIndex != oldWidget.initialSelectedIndex) {
      setState(() {
        filteredConditions = widget.conditions ?? [];
        filteredItems = widget.items;
        selectedIndex = widget.initialSelectedIndex;
        searchController.clear(); // Clear search on update
      });
    }
  }

  void _filterConditions() {
    if (!widget.enableSearch) return;

    String query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        filteredConditions = widget.conditions ?? [];
        filteredItems = widget.items;
      });
      return;
    }

    // If items are provided, search in items
    if (widget.items != null) {
      final filtered = widget.items!.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
      }).toList();

      setState(() {
        filteredItems = filtered;
        filteredConditions = filtered.map((e) => e.name).toList();
      });
    } else {
      // Fallback to string search
      setState(() {
        filteredConditions = (widget.conditions ?? []).where((condition) {
          return condition.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bluetextColor = isDarkMode ? Colors.white : AppColors.darkText;

    return Container(
      padding: const EdgeInsets.only(left: 4, right: 6, top: 4),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar
          if (widget.enableSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search packaging type...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                          },
                        )
                      : null,
                ),
              ),
            ),

          // Options list
          Flexible(
            child: filteredConditions.isEmpty && widget.enableSearch
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No packaging types found for "${searchController.text}"',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredConditions.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final isSelected =
                          selectedIndex != null &&
                          widget.conditions != null &&
                          selectedIndex! < widget.conditions!.length &&
                          filteredConditions[index] ==
                              widget.conditions![selectedIndex!];

                      // Get description if items are available
                      String? description;
                      if (widget.items != null && filteredItems != null) {
                        final matchingItem = filteredItems!.firstWhere(
                          (item) => item.name == filteredConditions[index],
                          orElse: () => PackagingTypeItem(
                            id: 0,
                            name: '',
                            description: '',
                            fixedWeightKg: null,
                            requiresDimensions: false,
                            typicalCapacityKg: null,
                            handlingMultiplier: 1.0,
                            icon: 'box',
                          ),
                        );
                        description = matchingItem.description;
                      }

                      return InkWell(
                        onTap: () {
                          if (widget.conditions != null) {
                            final originalIndex = widget.conditions!.indexOf(
                              filteredConditions[index],
                            );
                            setState(() {
                              selectedIndex = originalIndex;
                            });

                            if (widget.onItemSelected != null) {
                              widget.onItemSelected!(
                                widget.conditions![originalIndex],
                              );
                            } else {
                              Navigator.pop(
                                context,
                                widget.conditions![originalIndex],
                              );
                            }
                          }
                        },
                        child: Container(
                          height: widget.height,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: widget.verticalPadding,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.electricTeal.withOpacity(0.08)
                                : Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.mediumGray.withOpacity(0.20),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: isSelected
                                        ? Colors.green
                                        : (isDarkMode
                                              ? Colors.white38
                                              : Colors.black38),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      filteredConditions[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected
                                            ? bluetextColor
                                            : Colors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (description != null && description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 28,
                                    top: 2,
                                  ),
                                  child: Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
