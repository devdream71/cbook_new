import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/add_unit.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/update_item_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UpdateItem extends StatefulWidget {
  final int itemId;
  const UpdateItem({super.key, required this.itemId});

  @override
  State<UpdateItem> createState() => _UpdateItemState();
}

class _UpdateItemState extends State<UpdateItem> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _existingImage;

  void _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  int? selectedCategoryId;
  int? selectedSubCategoryId;

  String selectedStatus = "1";

  @override
  void initState() {
    super.initState();

    // Fetch categories
    Future.microtask(() =>
        Provider.of<ItemCategoryProvider>(context, listen: false)
            .fetchCategories());

    // Fetch item details and update UI
    final itemProvider =
        Provider.of<ItemUpdateProvider>(context, listen: false);
    itemProvider.fetchItemDetails(widget.itemId).then((_) {
      setState(() {}); // Rebuild the widget once the data is fetched
    });

    // Add listeners to update UI when text changes
    itemProvider.nameController.addListener(() {
      setState(() {});
    });
    itemProvider.priceController.addListener(() {
      setState(() {});
    });
    itemProvider.stockController.addListener(() {
      setState(() {});
    });
    itemProvider.valueController.addListener(() {
      setState(() {});
    });
    itemProvider.purchasePriceController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<ItemCategoryProvider>(context);
    final itemProvider = Provider.of<ItemUpdateProvider>(context);
    final controller = Provider.of<SalesController>(context);

    if (itemProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (itemProvider.item != null) {
      _existingImage = itemProvider.item!.image;
    }

    debugPrint("Name: ${itemProvider.nameController.text}");
    debugPrint("Price: ${itemProvider.priceController.text}");
    debugPrint("Stock: ${itemProvider.stockController.text}");
    debugPrint("Value: ${itemProvider.valueController.text}");
    debugPrint("Purchase Price: ${itemProvider.valueController.text}");

    return Scaffold(
      appBar: AppBar(title: const Text("Update Item")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.green[100],
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(File(_imageFile!.path))
                            : (_existingImage != null
                                    ? NetworkImage(_existingImage!)
                                    : const AssetImage(
                                        'assets/image/cbook_logo.png'))
                                as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
             

              AddSalesFormfield(
                label: "Name",
                controller: itemProvider.nameController,
              ),

              const SizedBox(height: 10),
             

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  

                  Column(
                children: [
                  // Check if secondary unit is selected and different from base unit
                  if (controller.selectedUnit2 != null &&
                      controller.selectedUnit2!.isNotEmpty &&
                      controller.selectedUnit2 != controller.selectedUnit) ...[
                    vPad5,
                    Row(
                      children: [
                        Text(
                          "1 ${controller.selectedUnit} = ",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:  3.0),
                          child: Text(
                            controller.conversionRate,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                 ),
                          ),
                        ),
                        Text(
                          " ${controller.selectedUnit2}",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                               ),
                        ),
                      ],
                    ),
                  ]
                  // If no secondary unit is selected, show the base unit only
                  else if (controller.selectedUnit != null &&
                      controller.selectedUnit!.isNotEmpty) ...[
                    vPad5,
                    Row(
                      children: [
                        Text(
                          "Base Unit: ${controller.selectedUnit}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                  ]
                  // If no unit is selected at all, show "Not Selected"
                  else ...[
                    vPad5,
                    const Text(
                      // "Base Unit: Not Selected",
                      "",

                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ],
                ],
              ),

                   

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SingleChildScrollView(
                              child: SelectUnitBottomSheet(
                                selectedUnit: controller.selectedUnit,
                                selectedUnit2: controller.selectedUnit2,
                                conversionRateController:
                                    controller.conversionRateController,
                                onUnit1Changed: (value) {
                                  controller.updateUnit1(value);
                                },
                                onUnit2Changed: (value) {
                                  controller.updateUnit2(value);
                                },
                              ),
                            );
                          },
                        );
                      },
                      child: const Text("Selected Unit"),
                    ),
                  ),
                ],
              ),
              vPad5,

              

              Row(
                children: [
                  // Category Dropdown
                  Expanded(
                    child: categoryProvider.isLoading
                        ? const Center(
                            child: SizedBox(
                              width:
                                  24, // Set a fixed size for the progress indicator
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : CustomDropdownTwo(
                            items: categoryProvider.categories
                                .map((category) => category.name)
                                .toList(),
                            hint: 'Select Category',
                            width: double.infinity,
                            height: 30, // Adjust height if needed
                            onChanged: (value) {
                              final selectedCategory = categoryProvider
                                  .categories
                                  .firstWhere((cat) => cat.name == value);

                              setState(() {
                                selectedCategoryId = selectedCategory.id;
                                selectedSubCategoryId =
                                    null; // Reset subcategory
                              });

                              // Fetch subcategories for selected category
                              categoryProvider
                                  .fetchSubCategories(selectedCategory.id);
                            },
                          ),
                  ),

                  const SizedBox(width: 10), // Spacing between dropdowns

                  // Subcategory Dropdown
                  Expanded(
                    child: categoryProvider.isSubCategoryLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : categoryProvider.subCategories.isNotEmpty
                            ? CustomDropdownTwo(
                                items: categoryProvider.subCategories
                                    .map((subCategory) => subCategory.name)
                                    .toList(),
                                hint: 'Select Sub Category',
                                width: double.infinity,
                                height: 30, // Adjust height if needed
                                onChanged: (value) {
                                  final selectedSubCategory =
                                      categoryProvider.subCategories.firstWhere(
                                          (subCat) => subCat.name == value);

                                  setState(() {
                                    selectedSubCategoryId =
                                        selectedSubCategory.id;
                                  });

                                  debugPrint(
                                      "Selected Sub Category ID: ${selectedSubCategory.id}");
                                },
                              )
                            : const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "No subcategories available",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                  ),
                ],
              ),

             

              const SizedBox(
                height: 5,
              ),

              SizedBox(
                //height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: AddSalesFormfield(
                        label: "Price",
                        controller: itemProvider.priceController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AddSalesFormfield(
                        label: "Value",
                        controller: itemProvider.valueController,
                      ),
                    ),
                  ],
                ),
              ),

             

              const SizedBox(height: 10),
             

              Row(
                children: [
                  Expanded(
                    child: AddSalesFormfield(
                      label: "Stock",
                      controller: itemProvider.stockController,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AddSalesFormfield(
                      label: "Purchase Price ",
                      controller: itemProvider.purchasePriceController,
                    ),
                  ),
                ],
              ),

              ///====> image
              AddSalesFormfield(
                label: "Image ",
                controller: itemProvider.imageController,
              ),

          

              const SizedBox(height: 10),

              

              Row(
                children: [
                  Expanded(
                    child: AddSalesFormfield(
                        label: "Sale Price",
                        controller: itemProvider.salePriceController),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AddSalesFormfield(
                        label: "MRP Price",
                        controller: itemProvider.mrpPriceController),
                  ),
                ],
              ),

              

              const SizedBox(height: 10),

             

              SizedBox(
                width: double.infinity,
                child: CustomDropdownTwo(
                  items: const ["Active", "Inactive"], // Display labels
                  hint: 'Select status',
                  width: double.infinity,
                  height: 30,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = (value == "Active")
                          ? "1"
                          : "0"; // ✅ Convert label to 1 or 0
                    });
                    debugPrint(selectedStatus);
                  },
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    final itemProvider =
                        Provider.of<ItemUpdateProvider>(context, listen: false);
                    itemProvider.updateItem(widget.itemId, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Update Item",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
